class Halro < Formula
  desc "Self-hosted LLM gateway for governance, routing, and accounting"
  homepage "https://halro.ai/"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/akz142857/Halro/releases/download/v0.15.0/halro-darwin-arm64.tar.gz"
      sha256 "86a4a3166ad28783d54df0f11f2fd19c05e9ad14dd1e09ea1c24da444cd0a98e"
    else
      url "https://github.com/akz142857/Halro/releases/download/v0.15.0/halro-darwin-amd64.tar.gz"
      sha256 "4173a45aec34079f558d8cb2d52f72b478c41b75203fa2074e80a60037c00edd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/akz142857/Halro/releases/download/v0.15.0/halro-linux-arm64.tar.gz"
      sha256 "f2157b80452bf1d6fe52cffe9e4d649304f5c2a68f1a3bc32c5309490c24d9bd"
    else
      url "https://github.com/akz142857/Halro/releases/download/v0.15.0/halro-linux-amd64.tar.gz"
      sha256 "cebd6d0e35bd27de57a853b1f51fb4fe9465e0c202da2abc6037a6317331818c"
    end
  end

  def install
    bin.install "halro", "halro-deadman"
    # The gateway's own example, not just the watchdog's. Without it `halro
    # init` has nothing to read and a Homebrew install is a dead end: the
    # command refuses with "open config: no such file or directory" and the
    # formula offers no file to copy.
    pkgshare.install "halro.config.example.yaml"
    (pkgshare/"deadman").install "config.example.yaml", "config.schema.json", "event.schema.json"
    doc.install "README.md", "NOTICE", "THIRD_PARTY_NOTICES.md", "RECEIVER-CONTRACT.md"
  end

  def caveats
    <<~EOS
      Halro does not initialize configuration or start a service during install,
      and nothing below happens on its own.

      First run, from a directory you have chosen deliberately:

        mkdir -p ~/halro && cd ~/halro
        cp #{pkgshare}/halro.config.example.yaml config.yaml
        # review config.yaml, then:
        halro config check --config config.yaml
        halro init --config config.yaml
        halro start --config config.yaml

      The example keeps its data directory and master key relative to the
      working directory (./data and ./master.key), so `halro init` writes them
      wherever it is run. Choose that directory before running it; the master
      key is not recoverable if it is lost, and a backup of it belongs
      somewhere other than the data directory it protects.

      `halro start` prints a one-time Admin Console setup token. It is shown
      once, and the console is on the admin listener in config.yaml
      (127.0.0.1:8081 in the example).

      Guides: https://halro.ai/docs/guides/quickstart-install/

      The dead-man watchdog is deployed separately, outside Halro's failure
      domain. Its example configuration and schemas:
        #{pkgshare}/deadman
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/halro version")
    assert_predicate bin/"halro-deadman", :executable?
    # The caveats tell an operator to copy this file; a formula that ships the
    # instruction without the file is worse than one that says nothing.
    assert_path_exists pkgshare/"halro.config.example.yaml"
    cp pkgshare/"halro.config.example.yaml", testpath/"config.yaml"
    assert_match "configuration valid",
                 shell_output("#{bin}/halro config check --config #{testpath}/config.yaml")
  end
end
