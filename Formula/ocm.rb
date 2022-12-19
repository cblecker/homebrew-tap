class Ocm < Formula
  desc "CLI for the Red Hat OpenShift Cluster Manager"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift-online/ocm-cli.git",
      tag:      "v0.1.65",
      revision: "7b624131af6f661be8c9a14b35e5156995346bcf"
  head "https://github.com/openshift-online/ocm-cli.git"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args, "./cmd/ocm"
    generate_completions_from_executable(bin/"ocm", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ocm version")

    # Test that completions were generated
    assert_match "complete -o default -F __start_ocm ocm", (bash_completion/"ocm").read
    assert_match "__ocm_bash_source <(__ocm_convert_bash_to_zsh)", (zsh_completion/"_ocm").read
  end
end
