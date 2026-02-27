# Gemini Skills: What We Learned

**Date:** 2026-02-27
**Topic:** Gemini, Skills, Portability, agentic-mind

## What We Know

During an Anthropic API outage, the agentic-mind infrastructure (entry, beliefs, checkpoint) was used with Gemini CLI. Findings:

- The markdown files (`entries/`, `beliefs.md`, `nogoods.md`, `checkpoint.md`) worked without changes — they are just files
- The skill instructions worked once loaded — the content is model-agnostic
- The `allowed-tools` frontmatter in skill files is Claude Code-specific — Gemini ignores it

## How Gemini Loads Skills

Gemini auto-loads skills from `~/.gemini/skills/` — a global, user-level directory.

This is different from Claude Code, which loads from `.claude/skills/` at the project level. The implication:

- **Claude**: install skills per project (`entry install-skill` inside the repo)
- **Gemini**: install skills once globally (`entry install-skill --skill-dir ~/.gemini/skills`)

## Updated Setup

`make install-skills-gemini` installs all three skills to `~/.gemini/skills/`:

```bash
make install-skills-gemini
# then append compact instructions:
cat CLAUDE.md >> ~/.gemini/GEMINI.md
```

After that, Gemini has checkpoint, entry, and beliefs available in every session, everywhere — same as Claude Code does per project.

## The Gap That Remains

The compact instructions (`CLAUDE.md`) still need to be appended to `~/.gemini/GEMINI.md` manually. This is the Gemini equivalent of appending to `~/.claude/CLAUDE.md`. Both are one-time user-level setup steps.

## Summary

| | Claude Code | Gemini CLI |
|---|---|---|
| Skills location | `.claude/skills/` (per project) | `~/.gemini/skills/` (global) |
| Install command | `entry install-skill` | `entry install-skill --skill-dir ~/.gemini/skills` |
| Compact instructions | `cat CLAUDE.md >> ~/.claude/CLAUDE.md` | `cat CLAUDE.md >> ~/.gemini/GEMINI.md` |
| Frontmatter (`allowed-tools`) | Used | Ignored |

## Related

- `entries/2026/02/27/gemini-and-claude-have-different-personalities.md`
- `/Users/ben/git/physics-pi-meta/entries/2026/02/27/anthropic-outage-portability-test.md`
