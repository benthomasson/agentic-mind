---
name: meeting-notes
description: Capture meeting notes and transcripts from the last 24 hours, create individual entries and a summary
user_invocable: true
---

# Meeting Notes Capture Skill

Fetches meeting notes and transcripts from Google Meet meetings in the last 24 hours, creates individual entries for each meeting, and generates a summary entry.

## When to Use This Skill

Use this skill when:
- User asks to capture meeting notes from recent meetings
- User says "meeting notes", "get my meetings", or "capture meetings"
- User wants to document what was discussed in meetings
- Daily/periodic knowledge capture from team meetings
- User asks "what did I discuss today/yesterday?"

## Workflow Overview

1. **Get meetings** from the last 24 hours using gcalcli
2. **Search for notes** for each meeting using gcmd (Gemini meeting notes, shared docs)
3. **Export notes** to /tmp/ using gcmd
4. **Create individual entries** for each meeting with ./new_entry
5. **Create summary entry** listing all meetings and key topics

## Step 1: Get Meetings from Last 24 Hours

Use gcalcli to list meetings from the last 24 hours:

```bash
# Get yesterday and today's meetings with details
uvx --from "/Users/ben/git/gcalcli" gcalcli --nocolor agenda "yesterday" "tomorrow" --detail-all

# For TSV output (easier parsing)
uvx --from "/Users/ben/git/gcalcli" gcalcli --nocolor agenda "yesterday" "tomorrow" --tsv
```

Extract from each meeting:
- Meeting title
- Start time
- Attendees (if shown)
- Description/agenda (if available)

## Step 2: Search for Meeting Notes in Google Drive

For each meeting, search for associated documents:

```bash
# Search for meeting notes by title
uvx --from "git+https://github.com/shanemcd/gcmd" gcmd list -q "MEETING_TITLE" -t docs -n 10

# Search for Gemini meeting notes (auto-generated)
uvx --from "git+https://github.com/shanemcd/gcmd" gcmd list -q "Notes from MEETING_TITLE" -t docs

# List recent docs modified today (may contain meeting notes)
uvx --from "git+https://github.com/shanemcd/gcmd" gcmd list -t docs -n 20
```

**Matching strategies:**
1. **Exact title match**: Search for the meeting title verbatim
2. **Gemini notes pattern**: Google Meet creates notes titled "Notes from [Meeting Title]"
3. **Partial match**: Try key words from the meeting title
4. **Recent documents**: Check recently modified docs during meeting time

**Capture for each found document:**
- Document title
- Document URL (from gcmd list output or construct from file ID)
- File ID (for export)

## Step 3: Export Meeting Notes

For each found document, export to /tmp/:

```bash
# Export meeting notes as markdown
uvx --from "git+https://github.com/shanemcd/gcmd" gcmd export "DOCUMENT_URL" -o /tmp/

# For multi-tab documents (less common for notes)
uvx --from "git+https://github.com/shanemcd/gcmd" gcmd export --all-tabs "DOCUMENT_URL" -o /tmp/
```

The file will be saved as `/tmp/Document Title.md`.

Read the exported file to extract:
- Meeting participants (from notes)
- Discussion topics
- Action items
- Decisions made
- Key quotes/context

## Step 4: Create Individual Meeting Entries

For each meeting with notes, create an entry:

```bash
./new_entry meeting-SLUG "Meeting: TITLE"
```

**Naming convention for SLUG:**
- Use lowercase, hyphenated version of meeting title
- Keep it short but recognizable
- Examples: `standup`, `1on1-manager`, `sprint-review`, `project-kickoff`

### Entry Structure

```markdown
# Meeting: [Title]

**Date:** YYYY-MM-DD
**Time:** HH:MM (meeting start time)
**Attendees:** [list from calendar or notes]
**Notes:** [Document Title](https://docs.google.com/document/d/FILE_ID/edit)

## Overview

Brief summary of the meeting purpose and outcome.

## Notes

[Exported meeting notes content - can be edited/summarized]

## Action Items

- [ ] Action 1 (@owner)
- [ ] Action 2 (@owner)

## Decisions

- Decision 1
- Decision 2

## Related

- [Previous meeting entry](relative-path) - If this is a recurring meeting
```

**Important:** Always include the Google Doc URL in the header metadata so readers can access the original notes.

## Step 5: Create Summary Entry

After processing all meetings, create a summary entry:

```bash
./new_entry meetings-summary "Meetings Summary"
```

### Summary Entry Structure

```markdown
# Meetings Summary

**Date:** YYYY-MM-DD
**Time:** HH:MM
**Period:** Last 24 hours

## Overview

X meetings captured with notes.

## Meetings

### [Meeting 1 Title](link-to-individual-entry) (HH:MM)
**Notes:** [Google Doc](https://docs.google.com/document/d/FILE_ID/edit)
- Key topic 1
- Key topic 2
- Action: [brief action item]

### [Meeting 2 Title](link-to-individual-entry) (HH:MM)
**Notes:** [Google Doc](https://docs.google.com/document/d/FILE_ID/edit)
- Key topic 1
- Key topic 2

### Meetings Without Notes
- [Meeting Title] (HH:MM) - No notes found

## Cross-Meeting Themes

- Theme 1 that appeared in multiple meetings
- Theme 2

## All Action Items

- [ ] Action from Meeting 1 (@owner)
- [ ] Action from Meeting 2 (@owner)

## Related

- Individual meeting entries linked above
```

## Example Workflow

```bash
# 1. Get meetings
uvx --from "/Users/ben/git/gcalcli" gcalcli --nocolor agenda "yesterday" "tomorrow" --detail-all

# Output:
# Wed Feb 19  09:00 AM - 09:30 AM  Daily Standup
# Wed Feb 19  11:00 AM - 12:00 PM  Project Analyze Sync
# Wed Feb 19  02:00 PM - 02:30 PM  1:1 with Manager

# 2. Search for notes for each
uvx --from "git+https://github.com/shanemcd/gcmd" gcmd list -q "Daily Standup" -t docs -n 5
uvx --from "git+https://github.com/shanemcd/gcmd" gcmd list -q "Notes from Daily Standup" -t docs -n 5
uvx --from "git+https://github.com/shanemcd/gcmd" gcmd list -q "Project Analyze Sync" -t docs -n 5

# 3. Export found notes
uvx --from "git+https://github.com/shanemcd/gcmd" gcmd export "https://docs.google.com/document/d/abc123/edit" -o /tmp/

# 4. Read exported notes
cat "/tmp/Notes from Daily Standup.md"

# 5. Create individual entries
./new_entry meeting-standup "Meeting: Daily Standup"
./new_entry meeting-project-analyze "Meeting: Project Analyze Sync"
./new_entry meeting-1on1 "Meeting: 1:1 with Manager"

# 6. Create summary entry
./new_entry meetings-summary "Meetings Summary"
```

## Handling Edge Cases

### No Notes Found

If no meeting notes are found for a meeting:
- Still list the meeting in the summary
- Mark as "No notes found"
- Include any calendar description/agenda if available

### Recurring Meetings

For recurring meetings (standups, 1:1s):
- Link to previous entries in the "Related" section
- Note patterns or continuity from previous meetings

### Private/Confidential Meetings

For 1:1s or sensitive meetings:
- Capture what's appropriate to document
- Focus on action items and decisions
- Skip personal discussions

### Large Meetings

For all-hands or large meetings:
- Focus on key announcements
- Capture action items that affect you/your team
- Link to official meeting recording/notes if shared

## Tips

1. **Run daily**: Best run at end of day or start of next day to capture all meetings
2. **Check Gemini notes**: Google Meet auto-generates "Notes from [Meeting]" documents
3. **Search variations**: Try meeting title, key words, and attendee names
4. **Clean up /tmp/**: Delete exported files after creating entries
5. **Link entries**: Always link individual entries in the summary
6. **Track patterns**: Note recurring themes across meetings

## Related Skills

- **gcalcli** - Gets calendar events
- **gcmd** - Exports Google Docs meeting notes
- **new_entry** - Creates dated entries

---

*Last updated: 2026-02-19*
