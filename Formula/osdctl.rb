class Osdctl < Formula
  desc "SRE toolbox utility for OpenShift Dedicated"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/osdctl.git",
      tag:      "v0.13.7",
      revision: "da9e45d6706e2b603a7d8487ad16ea216484bdae"
  head "https://github.com/openshift/osdctl.git", branch: "master"

  depends_on "go" => :build
  depends_on "goreleaser" => :build

  def install
    # Don't dirty the git tree
    (buildpath/".git/info/exclude").append_lines ".brew_home"

    # Create bin directory, as goreleaser doesn't do this
    bin.mkdir

    args = ["--rm-dist", "--single-target"]
    args << "--snapshot" if build.head?
    system "goreleaser", "build", *args, "--output=#{bin}/osdctl"

    generate_completions_from_executable(bin/"osdctl", "completion", "--skip-version-check", shells: [:bash, :zsh])
  end

  test do
    # Grab version details from built client
    version_raw = shell_output("#{bin}/osdctl version --skip-version-check")
    version_json = JSON.parse(version_raw)

    if build.stable?
      # Verify the built artifact matches the formula
      assert_equal version_json["commit"], stable.specs[:revision]
      assert_equal version_json["version"], version.to_s
    end

    # Test that completions were generated
    assert_match "complete -o default -F __start_osdctl osdctl", (bash_completion/"osdctl").read
    assert_match "__osdctl_bash_source <(__osdctl_convert_bash_to_zsh)", (zsh_completion/"_osdctl").read
  end
end
