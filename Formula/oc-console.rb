class OcConsole < Formula
  desc "oc plugin to open the OpenShift 4 console in your web browser"
  homepage "https://github.com/cblecker/oc-console/"
  url "https://github.com/cblecker/oc-console.git",
      tag:      "v1.2.0",
      revision: "efeb17c800bc285a6825560fc72c38ab53ccd3c5"
  head "https://github.com/cblecker/oc-console.git"
  revision 3

  depends_on "go" => :build
  depends_on "goreleaser" => :build
  depends_on "upx" => :build

  def install
    # Don't dirty the git tree
    rm_rf ".brew_home"

    # Build binary using goreleaser
    system "goreleaser", "build", "--rm-dist"

    # Select version to install from build
    os = OS.linux? ? "linux" : "darwin"
    arch = Hardware::CPU.arm? ? "arm64" : "amd64_v1"

    bin.install "dist/oc-console-main_#{os}_#{arch}/oc-console"
    prefix.install_metafiles
  end
end
