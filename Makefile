.PHONY: bump
bump:
	claude --allowedTools "Bash(brew livecheck --tap=cblecker/tap *),Bash(git ls-remote * refs/tags/*),Bash(git add Formula/*),Bash(git commit -m *),Read,Edit(Formula/**),Grep,Glob,mcp__plugin_github_github__get_latest_release" \
	  --permission-mode acceptEdits \
	  --print \
	  "/bump and then commit the changes to this branch"
