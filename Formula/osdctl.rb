class Osdctl < Formula
  desc "SRE toolbox utility for OpenShift Dedicated"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/osdctl.git",
      tag:      "v0.4.4",
      revision: "705df925554474c3bb164fee32a494608a8debbf"
  head "https://github.com/openshift/osdctl.git"

  depends_on "go" => :build
  depends_on "goreleaser" => :build

  def install
    # Don't dirty the git tree
    rm_rf ".brew_home"

    # Build binary using goreleaser
    system "make", "build"

    # Select version to install from build
    os = "darwin"
    on_linux do
      os = "linux"
    end

    bin.install "dist/osdctl_#{os}_amd64/osdctl"
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
