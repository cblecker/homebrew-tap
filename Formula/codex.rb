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

    cd "codex-rs" do
      system "cargo", "build", "--release", "--locked",
             "--jobs", ENV.make_jobs.to_s,
             "--package", "codex-cli", "--bin", "codex"
    end

    # Upstream's package layout, with our codex swapped in for theirs.
    resource("codex-package").stage do
      libexec.install Dir["*"]
    end
    rm libexec/"bin/codex"
    (libexec/"bin").install "codex-rs/target/release/codex"

    # codex-package.json is what BuildInfo reads for the reported version.
    manifest = JSON.parse((libexec/"codex-package.json").read)
    manifest["version"] = version.to_s
    (libexec/"codex-package.json").atomic_write("#{JSON.pretty_generate(manifest)}\n")

    bin.install_symlink libexec/"bin/codex"
    generate_completions_from_executable(libexec/"bin/codex", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/codex --version")
    assert_path_exists libexec/"bin/codex-code-mode-host"
    assert_path_exists libexec/"codex-path/rg"
    assert_path_exists zsh_completion/"_codex"
  end
end
