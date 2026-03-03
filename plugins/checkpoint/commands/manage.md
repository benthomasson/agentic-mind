---
name: checkpoint
description: Save and restore working state across context boundaries — task, files read, plan, next step
argument-hint: "[load|clear|init|install-skill]"
allowed-tools: Bash(checkpoint *), Bash(./checkpoint *), Bash(uvx *checkpoint*), Read, Write, Edit
---

You are managing a working-state checkpoint at `.claude/checkpoint.md`. A checkpoint captures what the current session is doing so the next session can pick up without re-orientation.

## How to Run

Try these in order until one works:
1. `checkpoint $ARGUMENTS` (if installed via uv/pip)
2. `uvx --from git+https://github.com/benthomasson/checkpoint checkpoint $ARGUMENTS` (fallback)

## When to Save

**Save a checkpoint proactively** when you notice:
- The conversation is getting long and context compaction may be approaching
- You are finishing a major step and about to start a new one
- The user says "I need to stop for now" or similar
- You are about to do something that might take a long time

**The human should not have to ask.** If you sense the context window filling up, save a checkpoint before compaction destroys the working state.

## How to Save

Write `.claude/checkpoint.md` directly using the Write tool. Do NOT run `checkpoint save` — there is no save command. You write the file yourself.

Format:

```markdown
# Checkpoint

**Saved:** YYYY-MM-DD HH:MM
**Project:** /absolute/path/to/project

## Task

One or two sentences: what are we working on?

## Status

What has been completed this session. What is currently in progress.
- [x] Completed step
- [ ] In-progress step

## Key Files

Files read this session and what mattered about each one.
- `path/to/file` — what it contains / what we learned

## Commands

Key commands run this session that the next session should know about.
```bash
# example
uv tool install --reinstall git+https://github.com/benthomasson/beliefs
beliefs add-nogood --description "..." --resolution "..."
```

## Next Step

The single most important next action. Be specific enough that a cold session can start immediately.

## Context

Decisions made and why. Warnings. Anything the next session needs to know that isn't obvious from the files.
```

**Be specific.** "Working on beliefs tool" is not useful. "Adding `add-nogood` subcommand to `/Users/ben/git/beliefs/beliefs_lib/cli.py` — cmd_add_nogood written, subparser added, need to update SKILL.md then commit" is useful.

## How to Load

Run `checkpoint load` — it displays the checkpoint with its age.

When starting a fresh session and a checkpoint exists, read it immediately and use it to orient. It tells you exactly what to do next without re-reading everything from scratch.

If the checkpoint is more than a few hours old, mention the age to the user — it may be stale.

## Subcommand Behavior

### `load`
Run `checkpoint load`. It finds the nearest `.claude/checkpoint.md` (searching upward from cwd) and displays it with its age. Read it and use it to restore working state.

### `clear`
Run `checkpoint clear`. Deletes the checkpoint. Use after a task is fully complete.

### `init`
Run `checkpoint init` to create a blank checkpoint template at `.claude/checkpoint.md`. Use `--force` to overwrite an existing one. Prefer writing the file directly with the Write tool unless you want the template.

### `install-skill`
Run `checkpoint install-skill` to install this skill to `.claude/skills/checkpoint/SKILL.md`.

## After Saving

Tell the user: "Checkpoint saved. The next session can run `checkpoint load` to restore working state."

## After Loading

Summarize the checkpoint in one sentence and state what you're about to do next. Don't re-read every file mentioned in the checkpoint unless needed — the checkpoint summary should be enough to proceed.
