class Hypershift < Formula
  desc "CLI tool to install/administer the HyperShift middleware"
  homepage "https://www.openshift.com/"
  head "https://github.com/openshift/hypershift.git", branch: "main"

  depends_on "go" => :build

  def install
    system "make", "hypershift", "OUT_DIR=#{bin}"
    generate_completions_from_executable(bin/"hypershift", "completion")
  end

  test do
    assert_match(%r{.*quay.io/hypershift/hypershift-operator.*}, shell_output("#{bin}/hypershift install render"))
  end
end
