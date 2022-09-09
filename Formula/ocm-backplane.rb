class OcmBackplane < Formula
  desc "CLI for interacting with the IMS Backplane"
  homepage "https://www.openshift.com/"
  url "https://gitlab.cee.redhat.com/service/backplane-cli.git",
      tag:      "0.0.28",
      revision: "4f0ce14a7a2ab8d725ed3615eb81c55a5e0b2aa2"
  head "https://gitlab.cee.redhat.com/service/backplane-cli.git"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "go" => :build

  def install
    ENV["GOPRIVATE"] = "gitlab.cee.redhat.com"

    system "go", "build", *std_go_args(output: bin/"ocm-backplane"), "./cmd/ocm-backplane"
    generate_completions_from_executable(bin/"ocm-backplane", "completion", base_name: "ocm-backplane")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ocm-backplane version")
  end
end
