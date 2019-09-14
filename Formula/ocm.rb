class Ocm < Formula
  desc "CLI for the Red Hat OpenShift Cluster Manager"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift-online/ocm-cli.git",
      :tag      => "v0.1.24",
      :revision => "f1430d3a7caa596dfa75d278a54141456bcc19c5"
  head "https://github.com/openshift-online/ocm-cli.git"

  depends_on "go" => :build

  def install
    ENV["GO111MODULE"] = "on"
    ENV["CGO_ENABLED"] = "0"

    # Build binary
    system "go", "build", "-o", "#{bin}/ocm", "./cmd/ocm"

    # Install bash completion
    output = Utils.popen_read("#{bin}/ocm completion")
    (bash_completion/"ocm").write output
  end

  test do
    assert_match /^#{version}/, shell_output("#{bin}/ocm version")
  end
end
