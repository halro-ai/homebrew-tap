class Halro < Formula
  desc "Self-hosted LLM gateway for governance, routing, and accounting"
  homepage "https://halro.ai/"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/akz142857/Halro/releases/download/v0.8.4/halro-darwin-arm64.tar.gz"
      sha256 "e82f0e129046beea97984e20a6d7ed6c799b553d5a1298ce043f6b0568543a90"
    else
      url "https://github.com/akz142857/Halro/releases/download/v0.8.4/halro-darwin-amd64.tar.gz"
      sha256 "d0b2558f5872dd27967054099855029aa7668133c4d4e438715d1e3b107471f4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/akz142857/Halro/releases/download/v0.8.4/halro-linux-arm64.tar.gz"
      sha256 "8f777e63e8378064dbbfbdf14863a09c560d398f9424cec50305d9f0269880f0"
    else
      url "https://github.com/akz142857/Halro/releases/download/v0.8.4/halro-linux-amd64.tar.gz"
      sha256 "3ecda594aa61a108ea68a12df4976244e25ee250f679a88f691db097bc835b5c"
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
    assert_predicate pkgshare/"halro.config.example.yaml", :exist?
    cp pkgshare/"halro.config.example.yaml", testpath/"config.yaml"
    assert_match "configuration valid",
                 shell_output("#{bin}/halro config check --config #{testpath}/config.yaml")
  end
end
