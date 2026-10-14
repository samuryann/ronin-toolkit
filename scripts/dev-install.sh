#!/bin/sh
# Install a branch of phased side by side as /phased-dev, for testing without touching /phased.
# Usage: scripts/dev-install.sh [branch]   (default: dev)   Remove: scripts/dev-install.sh --remove
set -e
B=${1:-dev}; SK=~/.claude/skills/phased-dev; AG=~/.claude/agents
if [ "$B" = "--remove" ]; then rm -rf "$SK" "$AG/haiku-worker-dev.md" "$AG/opus-escalation-dev.md"; echo "phased-dev removed"; exit 0; fi
cd "$(dirname "$0")/.."
T=$(mktemp -d); git archive "$B" plugins/phased | tar -x -C "$T"
rm -rf "$SK"; mkdir -p "$SK" "$AG"
for f in "$T"/plugins/phased/skills/phased/*.md; do
  sed -e 's/^name: phased$/name: phased-dev/' \
      -e "s|^description: .*|description: TEST build of phased ($B branch). Use ONLY for /phased-dev, a pasted \"DEVSTART <path>\" line or a \"PHASED-DEV STATUS\" message.|" \
      -e 's/START HERE/DEVSTART/g; s/PHASED STATUS/PHASED-DEV STATUS/g' \
      -e 's#\*\*/phased/planning.md#**/phased-dev/planning.md#g' \
      -e 's#`/phased` or `/phased:start` alone#`/phased-dev` alone#; s#^\# Start menu (`/phased` or `/phased:start`#\# Start menu (`/phased-dev`#' \
      -e 's/phased:haiku-worker/haiku-worker/g; s/phased:opus-escalation/opus-escalation/g; s/haiku-worker/haiku-worker-dev/g; s/opus-escalation/opus-escalation-dev/g' "$f" > "$SK/$(basename "$f")"
done
for a in haiku-worker opus-escalation; do
  sed -e "s/^name: $a$/name: $a-dev/" -e "s/^description: /description: (phased-dev test) /" \
      "$T/plugins/phased/agents/$a.md" > "$AG/$a-dev.md"
done
rm -rf "$T"; echo "phased-dev installed from $B ($(git rev-parse --short "$B")). Start a new session and type /phased-dev."
