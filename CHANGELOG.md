# Changelog

All notable changes to ronin-toolkit. The plugin version is the git commit.

## 2026-10-16

### phased: break hook (real runs)
- New hook, when you send a message: in a phased project thread idle over an hour and over ~40k tokens, it adds one line, and phased offers a fresh session from a handover instead of re-reading the whole thread uncached. Measured on real projects: 11 such returns, ~3M tokens of plan usage re-read uncached; the returning turn still pays, a fresh session keeps the turns after it small. A script with no model call: silent and free otherwise, ~20 tokens when it fires.

### phased: hand-off offer in long threads (real run)
- A 200k+ thread printed the manual start block instead of offering to open the next phase, because the next phase was waiting on client inputs. Now a next phase that can start opens by itself with no question; one that waits on something (or a status request) asks, with *Later* recommended. And a thread past ~100k re-reads the end-of-phase steps before handing off (~1.3k tokens, only then).

### phased: escalation fix (real run)
- When a risky change, low confidence or a repeated failure triggers, phased now always reads the escalation step first and offers *Opus review* (or a matching specialist) / *Carry on* / *Stop*. A long thread had asked a plain *Approve* / *Not yet* instead.

### phased: phases no longer wake the thread that opened them
- Each phase detaches itself on its first turn, so its turns no longer wake (and re-bill) Control or the previous phase. Measured cost of those wake-ups on a real project: ~250k tokens in one afternoon.
- Phased now keeps each project in its own sidebar group (Control and all phases); phases sit side by side instead of nested. Close-out's Archive/Delete also removes a group phased created.
- About +600 tokens per phase thread for the two extra tool calls.

### phased: hand-off fix (real run)
- End of phase loads the session-opening tool if it isn't loaded yet, so the *Open it now* (nested) / *Later* / *Start block* question is always offered when the app supports it.
- The "is this phase done?" confirmation no longer absorbs the hand-off question.

### ticket-notes: new plugin
- Paste-ready PSA ticket notes (AutoTask, ConnectWise, HaloPSA) from rough notes or the work in the conversation.
- Only what was stated or done in the conversation; steps the user was told to do count as done; Next Steps only for open items; Outcome line for unfinished work; Optional Improvements for out-of-scope suggestions; never writes secrets.
- Note comes in a plain code block, so copying keeps the `- ` dashes and line breaks (loose chat text gets turned into bullets and merged lines).

## 2026-10-15

### phased: release hardening (comprehensive QA)
- Resume and close-out with a single project skip the picker (a one-answer question is rejected by the app).
- Project list reads each phase's status from the end of its row, so a `|` inside a "Done when" cell no longer shifts it.
- Past-fix search runs in `sh`, so a SOURCES.md glob that matches nothing no longer aborts it in zsh.
- Haiku findings are appended with a quoted heredoc, so `$` and `$(...)` in logs aren't expanded.
- `saved` also finds a file you name, or the newest file you dropped (in Downloads or the project folder, skipping phased's own files); unsure, it asks.
- First run with no projects says so and offers New project.
- README: `/phased:phased` (plugin skill name), uninstall keeps project folders, Windows needs Git for Windows; Windows clipboard saves as UTF-8.
- No longer loads an unused session tool on the first turn.
- Docs: footprint figures updated (~205 / ~2.8k); the 2026-10-13 "Continue here?" offer was later removed (every phase hands off).

### phased: hand-off choice and command blocks (real-run fixes)
- Opening the next phase now asks with three answers: Open it now (nested), Later, or Start block (manual, not nested, ~10% fewer tokens). Before, the question could have a single answer, which the app rejects, and the start block could go missing.
- If opening fails, the start block is printed in the same message.
- Device commands: only the next block is given (later ones depend on its output), ending with "run it, then `copied`". Before, one phase previewed six later blocks and ended with "paste".
- "status?" in Control and the resume command no longer offer to open a phase that is already in progress (they say it's running; say its thread is gone to reopen it).
- Cost: about +125 tokens per phase session.

### phased: deferred Phase 1 points to resume
- When Phase 1 isn't opened right after planning (declined, or planned for later), the manual start steps now end with one line: when ready, "status?" in the Control thread or the resume command offers to open it. Before, it looked as if auto-open had stopped working.

### README: grouping a project in the sidebar
- Tip: right-click the Control thread → Move to → New section; nested phases move with it (docs only, no skill change).

## 2026-10-14

### README: hiding finished projects
- Documented that moving a project folder into `~/phased/archive/` removes it from the project lists (docs only, no skill change).

### phased: full project list for resume and close-out
- With more than 4 projects, `/phased:resume` and `/phased:close-out` now print the full list above the question (only `/phased` did before), so projects that don't fit in the 4 choices can be typed in Other.

### phased: efficiency pass (3 reviews each, Opus + Prompt Engineer)
- Shorter always-on descriptions for the skill and both agents (paid in every session), tighter core wording (~180 chars less per phase), one PLAN.md edit at phase end instead of two, one exact-name tool search on the first turn (more reliable session auto-open), and the archive/delete tools load only at close-out.
- README: table of the `/phased` commands and what each does.

### phased: menu options in autocomplete
- `/phased:new`, `/phased:resume`, `/phased:status` and `/phased:close-out` jump straight to that start menu option. All phased commands, `/phased:start` included, are marked `disable-model-invocation`, so they show in the `/` menu but add nothing to each session's context (`/phased:start` used to).

### phased: start menu
- `/phased` or `/phased:start` on its own now asks: **New project**, **Resume a project**, **Status of all projects** or **Close out a project**. Projects are listed with progress (`2/6 done · next: Verify`) from one quick read of each plan's header and phase table. Typing the job (or giving details, a START HERE line, or a folder with a plan) skips the menu as before.

### phased: close-out cleans up the saved environment
- Choosing Archive or Delete at close-out now ends with a reminder to remove the project folder's saved environment from the desktop app's new-session box. A leftover one can make new sessions warn "the Local environment isn't available anymore". The four close-out options are unchanged.

### phased: commands always shown
- Commands go in the message itself, never only in the app's next-step box, and the recap can't claim commands were given when they weren't (a phase ended its turn saying "I've given you the commands" without showing them).
- Read-only evidence steps change nothing, except turning off output paging on any platform: a session-only switch where one exists (e.g. `terminal length 0`), a saved setting only where it doesn't (e.g. FortiOS), labelled as the only change.

### phased: Haiku does the heavy reading
- **Big output never goes into the chat.** When a command is likely to print more than ~100 lines, phased combines the step's commands into one block that writes one labelled UTF-8 file (`C:\Temp\phased-<step>.txt`, or `/tmp` on Linux) and prints its line count. Bring it back with `copied` (clipboard saved to the project folder) or `saved` (downloaded; phased finds it in the project folder or Downloads). The Haiku worker reads it and returns a short extract. Details load from `bigoutput.md` only when needed.
- The Haiku worker is called by whichever name is installed (plugin or manual), so no failed first call, and its handback is held to its four lines. Threshold lowered to ~5k of material; mechanical phases (verify, cleanup) are planned on Haiku.
- Haiku findings are kept: each Haiku answer (date, question, files) is appended to the project's `FINDINGS.md`; the worker itself stays read-only. Phases grep it before asking Haiku again, handovers point to it instead of copying, close-out reads it for missing facts, and `SOURCES.md` can search every project's findings (`~/phased/*/FINDINGS.md`).
- Clipboard save commands for macOS, Windows and Linux. In an interactive remote session the command also puts the file on the clipboard (`Set-Clipboard`), so it's one reply; the line count catches a clipboard sync that cut it short.

### README
- New "How it saves tokens" section: the Haiku worker, `copied`, big output as a file, dropping files in the project folder, `FINDINGS.md`, and phases that open themselves.

### phased: `copied` works everywhere
- Reply `copied` after copying any output or value and phased reads your clipboard: it saves it to the project folder, reads up to ~100 lines itself and sends anything bigger to the Haiku worker. Before, `copied` was only understood after a big-output command, so a phase could answer "paste the output" instead.

### phased: opening the next phase
- In the Claude desktop app, phases open themselves: one start-session call with the project folder, phase name, model, effort and START HERE line, then the old thread stops instead of waiting. The tool is found by its bare name, since the prefix differs between apps.

### phased: remote systems
- `PLAN.md` gets an `Access:` line (how commands reach the systems, and their OS). Planning asks when it isn't obvious. Commands are shaped for it, e.g. RMM jobs run as SYSTEM with no prompts, mapped drives or user-profile paths.

### phased: experience
- Each phase's first turn loads tools, renames the thread and records usage before any work.
- Name first: the guided start asks for a project name, and the planning thread is renamed `<Project> — Control` before any searching or reading. Phases no longer message it (each message reloaded it); ask it "status?" and it answers from `PLAN.md`.
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
