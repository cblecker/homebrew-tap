class OcmBackplane < Formula
  desc "CLI for interacting with the IMS Backplane"
  homepage "https://www.openshift.com/"
  url "https://gitlab.cee.redhat.com/service/backplane-cli.git",
      tag:      "0.0.30",
      revision: "1e67b5db51592573d01a9b533084def003139d5a"
  head "https://gitlab.cee.redhat.com/service/backplane-cli.git"

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
    assert_match "the api server is not a backplane url", shell_output("KUBECONFIG=#{testpath}/kubeconfig #{bin}/ocm-backplane status 2>&1", 1)
  end
end
