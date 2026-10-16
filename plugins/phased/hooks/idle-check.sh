#!/bin/sh
# phased prompt check (UserPromptSubmit, no model call). Silent outside phased threads (see below).
# In one (a phase, or a Control/planning thread that ran phased): (1) a paste over MAX_PASTE chars is stopped, so big output goes to a file instead of the
# thread; (2) after IDLE_MIN idle with over MIN_CTX tokens it adds one line, so phased can offer a
# fresh session instead of re-reading the whole thread uncached.
IDLE_MIN=60; MIN_CTX=40000; MAX_PASTE=30000
command -v jq >/dev/null 2>&1 || exit 0
in=$(cat)
cwd=$(printf '%s' "$in" | jq -r '.cwd // empty' 2>/dev/null)
tp=$(printf '%s' "$in" | jq -r '.transcript_path // empty' 2>/dev/null)
[ -f "$tp" ] || exit 0
# A phased thread: works in a phased project folder, or a START HERE line (phase start or the loaded skill) is near the top.
case "$cwd" in */phased/*) [ -f "$cwd/PLAN.md" ] ;; *) false ;; esac || head -n 5 "$tp" | grep -q 'START HERE' || exit 0
len=$(printf '%s' "$in" | jq -r '.prompt // "" | length' 2>/dev/null)
if [ "${len:-0}" -gt "$MAX_PASTE" ]; then
  echo "phased: not sent (${len} characters would stay in this thread for every later message). Still on your clipboard? Reply \`copied\`. Or save it in the project folder and reply \`saved\`." >&2
  exit 2
fi
last=$(tail -n 300 "$tp" | jq -R -r 'fromjson? | select(.type == "assistant" and .message.usage != null and .timestamp != null)
  | "\(.timestamp | sub("\\.[0-9]+"; "") | fromdateiso8601) \(.message.usage | (.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0))"' 2>/dev/null | tail -n 1)
[ -n "$last" ] || exit 0
set -- $last
idle=$(( ($(date +%s) - $1) / 60 ))
[ "$idle" -gt "$IDLE_MIN" ] && [ "$2" -gt "$MIN_CTX" ] || exit 0
echo "PHASED IDLE: ${idle} min since the last reply, context ~$(( $2 / 1000 ))k: the cache has expired, so this turn re-reads the whole thread."
exit 0
