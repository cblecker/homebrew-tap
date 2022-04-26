class OcmBackplane < Formula
  desc "CLI for interacting with the IMS Backplane"
  homepage "https://www.openshift.com/"
  url "https://gitlab.cee.redhat.com/service/backplane-cli.git",
      tag:      "0.0.22",
      revision: "ed0ac73f1ed37b8600d9eb30db71282b71e594d8"
  head "https://gitlab.cee.redhat.com/service/backplane-cli.git"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "go" => :build

  def install
    ENV["GOPRIVATE"] = "gitlab.cee.redhat.com"

    # Build binary
    system "go", "build", "-o", "#{bin}/ocm-backplane", "./cmd/ocm-backplane"
  end

  test do
    assert_match(/^#{version}/, shell_output("#{bin}/ocm-backplane version"))
  end
end
