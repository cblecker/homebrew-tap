class OcContainerLogin < Formula
  desc "Oc plugin to log Apple's container CLI in to an OpenShift registry"
  homepage "https://github.com/cblecker/oc-container-login/"
  url "https://github.com/cblecker/oc-container-login.git",
      tag:      "v0.1.0",
      revision: "c23935080d32c2fa583ce8dfa3cdbc299e32c4a6"
  license "Apache-2.0"
  head "https://github.com/cblecker/oc-container-login.git", branch: "main"

  depends_on "go" => :build
  depends_on "goreleaser" => :build
  depends_on arch: :arm64
  depends_on "container"
  depends_on :macos

  def install
    # Don't dirty the git tree
    (buildpath/".git/info/exclude").append_lines ".brew_home"

    # Create bin directory, as goreleaser doesn't do this
    bin.mkpath

    args = ["--clean", "--single-target"]
    args << "--snapshot" if build.head?
    system "goreleaser", "build", *args, "--output=#{bin}/oc-container-login"
  end

  test do
    assert_match "must be a bare host", shell_output("#{bin}/oc-container-login --registry https://x 2>&1", 1)
  end
end
