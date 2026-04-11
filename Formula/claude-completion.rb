class ClaudeCompletion < Formula
  desc "Bash completion for Claude Code CLI"
  homepage "https://github.com/cblecker/claude-completion"
  url "https://github.com/cblecker/claude-completion.git",
      tag:      "v2.1.101",
      revision: "65b44f06781d6ba114155a4b84a001fdeaabcec6"
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
