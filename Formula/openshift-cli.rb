class OpenshiftCli < Formula
  desc "OpenShift command-line interface tools"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/oc.git",
      shallow:  false,
      # tag: => "v4.12.5",
      # oc adm release info 4.12.5 --output=json | jq -r '.references.spec.tags[] | select (.name=="cli") | .annotations."io.openshift.build.commit.id"'
      revision: "b05f7d40f9a2dac30771be620e9e9148d26ffd07"
  version "4.12.5"
  head "https://github.com/openshift/oc.git", shallow: false, branch: "master"

  livecheck do
    url "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/"
    regex(/href=.*?openshift-client-mac-(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "go" => :build
  uses_from_macos "krb5"

  on_macos do
    depends_on "heimdal" => :build
  end

  def install
    ENV["SOURCE_GIT_TAG"] = version.to_s if build.stable?

    args = []
    if OS.linux?
      args << "SHELL=/bin/bash"
      ENV.O0
    end

    system "make", "oc", *args
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
      assert_equal version_json["clientVersion"]["gitCommit"], stable.specs[:revision].slice(0, 9)

      # Get remote release details
      release_raw = shell_output("#{bin}/oc adm release info #{version} --output=json")
      release_json = JSON.parse(release_raw)

      # Verify the formula matches the release data for the version
      assert_match release_json["references"]["spec"]["tags"].find { |tag|
                     tag["name"]=="cli"
                   } ["annotations"]["io.openshift.build.commit.id"], stable.specs[:revision]

    end

    # Test that we can generate and write a kubeconfig
    (testpath/"kubeconfig").write ""
    system "KUBECONFIG=#{testpath}/kubeconfig #{bin}/oc config set-context foo 2>&1"
    assert_match "foo", shell_output("KUBECONFIG=#{testpath}/kubeconfig #{bin}/oc config get-contexts -o name")
  end
end
