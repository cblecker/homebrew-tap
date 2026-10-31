class ClaudeCompletion < Formula
  desc "Bash completion for Claude Code CLI"
  homepage "https://github.com/cblecker/claude-completion"
  url "https://github.com/cblecker/claude-completion.git",
      tag:      "v2.1.316",
      revision: "fa280e91716336b803c511b38eab9d6ba885b359"
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
