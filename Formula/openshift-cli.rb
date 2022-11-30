class OpenshiftCli < Formula
  desc "OpenShift command-line interface tools"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/oc.git",
      shallow:  false,
      # tag: => "v4.11.13",
      # oc adm release info 4.11.13 --output=json | jq -r '.references.spec.tags[] | select (.name=="cli") | .annotations."io.openshift.build.commit.id"'
      revision: "142cb4431e96f510b4ed4c61a13d68cb13a76c3c"
  version "4.11.13"
  head "https://github.com/openshift/oc.git",
       shallow: false

  livecheck do
    url "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/"
    regex(/href=.*?openshift-client-mac-(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "go" => :build
  on_macos do
    depends_on "heimdal" => :build
  end
  on_linux do
    depends_on "krb5"
  end


  def install
    ENV["SOURCE_GIT_TAG"] = version.to_s if build.stable?

    system "make", "oc"
    bin.install "oc"
    generate_completions_from_executable(bin/"oc", "completion", base_name: "oc")
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
    assert_match "foo", shell_output("KUBECONFIG=#{testpath}/kubeconfig #{bin}/oc config get-contexts -o name")
  end
end
