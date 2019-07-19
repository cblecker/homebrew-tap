class Kubebuilder < Formula
  desc "SDK for building Kubernetes APIs using CRDs"
  homepage "https://github.com/kubernetes-sigs/kubebuilder"
  url "https://github.com/kubernetes-sigs/kubebuilder.git",
      :tag      => "v2.0.0-beta.0",
      :revision => "b12371ccabd1bc8de7ec7ec1a1ca7bfabe567701"
  head "https://github.com/kubernetes-sigs/kubebuilder.git"

  depends_on "git-lfs" => :build
  depends_on "go" => :build

  def install
    ENV["GO111MODULE"] = "on"
    ENV["GOPATH"] = buildpath
    dir = buildpath/"src/sigs.k8s.io/kubebuilder"
    dir.install buildpath.children - [buildpath/".brew_home"]

    cd dir do
      # Make binary
      system "make", "build"
      bin.install "bin/kubebuilder"
      prefix.install_metafiles
    end
  end

  test do
    ENV["GO111MODULE"] = "on"
    ENV["GOPATH"] = testpath
    dir = testpath/"src/github.com/example/test-repo"
    dir.mkpath

    cd dir do
      system "#{bin}/kubebuilder", "init", "--domain=example.com", "--license=apache2", "--owner='The Example authors'", "--fetch-deps=false"
    end
  end
end
