class KubectlDevTool < Formula
  desc "Kubectl/oc plugin with various tools useful for the OpenShift developers"
  homepage "https://www.openshift.com/"
  head "https://github.com/openshift/cluster-debug-tools.git", branch: "master"

  depends_on "homebrew/core/go" => :build

  def install
    system "go", "build", *std_go_args(output: bin/"kubectl-dev_tool"), "./cmd/kubectl-dev_tool"
  end

  test do
    (testpath/"audit.log").write(<<~EOF)
      {"kind":"Event","apiVersion":"audit.k8s.io/v1","level":"Metadata","auditID":"548af3f4-e19b-4fa0-a824-f96cc55c3f4b","stage":"ResponseComplete","requestURI":"/api/v1/namespaces/default","verb":"get","user":{"username":"system:admin","groups":["system:masters","system:authenticated"]},"sourceIPs":["10.0.81.191"],"userAgent":"Go-http-client/1.1","objectRef":{"resource":"namespaces","namespace":"default","name":"default","apiVersion":"v1"},"responseStatus":{"metadata":{},"code":200},"requestReceivedTimestamp":"2021-09-22T11:04:06.715585Z","stageTimestamp":"2021-09-22T11:04:06.718916Z","annotations":{"authorization.k8s.io/decision":"allow","authorization.k8s.io/reason":""}}
      {"kind":"Event","apiVersion":"audit.k8s.io/v1","level":"Metadata","auditID":"f33133a4-93fe-4fba-8a64-d33a2e47d96d","stage":"ResponseComplete","requestURI":"/apis/apiserver.openshift.io/v1/apirequestcounts/certificatesigningrequests.v1.certificates.k8s.io","verb":"get","user":{"username":"system:apiserver","uid":"364c608f-bc63-4f8a-861d-e449f05d51c5","groups":["system:masters"]},"sourceIPs":["::1"],"userAgent":"kube-apiserver/v1.22.1 (linux/amd64) kubernetes/00cc883","objectRef":{"resource":"apirequestcounts","name":"certificatesigningrequests.v1.certificates.k8s.io","apiGroup":"apiserver.openshift.io","apiVersion":"v1"},"responseStatus":{"metadata":{},"code":200},"requestReceivedTimestamp":"2021-09-22T11:04:06.860664Z","stageTimestamp":"2021-09-22T11:04:06.867620Z","annotations":{"authorization.k8s.io/decision":"allow","authorization.k8s.io/reason":""}}
      {"kind":"Event","apiVersion":"audit.k8s.io/v1","level":"Metadata","auditID":"7f5e8a78-c00b-4988-9458-56de859f5713","stage":"ResponseComplete","requestURI":"/apis/apiserver.openshift.io/v1/apirequestcounts/certificatesigningrequests.v1.certificates.k8s.io","verb":"get","user":{"username":"system:apiserver","uid":"364c608f-bc63-4f8a-861d-e449f05d51c5","groups":["system:masters"]},"sourceIPs":["::1"],"userAgent":"kube-apiserver/v1.22.1 (linux/amd64) kubernetes/00cc883","objectRef":{"resource":"apirequestcounts","name":"certificatesigningrequests.v1.certificates.k8s.io","apiGroup":"apiserver.openshift.io","apiVersion":"v1"},"responseStatus":{"metadata":{},"code":200},"requestReceivedTimestamp":"2021-09-22T11:04:06.868500Z","stageTimestamp":"2021-09-22T11:04:06.875219Z","annotations":{"authorization.k8s.io/decision":"allow","authorization.k8s.io/reason":""}}
      {"kind":"Event","apiVersion":"audit.k8s.io/v1","level":"Metadata","auditID":"35b1c60a-7f6b-4ee4-833a-2e5b3166b830","stage":"ResponseComplete","requestURI":"/apis/apiserver.openshift.io/v1/apirequestcounts/certificatesigningrequests.v1.certificates.k8s.io/status","verb":"update","user":{"username":"system:apiserver","uid":"364c608f-bc63-4f8a-861d-e449f05d51c5","groups":["system:masters"]},"sourceIPs":["::1"],"userAgent":"kube-apiserver/v1.22.1 (linux/amd64) kubernetes/00cc883","objectRef":{"resource":"apirequestcounts","name":"certificatesigningrequests.v1.certificates.k8s.io","uid":"52483281-3a55-4725-85c2-0c8d1fc8dfdd","apiGroup":"apiserver.openshift.io","apiVersion":"v1","resourceVersion":"202601","subresource":"status"},"responseStatus":{"metadata":{},"code":200},"requestReceivedTimestamp":"2021-09-22T11:04:06.875996Z","stageTimestamp":"2021-09-22T11:04:06.891422Z","annotations":{"authorization.k8s.io/decision":"allow","authorization.k8s.io/reason":""}}
    EOF
    getverb_output = shell_output("#{bin}/kubectl-dev_tool audit -f #{testpath}/audit.log --verb=get")
    updateverb_output = shell_output("#{bin}/kubectl-dev_tool audit -f #{testpath}/audit.log --verb=update")
    assert_equal 3, getverb_output.lines.count
    assert_equal 1, updateverb_output.lines.count
  end
end
