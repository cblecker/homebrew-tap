class Kind < Formula
  desc "Run local Kubernetes cluster in Docker"
  homepage "https://kind.sigs.k8s.io/"
  url "https://github.com/kubernetes-sigs/kind/archive/v0.5.1.tar.gz"
  sha256 "fa137ac15eda93776a74ce23a235f5f7bcab995786abba25f4be47c161125206"
  head "https://github.com/kubernetes-sigs/kind.git"

  depends_on "go" => :build

  def install
    ENV["GO111MODULE"] = "on"
    system "go", "build", "-o", bin/"kind"
    prefix.install_metafiles

    # Install bash completion
    output = Utils.popen_read("#{bin}/kind completion bash")
    (bash_completion/"kind").write output

    # Install zsh completion
    output = Utils.popen_read("#{bin}/kind completion zsh")
    (zsh_completion/"_kind").write output
  end

  test do
    ENV["GOPATH"] = testpath
    dir = testpath/"src/sigs.k8s.io/kind"
    mkdir dir
    system "git", "clone", "https://github.com/kubernetes-sigs/kind.git", dir
    system "#{bin}/kind", "build", "base-image"
  end
end
