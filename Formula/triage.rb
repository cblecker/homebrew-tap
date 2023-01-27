class Triage < Formula
  desc "Interactive command-line GitHub issue & notification triaging tool"
  homepage "https://github.com/tj/triage/"
  url "https://github.com/tj/triage.git",
      tag:      "v1.0.0",
      revision: "994fb89cf67a1ad8b92e9dc49f42bc9eb7022d6b"
  head "https://github.com/tj/triage.git", branch: "master"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args, "./cmd/triage"
  end

  test do
    assert_match "You can generate a personal access token", shell_output("#{bin}/triage 2>&1", 1)
  end
end
