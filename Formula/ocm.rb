class Ocm < Formula
  desc "CLI for the Red Hat OpenShift Cluster Manager"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift-online/ocm-cli.git",
      :tag      => "v0.1.35",
      :revision => "34d85ca2fbacb6424af98110400b272587200225"
  head "https://github.com/openshift-online/ocm-cli.git"

  depends_on "go" => :build

  def install
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
