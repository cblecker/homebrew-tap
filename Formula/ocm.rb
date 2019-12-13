class Ocm < Formula
  desc "CLI for the Red Hat OpenShift Cluster Manager"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift-online/ocm-cli.git",
      :tag      => "v0.1.32",
      :revision => "e72abb7e3be30eea8f14b0532fe00df8b5fca3bd"
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
