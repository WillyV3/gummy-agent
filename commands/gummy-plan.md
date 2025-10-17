---
description: Plan a task with Haiku agent - human approves before execution
---

## What This Does

Creates a detailed execution plan using a Haiku agent. You control the scope by telling me exactly what to plan. After planning, you review with me before executing.

## Usage

```bash
/gummy-plan "Create login system with email/password"
```

## Workflow

1. **You tell me what to plan** - Just the task description
2. **Haiku plans fast** - Discovery + detailed implementation plan
3. **You review with me** - We discuss scope, approach, risks
4. **You approve** - Then run `gummy execute [task-id]`

## Instructions for Claude

When user invokes `/gummy-plan "task description"`:

### Step 1: Launch Planner

The launcher handles everything (task ID generation, instruction building, agent spawning):

```bash
~/master-claude/bin/gummy plan "task description here"
```

Tell user:
```
📋 Planning with Haiku...

Monitor in real-time: gummy-watch

I'll wait for planning to complete...
```

### Step 2: Wait for Completion

The launcher runs synchronously. When it exits, it shows:
- Task ID generated
- Location of plan files in `~/.claude/agent_comms/gummy/`

### Step 3: Read Plan Files

Read:
1. `~/.claude/agent_comms/gummy/[task-id]-discoveries.md`
2. `~/.claude/agent_comms/gummy/[task-id]-plan.md`
3. `~/.claude/agent_comms/gummy/[task-id]-plan-report.md`

### Step 4: Present Plan to User

Summarize for user:

```markdown
## Plan Complete: [task]

### What Haiku Discovered
[Key findings from discoveries]

### Proposed Approach
[High-level plan summary]

### Implementation Phases
1. [Phase 1 summary]
2. [Phase 2 summary]
...

### Haiku's Assessment
- Confidence: [High/Medium/Low]
- Complexity: [Trivial/Low/Medium/High]
- Estimated time: [X minutes]
- Risks: [Key risks identified]

### My Assessment
[Your take on the plan - does it make sense? concerns?]

---

**Ready to execute?**
- Review full plan: ~/.claude/agent_comms/gummy/[task-id]-plan.md
- If approved: `gummy execute [task-id]`
- If changes needed: Tell me what to adjust and I'll replan
```

## Key Principles

- **User controls scope** - They tell you what to plan
- **Launcher handles orchestration** - You just call it and review results
- **Fast planning** - Haiku is quick
- **Human approval** - No execution without review
- **Works from any directory** - Launcher uses fixed ~/.claude/ paths
