class Halro < Formula
  desc "Self-hosted LLM gateway for governance, routing, and accounting"
  homepage "https://halro.ai/"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/akz142857/Halro/releases/download/v0.13.0/halro-darwin-arm64.tar.gz"
      sha256 "3af5adae2c0fe4c7af60f652ba57d08f45e18a77e5aa7939e88222e71d0c0576"
    else
      url "https://github.com/akz142857/Halro/releases/download/v0.13.0/halro-darwin-amd64.tar.gz"
      sha256 "6f30526b00b5496cb6a2fd0fe358a4f008eff30be120c4c6af83d6bbb09c6c11"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/akz142857/Halro/releases/download/v0.13.0/halro-linux-arm64.tar.gz"
      sha256 "5582a646fce522be267a4cbc5dc64d63f6218f77bb0301d111a63645bff7d562"
    else
      url "https://github.com/akz142857/Halro/releases/download/v0.13.0/halro-linux-amd64.tar.gz"
      sha256 "bf043a48b732dfbcf8c0828f99c27e955bcd020e3383780ecb005fbaf5e48ab8"
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
