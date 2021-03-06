class Triage < Formula
  desc "Interactive command-line GitHub issue & notification triaging tool"
  homepage "https://github.com/tj/triage/"
  head "https://github.com/tj/triage.git"

  depends_on "go" => :build

  def install
    system "go", "build", "-o", "#{bin}/triage", "./cmd/triage"
  end
end
