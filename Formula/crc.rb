class Crc < Formula
  desc "Minimal OpenShift 4 cluster on your local machine"
  homepage "https://www.openshift.com/"
  url "https://github.com/code-ready/crc.git",
      :tag      => "1.0.0-beta.5",
      :revision => "f2aa58c1e72a75e4ac24529923bf33ce7bc67c17"
  version "1.0.0-beta.5"
  head "https://github.com/code-ready/crc.git"

  depends_on "go" => :build

  def install
    ENV["GO111MODULE"] = "on"

    os = `go env GOOS`.strip
    arch = `go env GOARCH`.strip
    os = "macos" if os == "darwin"
    system "make", "out/#{os}-#{arch}/crc", "CRC_VERSION=#{version}"

    bin.install "out/#{os}-#{arch}/crc"
  end

  test do
    assert_match /^version: #{version}-.{5}+/, shell_output("#{bin}/crc version")
  end
end
