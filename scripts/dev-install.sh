#!/bin/sh
# Install a branch of phased side by side as /phased-dev, for testing without touching /phased.
# Usage: scripts/dev-install.sh [branch]   (default: dev)   Remove: scripts/dev-install.sh --remove
set -e
B=${1:-dev}; SK=~/.claude/skills/phased-dev; AG=~/.claude/agents
CM=~/.claude/commands
if [ "$B" = "--remove" ]; then rm -rf "$SK" "$AG/haiku-worker-dev.md" "$AG/opus-escalation-dev.md" "$CM"/phased-dev-*.md; echo "phased-dev removed"; exit 0; fi
cd "$(dirname "$0")/.."
T=$(mktemp -d); git archive "$B" plugins/phased | tar -x -C "$T"
rm -rf "$SK"; mkdir -p "$SK" "$AG"
for f in "$T"/plugins/phased/skills/phased/*.md; do
  sed -e 's/^name: phased$/name: phased-dev/' \
      -e "s|^description: .*|description: TEST build of phased ($B branch). Use ONLY for /phased-dev or /phased-dev-* commands, a pasted \"DEVSTART <path>\" line or a \"PHASED-DEV STATUS\" message.|" \
      -e 's/START HERE/DEVSTART/g; s/PHASED STATUS/PHASED-DEV STATUS/g' \
      -e 's#\*\*/phased/planning.md#**/phased-dev/planning.md#g' \
      -e 's#`/phased` or `/phased:start` alone)#`/phased-dev` alone)#; s#^\# Start menu (`/phased` or `/phased:start`#\# Start menu (`/phased-dev`#' \
      -e 's/phased:haiku-worker/haiku-worker/g; s/phased:opus-escalation/opus-escalation/g; s/haiku-worker/haiku-worker-dev/g; s/opus-escalation/opus-escalation-dev/g' "$f" > "$SK/$(basename "$f")"
done
for a in haiku-worker opus-escalation; do
  sed -e "s/^name: $a$/name: $a-dev/" -e "s/^description: /description: (phased-dev test) /" \
      "$T/plugins/phased/agents/$a.md" > "$AG/$a-dev.md"
done
mkdir -p "$CM"; rm -f "$CM"/phased-dev-*.md
for c in new resume status close-out; do
  [ -f "$T/plugins/phased/commands/$c.md" ] || continue
  sed -e 's/^description: /description: (phased-dev) /' -e 's/the phased skill/the phased-dev skill/' \
      "$T/plugins/phased/commands/$c.md" > "$CM/phased-dev-$c.md"
done
rm -rf "$T"; echo "phased-dev installed from $B ($(git rev-parse --short "$B")). Start a new session and type /phased-dev (or /phased-dev-new, -resume, -status, -close-out)."
