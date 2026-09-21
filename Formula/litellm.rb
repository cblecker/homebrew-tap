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

  depends_on "rust" => :build
  depends_on "uv" => :build
  depends_on "python@3.14"

  def install
    # Don't dirty the git tree
    (buildpath/".git/info/exclude").append_lines ".brew_home"

    # Install the tag's own uv.lock. One command covers the hash-verified
    # third-party deps, the two [tool.uv.workspace] members and the root
    # project, so bumping tag:/revision: advances the source and its pinned
    # dependencies together -- no hand-maintained resource blocks.
    #
    # --frozen uses the lock as-is rather than re-resolving; --no-editable gets
    # a real site-packages install instead of a link back into the build dir;
    # the pinned PEP 517 backends (maturin==1.15.0, uv_build==0.11.8) come from
    # each pyproject.toml's build-system.requires, in isolated build envs.
    ENV["UV_PROJECT_ENVIRONMENT"] = libexec.to_s
    ENV["UV_PYTHON_DOWNLOADS"] = "never"
    system "uv", "sync", "--frozen", "--no-dev", "--extra", "proxy",
           "--no-editable",
           "--python", Formula["python@3.14"].opt_bin/"python3.14"

    bin.install_symlink libexec/"bin/litellm"
  end

  test do
    # Proves the [proxy] extra actually resolved, not just that the entrypoint exists.
    system libexec/"bin/python", "-c", "import litellm.proxy.proxy_server"
    assert_match version.to_s, shell_output("#{bin}/litellm --version")
  end
end
