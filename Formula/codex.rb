class Codex < Formula
  desc "OpenAI's coding agent that runs in your terminal"
  homepage "https://github.com/cblecker/codex"
  # Fork of openai/codex carrying the honor-worktree-git-write-permissions branch,
  # rebased onto upstream main after rust-v0.155.0.
  url "https://github.com/cblecker/codex.git",
      revision: "95ad5e3fce8c59fbd7e7a7d716e81f33ff7dff6a"
  version "0.156.0-dev"
  head "https://github.com/cblecker/codex.git", branch: "honor-worktree-git-write-permissions"

  depends_on "cmake" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "pkgconf" => :build
    depends_on "openssl@3"
  end

  # Upstream's packaged release supplies codex-code-mode-host, codex-path/rg and
  # codex-resources/zsh; only bin/codex is rebuilt from the fork.
  resource "codex-package" do
    on_macos do
      on_arm do
        url "https://github.com/openai/codex/releases/download/rust-v0.155.0/codex-package-aarch64-apple-darwin.tar.gz"
        sha256 "b1411ec00ac410467e05cf8fb5b063cf83632613530201cd4724ef8dd0e9c33f"
      end
      on_intel do
        url "https://github.com/openai/codex/releases/download/rust-v0.155.0/codex-package-x86_64-apple-darwin.tar.gz"
        sha256 "88df3120417823949cdcdc131dc0c3bbebab197a21fdb5595f53fed227e024ec"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/openai/codex/releases/download/rust-v0.155.0/codex-package-aarch64-unknown-linux-musl.tar.gz"
        sha256 "28110b360a635fca2c4501036a8efbe0da5b7fe66153ae1f2f944d3fb4c7b5d2"
      end
      on_intel do
        url "https://github.com/openai/codex/releases/download/rust-v0.155.0/codex-package-x86_64-unknown-linux-musl.tar.gz"
        sha256 "135bfe1af2d8d5954c12f03bee2cf8b40dffb06f76bb0ec3bd6105de5357e009"
      end
    end
  end

  def install
    # Don't dirty the git tree
    (buildpath/".git/info/exclude").append_lines ".brew_home"

    # Stamped into the binary; see codex-rs/build-info/src/lib.rs.
    ENV["STABLE_GIT_COMMIT"] = stable.specs[:revision] if build.stable?

    # Upstream's package layout, minus the codex we're replacing.
    resource("codex-package").stage do
      libexec.install Dir["*"]
    end
    rm libexec/"bin/codex"

    # Homebrew's rust is 1.98, but codex-rs/rust-toolchain.toml pins 1.95 and only
    # rustup honors it. 1.98 overflows the query depth limit computing the layout of
    # codex-chatgpt's connectors::list_connectors, and -Zcrate-attr is nightly-only.
    inreplace "codex-rs/chatgpt/src/lib.rs",
              /\A/,
              "#![recursion_limit = \"512\"]\n"

    # --root=libexec puts our build back at libexec/bin/codex; --bin skips logs_client.
    system "cargo", "install", "--bin", "codex", *std_cargo_args(root: libexec, path: "codex-rs/cli")

    # Upstream's Linux zsh links the system libtinfo, which `brew linkage` rejects
    # as an unwanted system library. Dropping it makes bundled_zsh_path return None
    # and codex falls back to the system zsh; homebrew-core's codex-acp does the same.
    rm libexec/"codex-resources/zsh/bin/zsh" if OS.linux?

    # codex-package.json is what BuildInfo reads for the reported version.
    manifest = JSON.parse((libexec/"codex-package.json").read)
    manifest["version"] = stable.version.to_s
    (libexec/"codex-package.json").atomic_write("#{JSON.pretty_generate(manifest)}\n")

    bin.install_symlink libexec/"bin/codex"
    generate_completions_from_executable(libexec/"bin/codex", "completion")
  end

  test do
    # Upstream's clap version is CARGO_PKG_VERSION, which is 0.0.0 for any build
    # from source; the packaged version lives in the manifest BuildInfo reads.
    assert_match "codex-cli", shell_output("#{bin}/codex --version")
    assert_match stable.version.to_s, (libexec/"codex-package.json").read
    assert_path_exists libexec/"bin/codex-code-mode-host"
    assert_path_exists libexec/"codex-path/rg"
    assert_path_exists zsh_completion/"_codex"
  end
end
