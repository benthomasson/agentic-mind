# Agents Switch Directories and Write to the Wrong Repo

**Date:** 2026-02-27
**Topic:** Failure Mode, entry, beliefs, cwd, Multi-Agent Research

## The Problem

`entry` and `beliefs` are cwd-relative. They write to whatever directory the agent is currently in.

Agents — both Claude and Gemini — switch directories frequently during a session: to run simulations, check code, inspect files in other repos. When they then run `entry create` or `beliefs add`, the entry or belief lands wherever they happen to be standing, not in the intended repository.

The result: entries accumulate in simulation directories, belief registries get written to the wrong repo, and the human has to find them and move them to the correct location manually.

## Why Agents Do This

Agents cd around because that's how shell tools work. Running a simulation in `physics-quantum-lattice/simulations/` requires being in or near that directory. Checking a file in another repo requires navigating there. The agent has no automatic sense of "home" — it goes where the work is, and the tools follow.

## Current Workaround

Tell the agent to move the entries to the correct repo. This works but is manual, after-the-fact, and requires the human to notice the problem.

## The Right Fix

The tools need a way to know where home is, independent of cwd. Three options:

1. **Environment variable** — `ENTRY_HOME` / `BELIEFS_HOME` overrides cwd. Set once per session, tools write there regardless of where the shell is. Low friction, no config file needed.
2. **Config file** — `.entry.toml` at the user or repo level specifies the default target directory. More explicit, survives across sessions.
3. **Explicit path flag** — skill instructions always pass `--repo /absolute/path/to/repo`. Requires no tool changes, just discipline in the instructions.

Option 1 is the lowest-friction fix. Option 3 is immediately actionable without tool changes.

## Interim Fix

Update skill files to warn about the cwd problem and instruct agents to always cd back to the home repo before writing entries or beliefs.

## Related

- `entries/2026/02/27/gemini-and-claude-have-different-personalities.md`
- `https://github.com/benthomasson/entry` — feature request: ENTRY_HOME env var
- `https://github.com/benthomasson/beliefs` — feature request: BELIEFS_HOME env var
