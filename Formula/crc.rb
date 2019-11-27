class Crc < Formula
  desc "Minimal OpenShift 4 cluster on your local machine"
  homepage "https://www.openshift.com/"
  url "https://github.com/code-ready/crc.git",
      :tag      => "1.2.0",
      :revision => "c2e3c0fd4ae6a27cc9338552cdc71b18ad37c5aa"
  head "https://github.com/code-ready/crc.git"

  depends_on "go" => :build

  def install
    ENV["GO111MODULE"] = "on"

    os = `go env GOOS`.strip
    arch = `go env GOARCH`.strip
    os = "macos" if os == "darwin"
    system "make", "out/#{os}-#{arch}/crc"

    bin.install "out/#{os}-#{arch}/crc"
  end

  test do
    assert_match /^crc version: #{version}/, shell_output("#{bin}/crc version")
  end
end
