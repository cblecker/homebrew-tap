class Crc < Formula
  desc "Minimal OpenShift 4 cluster on your local machine"
  homepage "https://www.openshift.com/"
  url "https://github.com/code-ready/crc.git",
      :tag      => "1.0.0-beta.2",
      :revision => "158cb9d37a5f034b5a05f45b7a69d477c4bd95dc"
  version "1.0.0-beta.2"
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
      os = "macos" if os == "darwin"
      system "make", "out/#{os}-#{arch}/crc", "CRC_VERSION=#{version}"

      bin.install "out/#{os}-#{arch}/crc"
    end
  end

  test do
    assert_match /^version: #{version}-.{5}+/, shell_output("#{bin}/crc version")
  end
end
