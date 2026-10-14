# Changelog

All notable changes to ronin-toolkit. The plugin version is the git commit.

## 2026-10-14

### phased: Haiku does the heavy reading
- **Big output never goes into the chat.** When a command is likely to print more than ~100 lines, phased combines the step's commands into one block that writes one labelled file (`C:\Temp\phased-<step>.txt`, or `/tmp` on Linux) and prints its line count. Bring it back with `copied` (clipboard saved to the project folder) or `saved` (downloaded; phased finds it in the project folder or Downloads). The Haiku worker reads it and returns a short extract. Details load from `bigoutput.md` only when needed.
- Haiku worker threshold lowered to ~5k of material; mechanical phases (verify, cleanup) are planned on Haiku.
- Clipboard save commands for macOS, Windows and Linux.

### phased: remote systems
- `PLAN.md` gets an `Access:` line (how commands reach the systems, and their OS). Planning asks when it isn't obvious. Commands are shaped for it, e.g. RMM jobs run as SYSTEM with no prompts, mapped drives or user-profile paths.

### phased: experience
- Each phase's first turn loads tools, renames the thread and records usage before any work.
- The planning thread is renamed `<Project> — Control` as soon as the project is named. Phases no longer message it (each message reloaded it); ask it "status?" and it answers from `PLAN.md`.
- Every choice is a selectable menu: at most 4 options, never an added Other/None/Skip. Plan approval is *Approve* / *Revise*.
- Close-out asks exactly *Ticket note* · *Save the lesson* · *Archive the sessions* · *Delete the sessions*; anything else goes through Other. It marks `Next start: none (project complete)` first, and resuming a finished project says so.
- After an Opus GO on a risky change, phased asks *Make the change* / *Stop* before acting. Opus questions are passed to you.
- "Why a new session" shows on every hand-off; declining to open the next session gives you the start block.
- Agent costs are stated before approval: agents with "All tools" cost ~50k+ per call, tool-listed ones far less. The cheapest fitting model is passed.

### phased: efficiency
- Core instructions trimmed and rarely needed steps moved to files that load on demand. Status checks no longer load the planning file.
- Estimating figures updated from real runs. Escalations table column is now `Tokens`.

### Repository
- `dev` branch for testing; `scripts/dev-install.sh` installs any branch side by side as `/phased-dev`.

## 2026-10-13

### phased: no unexplained hand-offs
- Questions the user can answer now (approvals, pastes, choices) no longer end a phase: phased asks and carries on. `part done` is only for size, a wait, or something unavailable this session.
- Every hand-off states why in one line (phase done, size with the figure, waiting, blocked, or model change).

### phased: part-phase names
- A resumed `part done` phase is named `<Project> — Phase <n>: <name> (part 2)`, so it doesn't duplicate the earlier thread's name.

### phased: usage measured every phase
- The baseline step searches for the (usually deferred) usage tool instead of assuming it's missing, and re-checks every ~10 turns so the session-size rule actually fires. A real phase ran to ~108k of work with `not measured`.

### README
- phased section rewritten: how to start it, where the control and phase threads live, how memory and `SOURCES.md` work, then a short feature list.

### phased: choices and device syntax
- Every user choice (plan approval, model check, escalation, continue here, opening a session, close-out) is asked with selectable options, recommended first, not as a text list.
- Before giving device CLI, phased greps any installed agent file for that platform and checks the command's syntax there (e.g. FortiOS `grep -f` prints whole config blocks).

### phased: usage savings
- New `haiku-worker` subagent: bulk reading (logs, inventories, exports, large configs) goes to Haiku inside any phase and comes back as a ≤200-word extract with quoted lines. No approval needed. Models now switch inside a phase (Haiku down, Opus up) instead of forcing a new session.
- Phases split only where it pays: a model change, a wait, ~60k of work or a risky change. Otherwise merge.
- End of phase offers **Continue here?** when the next phase has the same model, no wait and fits ~60k.
- Session size: at ~60k of work, hand over if more than ~15 messages remain (a fresh session repays its cache rebuild in about that many); always by ~100k.

### phased: past-fix lookup
- Searches `~/phased/LESSONS.md` and the folders in an optional `~/phased/SOURCES.md` (e.g. Claude's memory folder) for client, device and error keywords, reads only the 1–3 best matches, and records them under `Notes:` in `PLAN.md`. Past notes are leads, confirmed against current output.
- Planning offers to create `SOURCES.md` with one wildcard line, `~/.claude/projects/*/memory`, covering all Claude memory folders including future ones.
- Planning names the project (1–4 words) and renames the planning thread to it when its auto-title doesn't fit (e.g. a thread started with `/phased`), so every phase carries a meaningful name.
- Close-out saves the lesson into a `save:` folder as a proper note (with an index pointer) when one is set; otherwise to `LESSONS.md`.
- The ▶ hand-off is now three steps: open the session in the project folder, pick the model, paste the START HERE line. The guided start says so when it creates the folder.
- The planning thread is renamed `<Project> — Control` once the plan is approved, so every thread in a project shares one prefix (phases find it by session id, not title).

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
