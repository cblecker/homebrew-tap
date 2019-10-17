class Crc < Formula
  desc "Minimal OpenShift 4 cluster on your local machine"
  homepage "https://www.openshift.com/"
  url "https://github.com/code-ready/crc.git",
      :tag      => "1.0.0",
      :revision => "2aa31434d66e569b04af4c831d20f4643c18c61f"
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
    assert_match /^version: #{version}-.{5}+/, shell_output("#{bin}/crc version")
  end
end
