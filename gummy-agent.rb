class GummyAgent < Formula
  desc "Fast multi-agent orchestration using Claude Haiku with real-time TUI monitoring"
  homepage "https://github.com/WillyV3/gummy-agent"
  url "https://github.com/WillyV3/gummy-agent/archive/v0.0.1.tar.gz"
  sha256 "ffa74102df7cf073e8f8083e6d87dcbf4ef54d26fd7edecef0aaea4e22ab1e11"
  license "MIT"

  depends_on "go" => :build

  def install
    # Build the TUI
    system "go", "build", "-o", "gummy-watch", "gummy-watch.go"

    # Install binaries
    bin.install "gummy"
    bin.install "gummy-watch"

    # Install slash commands for Claude CLI
    (prefix/"commands").install Dir["commands/*.md"]
  end

  def post_install
    # Create necessary directories
    claude_home = File.expand_path("~/.claude")
    commands_dir = "#{claude_home}/commands"
    logs_dir = "#{claude_home}/logs/gummy"
    comms_dir = "#{claude_home}/agent_comms/gummy"

    # Create directories
    system "mkdir", "-p", commands_dir
    system "mkdir", "-p", logs_dir
    system "mkdir", "-p", comms_dir

    # Install slash commands to user's Claude config
    Dir["#{prefix}/commands/*.md"].each do |cmd_file|
      cmd_name = File.basename(cmd_file)
      target = "#{commands_dir}/#{cmd_name}"

      # Copy command file if it doesn't exist or update if different
      if !File.exist?(target) || File.read(cmd_file) != File.read(target)
        system "cp", cmd_file, target
        puts "  Installed command: /#{File.basename(cmd_name, '.md')}"
      end
    end
  end

  def caveats
    <<~EOS

  _   _  _     _ _ _  _/ _
 (/(///)//)(/ (/(/(-/)/_)
_/         /   _/

                    @builtbywilly.com

      gummy-agent has been installed!

      Fast multi-agent orchestration using Claude Haiku 4.5

      Three Execution Modes:

        1. Plan Mode (Complex Features):
           gummy plan "Build authentication system with JWT"
           - Creates detailed implementation plan
           - Research and discovery phase
           - Review plan before execution

        2. Task Mode (Simple Changes):
           gummy task "Refactor auth helper functions"
           - Fast single-shot execution
           - No planning phase
           - Perfect for quick tasks

        3. Execute Mode (Run Approved Plan):
           gummy execute [task-id]
           - Implements approved plan
           - Full execution with reports

      Monitor in Real-Time:
        gummy-watch [task-id]
        - Live agent status and progress
        - Full markdown rendering
        - Press 'c' to copy final message
        - Press 'q' to quit

      Requirements:
        - Claude CLI with API key configured
        - Haiku model access

      File Locations:
        Logs:    ~/.claude/logs/gummy/
        Reports: ~/.claude/agent_comms/gummy/

      Documentation:
        https://github.com/WillyV3/gummy-agent
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/gummy 2>&1", 1)
  end
end
