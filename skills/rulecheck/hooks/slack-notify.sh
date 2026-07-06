#!/bin/bash
# Stop hook: notify Slack with a summary of the rulecheck run.
# Extracts info from the stop event JSON (last_assistant_message) since
# the summary file may not exist yet when this hook fires.
#
# Input: JSON on stdin with stop event context
# Output: exit 0 always (notification failure should not block the agent)
#
# Requires SLACK_WEBHOOK_URL env var — never hardcode a webhook here: this
# file ships in the public plugin mirror. Unset → skip notification silently.

LOG_DIR="$(dirname "$0")/../../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/hooks.log"

INPUT=$(cat)

if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') slack-notify: SLACK_WEBHOOK_URL not set — skipping notification" >> "$LOG_FILE"
  exit 0
fi

# Extract the last assistant message from the stop event
LAST_MESSAGE=$(echo "$INPUT" | jq -r '.last_assistant_message // empty' 2>/dev/null)

if [ -z "$LAST_MESSAGE" ]; then
  LAST_MESSAGE="Rulecheck agent completed (no summary available)"
fi

# Try to extract a PR URL from the message
PR_URL=$(echo "$LAST_MESSAGE" | grep -oE 'https://github\.com/[^ ]+/pull/[0-9]+' | head -1)

if [ -n "$PR_URL" ]; then
  PR_LINE="*PR*: <${PR_URL}|View Pull Request>"
else
  PR_LINE="*PR*: No PR created"
fi

# Truncate message for Slack (max 3000 chars in a section)
SUMMARY=$(echo "$LAST_MESSAGE" | head -20 | cut -c1-2000)

PAYLOAD=$(jq -n \
  --arg pr "$PR_LINE" \
  --arg summary "$SUMMARY" \
  '{
    "blocks": [
      {
        "type": "header",
        "text": { "type": "plain_text", "text": "Rulecheck Agent Run Complete" }
      },
      {
        "type": "section",
        "text": { "type": "mrkdwn", "text": $pr }
      },
      {
        "type": "section",
        "text": { "type": "mrkdwn", "text": $summary }
      }
    ]
  }')

# Send to Slack — don't let curl failure block the agent
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$SLACK_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" 2>/dev/null || echo "failed")

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] SubagentStop/slack-notify: sent to Slack (status=$HTTP_STATUS, pr=${PR_URL:-none})" >> "$LOG_FILE"

exit 0
