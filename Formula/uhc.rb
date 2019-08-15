class Uhc < Formula
  desc "Unified Hybrid Cloud provisioning tool"
  homepage "https://www.openshift.com/"
  url "https://github.com/openshift-online/uhc-cli.git",
      :tag      => "v0.1.19",
      :revision => "a53cd6cfc875f27944444d8a35e6dabc26bffdc9"
  head "https://github.com/openshift-online/uhc-cli.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "on"
    dir = buildpath/"src/github.com/openshift-online/uhc-cli"
    dir.install buildpath.children - [buildpath/".brew_home"]

    cd dir do
      system "go", "build", "-o", "#{bin}/uhc", "./cmd/uhc"

      # Install bash completion
      output = Utils.popen_read("#{bin}/uhc completion")
      (bash_completion/"uhc").write output
    end
  end

  test do
    assert_match /^#{version}/, shell_output("#{bin}/uhc version")
  end
end
