class OpenshiftCli < Formula
  desc "OpenShift command-line interface tools"
  homepage "https://www.openshift.com/"
  url "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.12.12/oc-source.tar.gz"
  version "4.12.12"
  sha256 "807262caeb6d4c01ca63979425767a786190a840c95cc04cecfbf5919d54c7b1"
  head "https://github.com/openshift/oc.git", shallow: false, branch: "master"

  livecheck do
    url "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/"
    regex(/href=.*?openshift-client-src-(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "go" => :build
  uses_from_macos "krb5"

  on_macos do
    depends_on "heimdal" => :build
  end

  def install
    if build.stable?
      ENV["OS_GIT_VERSION"] = version.to_s
      ENV["SOURCE_GIT_COMMIT"] = Pathname.pwd.basename.to_s.delete_prefix("oc-")
    end

    # See https://github.com/golang/go/issues/26487
    ENV.O0 if OS.linux?

    system "make", "oc", "SHELL=/bin/bash"
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

      # Get remote release details
      release_raw = shell_output("#{bin}/oc adm release info #{version} --output=json")
      release_json = JSON.parse(release_raw)

      # Verify the formula matches the release data for the version
      assert_match version_json["clientVersion"]["gitVersion"],
        release_json["references"]["spec"]["tags"].find { |tag|
          tag["name"]=="cli"
        } ["annotations"]["io.openshift.build.commit.id"]

    end

    # Test that we can generate and write a kubeconfig
    (testpath/"kubeconfig").write ""
    system "KUBECONFIG=#{testpath}/kubeconfig #{bin}/oc config set-context foo 2>&1"
    assert_match "foo", shell_output("KUBECONFIG=#{testpath}/kubeconfig #{bin}/oc config get-contexts -o name")
  end
end
