---
description: Execute simple tasks with Haiku - no planning needed
---

## What This Does

Single-shot Haiku execution for simple, straightforward tasks. No planning phase - just direct execution. Use this for remedial, tedious, or simple tasks that don't need the full plan/execute workflow.

**🧠 Persistence Feature:** When run from a project with `.gummy/` directory, tasks automatically use persistent specialists that remember previous work. Specialists accumulate knowledge across tasks, avoiding repeated mistakes.

## Usage

```bash
/gummy-task "add logging to the login function"
```

## When to Use This

**Good for:**
- Simple code changes (add a function, fix a typo)
- Tedious tasks (rename variables, update comments)
- Straightforward additions (add logging, add validation)
- Quick fixes that are obvious
- Repetitive work

**NOT for:**
- Complex features requiring multiple files
- Architectural changes
- Anything that needs careful planning
- Tasks with significant risk

## Workflow

1. **You decide it's simple** - No planning needed
2. **You build the instruction** - Give Haiku specific context
3. **Haiku executes fast** - Direct implementation
4. **You review results** - Quick validation

## Instructions for Claude

When user invokes `/gummy-task "description"`:

### Step 1: Assess Task Complexity

Ask yourself:
- Is this truly simple and straightforward?
- Can it be done without planning?
- Are the requirements clear?
- Is risk minimal?

If NO to any: Use `/gummy-plan` instead.

### Step 2: Build Rich Instruction

The launcher has a basic template, but YOU should provide rich context through the task description:

```bash
~/master-claude/bin/gummy task "
Add detailed logging to the login function in auth/login.ts.

Context:
- Function is at line 45
- Use the logger from utils/logger.ts
- Log: attempt, success, failure with user email
- Follow existing logging patterns in the codebase

Validation:
- Check that logs appear in console when function runs
- Ensure no sensitive data (passwords) in logs
"
```

**Key principle:** You are still responsible for providing:
- Specific file paths
- Context about the codebase
- Validation requirements
- Any constraints or patterns to follow

### Step 3: Launch Task Agent

```bash
~/master-claude/bin/gummy task "[your detailed instruction]"
```

**How Specialist Routing Works:**
The gummy script automatically:
1. Analyzes task description for keywords (database, api, test, ui, etc.)
2. Routes to appropriate specialist (database-expert, api-developer, testing-specialist, etc.)
3. Creates specialist if it doesn't exist (with project context from CLAUDE.md/README.md)
4. Resumes existing specialist session (preserving conversation memory)
5. Executes task with accumulated specialist knowledge

**Specialist Benefits:**
- ✅ Remembers previous work in the codebase
- ✅ Won't repeat mistakes from earlier tasks
- ✅ Accumulates project-specific knowledge
- ✅ Session conversation preserved across tasks
- ✅ Monitor specialists with `gummy-watch` TUI

Tell user:
```
⚡ Executing with Haiku (fast mode)...
🧠 Using persistent specialist (remembers previous work)

Monitor in real-time: gummy-watch

I'll wait for completion...
```

### Step 4: Wait for Completion

The launcher runs synchronously. When it exits, it shows:
- Task ID generated
- Location of task report in `~/.claude/agent_comms/gummy/`

### Step 5: Read Task Report

Read:
- `~/.claude/agent_comms/gummy/[task-id]-task-report.md`

### Step 6: Validate Results

**Quick validation:**
1. Read the report - what was done?
2. Spot check modified files
3. Run any obvious tests
4. Verify it makes sense

### Step 7: Present to User

```markdown
## Task Complete: [task]

### What Haiku Did
[Summary from report]

### Files Modified
- path/to/file.ext (N lines) - [change description]

### My Quick Check
[Your validation - does it look right?]

---

**Status:** ✅ Complete / ⚠️ Needs adjustment

Report: ~/.claude/agent_comms/gummy/[task-id]-task-report.md
```

## Examples

### Good Use Case
```
/gummy-task "Add input validation to the email field in forms/SignupForm.tsx - check for valid email format using regex, show error message if invalid"
```

### Bad Use Case (should use /gummy-plan)
```
/gummy-task "Build a new authentication system with JWT tokens, refresh tokens, and role-based access control"
```
^ Too complex! Use `/gummy-plan` for this.

## Key Principles

- **You control complexity** - Only use for simple tasks
- **You provide context** - Give Haiku what it needs
- **Fast execution** - No planning overhead
- **Quick review** - Less thorough than plan/execute
- **Works from any directory** - Launcher uses fixed ~/.claude/ paths

## Safety Notes

- This bypasses the planning/approval workflow
- Main Claude is responsible for ensuring task is appropriate
- If Haiku reports the task is more complex than expected, escalate to `/gummy-plan`
- Review results before accepting - fast doesn't mean careless
