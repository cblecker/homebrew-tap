class Osdctl < Formula
  desc "SRE toolbox utility for OpenShift Dedicated"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/osd-utils-cli.git",
      :tag      => "v0.2.0",
      :revision => "d703fd3a028b1069dde4dc65ec93dc782550631e"
  head "https://github.com/openshift/osd-utils-cli.git"

  depends_on "go" => :build

  def install
    ENV["GOOS"] = "darwin"
    ENV["GOARCH"] = "amd64"

    # Build binary
    system "make", "build"

    bin.install "bin/osdctl"
    prefix.install_metafiles

    # Install bash completion
    output = Utils.safe_popen_read("#{bin}/osdctl completion bash")
    (bash_completion/"osdctl").write output

    # Install zsh completion
    output = Utils.safe_popen_read("#{bin}/osdctl completion zsh")
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
