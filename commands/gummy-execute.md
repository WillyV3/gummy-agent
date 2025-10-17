---
description: Execute an approved plan with Haiku agent
---

## What This Does

Executes a plan that you've already reviewed and approved from `/gummy-plan`.

## Usage

```bash
/gummy-execute gummy-1234567890
```

## Workflow

1. **You've approved the plan** - After reviewing with me
2. **Haiku executes** - Follows plan exactly
3. **I review results** - Verify success criteria

## Instructions for Claude

When user invokes `/gummy-execute [task-id]`:

### Step 1: Launch Executor

The launcher handles everything (plan verification, instruction building, agent spawning):

```bash
~/master-claude/bin/gummy execute [task-id]
```

The launcher will verify the plan exists and exit with error if not found.

Tell user:
```
⚙️  Executing with Haiku...

Monitor in real-time: gummy-watch [task-id]

I'll wait for execution to complete...
```

### Step 2: Wait for Completion

The launcher runs synchronously. When it exits, it shows:
- Location of execution report in `~/.claude/agent_comms/gummy/`

### Step 3: Read Execution Report

Read:
- `~/.claude/agent_comms/gummy/[task-id]-execution-report.md`

### Step 4: Review and Validate

**My Review Process:**

1. **Read execution report** - What phases completed?
2. **Verify success criteria** - Did they all pass?
3. **Check for deviations** - Did Haiku follow the plan?
4. **Spot check files** - Read key modified files
5. **Run validation myself** - Verify claims

**Create:** `~/.claude/agent_comms/gummy/[task-id]-review.md`

```markdown
# Main Claude Review: [task]

## Overall Assessment
[Complete ✅ / Partial ⚠️ / Failed ❌]

## What Was Accomplished
[Summary]

## Success Criteria Verification
- Criterion 1: [PASS/FAIL] - [my verification]
- Criterion 2: [PASS/FAIL] - [my verification]

## Plan Adherence
[Did executor follow the approved plan?]

## Files Verification
[Spot-checked key files - look correct?]

## Issues Found
[Any problems I noticed]

## Recommendation
[Accept / Needs fixes / Reject]
```

### Step 5: Present Results to User

```markdown
## Execution Complete: [task]

### Status: [Complete/Partial/Failed]

### What Was Done
[Summary from execution report]

### My Verification
[My review findings]

### Files Modified
- [file list with line counts]

### Success Criteria
- ✅ [passed items]
- ❌ [failed items if any]

---

**Recommendation:** [Accept/Fix/Reject with reasoning]

Full reports:
- Execution: ~/.claude/agent_comms/gummy/[task-id]-execution-report.md
- My Review: ~/.claude/agent_comms/gummy/[task-id]-review.md
```

## Key Principles

- **Approved plans only** - No execution without planning
- **Launcher handles orchestration** - You just call it and review results
- **Fast execution** - Haiku implements quickly
- **Strict adherence** - Follow plan exactly
- **Main Claude oversight** - I verify the results
- **Works from any directory** - Launcher uses fixed ~/.claude/ paths
