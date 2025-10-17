# gummy-agent

Multi-agent orchestration for Claude Code using Haiku 4.5 to manage context across development sessions.

## What This Is

A personal tool for managing context during Claude Code development. When Sonnet 4.5 runs out of context mid-session, this system uses Haiku 4.5 agents to handle specific tasks while keeping the main conversation focused.

Not a competitor to other agentic frameworks. This made sense for my workflow and still does.

Named after charmbracelet/gum (the initial inspiration), though it now uses full bubbletea for the TUI.

## Why This Exists

Working in an enterprise Go codebase where every line gets scrutinized. Using this to:
- Double-check implementations against plans
- Triple-check before, during, and after implementation
- Manage context when Sonnet runs out mid-feature
- Avoid starting conversations from zero when context is lost

## Modes

### Plan Mode
Haiku creates implementation plan with research. Used for:
- Planning complex features before implementation
- Getting a second opinion on approach
- Documenting discovery phase

### Execute Mode
Haiku implements an approved plan. Used after:
- Reviewing plan with main Claude
- Validating approach
- Getting approval to proceed

### Task Mode
Haiku handles single-shot tasks. Used for:
- Refactoring code
- Adding documentation
- Simple bug fixes
- Repetitive changes

## Installation

```bash
brew install willyv3/tap/gummy-agent
gummy setup
```

Or from source:
```bash
git clone https://github.com/WillyV3/gummy-agent.git
cd gummy-agent
./scripts/install.sh
```

## Usage

```bash
# Plan a feature
gummy plan "Add rate limiting middleware with Redis"

# Review plan files in ~/.claude/agent_comms/gummy/

# Execute if approved
gummy execute [task-id]

# Quick tasks
gummy task "Add JSDoc comments to utils"

# Monitor any mode
gummy-watch [task-id]
```

## Monitoring TUI

Real-time monitoring with:
- Agent status and progress
- Markdown rendering with syntax highlighting
- Press 'c' to copy output
- Press 'q' to quit

## Files

All stored in `~/.claude/`:
- `logs/gummy/` - Execution logs (stream-json format)
- `agent_comms/gummy/` - Plans, reports, discoveries
- `commands/` - Claude Code slash commands

## Workflow

Typical usage during feature development:

1. Main Claude conversation hits context limits or needs validation
2. Run `gummy plan "feature description"`
3. Review plan files with main Claude
4. If approved: `gummy execute [task-id]`
5. Continue main conversation with results

Or for simple tasks:
1. `gummy task "refactor X"`
2. Review output
3. Continue

## Requirements

- Claude Code CLI with API key configured
- Go 1.21+ (for building from source)
- Bash 4.0+
- macOS or Linux

## Architecture

- `gummy` - Bash launcher, handles orchestration
- `gummy-watch` - Go TUI (bubbletea + lipgloss + glamour)
- All agents use Haiku 4.5
- Fixed paths in `~/.claude/` (works from any directory)

## Status

Work in progress. Building features as needed.

Known issues tracked at: https://github.com/WillyV3/gummy-agent/issues

## Contact

- [@willyv3.com](https://willyv3.com)
- [@builtbywilly.com](https://builtbywilly.com)
- [@breakshit.blog](https://breakshit.blog)

## License

MIT
