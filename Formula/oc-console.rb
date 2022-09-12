class OcConsole < Formula
  desc "oc plugin to open the OpenShift 4 console in your web browser"
  homepage "https://github.com/cblecker/oc-console/"
  url "https://github.com/cblecker/oc-console.git",
      tag:      "v1.2.1",
      revision: "8d01b0e9d7a1584141d44d48324a163a492e1c9f"
  head "https://github.com/cblecker/oc-console.git"

  depends_on "go" => :build
  depends_on "goreleaser" => :build

  def install
    # Don't dirty the git tree
    rm_rf ".brew_home"

    # Create bin directory, as goreleaser doesn't do this
    mkdir bin

    system "goreleaser", "build", "--rm-dist", "--single-target", "--output=#{bin}/oc-console"
  end
end
