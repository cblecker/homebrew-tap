class OcmBackplane < Formula
  desc "CLI for interacting with the IMS Backplane"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/backplane-cli.git",
      tag:      "v0.1.27",
      revision: "ee590bdc15aecdad7a44e8a5b5c7ce6dda9e9596"
  head "https://github.com/openshift/backplane-cli.git", branch: "main"

  depends_on "go" => :build
  depends_on "goreleaser" => :build

  def install
    # Don't dirty the git tree
    (buildpath/".git/info/exclude").append_lines ".brew_home"

    # Create bin directory, as goreleaser doesn't do this
    mkdir bin

    args = ["--clean", "--single-target"]
    args << "--snapshot" if build.head?
    system "goreleaser", "build", *args, "--output=#{bin}/ocm-backplane"
    generate_completions_from_executable(bin/"ocm-backplane", "completion")
  end

  def caveats
    <<~EOS
      Please ensure you follow setup instructions for the Backplane CLI:
      https://url.corp.redhat.com/3fb13db
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ocm-backplane version")

    (testpath/"kubeconfig").write(<<~EOF)
      apiVersion: v1
      clusters:
      - cluster:
          server: https://cluster.example:443
        name: cluster-example:443
      contexts:
      - context:
          cluster: cluster-example:443
          namespace: default
          user: test-user/cluster-example:443
        name: default/cluster-example:443/test-user
      current-context: default/cluster-example:443/test-user
      kind: Config
      preferences: {}
      users:
      - name: test-user/cluster-example:443
        user:
          token: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    EOF
    assert_match "couldn't find cluster-id from the backplane cluster url",
      shell_output("KUBECONFIG=#{testpath}/kubeconfig #{bin}/ocm-backplane status 2>&1", 1)

    # Test that completions were generated
    assert_match(/^# bash completion .* -\*- shell-script -\*-$/, (bash_completion/"ocm-backplane").read)
    assert_match(/^# zsh completion .* -\*- shell-script -\*-$/, (zsh_completion/"_ocm-backplane").read)
    assert_match(/^# fish completion .* -\*- shell-script -\*-$/, (fish_completion/"ocm-backplane.fish").read)
  end
end
