class Rosa < Formula
  desc "CLI for the Red Hat OpenShift Service on AWS"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/rosa.git",
      tag:      "v1.2.2",
      revision: "5f4e5538bfc7fef57b02ce3ae8bc1fe7895a4825"
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
    assert_match(/INFO: Successfully downloaded/, shell_output("#{bin}/rosa download oc"))
  end
end
