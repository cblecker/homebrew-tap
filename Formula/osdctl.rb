class Osdctl < Formula
  desc "SRE toolbox utility for OpenShift Dedicated"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/osdctl.git",
      tag:      "v0.12.0",
      revision: "839880593f618546ea9a709237f15623c705cc1b"
  head "https://github.com/openshift/osdctl.git"

  depends_on "go" => :build
  depends_on "goreleaser" => :build

  def install
    # Don't dirty the git tree
    rm_rf ".brew_home"

    # Build binary using goreleaser
    system "goreleaser", "build", "--rm-dist"

    # Select version to install from build
    os = OS.linux? ? "linux" : "darwin"
    arch = Hardware::CPU.arm? ? "arm64" : "amd64_v1"

    bin.install "dist/osdctl_#{os}_#{arch}/osdctl"
    prefix.install_metafiles
    generate_completions_from_executable(bin/"osdctl", "completion", base_name: "osdctl")
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
