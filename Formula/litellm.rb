class Litellm < Formula
  desc "Unified Anthropic/OpenAI-compatible LLM gateway"
  homepage "https://github.com/BerriAI/litellm"
  url "https://github.com/BerriAI/litellm.git",
      tag:      "v1.106.0",
      revision: "955bdaafa8b72b2b6ff728048f272fbc06049f63"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "rust" => :build
  depends_on "uv" => :build
  depends_on "libpq"
  depends_on "python@3.14"

  def install
    # Don't dirty the git tree
    (buildpath/".git/info/exclude").append_lines ".brew_home"

    # PyPI's Rust wheels for these four are linked without enough Mach-O header
    # padding for Homebrew to rewrite their dylib IDs to the keg path, so the
    # install fails linkage fixup. Building them here picks up the headerpad.
    no_binary = []
    if OS.mac?
      ENV["RUSTFLAGS"] = "-C link-arg=-Wl,-headerpad_max_install_names"
      no_binary = %w[jiter orjson rpds-py tiktoken].flat_map { |pkg| ["--no-binary-package", pkg] }
    end

    # --no-editable, or the install links back into the build directory.
    # psycopg-binary bundles its own libpq, OpenSSL and Kerberos, which hit the
    # same Mach-O header padding failure on macOS and fail `brew linkage` on
    # Linux. It is wheel-only, so skip it and build psycopg-c below instead.
    ENV["UV_PROJECT_ENVIRONMENT"] = libexec.to_s
    ENV["UV_PYTHON_DOWNLOADS"] = "never"
    system "uv", "sync", "--frozen", "--no-dev", "--extra", "proxy",
           "--no-editable", "--no-install-package", "psycopg-binary", *no_binary,
           "--python", formula_opt_bin("python@3.14")/"python3.14"

    # psycopg-c is not in uv.lock and must match the locked psycopg version exactly.
    psycopg_version = Utils.safe_popen_read(libexec/"bin/python", "-c",
                                            "import importlib.metadata as m; print(m.version('psycopg'))").chomp
    ENV.prepend_path "PATH", formula_opt_bin("libpq")
    system "uv", "pip", "install", "--python", libexec/"bin/python", "--no-deps",
           "--no-binary", "psycopg-c", "psycopg-c==#{psycopg_version}"

    bin.install_symlink libexec/"bin/litellm"
  end

  test do
    # Proves the [proxy] extra actually resolved, not just that the entrypoint exists.
    system libexec/"bin/python", "-c", "import litellm.proxy.proxy_server"
    # Proves psycopg loads the C implementation linked to Homebrew's libpq, not a bundled one.
    assert_equal "c", shell_output("#{libexec}/bin/python -c 'import psycopg; print(psycopg.pq.__impl__)'").chomp
    assert_match version.to_s, shell_output("#{bin}/litellm --version")
  end
end
