class Kind < Formula
  desc "Run local Kubernetes cluster in Docker"
  homepage "https://kind.sigs.k8s.io/"
  url "https://github.com/kubernetes-sigs/kind.git",
      :tag      => "v0.4.0",
      :revision => "08872cfc811c76a7cfcf11338fbf6f157477c1cf"
  head "https://github.com/kubernetes-sigs/kind.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "on"
    dir = buildpath/"src/sigs.k8s.io/kind"
    dir.install buildpath.children - [buildpath/".brew_home"]

    cd dir do
      system "go", "build", "-o", bin/"kind"

      prefix.install_metafiles

      # Install bash completion
      output = Utils.popen_read("#{bin}/kind completion bash")
      (bash_completion/"kind").write output

      # Install zsh completion
      output = Utils.popen_read("#{bin}/kind completion zsh")
      (zsh_completion/"_kind").write output
    end
  end

  test do
    ENV["GOPATH"] = testpath
    dir = testpath/"src/sigs.k8s.io/kind"
    mkdir dir
    system "git", "clone", "https://github.com/kubernetes-sigs/kind.git", dir
    system "#{bin}/kind", "build", "base-image"
  end
end
