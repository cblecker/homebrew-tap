class Crc < Formula
  desc "Minimal OpenShift 4 cluster on your local machine"
  homepage "https://www.openshift.com/"
  url "https://github.com/code-ready/crc.git",
      :tag      => "1.0.0-beta.4",
      :revision => "4f801d28d1af0318df9a88a5d3db66874a300e8c"
  version "1.0.0-beta.4"
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
