---
description: Multi-agent orchestration - Sonnet plans, Haiku executes, Main Claude reviews
---

## What This Does

Orchestrates a three-agent workflow for complex tasks:
1. **Main Claude (you)** - Builds comprehensive context and instructions
2. **Sonnet Planner** - Creates detailed execution plan with discovery phase
3. **Haiku Executor** - Fast implementation of the plan
4. **Main Claude Reviews** - Validates work and ensures instructions were followed

All agents run as background `claude -p` processes with real-time monitoring.

## Usage

```bash
/gummy "Your task description"
```

## How It Works

1. **Context Building** - I analyze your project and create planning instructions
2. **Sonnet Plans** - Spawns Sonnet agent to perform discovery and create detailed plan
3. **Haiku Executes** - Spawns Haiku agent (resumes from Sonnet's context) to implement
4. **I Review** - Read all reports and validate the work meets requirements
5. **Real-time Monitoring** - You can watch both agents work in separate terminals

## Instructions for Claude

When the user invokes `/gummy "task description"`, follow these steps:

### Step 1: Build Planning Instruction for Sonnet

Using your CURRENT context about the project, create a comprehensive planning instruction:

```markdown
## Planning Task: [task-description]

### Your Role
You are the PLANNER agent. Your job is to investigate, discover, and create a detailed execution plan. You will NOT implement the changes - a Haiku agent will execute your plan.

### Context from Main Claude
- Project: [what you know about this project]
- Current state: [relevant files, recent changes]
- Architecture: [patterns you've observed]
- Key considerations: [important constraints or requirements]

### Documentation to Read FIRST
Before planning, read these files to understand patterns and conventions:
1. CLAUDE.md - [key points about project]
2. docs/[relevant-doc].md - [why this matters]
3. [other-relevant-files] - [context they provide]

### Phase 0: Discovery (DO THIS FIRST - DO NOT SKIP)

Investigate thoroughly before creating the plan:
1. [Specific files/patterns to search for]
2. [Baseline to establish - e.g., "run existing tests"]
3. [Dependencies to verify - e.g., "check package versions"]
4. [Current implementation to understand]
5. [Related code that might be affected]

**STOP and document ALL findings before proceeding to planning**

Document your discoveries in:
.claude/agent_comms/gummy/[task-id]-discoveries.md

Include:
- What you found
- Current implementation details
- Potential issues or conflicts
- Dependencies that matter
- Test coverage status

### Phase 1: Create Detailed Execution Plan

Based on your discoveries, create an execution plan with:

1. **Atomic phases** - Break work into smallest possible steps
2. **Validation checkpoints** - After each phase, how to verify it worked
3. **Error recovery** - For each phase, what could go wrong and how to fix
4. **File-by-file changes** - Specific files and what changes each needs
5. **Test strategy** - What tests to run when

Each phase should follow this format:
```
#### Phase N: [Specific action]
- What: [Exact change to make]
- Why: [Reason based on discoveries]
- Files: [Specific files to modify]
- Validation: [Command to verify - e.g., "npm test AuthService"]
- Rollback: [How to undo if it fails]
```

### Phase 2: Document the Plan

Create your execution plan at:
.claude/agent_comms/gummy/[task-id]-plan.md

Structure:
```markdown
# Execution Plan: [task-description]

## Discovery Summary
[Key findings from Phase 0]

## Implementation Phases
[Detailed phase-by-phase plan]

## Error Recovery Playbook
**If [specific error]**: [Specific fix]
**If [another error]**: [Specific fix]

## Success Criteria (ALL must pass)
- [ ] [Specific, testable criterion with command]
- [ ] [Another criterion]
- [ ] [Final validation]

## Backward Compatibility
- [What must remain unchanged]
- [Verification command]

## Testing Strategy
- [What to test]
- [How to test]
- [When to test]
```

### Phase 3: Final Planner Report

Create a report at:
.claude/agent_comms/gummy/[task-id]-planner-report.md

Include:
- Summary of discoveries
- Confidence level in the plan
- Potential risks identified
- Estimated complexity
- Any areas that need human review
- Why you structured the plan this way
```

### Step 1.5: Build Executor Instruction Template

Also build the executor instruction (the launcher will pass this after planner completes):

```markdown
## Execution Task: [task-description]

### Your Role
You are the EXECUTOR agent. A Sonnet planner has already investigated and created a detailed plan. Your job is to implement the plan EXACTLY as specified.

### Context from Main Claude
[Repeat the same context you gave to planner - project, current state, architecture]

### Execution Guidelines

1. **Read the plan first**: .claude/agent_comms/gummy/[task-id]-plan.md
2. **Follow the plan phases IN ORDER**
3. **Run validation checkpoints** after each phase
4. **Stop immediately if validation fails** - document the failure
5. **Use the error recovery playbook** if you encounter known errors
6. **Do NOT improvise** - if plan is unclear, document it and stop
7. **Run all success criteria** at the end

### Validation is CRITICAL
After EVERY phase, you MUST run the validation command specified in the plan.
If validation fails, stop and document:
- What phase failed
- What the validation command showed
- What you think went wrong

### Final Executor Report

Create a report at:
.claude/agent_comms/gummy/[task-id]-executor-report.md

Include:
- Which phases completed successfully
- All files you created or modified (with line counts)
- Any validation failures encountered
- How you resolved any errors
- Results of all success criteria checks
- Whether task is 100% complete or has remaining work
```

### Step 2: Write Instructions to Temporary Files and Launch

Generate unique task ID using timestamp format: gummy-[unix-timestamp]

Write the planning instruction to a temporary file:
- /tmp/gummy-[task-id]-planner-instruction.txt

Write the executor instruction to a temporary file:
- /tmp/gummy-[task-id]-executor-instruction.txt

Launch the orchestrator:
```bash
./bin/gummy /tmp/gummy-[task-id]-planner-instruction.txt /tmp/gummy-[task-id]-executor-instruction.txt [task-id]
```

The launcher will:
- Spawn planner, wait for completion
- Extract session ID
- Spawn executor with --resume
- Wait for completion
- Report paths to all generated reports

### Step 3: Wait for Launcher to Complete

The launcher runs synchronously and will exit when both agents complete.

Once launcher completes, read the reports:
1. Read .claude/agent_comms/gummy/[task-id]-discoveries.md
2. Read .claude/agent_comms/gummy/[task-id]-plan.md
3. Read .claude/agent_comms/gummy/[task-id]-planner-report.md
4. Read .claude/agent_comms/gummy/[task-id]-executor-report.md

### Step 4: Main Claude Review

Now YOU (main Claude) review the complete work:

1. **Read all agent reports**:
   - Planner discoveries
   - Execution plan
   - Planner report
   - Executor report

2. **Verify success criteria**:
   - Check if executor ran all success criteria from plan
   - Re-run key validation commands yourself if needed
   - Verify files were modified as planned

3. **Check for instruction adherence**:
   - Did executor follow the plan?
   - Were validation checkpoints run?
   - Were errors handled correctly?
   - Is work complete or partial?

4. **Create review report** at:
   .claude/agent_comms/gummy/[task-id]-review.md

   Include:
   ```markdown
   # Main Claude Review: [task-description]

   ## Overall Assessment
   [Complete/Partial/Failed]

   ## What Was Accomplished
   [Summary of completed work]

   ## Success Criteria Results
   - [Criterion 1]: [PASS/FAIL] - [Evidence]
   - [Criterion 2]: [PASS/FAIL] - [Evidence]

   ## Instruction Adherence
   [Did agents follow instructions? Any deviations?]

   ## Files Modified
   [List with line counts and purpose]

   ## Issues Found
   [Any problems in the implementation]

   ## Remaining Work
   [What still needs to be done, if anything]

   ## Recommendation
   [Accept/Needs fixes/Needs human review]
   ```

5. **Inform user**:
   - Show them your review summary
   - Highlight any issues found
   - Provide next steps if work is incomplete
   - Show paths to all reports for their reference

## Example Session Flow

User: `/gummy "Add retry logic to API client"`

Main Claude:
```
I'll orchestrate a three-agent workflow to add retry logic to the API client.

=== PHASE 1: SONNET PLANNING ===

Spawned Sonnet planner (PID: 12345, Task ID: gummy-1734567890)

I've instructed the planner to:
- Investigate current API client implementation
- Review error handling patterns in docs/
- Identify all network call sites
- Create detailed implementation plan with validation checkpoints

Monitor planner: tail -f logs/gummy/gummy-1734567890-planner.log | jq -r 'select(.type=="text") | .text'

[Planner is discovering current implementation...]

[... wait for planner completion ...]

=== PLANNER COMPLETED ===

The planner discovered:
- 5 API client methods that need retry logic
- Existing exponential backoff utility in utils/
- 23 tests that will need updates
- Backward compatibility requirement: existing retry behavior must be preserved

The plan includes 7 atomic phases with validation after each phase.

=== PHASE 2: HAIKU EXECUTION ===

Spawned Haiku executor (PID: 12346, resuming from planner context)

I've instructed the executor to:
- Follow the planner's 7-phase implementation plan exactly
- Run validation checkpoints after each phase
- Use error recovery playbook if issues occur

Monitor executor: tail -f logs/gummy/gummy-1734567890-executor.log | jq -r 'select(.type=="text") | .text'

[Executor is implementing Phase 1...]

[... wait for executor completion ...]

=== EXECUTOR COMPLETED ===

The executor reports:
- All 7 phases completed successfully
- Modified 8 files (247 lines changed)
- All validation checkpoints passed
- All tests passing (23 updated, 12 new)

=== PHASE 3: MY REVIEW ===

[Reading all reports and verifying work...]

Review complete! Here's my assessment:

✅ Task completed successfully
✅ All success criteria passed
✅ Agents followed instructions precisely
✅ No issues found in implementation

Files modified:
- src/api/client.ts (89 lines) - Added retry logic
- src/utils/retry.ts (45 lines) - Enhanced backoff utility
- tests/api/client.test.ts (78 lines) - Updated tests
[... 5 more files ...]

Full reports available at:
- .claude/agent_comms/gummy/gummy-1734567890-plan.md
- .claude/agent_comms/gummy/gummy-1734567890-executor-report.md
- .claude/agent_comms/gummy/gummy-1734567890-review.md

Recommendation: Accept this implementation ✅
```

## Key Principles

- **No turn limits** - Agents finish when the work is done, naturally
- **Sonnet for reasoning** - Better at planning and discovery
- **Haiku for speed** - Fast implementation, matches Sonnet 4 coding ability
- **Context continuity** - --resume chains planner discoveries to executor
- **Human visibility** - Real-time monitoring and comprehensive reports
- **Validation checkpoints** - Catch issues early
- **Main Claude oversight** - Final review ensures quality
