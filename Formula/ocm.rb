class Ocm < Formula
  desc "CLI for the Red Hat OpenShift Cluster Manager"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift-online/ocm-cli.git",
      tag:      "v0.1.65",
      revision: "7b624131af6f661be8c9a14b35e5156995346bcf"
  head "https://github.com/openshift-online/ocm-cli.git"

  depends_on "go" => :build

  binary_name = "ocm"

  def install
    system "go", "build", *std_go_args, "./cmd/#{binary_name}"
    generate_completions_from_executable(bin/binary_name.to_s, "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/#{binary_name} version")

    # Test that completions were generated
    assert_match(/^# bash completion .* -\*- shell-script -\*-$/, (bash_completion/binary_name.to_s).read)
    assert_match(/^# zsh completion .* -\*- shell-script -\*-$/, (zsh_completion/"_#{binary_name}").read)
    assert_match(/^# fish completion .* -\*- shell-script -\*-$/, (fish_completion/"#{binary_name}.fish").read)
  end
end
