class OcmBackplane < Formula
  desc "CLI for interacting with the IMS Backplane"
  homepage "https://www.openshift.com/"
  url "https://gitlab.cee.redhat.com/service/backplane-cli.git",
      tag:      "0.0.18",
      revision: "cb39230e4e00176b69c0d939e34b613a4a04a4c4"
  head "https://gitlab.cee.redhat.com/service/backplane-cli.git"

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
