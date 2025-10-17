# gummy-agent

Fast multi-agent orchestration system using Claude Haiku 4.5 for rapid task execution with real-time TUI monitoring.

## Overview

gummy-agent provides three execution modes:

1. **Plan Mode**: Haiku creates a detailed implementation plan with research and analysis
2. **Execute Mode**: Haiku executes an approved plan with full implementation
3. **Task Mode**: Haiku handles simple, single-shot tasks quickly

All modes include real-time TUI monitoring with markdown rendering and clipboard integration.

## Installation

### Homebrew (Recommended)

```bash
brew install willyv3/tap/gummy-agent
```

### From Source

```bash
git clone https://github.com/WillyV3/gummy-agent.git
cd gummy-agent
./install.sh
```

## Quick Start

### Plan a Complex Feature

```bash
gummy plan "Build authentication system with JWT tokens and refresh logic"
```

Review the generated plan files:
- `~/.claude/agent_comms/gummy/[task-id]-discoveries.md` - Research findings
- `~/.claude/agent_comms/gummy/[task-id]-plan.md` - Implementation plan
- `~/.claude/agent_comms/gummy/[task-id]-plan-report.md` - Final plan summary

### Execute an Approved Plan

```bash
gummy execute [task-id]
```

### Run a Simple Task

```bash
gummy task "Refactor the authentication helper functions for better readability"
```

### Monitor in Real-Time

```bash
gummy-watch [task-id]
```

Features:
- Live agent status and progress
- Full markdown rendering with syntax highlighting
- Press 'c' to copy final message to clipboard
- Press 'q' or Ctrl+C to quit

## Architecture

- **Launcher**: Bash script (`gummy`) handles orchestration and agent spawning
- **Agents**: All modes use Claude Haiku 4.5 for speed
- **TUI**: Go application using Bubbletea, Lipgloss, and Glamour
- **Logs**: Stream-JSON format in `~/.claude/logs/gummy/`
- **Reports**: Markdown files in `~/.claude/agent_comms/gummy/`

## Workflow Examples

### Feature Development Workflow

```bash
# 1. Create detailed plan
gummy plan "Add rate limiting middleware with Redis backend"

# 2. Review plan with main Claude instance
# Check the plan files, discuss with Claude

# 3. Execute approved plan
gummy execute gummy-1234567890

# 4. Monitor execution
gummy-watch gummy-1234567890
```

### Quick Task Workflow

```bash
# Single command for simple tasks
gummy task "Add JSDoc comments to util functions"

# Monitor if desired
gummy-watch gummy-1234567891
```

## Configuration

All files stored in `~/.claude/`:
- `logs/gummy/` - Agent execution logs
- `agent_comms/gummy/` - Plans, reports, and discoveries

Works from any directory - no project-specific setup required.

## Requirements

- Claude CLI configured with API key
- Go 1.21+ (for building from source)
- Bash 4.0+
- macOS or Linux

## Use Cases

**Best for Plan Mode:**
- Multi-file features requiring careful planning
- Complex architectural changes
- Features with multiple integration points
- Changes requiring research and discovery

**Best for Task Mode:**
- Refactoring existing code
- Adding comments or documentation
- Simple bug fixes
- Repetitive code changes
- Single-file modifications

**Best for Execute Mode:**
- Implementing an approved plan
- Following established patterns
- Changes reviewed and validated by main Claude

## Development

### Project Structure

```
bin/
├── gummy              # Main launcher script
├── gummy-watch.go     # TUI monitoring application
├── build-gummy-watch.sh
└── go.mod

~/.claude/
├── logs/gummy/        # Execution logs
└── agent_comms/gummy/ # Plans and reports
```

### Building

```bash
cd bin
./build-gummy-watch.sh
```

## License

MIT

## Author

Created by WillyV3
