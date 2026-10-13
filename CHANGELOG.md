# Changelog

All notable changes to ronin-toolkit. The plugin version is the git commit.

## 2026-10-13

### phased: close-out
- At project end (new `closeout.md`, read only then): offers to save a 3–5 line lesson to a shared `LESSONS.md`, archive the project's sessions (never delete), and keep or remove the folder. Sends a final status to the control thread.
- Planning greps `LESSONS.md` for keywords from the problem, so past fixes surface without loading anything into every session.

### phased: fixes from the first end-to-end test
- **Control thread**: the planning thread becomes `<Project> — Control`; each phase sends a 5-line `PHASED STATUS`. It offers to open the next phase automatically where a start-session tool exists.
- **Evidence ladder** (skill and agent): free evidence (config, logs, state) before testers or downtime; merges or skips phases the evidence already answered.
- **Budgets** are measured as work above each session's starting context: ~60k per phase, hand over past ~100k (not a % of the window).
- One code block per device CLI sequence; only syntax verified for that platform; every verification must be able to fail.
- A roadmap line at the start of each phase and an explicit **▶ Start a NEW session** cue.
- One short project name everywhere; asks for a config paste instead of questions the config answers.
- Searches for deferred session tools (rename, usage, messaging, start session).
- Opus agent: tools limited to Read, Grep, Glob, Bash, Edit and Write, and no CLAUDE.md, to cut the overhead of each escalation.

### phased: necessity and efficiency pass
- Removed rules Claude Code already follows (parallel tool calls, no re-reads, edit in place, asking questions, the date).
- Merged duplicate rules and shortened both descriptions. Always-on ~210 → ~108 tokens; phase run ~3.2k → ~1.4k.

### phased: robustness pass
- Ignores a `PLAN.md` that isn't a phased plan (no `Next start` line).
- Batch approval for a stated list of related risky changes.
- Already on Opus: reviews the step itself instead of spawning the subagent.
- A default `~/phased/<project>/` folder for remote-system work; keeps client details out of shared folders.

### phased: token-efficiency rewrite
- The skill is split: the core loads per phase; `planning.md` and `escalation.md` are read only when needed.
- Token rules: search before reading, line ranges, filter output at the source, batch user-run commands.
- IT rules: mask secrets before pasting, fact vs inference, capture state and rollback before risky changes, the fix in its own phase.
- Handovers capped at ~500 words; phase 1 starts from `PLAN.md`.

### phased: hardening
- Troubleshooting shape with a "Ruled out" table; a `NEEDS INFO` verdict; REVIEW is read-only; at most 2 escalations per step; re-read files after an Opus fix; no handover overwrites; handover-vs-reality check.

### Repository
- Rebranded **claude-toolkit → ronin-toolkit** (Ronin Toolkit by Samuryann, assisted by Claude).
- Licence changed from MIT to **MIT + Commons Clause** (free to use, not for sale). Earlier copies remain MIT.
- Packaged as a plugin marketplace (`/plugin install phased@ronin-toolkit`).
- First release: the `phased` skill and the `opus-escalation` subagent.
