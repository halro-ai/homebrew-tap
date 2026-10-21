class Halro < Formula
  desc "Self-hosted LLM gateway for governance, routing, and accounting"
  homepage "https://halro.ai/"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/akz142857/Halro/releases/download/v0.9.2/halro-darwin-arm64.tar.gz"
      sha256 "bcdffe42f63677997254ff7ef6b684c00dce0dc3571e28adc1fccee0a348d995"
    else
      url "https://github.com/akz142857/Halro/releases/download/v0.9.2/halro-darwin-amd64.tar.gz"
      sha256 "e4bdae9d669971d6660a1b44764e87932bbc6a61a1578a866b814cf7bbeee322"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/akz142857/Halro/releases/download/v0.9.2/halro-linux-arm64.tar.gz"
      sha256 "06b349a0e646e30081a4e0fe2cba46c55399f0797b2d047854df7b031822ca32"
    else
      url "https://github.com/akz142857/Halro/releases/download/v0.9.2/halro-linux-amd64.tar.gz"
      sha256 "5b77d2b2319cad7a0af52abc2779703648bc287ab599b559cb883f182028c836"
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
