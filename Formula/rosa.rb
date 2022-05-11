class Rosa < Formula
  desc "CLI for the Red Hat OpenShift Service on AWS"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/rosa.git",
      tag:      "v1.2.2",
      revision: "5f4e5538bfc7fef57b02ce3ae8bc1fe7895a4825"
  head "https://github.com/openshift/rosa.git"

  depends_on "go" => :build

  def install
    binary_name = "rosa"

    # Build binary
    system "go", "build", "-o", "#{bin}/#{binary_name}", "./cmd/#{binary_name}"

    # Install bash completion
    bash_output = Utils.safe_popen_read("#{bin}/#{binary_name}", "completion", "bash")
    (bash_completion/"#{binary_name}").write bash_output

    # Install zsh completion
    zsh_output = Utils.safe_popen_read("#{bin}/#{binary_name}", "completion", "zsh")
    (zsh_completion/"_#{binary_name}").write zsh_output

    # Install fish completion
    fish_output = Utils.safe_popen_read("#{bin}/#{binary_name}", "completion", "zsh")
    (fish_completion/"#{binary_name}.fish").write fish_output
  end

  test do
    assert_match(/^#{version}/, shell_output("#{bin}/rosa version"))
    assert_match(/INFO: Successfully downloaded/, shell_output("#{bin}/rosa download oc"))
  end
end
