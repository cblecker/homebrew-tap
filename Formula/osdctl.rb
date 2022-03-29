class Osdctl < Formula
  desc "SRE toolbox utility for OpenShift Dedicated"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/osdctl.git",
      tag:      "v0.9.5",
      revision: "f97ffe3cc99189e2ca073e47fcd3a454113f3ae9"
  head "https://github.com/openshift/osdctl.git"

  depends_on "go" => :build
  depends_on "goreleaser" => :build

  def install
    # Don't dirty the git tree
    rm_rf ".brew_home"

    # Build binary using goreleaser
    system "goreleaser", "build", "--rm-dist"

    # Select version to install from build
    OS.linux? ? os = "linux" : os = "darwin"
    Hardware::CPU.arm? ? arch = "arm64" : arch = "amd64"

    bin.install "dist/osdctl_#{os}_#{arch}/osdctl"
    prefix.install_metafiles

    # Install bash completion
    output = Utils.safe_popen_read("#{bin}/osdctl", "completion", "bash")
    (bash_completion/"osdctl").write output

    # Install zsh completion
    output = Utils.safe_popen_read("#{bin}/osdctl", "completion", "zsh")
    (zsh_completion/"_osdctl").write output
  end

  test do
    if build.stable?
      # Verify we built based on the commit we checked out
      assert_match stable.instance_variable_get(:@resource)
                         .instance_variable_get(:@specs)[:revision].slice(0, 7),
                         shell_output("#{bin}/osdctl --version")
    end
  end
end
