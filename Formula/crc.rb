class Crc < Formula
  desc "Minimal OpenShift 4 cluster on your local machine"
  homepage "https://www.openshift.com/"
  url "https://github.com/code-ready/crc.git",
      :tag      => "0.90.0",
      :revision => "de323ea2c58b4f6c64a31aa252d3e8ed207996ea"
  head "https://github.com/code-ready/crc.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "on"
    dir = buildpath/"src/github.com/code-ready/crc"
    dir.install buildpath.children - [buildpath/".brew_home"]

    cd dir do
      os = `go env GOOS`.strip
      arch = `go env GOARCH`.strip
      system "make", "out/#{os}-#{arch}/crc", "CRC_VERSION=#{version}"

      bin.install "out/#{os}-#{arch}/crc"
    end
  end

  test do
    assert_match /^version: #{version}-.{5}+/, shell_output("#{bin}/crc version")
  end
end
