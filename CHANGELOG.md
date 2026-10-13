# Changelog

All notable changes to ronin-toolkit. The plugin version is the git commit.

## 2026-10-13

### phased: past-fix lookup
- Searches `~/phased/LESSONS.md` and the folders in an optional `~/phased/SOURCES.md` (e.g. Claude's memory folder) for client, device and error keywords, reads only the 1–3 best matches, and records them under `Notes:` in `PLAN.md`. Past notes are leads, confirmed against current output.
- Planning offers to create `SOURCES.md` when it finds Claude memory folders.
- Close-out saves the lesson into a `save:` folder as a proper note (with an index pointer) when one is set; otherwise to `LESSONS.md`.
- README: the planning thread keeps its name (no longer renamed to Control).

### fortigate-meraki: new plugin
- A FortiGate & Meraki engineer subagent: silent-fail traps, diagnostics, policy/NAT/local-in, shaping and voice, WAN failover, hardening, DDNS and certificates, a dial-up IPsec baseline, and Meraki MX/MS/MR gotchas. Restricted to file, shell and web tools. Follows the `phased` brief when called as a specialist.

### phased: specialist escalation
- At an escalation, if an installed agent fits the step's domain better than generic Opus, it's offered as `<Specialist> review`, with the same brief, approval, logging and 2-per-step limit. Its model is set by tier (Opus for risky changes, otherwise Sonnet), and the brief carries the handback format and REVIEW = read-only.

### phased: fixes from the second end-to-end test
- **Guided start**: `/phased:start` (plugin) or `/phased` with no details explains itself, asks for the job and a project folder (and creates it), or resumes the next phase if the folder already holds a plan.
- **Project name = the first thread's title**; phases are named `<Project> — Phase <n>: <name>` and must confirm the rename took.
- **Control thread found by session id** recorded in PLAN.md (no rename needed); an undeliverable status is reported instead of silently skipped.
- **Power ladder**: a second escalation on the same step runs Opus at `xhigh` effort; the agent defaults to `high`.
- **Close-out** adds a permanent delete option (the app confirms each one) and a telegraphic, paste-ready **ticket note** (`TICKET-NOTE.md`: Issue / Cause / Fix / Verified / Ruled out / Follow-up); the final status is sent before archiving.
- Realistic estimate figures (evidence 5–20k, build 15–40k, verify 3–10k work); searches for `start_session`/`hand_off_to_session` to open phases automatically where available.
- Measured: an Opus review cost ~14k, down from ~74k, after restricting the agent's tools.

### phased: consistent thread names
- Phase threads are named `<Project> — Phase <n>: <phase name>` to match `<Project> — Control`, so a project's threads group and read as one set. Phase names are 1–2 words.

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
