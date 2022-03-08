class Rosa < Formula
  desc "CLI for the Red Hat OpenShift Service on AWS"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/rosa.git",
      tag:      "v1.1.11",
      revision: "7ebfdbb4103e86558a5ef0a238a56ef9d5902a1c"
  head "https://github.com/openshift/rosa.git"

  depends_on "go" => :build

  def install
    # Build binary
    system "go", "build", "-o", "#{bin}/rosa", "./cmd/rosa"

    # Install bash completion
    output = Utils.safe_popen_read("#{bin}/rosa", "completion")
    (bash_completion/"rosa").write output
  end

  test do
    assert_match(/^#{version}/, shell_output("#{bin}/rosa version"))
  end
end
