class Litellm < Formula
  desc "Unified Anthropic/OpenAI-compatible LLM gateway"
  homepage "https://github.com/BerriAI/litellm"
  url "https://github.com/BerriAI/litellm.git",
      tag:      "v1.102.0",
      revision: "95293834e833b2d2979f87d1bd2a5be45db6728a"
  license "MIT"

  livecheck do
    url :stable
    # Anchored so the -rc.N, -dev.N, -stable and -nightly tags are skipped.
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "maturin" => :build
  depends_on "rust" => :build
  depends_on "uv" => :build
  depends_on "python@3.13"

  def install
    # Don't dirty the git tree
    (buildpath/".git/info/exclude").append_lines ".brew_home"

    python = libexec/"bin/python"
    system Formula["python@3.13"].opt_bin/"python3.13", "-m", "venv", libexec

    # Hash-verified third-party deps straight from the tag's uv.lock, so a
    # version bump advances the source and its pinned dependencies together.
    # --frozen trusts the lock as-is; --no-emit-project/-workspace drop the
    # three in-tree path entries, which carry no hashes.
    system "uv", "export", "--frozen", "--no-dev", "--extra", "proxy",
           "--no-emit-project", "--no-emit-workspace",
           "--format", "requirements-txt", "-o", "reqs.txt"
    system "uv", "pip", "install", "--python", python,
           "--require-hashes", "-r", "reqs.txt"

    # PEP 517 backends for the in-tree packages, so --no-build-isolation below
    # never resolves an unpinned backend at build time. uv passes PYTHONPATH
    # through to the backend, which picks up the `maturin` module Homebrew
    # installs alongside its binary; uv_build has no formula, so pin it to what
    # the two workspace members' pyproject.toml declares.
    ENV.prepend_path "PYTHONPATH", Formula["maturin"].opt_lib/"python3.13/site-packages"
    system "uv", "pip", "install", "--python", python, "uv-build==0.11.8"

    # The in-tree packages: the [tool.uv.workspace] members, then the root
    # project. --no-deps because the lockfile install above already covers them.
    ["./litellm-proxy-extras", "./enterprise", "."].each do |pkg|
      system "uv", "pip", "install", "--python", python,
             "--no-deps", "--no-build-isolation", pkg
    end

    bin.install_symlink libexec/"bin/litellm"
  end

  test do
    # Proves the [proxy] extra actually resolved, not just that the entrypoint exists.
    system libexec/"bin/python", "-c", "import litellm.proxy.proxy_server"
    assert_match version.to_s, shell_output("#{bin}/litellm --version")
  end
end
