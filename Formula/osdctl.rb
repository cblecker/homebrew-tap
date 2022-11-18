class Osdctl < Formula
  desc "SRE toolbox utility for OpenShift Dedicated"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/osdctl.git",
      tag:      "v0.13.3",
      revision: "6ba715fbe6a80369eb5748ab680f0845f9cd3cb6"
  head "https://github.com/openshift/osdctl.git"
  revision 1

  depends_on "go" => :build
  depends_on "goreleaser" => :build

  def install
    # Don't dirty the git tree
    (buildpath/".git/info/exclude").append_lines ".brew_home"

    # Create bin and .config directory, as goreleaser doesn't do this
    mkdir bin

    # Create .config directory for the stable release, as there is a bug.
    # https://github.com/openshift/osdctl/pull/289
    mkdir_p buildpath/".brew_home/.config" if build.stable?

    system "goreleaser", "build", "--rm-dist", "--single-target", "--output=#{bin}/osdctl"
    generate_completions_from_executable(bin/"osdctl", "completion", shells: [:bash, :zsh])
  end

  test do
    # Grab version details from built client
    version_raw = shell_output("#{bin}/osdctl version")
    version_json = JSON.parse(version_raw)

    assert_equal version_json["commit"],
                 stable.instance_variable_get(:@resource).instance_variable_get(:@specs)[:revision].slice(0, 7)

    if build.stable?
      # Verify the built artifact matches the formula
      assert_match version_json["version"], version.to_s

    end
  end
end
