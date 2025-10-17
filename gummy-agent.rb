class GummyAgent < Formula
  desc "Fast multi-agent orchestration using Claude Haiku with real-time TUI monitoring"
  homepage "https://github.com/WillyV3/gummy-agent"
  url "https://github.com/WillyV3/gummy-agent/archive/v0.1.0.tar.gz"
  sha256 "PLACEHOLDER_SHA256"
  license "MIT"

  depends_on "go" => :build

  def install
    # Build the TUI
    system "go", "build", "-o", "gummy-watch", "gummy-watch.go"

    # Install binaries
    bin.install "gummy"
    bin.install "gummy-watch"
  end

  def post_install
    # Create necessary directories
    (var/"claude/logs/gummy").mkpath
    (var/"claude/agent_comms/gummy").mkpath
  end

  def caveats
    <<~EOS
  ▄▀    ▄   █▀▄▀█ █▀▄▀█ ▀▄    ▄     ██     ▄▀  ▄███▄      ▄     ▄▄▄▄▀ ▄▄▄▄▄
▄▀       █  █ █ █ █ █ █   █  █      █ █  ▄▀    █▀   ▀      █ ▀▀▀ █   █     ▀▄
█ ▀▄  █   █ █ ▄ █ █ ▄ █    ▀█       █▄▄█ █ ▀▄  ██▄▄    ██   █    █ ▄  ▀▀▀▀▄
█   █ █   █ █   █ █   █    █        █  █ █   █ █▄   ▄▀ █ █  █   █   ▀▄▄▄▄▀
 ███  █▄ ▄█    █     █   ▄▀            █  ███  ▀███▀   █  █ █  ▀
       ▀▀▀    ▀     ▀                 █                █   ██
                                     ▀
                                                            @builtbywilly.com

      Fast multi-agent orchestration with Claude Haiku

      Quick Start:
        gummy plan "your complex task description"
        gummy task "simple task description"
        gummy-watch [task-id]

      Logs and reports stored in ~/.claude/
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/gummy 2>&1", 1)
  end
end
