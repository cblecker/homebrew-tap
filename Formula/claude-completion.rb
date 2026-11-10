class ClaudeCompletion < Formula
  desc "Bash completion for Claude Code CLI"
  homepage "https://github.com/cblecker/claude-completion"
  url "https://github.com/cblecker/claude-completion.git",
      tag:      "v2.1.322",
      revision: "25a9e5b6fb2c2ddd84b2162c6627f52d5b4d72b6"
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
