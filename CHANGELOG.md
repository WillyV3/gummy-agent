# Changelog

## v0.0.1 (2025-10-16)

Initial release of gummy-agent - fast multi-agent orchestration using Claude Haiku 4.5.

### Features

- **Plan Mode**: Haiku creates detailed implementation plans with research and analysis
  - Auto-generated task IDs (timestamp-based)
  - Structured discovery, planning, and reporting phases
  - Stores plans in `~/.claude/agent_comms/gummy/`

- **Execute Mode**: Haiku executes approved plans with full implementation
  - Human approval gate between planning and execution
  - Reads approved plans and implements changes
  - Generates execution reports

- **Task Mode**: Haiku handles simple, single-shot tasks quickly
  - No planning phase - direct execution
  - Perfect for refactoring, simple fixes, and tedious work

- **Real-time TUI Monitoring** (gummy-watch)
  - Built with Bubbletea, Lipgloss, and Glamour
  - Live agent status and progress tracking
  - Full markdown rendering with syntax highlighting
  - Window size responsive with text wrapping
  - Clipboard integration - press 'c' to copy final message
  - 30-second inactivity detection for accurate status
  - Support for all three modes (plan/execute/task)

### Architecture

- Self-contained bash launcher with embedded instruction templates
- Works from any directory using fixed `~/.claude/` paths
- Stream-JSON log format for real-time event parsing
- All agents use Claude Haiku 4.5 for consistent speed
- Go-based TUI with beautiful terminal rendering

### Installation

- Homebrew formula included for easy installation
- Manual installation script provided
- Comprehensive README documentation
- Release automation script for version management
