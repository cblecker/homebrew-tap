class Hypershift < Formula
  desc "CLI tool to install/administer the HyperShift middleware"
  homepage "https://www.openshift.com/"
  head "https://github.com/openshift/hypershift.git", branch: "main"

  depends_on "go" => :build

  def install
    system "make", "hypershift", "OUT_DIR=#{bin}"

    # Install bash completion
    output = Utils.safe_popen_read("#{bin}/hypershift", "completion", "bash")
    (bash_completion/"hypershift").write output

    # Install zsh completion
    output = Utils.safe_popen_read("#{bin}/hypershift", "completion", "zsh")
    (zsh_completion/"_hypershift").write output
  end

  test do
    assert_match(/.*quay.io\/hypershift\/hypershift-operator.*/, shell_output("#{bin}/hypershift install render"))
  end
end
