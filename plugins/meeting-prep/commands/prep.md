---
name: meeting-prep
description: Prepare context for upcoming meetings (next 24 hours) from Google Docs, Slack, and Jira
user_invocable: true
---

# Meeting Prep Skill

Gathers context for upcoming meetings from multiple sources (Google Docs, Slack, Jira) and creates context entries to help prepare for the day.

## When to Use This Skill

Use this skill when:
- User asks to prepare for upcoming meetings
- User says "prep meetings", "meeting prep", or "prepare for today"
- User wants context for tomorrow's meetings
- Morning routine to load context for the day
- User asks "what do I need to know for my meetings?"

## Workflow Overview

1. **Get upcoming meetings** from the next 24 hours using gcalcli
2. **Gather context** for each meeting from Google Docs, Slack, and Jira
3. **Create context entries** for each meeting with relevant background
4. **Create day context entry** summarizing all meetings and key prep items

## Step 1: Get Upcoming Meetings

Use gcalcli to list meetings for the next 24 hours:

```bash
# Get today and tomorrow's meetings
uvx --from "/Users/ben/git/gcalcli" gcalcli --nocolor agenda "now" "tomorrow 11:59pm"

# For more details (attendees, location, description)
uvx --from "/Users/ben/git/gcalcli" gcalcli --nocolor agenda "now" "tomorrow 11:59pm" --details all
```

Extract from each meeting:
- Meeting title
- Start/end time
- Attendees
- Description/agenda (often contains links to docs, Jira issues)
- Video conference link

## Step 2: Gather Context from Google Docs

For each meeting, search for related documents:

```bash
# Search for meeting-specific docs (agenda, notes from previous meetings)
uvx --from "git+https://github.com/shanemcd/gcmd" gcmd list -q "MEETING_TITLE" -t docs -n 10

# Search for attendee-related docs
uvx --from "git+https://github.com/shanemcd/gcmd" gcmd list -q "ATTENDEE_NAME" -t docs -n 5

# Check for previous meeting notes
uvx --from "git+https://github.com/shanemcd/gcmd" gcmd list -q "Notes from MEETING_TITLE" -t docs -n 5

# Export relevant docs
uvx --from "git+https://github.com/shanemcd/gcmd" gcmd export "FILE_ID" -o /tmp/
```

**What to look for:**
- Meeting agenda (if shared ahead of time)
- Previous meeting notes (for recurring meetings)
- Related project documents mentioned in calendar description
- Shared docs from attendees

**Extract from docs:**
- Agenda items
- Previous action items (check if completed)
- Discussion topics
- Relevant context/background

## Step 3: Gather Context from Slack

Search Slack for relevant discussions:

```bash
# Search for meeting-related discussions
uvx --from "git+https://github.com/shanemcd/slacker" slacker -o json api --workspace search.messages \
  --params '{"query": "MEETING_TITLE after:YYYY-MM-DD", "count": 20}'

# Search for attendee mentions
uvx --from "git+https://github.com/shanemcd/slacker" slacker -o json api --workspace search.messages \
  --params '{"query": "from:@ATTENDEE recent", "count": 10}'

# Search project/topic channels
uvx --from "git+https://github.com/shanemcd/slacker" slacker -o json api --workspace search.messages \
  --params '{"query": "in:#CHANNEL_NAME TOPIC after:YYYY-MM-DD", "count": 20}'
```

**What to look for:**
- Recent discussions about meeting topics
- Questions or issues raised by attendees
- Decisions made since last meeting
- Action items mentioned

**Extract:**
- Key discussion points with permalinks
- Unresolved questions
- Recent updates on relevant topics

## Step 4: Gather Context from Jira

Search Jira for related issues:

```bash
# Search for issues mentioned in meeting description
uvx --from "git+https://github.com/shanemcd/jirahhh" jirahhh search "PROJECT-123"

# Search for issues assigned to attendees
uvx --from "git+https://github.com/shanemcd/jirahhh" jirahhh search "assignee = attendee@redhat.com AND updated >= -7d"

# Search for project-related issues
uvx --from "git+https://github.com/shanemcd/jirahhh" jirahhh search "project = PROJECT AND updated >= -7d ORDER BY updated DESC"

# Get issue details
uvx --from "git+https://github.com/shanemcd/jirahhh" jirahhh issue AAP-12345
```

**What to look for:**
- Issues mentioned in calendar description
- Recent activity on relevant projects
- Blockers or high-priority items
- Issues assigned to meeting attendees

**Extract:**
- Issue key, summary, status
- Recent comments or updates
- Blockers that might need discussion

## Step 5: Create Meeting Context Entries

For each meeting with gathered context, create an entry:

```bash
./new_entry prep-MEETING-SLUG "Prep: MEETING TITLE"
```

### Meeting Context Entry Structure

```markdown
# Prep: [Meeting Title]

**Date:** YYYY-MM-DD
**Time:** HH:MM - HH:MM
**Attendees:** [list]
**Video:** [link if available]

## Meeting Purpose

Brief description of meeting purpose/recurring cadence.

## Agenda

- [ ] Topic 1
- [ ] Topic 2
- [ ] Topic 3

## Context from Previous Meeting

**Last meeting:** [link to previous notes]

### Outstanding Action Items
- [ ] Action 1 (@owner) - status
- [ ] Action 2 (@owner) - status

### Decisions Made
- Decision 1
- Decision 2

## Recent Slack Discussions

### [Topic](permalink)
Summary of relevant discussion...

### [Another Topic](permalink)
Summary...

## Related Jira Issues

| Issue | Summary | Status | Updated |
|-------|---------|--------|---------|
| [AAP-123](url) | Issue summary | In Progress | 2026-02-19 |
| [AAP-456](url) | Another issue | Blocked | 2026-02-18 |

## Key Documents

- [Agenda Doc](url) - Meeting agenda
- [Project Doc](url) - Related project documentation

## Prep Notes

Things to prepare before meeting:
- [ ] Review X
- [ ] Prepare update on Y
- [ ] Questions to raise: Z

## Related

- [Previous meeting entry](relative-path)
```

## Step 6: Create Day Context Entry

After processing all meetings, create a summary entry:

```bash
./new_entry day-context "Day Context: YYYY-MM-DD"
```

### Day Context Entry Structure

```markdown
# Day Context: YYYY-MM-DD

**Generated:** HH:MM
**Meetings:** X meetings scheduled

## Today's Schedule

| Time | Meeting | Prep Entry |
|------|---------|------------|
| 09:00 | [Meeting 1](prep-meeting-1.md) | Ready |
| 11:00 | [Meeting 2](prep-meeting-2.md) | Ready |
| 14:00 | [Meeting 3](prep-meeting-3.md) | Needs review |

## Priority Prep Items

### Must Review Before Meetings
- [ ] Review [doc](url) before Meeting 1
- [ ] Check status of AAP-123 before Meeting 2
- [ ] Prepare update on X for Meeting 3

### Open Questions to Address
- Question from Meeting 1 context
- Blocker to discuss in Meeting 2

## Cross-Meeting Themes

Topics appearing in multiple meetings:
- Theme 1 (Meeting 1, Meeting 3)
- Theme 2 (Meeting 2)

## Key People Today

| Person | Meetings | Context |
|--------|----------|---------|
| @person1 | Meeting 1, 2 | Working on X |
| @person2 | Meeting 3 | Blocked on Y |

## Active Jira Items

Issues relevant across today's meetings:

| Issue | Summary | Status | Relevant To |
|-------|---------|--------|-------------|
| [AAP-123](url) | Issue 1 | In Progress | Meeting 1, 2 |
| [AAP-456](url) | Issue 2 | Blocked | Meeting 3 |

## Quick Reference

### Important Links
- [Project Dashboard](url)
- [Team Slack Channel](url)
- [Sprint Board](url)

### Key Contacts
- @person1 - Role/context
- @person2 - Role/context

## Related

- Individual prep entries linked above
- [Yesterday's day context](../18/day-context.md)
```

## Example Workflow

```bash
# 1. Get upcoming meetings
uvx --from "/Users/ben/git/gcalcli" gcalcli --nocolor agenda "now" "tomorrow 11:59pm" --details all

# Output:
# Thu Feb 20  09:00 - 09:30  1:1 with Manager
#   Attendees: manager@redhat.com
#   Video: https://meet.google.com/xxx
# Thu Feb 20  11:00 - 12:00  Project Analyze Sync
#   Attendees: team@redhat.com
#   Description: Discuss AAP-12345, review progress

# 2. For each meeting, gather context
# Meeting 1: 1:1 with Manager
uvx --from "git+https://github.com/shanemcd/gcmd" gcmd list -q "1:1 Manager" -t docs -n 5
uvx --from "git+https://github.com/shanemcd/slacker" slacker -o json api --workspace search.messages \
  --params '{"query": "from:@manager after:2026-02-13", "count": 10}'

# Meeting 2: Project Analyze Sync
uvx --from "git+https://github.com/shanemcd/gcmd" gcmd list -q "Project Analyze" -t docs -n 10
uvx --from "git+https://github.com/shanemcd/jirahhh" jirahhh issue AAP-12345
uvx --from "git+https://github.com/shanemcd/slacker" slacker -o json api --workspace search.messages \
  --params '{"query": "in:#wg-project-analyze after:2026-02-17", "count": 20}'

# 3. Create prep entries
./new_entry prep-1on1-manager "Prep: 1:1 with Manager"
./new_entry prep-project-analyze "Prep: Project Analyze Sync"

# 4. Create day context
./new_entry day-context "Day Context: 2026-02-20"
```

## Context Gathering Strategies

### For 1:1 Meetings
- Check previous 1:1 notes for outstanding items
- Review your recent work to share updates
- Check Jira for your recent activity
- Prepare questions/topics to discuss

### For Team Standups
- Check team Slack channel for recent updates
- Review sprint board status
- Identify blockers to raise

### For Project Meetings
- Review project documentation
- Check related Jira epics/issues
- Search Slack for recent project discussions
- Review previous meeting notes

### For External/Customer Meetings
- Review customer context docs
- Check recent support tickets
- Prepare demo/presentation materials

## Tips

1. **Run morning routine**: Best run first thing in the morning or evening before
2. **Prioritize high-stakes meetings**: Gather more context for important meetings
3. **Use calendar description**: Often contains links to relevant docs/issues
4. **Check attendee context**: Review recent activity from key attendees
5. **Link entries**: Always link prep entries in day context
6. **Update after meetings**: Convert prep entries to meeting notes entries

## Handling Edge Cases

### No Context Found
- Note in prep entry that no prior context exists
- Focus on meeting purpose and expected outcomes
- List questions to establish context during meeting

### Recurring Meetings
- Always link to previous meeting notes
- Track action items across meetings
- Note patterns or recurring themes

### Back-to-Back Meetings
- Prioritize prep for most important meetings
- Note time constraints in day context
- Identify any prep that can be done between meetings

## Related Skills

- **gcalcli** - Gets calendar events
- **gcmd** - Exports Google Docs
- **slacker** - Searches Slack messages
- **jirahhh** - Searches Jira issues
- **meeting-notes** - Captures notes after meetings
- **new_entry** - Creates dated entries

---

*Last updated: 2026-02-19*
