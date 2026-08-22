class ClaudeCompletion < Formula
  desc "Bash completion for Claude Code CLI"
  homepage "https://github.com/cblecker/claude-completion"
  url "https://github.com/cblecker/claude-completion.git",
      tag:      "v2.1.240",
      revision: "d600d2caba83d70eb6e4e97896dc2f8f92eb6cb7"
  head "https://github.com/cblecker/claude-completion.git", branch: "main"

  depends_on "bash-completion@2"

  def install
    bash_completion.install "completions/claude.bash" => "claude"
  end

  test do
    assert_path_exists bash_completion/"claude"
    assert_match "_comp_cmd_claude", (bash_completion/"claude").read
  end
end
