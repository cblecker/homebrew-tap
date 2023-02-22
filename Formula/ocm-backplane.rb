class OcmBackplane < Formula
  desc "CLI for interacting with the IMS Backplane"
  homepage "https://www.openshift.com/"
  url "https://gitlab.cee.redhat.com/service/backplane-cli/-/archive/0.0.35/backplane-cli-0.0.35.tar.gz"
  sha256 "3ad3e80449998e788b2cd86b597adb879b57c377a1baffa965f54717cd57613f"
  head "https://gitlab.cee.redhat.com/service/backplane-cli.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "go" => :build

  def install
    ENV["GOPRIVATE"] = "gitlab.cee.redhat.com"

    system "go", "build", *std_go_args, "./cmd/ocm-backplane"
    generate_completions_from_executable(bin/"ocm-backplane", "completion")
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
    assert_match "the api server is not a backplane url",
      shell_output("KUBECONFIG=#{testpath}/kubeconfig #{bin}/ocm-backplane status 2>&1", 1)

    # Test that completions were generated
    assert_match(/^# bash completion .* -\*- shell-script -\*-$/, (bash_completion/"ocm-backplane").read)
    assert_match(/^# zsh completion .* -\*- shell-script -\*-$/, (zsh_completion/"_ocm-backplane").read)
    assert_match(/^# fish completion .* -\*- shell-script -\*-$/, (fish_completion/"ocm-backplane.fish").read)
  end
end
