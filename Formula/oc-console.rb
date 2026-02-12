class OcConsole < Formula
  desc "Oc plugin to open the OpenShift 4 console in your web browser"
  homepage "https://github.com/cblecker/oc-console/"
  url "https://github.com/cblecker/oc-console.git",
      tag:      "v1.7.0",
      revision: "7036492ede85fda729f3e747c84bd85bc4723a02"
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
