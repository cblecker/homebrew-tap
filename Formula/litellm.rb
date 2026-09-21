class Litellm < Formula
  desc "Unified Anthropic/OpenAI-compatible LLM gateway"
  homepage "https://github.com/BerriAI/litellm"
  url "https://github.com/BerriAI/litellm.git",
      tag:      "v1.101.0",
      revision: "18243cd7af4c3325165ba68b21379e2719e051c7"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "rust" => :build
  depends_on "uv" => :build
  depends_on "python@3.14"

  def install
    # Don't dirty the git tree
    (buildpath/".git/info/exclude").append_lines ".brew_home"

    # --no-editable, or the install links back into the build directory.
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
