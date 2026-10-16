#!/bin/sh
# phased break check (UserPromptSubmit, no model call). Silent unless this thread works in a
# phased project folder, has been idle over IDLE_MIN and holds over MIN_CTX tokens. Then it adds
# one line, so phased can offer a fresh session instead of re-reading the whole thread uncached.
IDLE_MIN=60; MIN_CTX=40000
command -v jq >/dev/null 2>&1 || exit 0
in=$(cat)
cwd=$(printf '%s' "$in" | jq -r '.cwd // empty' 2>/dev/null)
tp=$(printf '%s' "$in" | jq -r '.transcript_path // empty' 2>/dev/null)
case "$cwd" in */phased/*) ;; *) exit 0 ;; esac
[ -f "$cwd/PLAN.md" ] && [ -f "$tp" ] || exit 0
last=$(tail -n 300 "$tp" | jq -R -r 'fromjson? | select(.type == "assistant" and .message.usage != null and .timestamp != null)
  | "\(.timestamp | sub("\\.[0-9]+"; "") | fromdateiso8601) \(.message.usage | (.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0))"' 2>/dev/null | tail -n 1)
[ -n "$last" ] || exit 0
set -- $last
idle=$(( ($(date +%s) - $1) / 60 ))
[ "$idle" -gt "$IDLE_MIN" ] && [ "$2" -gt "$MIN_CTX" ] || exit 0
echo "PHASED IDLE: ${idle} min since the last reply, context ~$(( $2 / 1000 ))k: the cache has expired, so this turn re-reads the whole thread."
exit 0
