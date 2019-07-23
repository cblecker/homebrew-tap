class Crc < Formula
  desc "Minimal OpenShift 4 cluster on your local machine"
  homepage "https://www.openshift.com/"
  url "https://github.com/code-ready/crc.git",
      :tag      => "0.89.0",
      :revision => "6a3e401528bb982ddf1f3a5d26995b3d792f706b"
  head "https://github.com/code-ready/crc.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "on"
    dir = buildpath/"src/github.com/code-ready/crc"
    dir.install buildpath.children - [buildpath/".brew_home"]

    cd dir do
      system "make", "out/darwin-amd64/crc", "CRC_VERSION=#{version}"

      bin.install "out/darwin-amd64/crc"
    end
  end

  test do
    assert_match /^version: #{version}-.{5}+/, shell_output("#{bin}/crc version")
  end
end
