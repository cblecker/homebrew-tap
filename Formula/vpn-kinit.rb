class VpnKinit < Formula
  desc "Run kinit automatically when the NetBird VPN tunnel comes up"
  homepage "https://github.com/cblecker/vpn-kinit/"
  url "https://github.com/cblecker/vpn-kinit.git",
      tag:      "v0.2.0",
      revision: "f563552587eba748880141d28a38aa1cd8247048"
  license "MIT"
  head "https://github.com/cblecker/vpn-kinit.git", branch: "main"

  depends_on "go" => :build
  depends_on "goreleaser" => :build
  depends_on :macos

  def install
    # Don't dirty the git tree
    (buildpath/".git/info/exclude").append_lines ".brew_home"

    # Create bin directory, as goreleaser doesn't do this
    bin.mkpath

    args = ["--clean", "--single-target"]
    args << "--snapshot" if build.head?
    system "goreleaser", "build", *args, "--output=#{bin}/vpn-kinit"
  end

  service do
    run [opt_bin/"vpn-kinit"]
    keep_alive true
    log_path var/"log/vpn-kinit.log"
    error_log_path var/"log/vpn-kinit.log"
    process_type :background
  end

  test do
    assert_match "tunnel interface to watch", shell_output("#{bin}/vpn-kinit -h 2>&1")
  end
end
