class OpenshiftCli < Formula
  desc "OpenShift command-line interface tools"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/oc.git",
      # tag: => "v4.6.15", # oc adm release info 4.6.15 --output=json | jq -r '.references.spec.tags[] | select (.name=="cli") | .annotations."io.openshift.build.commit.id"'
      revision: "5797eaecac19b9c0e4d10d3d6b559c074e3c3c88",
      shallow:  false
  version "4.6.15"
  head "https://github.com/openshift/oc.git",
       shallow: false

  depends_on "go" => :build
  depends_on "heimdal" => :build

  def install
    ENV["SOURCE_GIT_TAG"] = "v#{version}" if build.stable?

    system "make", "oc"
    bin.install "oc"

    # Install bash completion
    output = Utils.safe_popen_read("#{bin}/oc", "completion", "bash")
    (bash_completion/"oc").write output

    # Install zsh completion
    output = Utils.safe_popen_read("#{bin}/oc", "completion", "zsh")
    (zsh_completion/"_oc").write output
  end

  test do
    # Grab version details
    version_raw = shell_output("#{bin}/oc version --client --output=json")
    version_json = JSON.parse(version_raw)

    # Ensure that we had a clean build tree
    assert_equal "clean", version_json["clientVersion"]["gitTreeState"]

    if build.stable?
      # Verify the tagged version matches the version we expect
      assert_match version_json["clientVersion"]["gitVersion"], "v#{version}"

      # Verify we built based on the commit we checked out
      assert_equal stable.instance_variable_get(:@resource)
                         .instance_variable_get(:@specs)[:revision].slice(0, 9),
                   version_json["clientVersion"]["gitCommit"]
    end

    # Test that release information matching the version is available
    system "#{bin}/oc", "adm", "release", "info", version.to_s

    # Test that we can generate and write a kubeconfig
    (testpath/"kubeconfig").write ""
    system "KUBECONFIG=#{testpath}/kubeconfig #{bin}/oc config set-context foo 2>&1"
    context_output = shell_output("KUBECONFIG=#{testpath}/kubeconfig #{bin}/oc config get-contexts -o name")
    assert_match "foo", context_output
  end
end
