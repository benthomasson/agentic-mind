# agentic-mind

Expert agent starter kit. Fork this repo to build an AI agent that accumulates domain knowledge, tracks what it knows, and persists across sessions.

## Quick Start

```bash
# Fork this repo, then:
git clone https://github.com/YOUR_ORG/agentic-mind my-expert-agent
cd my-expert-agent

# Install core tools
make setup

# Append compact instructions to your global Claude config
cat CLAUDE.md >> ~/.claude/CLAUDE.md
```

Then open Claude Code in the repo and start working. The agent will use entries, beliefs, and checkpoints automatically.

## Plugin Marketplace

agentic-mind includes a marketplace of optional plugins. Install only what you need:

```bash
# Add the marketplace (one-time)
/plugin marketplace add YOUR_ORG/agentic-mind

# Browse available plugins
/plugin

# Install individual plugins
/plugin install slacker@agentic-mind
/plugin install jirahhh@agentic-mind
/plugin install gcalcli@agentic-mind
```

### Available Plugins

#### Core (included with `make setup`)

| Plugin | Command | Description |
|--------|---------|-------------|
| **[entry](https://github.com/benthomasson/entry)** | `/entry:create` | Chronologically organized documentation entries |
| **[beliefs](https://github.com/benthomasson/beliefs)** | `/beliefs:manage` | Belief registry with staleness detection and contradiction tracking |
| **[checkpoint](https://github.com/benthomasson/checkpoint)** | `/checkpoint:manage` | Working state snapshots that survive context compaction |

#### Knowledge Management

| Plugin | Command | Description |
|--------|---------|-------------|
| **shared-enterprise** | `/shared-enterprise:manage` | Index markdown into SQLite for structured retrieval |

#### Communication

| Plugin | Command | Description |
|--------|---------|-------------|
| **slacker** | `/slacker:manage` | Slack reminders, DMs, activity, search |
| **jirahhh** | `/jirahhh:manage` | Create, update, view, and search Jira issues |
| **gcalcli** | `/gcalcli:manage` | Google Calendar agenda, events, reminders |
| **gcmd** | `/gcmd:manage` | Export Google Drive docs, sheets, meeting notes |
| **update-slack** | `/update-slack:update` | Monitor Slack channels and create summary entries |

#### Meetings

| Plugin | Command | Description |
|--------|---------|-------------|
| **meeting-prep** | `/meeting-prep:prep` | Gather context for upcoming meetings |
| **meeting-notes** | `/meeting-notes:capture` | Capture meeting notes from the last 24 hours |

#### Web

| Plugin | Command | Description |
|--------|---------|-------------|
| **browser-fetch** | `/browser-fetch:manage` | Fetch SSO/authenticated web content via browser |
| **curl** | `/curl:fetch` | Fast web fetching with curl |

## Core Tools

The three core tools solve fundamental LLM limitations:

- **entry** imposes time ordering that the model can't track internally
- **beliefs** tracks what is known and why, detects when it goes stale
- **checkpoint** preserves working state across the compaction boundary

### How They Work Together

```
Explore a domain
    → Write entries (entries/YYYY/MM/DD/)
    → Distill beliefs from entries (beliefs.md)
    → Track contradictions as nogoods (nogoods.md)
    → Save working state (checkpoint)
    → Repeat
```

Each tool has a different scope:

- `entry` is for *recording* — immutable, time-ordered, append-only
- `beliefs` is for *tracking* — mutable, reconcilable, queryable
- `checkpoint` is for *resuming* — ephemeral, session-scoped, overwritten each time

They compose but don't overlap. You can use any one without the others.

## Building an Expert Agent

To build an expert agent for your domain:

1. **Fork this repo** and rename it (e.g., `rhel-expert`, `aws-expert`, `my-team-knowledge`)
2. **Run `make setup`** to install core tools
3. **Edit CLAUDE.md** with your domain context
4. **Start exploring** — open Claude Code and start working in your domain
5. **Write entries** as you learn things
6. **Distill beliefs** from your entries
7. **Track nogoods** when you discover what doesn't work
8. **Install plugins** for the integrations you need

The agent gets more expert over time as entries, beliefs, and nogoods accumulate.

## What This Is Not

This is not a chatbot. It's an expert agent that:
- Has accumulated, structured knowledge with source tracking
- Knows what it knows and what it doesn't (via beliefs and nogoods)
- Tracks contradictions between sources
- Gets more capable over time
- Shares context across sessions and team members

## Multi-Agent Support

Works with multiple AI tools:

| | Claude Code | Gemini CLI |
|---|---|---|
| Skills location | `.claude/skills/` (per project) | `~/.gemini/skills/` (global) |
| Install command | `make setup` | `make setup-gemini` |
| Compact instructions | `cat CLAUDE.md >> ~/.claude/CLAUDE.md` | `cat CLAUDE.md >> ~/.gemini/GEMINI.md` |

## Creating Your Own Plugins

Add a plugin to the marketplace:

```
plugins/my-plugin/
├── .claude-plugin/
│   └── plugin.json        # name, description, version
└── commands/
    └── my-command.md       # instructions for Claude
```

Register it in `.claude-plugin/marketplace.json` and it becomes installable via `/plugin install`.
