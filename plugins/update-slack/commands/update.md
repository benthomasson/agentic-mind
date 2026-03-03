---
name: update-slack
description: Fetch new Slack messages from monitored channels and create an entry
user_invocable: true
---

# Update Slack Skill

Fetches new messages from channels listed in `channels.md` and creates a dated entry summarizing the activity.

## When to Use This Skill

Use this skill when:
- User asks to check Slack channels for updates
- User wants to capture recent Slack activity as an entry
- User says "update slack" or "check channels"
- Daily/periodic knowledge capture from team channels

## Workflow

### Step 1: Read channels.md

Read `channels.md` from the repository root to get the list of channels to monitor.

```bash
cat channels.md
```

Extract channel names from the markdown table (e.g., `#wg-project-analyze`).

### Step 2: Fetch Messages from Each Channel

For each channel, fetch recent messages using slacker:

```bash
# Get today's messages (default)
uvx --from "git+https://github.com/shanemcd/slacker" slacker -o json api --workspace search.messages \
  --params '{"query": "in:#CHANNEL_NAME today", "count": 50}'

# Or get messages since a specific date
uvx --from "git+https://github.com/shanemcd/slacker" slacker -o json api --workspace search.messages \
  --params '{"query": "in:#CHANNEL_NAME after:YYYY-MM-DD", "count": 50}'
```

Parse the JSON response to extract:
- `username` - Who posted
- `text` - Message content
- `ts` - Timestamp
- `permalink` - Link to message

### Step 3: Create Entry Using new_entry

**IMPORTANT:** Always use the `./new_entry` script to create entries (see `new_entry` skill for details).

```bash
# Create dated entry - automatically places in entries/YYYY/MM/DD/
./new_entry slack-update "Slack Channel Update"
```

This creates: `entries/2026/02/18/slack-update.md` with the standard template.

### Step 4: Write Entry Content

Write the entry with the following structure. **Include the permalink for each message** so readers can click through to the original Slack thread:

```markdown
# Slack Channel Update

**Date:** YYYY-MM-DD
**Time:** HH:MM

## Overview

Summary of activity across monitored channels.

## #channel-name

### [@username (HH:MM)](permalink-url)
Message content here

### [@another-user (HH:MM)](permalink-url)
Another message

## #another-channel

...

## Key Topics

- Topic 1 discussed
- Topic 2 mentioned
- Decisions made

## Action Items

- [ ] Any action items mentioned
- [ ] Follow-ups needed

## Related

- Link to previous slack updates
- Related entries
```

## Example Output

```markdown
# Slack Channel Update

**Date:** 2026-02-18
**Time:** 14:30

## Overview

3 messages in #wg-project-analyze discussing latency issues and model performance.

## #wg-project-analyze

### [@kaixu (10:15)](https://redhat-internal.slack.com/archives/C0AF9FBN5NX/p1771344347884989)
is the 429 error persistent? like if you run ./analyze again does it always error out like this?

### [@jboyer (10:18)](https://redhat-internal.slack.com/archives/C0AF9FBN5NX/p1771344527012345)
i mean... a model literally not responding because it can't handle the load will definitely increase latency

### [@kaixu (10:20)](https://redhat-internal.slack.com/archives/C0AF9FBN5NX/p1771344647098765)
can we do a quick distributional comparison in terms of latency on the 36 samples?

## Key Topics

- 429 rate limiting errors from model API
- Latency analysis on 36 sample queries
- Model load handling

## Action Items

- [ ] Run distributional comparison on latency samples (@gxxu)
```

## Tips

1. **Date filtering**: Use `today`, `yesterday`, or `after:YYYY-MM-DD` in search queries
2. **Multiple channels**: Process each channel separately and combine into one entry
3. **Thread context**: For threaded replies, note the parent message context
4. **Summarize**: Don't just dump messages - summarize key topics and action items
5. **Skip bots**: Filter out bot messages (giphy, etc.) unless relevant

## Error Handling

If a channel returns no messages:
- Note "No new messages" for that channel
- Still include the channel section for completeness

If search fails with `enterprise_is_restricted`:
- Try alternative query format
- Note the restriction in the entry

## Related Skills

- **new_entry** - Creates the dated entry files (required)
- **slacker** - Underlying Slack API access
