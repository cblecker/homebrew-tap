class Ocm < Formula
  desc "CLI for the Red Hat OpenShift Cluster Manager"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift-online/ocm-cli.git",
      :tag      => "v0.1.58",
      :revision => "c5b0676bcafeb38b32da024d20b4af066a9b0f52"
  head "https://github.com/openshift-online/ocm-cli.git"

  depends_on "go" => :build
  depends_on "go-bindata" => :build

  def install
    # Generate bindata
    system "go", "generate", "-x", "./cmd/...", "./pkg/..."

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
