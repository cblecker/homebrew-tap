class OcmBackplane < Formula
  desc "CLI for interacting with the IMS Backplane"
  homepage "https://www.openshift.com/"
  url "https://gitlab.cee.redhat.com/service/backplane-cli.git",
      :tag      => "0.0.9",
      :revision => "a9e9e3f888e859ca7e9fd359c8d19d5914dd9320"
  head "https://gitlab.cee.redhat.com/service/backplane-cli.git"

  depends_on "go" => :build

  def install
    ENV["GOPRIVATE"] = "gitlab.cee.redhat.com"

    # Build binary
    system "go", "build", "-o", "#{bin}/ocm-backplane", "./cmd/ocm-backplane"
  end

  test do
    assert_match /^#{version}/, shell_output("#{bin}/ocm-backplane version")
  end
end
