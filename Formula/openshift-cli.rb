class OpenshiftCli < Formula
  desc "OpenShift command-line interface tools"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift/oc.git",
      # :tag => "v4.4.11", # oc adm release info 4.4.11 --commits
      :revision => "d89e458c3dff553f9a732b282830bfa9b4e0ab9b",
      :shallow  => false
  version "4.4.11"
  head "https://github.com/openshift/oc.git",
      :shallow  => false

  depends_on "go" => :build
  depends_on "heimdal" => :build

  def install
    system "make"

    bin.install "oc"
    prefix.install_metafiles

    # Install bash completion
    output = Utils.popen_read("#{bin}/oc completion bash")
    (bash_completion/"oc").write output

    # Install zsh completion
    output = Utils.popen_read("#{bin}/oc completion zsh")
    (zsh_completion/"_oc").write output
  end

  test do
    if build.stable?
      # If stable, ensure version matches
      version_output = shell_output("#{bin}/oc version --client 2>&1")
      # assert_match "Client Version: v#{version}", version_output
      assert_match stable.instance_variable_get(:@resource)
                         .instance_variable_get(:@specs)[:revision].slice(0, 7),
                   version_output
    end

    # Test that release information matching the version is available
    system "#{bin}/oc", "adm", "release", "info", version.to_s
  end
end
