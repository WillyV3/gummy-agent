# gummy-agent

Multi-agent orchestration for Claude Code using Haiku 4.5.

## What This Is

Since Sonnet 4.5 came out I've been running out of context really quickly. Different strategies to manage context across sessions - sometimes forced to start conversations from zero (praying I had prepared carryover prompts, but often hadn't) or being forced into /compact.

Haiku 4.5 got released and I wanted to make my own little agent system.

Named after charmbracelet/gum (the inspiration during initial build) - though we went full bubbletea and will probably over-engineer on the UI in later updates.

This is not a competition with other agentic frameworks on the market and definitely not as fancy. It made sense to me and still does.

## Install

```bash
brew install willyv3/tap/gummy-agent
gummy setup
```

## Usage

Three slash commands in Claude Code:

### `/gummy-task "description"`

Quick single-shot tasks when there's context:
```
/gummy-task "refactor the auth helpers"
/gummy-task "add JSDoc to all utils"
/gummy-task "fix bug in parseUserInput"
```

### `/gummy-plan "description"`

Plan bigger features:
```
/gummy-plan "Build full Go TUI with bubbletea for process monitoring"
/gummy-plan "Create bash script that syncs git repos with conflict detection"
```

Haiku researches, discovers, creates implementation plan.

### `/gummy-execute task-id`

Execute approved plan:
```
/gummy-execute gummy-1234567890
```

Review plan files first, then run this.

## When to Use What

**Task:** Quick stuff, you know what to do, lots of context already

**Plan/Execute:** Bigger features, multiple files, need research

## Files

Everything in `~/.claude/`:
- `logs/gummy/` - Execution logs
- `agent_comms/gummy/` - Plans, reports, discoveries

## CLI

You can also run directly:
```bash
gummy task "description"
gummy plan "description"
gummy execute task-id

# Watch real-time
gummy-watch task-id
```

## Why

Building features in an enterprise Go codebase. New to having every line of code I write be scrutinized this much. Using this to double and triple check implementations against plans - before, during, and after.

These commands are meant to be used by Claude Code during development.

## Tech

- Bash launcher handles all orchestration
- Go TUI (bubbletea + lipgloss + glamour) for monitoring
- All agents use Haiku 4.5
- Fixed paths in `~/.claude/`

## Status

Still a WIP. Building features as needed.

Issues: https://github.com/WillyV3/gummy-agent/issues

## Contact

- [@willyv3.com](https://willyv3.com)
- [@builtbywilly.com](https://builtbywilly.com)
- [@breakshit.blog](https://breakshit.blog)

## License

MIT
