class ClaudeCompletion < Formula
  desc "Bash completion for Claude Code CLI"
  homepage "https://github.com/cblecker/claude-completion"
  url "https://github.com/cblecker/claude-completion.git",
      tag:      "v2.1.71",
      revision: "6f90f437763b65f25407dda22f2dceb241fe0ca6"
  head "https://github.com/cblecker/claude-completion.git", branch: "main"

  depends_on "bash-completion@2"

  def install
    bash_completion.install "completions/claude.bash" => "claude"
  end

  test do
    assert_predicate bash_completion/"claude", :exist?
    assert_match "_comp_cmd_claude", (bash_completion/"claude").read
  end
end
