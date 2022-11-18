class Osdctl < Formula
  desc "SRE toolbox utility for OpenShift Dedicated"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/osdctl.git",
      tag:      "v0.13.4",
      revision: "c8c4e457c2d3c0e604abab5660893937e949ce55"
  head "https://github.com/openshift/osdctl.git"

  depends_on "go" => :build
  depends_on "goreleaser" => :build

  def install
    # Don't dirty the git tree
    (buildpath/".git/info/exclude").append_lines ".brew_home"

    # Create bin and .config directory, as goreleaser doesn't do this
    mkdir bin

    args = ["--rm-dist", "--single-target"]
    args << "--snapshot" if build.head?
    system "goreleaser", "build", *args, "--output=#{bin}/osdctl"

    generate_completions_from_executable(bin/"osdctl", "completion", shells: [:bash, :zsh])
  end

  test do
    # Grab version details from built client
    version_raw = shell_output("#{bin}/osdctl version")
    version_json = JSON.parse(version_raw)

    if build.stable?
      # Verify the built artifact matches the formula
      assert_equal version_json["commit"],
                  stable.instance_variable_get(:@resource).instance_variable_get(:@specs)[:revision].slice(0, 7)
      assert_match version_json["version"], version.to_s
    end
  end
end
