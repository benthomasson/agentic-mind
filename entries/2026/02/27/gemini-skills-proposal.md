# Gemini Skills Proposal

**Date:** 2026-02-27
**Topic:** Gemini, Skills, Portability, agentic-mind

## What We Know

During an Anthropic API outage, the agentic-mind infrastructure (entry, beliefs, checkpoint) was used with Gemini CLI. Findings:

- The markdown files (`entries/`, `beliefs.md`, `nogoods.md`, `checkpoint.md`) worked without changes — they are just files
- The skill instructions worked once loaded — the content is model-agnostic
- Gemini does not auto-discover `.claude/skills/*/SKILL.md` like Claude Code does
- The `allowed-tools` frontmatter in skill files is Claude Code-specific

## The Gap

Claude Code injects skill files automatically. Gemini needs to be told where they are.

## Proposed Solution

Add a `gemini.md` to the repo (Gemini's equivalent of `CLAUDE.md`) with:

1. The same compact instructions as `CLAUDE.md`
2. An explicit skills section pointing to the skill files

```markdown
## Skills

Skills are in `.claude/skills/`. Read the relevant skill file before using any of these tools.

Available skills:
- `.claude/skills/checkpoint/SKILL.md` — working state snapshots that survive context boundaries
- `.claude/skills/entry/SKILL.md` — chronological documentation entries at `entries/YYYY/MM/DD/`
- `.claude/skills/beliefs/SKILL.md` — belief registry with staleness detection and contradiction tracking

Note: skill files contain YAML frontmatter between `---` markers at the top.
This is Claude Code-specific configuration — ignore it and read the rest of the file.
```

## Questions to Verify with Gemini

1. Does `gemini.md` auto-load as a system prompt the same way `CLAUDE.md` does for Claude Code?
2. Does Gemini ignore unknown YAML frontmatter, or does it need to be stripped?
3. Does Gemini have a compaction/summarization step where compact instructions would apply?
4. After loading a skill file, does Gemini follow tool invocation instructions (e.g. "run `checkpoint load`") without further prompting?

## Next Step

Test this in a live Gemini session. Ask Gemini to read this entry and confirm or correct the proposal.
