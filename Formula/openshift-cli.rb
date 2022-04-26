class OpenshiftCli < Formula
  desc "OpenShift command-line interface tools"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/oc.git",
      shallow:  false,
      # tag: => "v4.10.9", # oc adm release info 4.10.9 --output=json | jq -r '.references.spec.tags[] | select (.name=="cli") | .annotations."io.openshift.build.commit.id"'
      revision: "3e24949fea37244367d50a1f3a226ec20d51eef1"
  version "4.10.9"
  head "https://github.com/openshift/oc.git",
       shallow: false

  livecheck do
    url "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/"
    regex(/href=.*?openshift-client-mac-(\d+(?:\.\d+)+)\.tar\.gz/i)
  end

  depends_on "go" => :build
  depends_on "heimdal" => :build

  def install
    ENV["SOURCE_GIT_TAG"] = version.to_s if build.stable?

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
    # Grab version details from built client
    version_raw = shell_output("#{bin}/oc version --client --output=json")
    version_json = JSON.parse(version_raw)

    # Ensure that we had a clean build tree
    assert_equal "clean", version_json["clientVersion"]["gitTreeState"]

    if build.stable?
      # Verify the built artifact matches the formula
      assert_match version_json["clientVersion"]["gitVersion"], "v#{version}"
      assert_equal version_json["clientVersion"]["gitCommit"],
                   stable.instance_variable_get(:@resource).instance_variable_get(:@specs)[:revision].slice(0, 9)

      # Get remote release details
      release_raw = shell_output("#{bin}/oc adm release info #{version} --output=json")
      release_json = JSON.parse(release_raw)

      # Verify the formula matches the release data for the version
      assert_match release_json["references"]["spec"]["tags"].find { |tag|
                     tag["name"]=="cli"
                   } ["annotations"]["io.openshift.build.commit.id"],
                   stable.instance_variable_get(:@resource).instance_variable_get(:@specs)[:revision]

    end

    # Test that we can generate and write a kubeconfig
    (testpath/"kubeconfig").write ""
    system "KUBECONFIG=#{testpath}/kubeconfig #{bin}/oc config set-context foo 2>&1"
    context_output = shell_output("KUBECONFIG=#{testpath}/kubeconfig #{bin}/oc config get-contexts -o name")
    assert_match "foo", context_output
  end
end
