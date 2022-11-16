class Osdctl < Formula
  desc "SRE toolbox utility for OpenShift Dedicated"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/osdctl.git",
      tag:      "v0.13.3",
      revision: "6ba715fbe6a80369eb5748ab680f0845f9cd3cb6"
  head "https://github.com/openshift/osdctl.git"

  depends_on "go" => :build
  depends_on "goreleaser" => :build

  def install
    # Don't dirty the git tree
    rm_rf ".brew_home"

    # Create bin directory, as goreleaser doesn't do this
    mkdir bin

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
