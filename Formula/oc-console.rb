class OcConsole < Formula
  desc "oc plugin to open the OpenShift 4 console in your web browser"
  homepage "https://github.com/cblecker/oc-console/"
  url "https://github.com/cblecker/oc-console.git",
      tag:      "v1.1.2",
      revision: "8ce67772bcbba43658ffabe3da7d71a46bdf26b7"
  head "https://github.com/cblecker/oc-console.git"

  depends_on "go" => :build
  depends_on "goreleaser" => :build

  def install
    # Don't dirty the git tree
    rm_rf ".brew_home"

    # Build binary using goreleaser
    system "goreleaser", "build", "--rm-dist"

    # Select version to install from build
    OS.linux? ? os = "linux" : os = "darwin"
    Hardware::CPU.arm? ? arch = "arm64" : arch = "amd64"

    bin.install "dist/oc-console_#{os}_#{arch}/oc-console"
    prefix.install_metafiles
  end
end
