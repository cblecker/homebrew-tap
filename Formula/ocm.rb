class Ocm < Formula
  desc "CLI for the Red Hat OpenShift Cluster Manager"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift-online/ocm-cli.git",
      tag:      "v0.1.64",
      revision: "223ae5a437f226a931f956961297be6823891ba8"
  head "https://github.com/openshift-online/ocm-cli.git"

  depends_on "go" => :build
  depends_on "go-bindata" => :build

  def install
    system "go", "generate", *std_go_args, "./..."
    system "go", "build", *std_go_args(output: bin/"ocm"), "./cmd/ocm"
    generate_completions_from_executable(bin/"ocm", "completion", base_name: "ocm")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ocm version")
  end
end
