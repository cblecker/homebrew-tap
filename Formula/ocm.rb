class Ocm < Formula
  desc "CLI for the Red Hat OpenShift Cluster Manager"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift-online/ocm-cli.git",
      tag:      "v0.1.63",
      revision: "6ef8ec59557133ef383ce0ad1ca8b7e5e76609d7"
  head "https://github.com/openshift-online/ocm-cli.git"

  depends_on "go" => :build
  depends_on "go-bindata" => :build

  def install
    # Generate bindata
    system "go", "generate", "-x", "./cmd/...", "./pkg/..."

    # Build binary
    system "go", "build", "-o", "#{bin}/ocm", "./cmd/ocm"

    # Install bash completion
    output = Utils.safe_popen_read("#{bin}/ocm", "completion")
    (bash_completion/"ocm").write output
  end

  test do
    assert_match(/^#{version}/, shell_output("#{bin}/ocm version"))
  end
end
