class Litellm < Formula
  desc "Unified Anthropic/OpenAI-compatible LLM gateway"
  homepage "https://github.com/BerriAI/litellm"
  url "https://github.com/BerriAI/litellm.git",
      tag:      "v1.101.0",
      revision: "18243cd7af4c3325165ba68b21379e2719e051c7"
  license "MIT"

  livecheck do
    # Upstream tags ahead of publishing, so the default Git strategy offers
    # unreleased tags: v1.102.0 is tagged but has no release, while
    # /releases/latest is still v1.101.0. Checking the latest release also
    # skips the -rc.N and -dev.N prereleases, which are marked as such.
    url :stable
    strategy :github_latest
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
           "--python", formula_opt_bin("python@3.14")/"python3.14"

    bin.install_symlink libexec/"bin/litellm"
  end

  test do
    # Proves the [proxy] extra actually resolved, not just that the entrypoint exists.
    system libexec/"bin/python", "-c", "import litellm.proxy.proxy_server"
    assert_match version.to_s, shell_output("#{bin}/litellm --version")
  end
end
