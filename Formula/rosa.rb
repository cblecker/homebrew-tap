class Rosa < Formula
  desc "CLI for the Red Hat OpenShift Service on AWS"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/rosa.git",
      tag:      "v1.1.9",
      revision: "9329ed8eef2222a506e248c87514cd4e51508531"
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
