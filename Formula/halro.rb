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
    (pkgshare/"deadman").install "config.example.yaml", "config.schema.json", "event.schema.json"
    doc.install "README.md", "NOTICE", "THIRD_PARTY_NOTICES.md", "RECEIVER-CONTRACT.md"
  end

  def caveats
    <<~EOS
      Halro does not initialize configuration or start a service during install.
      Create and protect your configuration explicitly before starting Halro.
      The bundled dead-man example is installed under:
        #{pkgshare}/deadman
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/halro version")
    assert_predicate bin/"halro-deadman", :executable?
  end
end
