class Rosa < Formula
  desc "CLI for the Red Hat OpenShift Service on AWS"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/rosa.git",
      tag:      "v1.2.1",
      revision: "39d2650049f741042dddb565d8b7236e2b66fd80"
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
