class OcmBackplane < Formula
  desc "CLI for interacting with the IMS Backplane"
  homepage "https://www.openshift.com/"
  url "https://gitlab.cee.redhat.com/service/backplane-cli.git",
      :tag      => "0.0.8",
      :revision => "2790993dec1a2b60f34f1136254921192e55cc55"
  head "https://gitlab.cee.redhat.com/service/backplane-cli.git"

  depends_on "go" => :build

  def install
    # Build binary
    system "go", "build", "-o", "#{bin}/ocm-backplane"
    bin.install Dir["scripts/*"]
  end

  test do
    assert_match /^#{version}/, shell_output("#{bin}/ocm-backplane version")
  end
end
