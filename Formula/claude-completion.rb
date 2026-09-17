class ClaudeCompletion < Formula
  desc "Bash completion for Claude Code CLI"
  homepage "https://github.com/cblecker/claude-completion"
  url "https://github.com/cblecker/claude-completion.git",
      tag:      "v2.1.274",
      revision: "d06c8e30f0dbfc9c47f7e9db1b69c2d21fdfe2e5"
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
