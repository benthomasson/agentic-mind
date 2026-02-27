# agentic-mind

AI agent memory management starter kit. Three tools that work together to give Claude persistent memory across context boundaries.

## Tools

- **[entry](https://github.com/benthomasson/entry)** — chronologically organized documentation entries (`entries/YYYY/MM/DD/`). Encodes time structurally so models can't lose it.
- **[beliefs](https://github.com/benthomasson/beliefs)** — belief registry with justification tracking, staleness detection, and contradiction management.
- **[checkpoint](https://github.com/benthomasson/checkpoint)** — working state snapshots at `.claude/checkpoint.md`. Survives context compaction and auto-loads at session start.

## The Problem These Solve

LLMs have no internal sense of time and no mechanism for maintaining consistency across a knowledge base as beliefs change. When a context window fills and compacts, working state is lost. When a CLAUDE.md goes stale, the agent operates on outdated beliefs without knowing it.

These three tools are the application-layer solution:

1. **entry** imposes time ordering that the model can't track internally
2. **beliefs** tracks what is known and why, detects when it goes stale
3. **checkpoint** preserves working state across the compaction boundary

They emerged from a year-long multi-agent physics research program. See [entries/](entries/) for the methodology findings.

## Setup

```bash
# Install all three tools and set up skills for this project
make setup

# Then append the compact instructions to your global Claude config
cat CLAUDE.md >> ~/.claude/CLAUDE.md
```

The compact instructions tell Claude's context summarizer to preserve belief state, warnings, contradictions, and checkpoint contents across compaction — so the next session can orient immediately without re-explanation.

## How It Works

After setup, in any Claude session in this directory:

- Run `/checkpoint` to save or load working state
- Run `/entry` to create a dated entry
- Run `/beliefs` to check or update the belief registry

When the context window fills, the compact instructions preserve what matters. The next session runs `checkpoint load` and picks up where the previous one left off.

This was demonstrated in practice: a session compacted, a new Claude instance started, and it immediately ran `checkpoint load` without being asked — because the skill instructions say "the human should not have to ask."

## Why Three Separate Tools

Each tool has a different job and a different scope:

- `entry` is for *recording* — immutable, time-ordered, append-only
- `beliefs` is for *tracking* — mutable, reconcilable, queryable
- `checkpoint` is for *resuming* — ephemeral, session-scoped, overwritten each time

They compose but don't overlap. You can use any one without the others.
