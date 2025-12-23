class OcConsole < Formula
  desc "Oc plugin to open the OpenShift 4 console in your web browser"
  homepage "https://github.com/cblecker/oc-console/"
  url "https://github.com/cblecker/oc-console.git",
      tag:      "v1.6.0",
      revision: "aa8a179e4d6b8f8a05724f0a8bfc0d01a5253c61"
  head "https://github.com/cblecker/oc-console.git", branch: "main"

  depends_on "go" => :build
  depends_on "goreleaser" => :build

  def install
    # Don't dirty the git tree
    (buildpath/".git/info/exclude").append_lines ".brew_home"

    # Create bin directory, as goreleaser doesn't do this
    mkdir bin

    args = ["--clean", "--single-target"]
    args << "--snapshot" if build.head?
    system "goreleaser", "build", *args, "--output=#{bin}/oc-console"
  end

  test do
    assert_match "unable to determine console location", shell_output("#{bin}/oc-console --server=localhost 2>&1", 1)
  end
end
