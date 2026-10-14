---
name: phased
description: Token-efficient phased workflow for IT projects and troubleshooting: small phases, one per thread, handovers, cheapest viable model, Opus only with approval. Use for /phased, "split this into phases", a pasted "START HERE <path>" line, or resuming or checking a phased PLAN.md.
---

# Phased

Other files in this skill's base directory (not shown? glob `**/phased/planning.md` under `~/.claude`), read only when needed: `menu.md` no details given · `planning.md` new project · `bigoutput.md` before any command that may print >~100 lines · `escalation.md` a trigger fires · `closeout.md` last phase done.

**Load tools first, in one search**: rename/get session, usage (`get_usage`), AskUserQuestion, `start_session`/`hand_off_to_session` (search by bare name: the server prefix varies), archive/delete are often deferred. Fetch them all on your first turn before deciding any is missing.

## Entry
- **No details** (`/phased` or `/phased:start` alone), or a start menu option named (new, resume, status, close-out commands): `menu.md`.
- **New project or problem** (details given): `planning.md`.
- **`START HERE` + a path** (match loosely): run a phase (**B**). The path is a handover, or PLAN.md for phase 1.
- **Control thread asked for status** (or an old `PHASED STATUS` message): from PLAN.md, in 2 lines: progress and the `Next start` line; offer to open it (D5).
- **Resume, no start line**: the `Next start` line in the folder's PLAN.md. `none`: say the project is complete. No such line: not a phased plan, don't adopt it. No PLAN.md: ask for the folder.

## Models
Cheapest tier that does the work well (tiers: `planning.md`); when torn, go lighter. New sessions rebuild the baseline cache, so switch inside a phase: bulk reading down to the Haiku worker (B7), one hard step up to Opus (`escalation.md`).

## Token rules
- **Budget**: work = tokens above the session's starting context. ~60k per phase; check at ~60k, hand over by ~100k (B10).
- **Evidence ladder**: free evidence first (config, existing logs, current state), analysed before asking for more; live tests, other people or downtime only if that didn't settle it. Batch within a step.
- **Past fixes: search, never bulk-load.** `grep -ril` 2–4 keywords (client, device, error; try synonyms) across `~/phased/LESSONS.md` and the paths in `~/phased/SOURCES.md` (one per line, globs ok, `#` comments, `save:` prefix); read only the 1–3 best notes. No hits: scan the index titles (e.g. `MEMORY.md`) once. Notes are leads: confirm against current output.
- **Read narrowly; filter at the source** (`grep`, `Select-String`, `tail`, time windows). Never dump a full file, config, log or listing.
- **User-run commands**: one block per device sequence where the CLI takes multi-line pastes; shells one paste-safe line per block. Ask for **only** the relevant output. Commands and anything the user must act on go in your message, never only in a next-step/wrap-up box, and a recap never says something was given that isn't shown above it. Evidence (read-only) steps change nothing, except turning off output paging on any platform. Prefer a session-only switch (e.g. `terminal length 0` on Cisco/EdgeOS/HP, `--no-pager`, `| Out-String`); use a saved setting only where none exists (e.g. FortiOS `config system console` / `set output standard`), and label it as the only change.
- **`copied` means: it's on my clipboard, read it.** Works any time, for any output or value, not just after a big-output block. Never ask for a paste instead. Save it first (macOS `pbpaste > <project folder>/clip-<HHMM>.txt`; other OS: the clipboard line in `bigoutput.md`) and print its line count. Up to ~100 lines: read it yourself. More: Haiku worker (B7). `saved` = a downloaded file (`bigoutput.md`).
- **Before giving a command expected to print >~100 lines** (recursion, unfiltered lists, full configs or logs): read `bigoutput.md`; never chat.
- **Platform syntax**: device CLIs aren't Linux. Before giving device commands, grep installed agent files for the platform (`grep -ril --include='*.md' <platform> ~/.claude/agents ~/.claude/plugins/cache`, then the command): their traps are verified syntax. Unverified = low confidence. **Every verification must be able to fail** (case-insensitive or substring matches can hit the old value).
- **Short replies**: don't restate the plan, echo files, or summarise the user.

## Ground rules
- Absolute paths in PLAN.md, handovers and start lines; the `Project:` name from PLAN.md everywhere.
- **No secrets in any file or brief**; ask the user to mask keys, PSKs, hashes and tokens before pasting. Shared or public folder: no client names, IPs or hostnames either.
- **Every choice is an AskUserQuestion** (recommended first; multi-select for close-out): plan approval, model check, escalation, opening a session, close-out. Max 4 options; never add Other/None/Skip/Nothing more/Done (built in). Text list only if the tool doesn't exist.
- **Systems you can't reach**: exact commands, pasted output is evidence, conclusions labelled **fact** (seen) or **inference**. Shape commands for PLAN.md's `Access:` (e.g. RMM jobs run as SYSTEM, non-interactive: no prompts, no mapped drives or user-profile paths).

## B. Run a phase
1. **First turn, before any work**, one batch: (a) load tools; (b) rename the thread `<Project> — Phase <n>: <phase name>`, plus ` (part <k>)` if PLAN.md shows the phase `part done` (k = its HANDOFF files + 1); (c) record the baseline: context size and plan usage (`get_usage`). Rename failed: give the user the exact name. Then one roadmap line: `Phase 2/3 · 1 Evidence ✓ · 2 Root cause ← · 3 Fix`.
2. **Model check**: yours differs from PLAN.md's pick? Ask whether to continue.
3. **Usage**: re-check every ~10 turns, after any agent call, and before D2.
4. **Read only** PLAN.md, the given handover (never older ones) and the files it names (phase 1: PLAN.md alone). `Notes:` paths only when a step needs them; a fresh error justifies a new past-fix search.
5. **Check the handover against reality** (not phase 1): named files exist, state as described? If not, stop and say what differs.
6. **Mark the phase `in progress`** (another already in progress? ask first), then work it.
   - **Troubleshooting**: Ruled out table first; cheapest, most likely hypothesis first; log each ruled out with its evidence.
   - **Evidence answers a later phase early?** Propose merging or skipping it.
7. **Bulk reading goes to Haiku, no approval needed.** Any step that needs >~5k of raw material (logs, inventories, exports, large configs, saved output, long docs) but only an extract, count or comparison: Agent tool, `subagent_type` whichever of `phased:haiku-worker` / `haiku-worker` is in your available agents (neither: `model: "haiku"`). First grep the project's `FINDINGS.md` for the question's keywords: answered there? Use it, no call. Brief: absolute paths, one precise question, what to quote. Then append the handback to `FINDINGS.md` yourself (subagents won't write files): one `cat >>` heredoc, `## <date> · <question>`, `Files:` line, handback. Spot-check the answer; never for judgement calls or risky-change review.
8. **Escalation triggers, in priority order** (several fire: lead with the first):
   1. **Risky change next**: hard to undo, e.g. production or device config, deleting or overwriting data, migrations, credentials, security or identity, sending or publishing, client-facing documents.
   2. **Low confidence**: guessing a command, flag or syntax; several causes fit; changing something unread; acting on memory rather than output seen here.
   3. **Stuck**: the same fix, or attempts at a working solution, failed twice.
9. **Before an approved risky change**: capture current state (backup or current values), have the rollback ready, restate exactly what will change.
10. **Session size.** At ~60k work: more than ~15 messages left, hand over `part done` now; nearly done, finish. Always hand over past ~100k (or 60% of the window), after compaction, or if an earlier decision was lost.
11. **Other subagents or parallel work** (beyond B7 and approved escalations) need approval with the cost: an agent listed with "All tools" carries every tool, ~50k+ per call; one with a tool list is far cheaper. Pass `model` at the cheapest tier that fits.

## D. End of phase (or part phase)
1. **Show the "done when" check passing** with real output; **wait for the user to confirm.** Failing = not done: keep working. Approvals, pastes or choices the user can give now aren't blockers: ask and continue. `part done` only for B10, a wait, or something unavailable this session; say what's left.
2. **Record the actual** in PLAN.md: `~<k> work, plan +<x>%` ("approx" if other sessions ran), plus escalation tokens; part phases add to the existing figure; `not measured` if no usage tool or the context was compacted. Never guess.
3. **Write `HANDOFF-<YYYY-MM-DD>-PHASE-<n>.md`** (add `-2`, `-3`... if it exists). **Under ~500 words, facts not narrative**: built/found (Haiku extracts: point to `FINDINGS.md`, don't copy) · decisions + why, one line each · files touched (absolute) · how to test, incl. user-run commands · ruled out · key output lines quoted, not whole logs · open faults and questions · escalations + verdicts · uncommitted git changes (offer to commit, never unasked) · **next start: first action + the only files it needs**.
4. **Update PLAN.md**: status (`done`, `part done` or `blocked`) and `Next start`. If a `CLAUDE.md` or memory note exists for this project, point it at the handover.
5. **Hand off.** Project complete: `closeout.md` instead. Otherwise always first say **Why a new session:** <phase done · size ~<k> work · waiting for <what/when> · blocked on <what> · model change to <Model>>. Then:
   - **Can start sessions** (`start_session` loaded, see Load tools): ask "Open Phase <m> on <Model>?"; yes: ONE call, `cwd` = the absolute project folder, `title` = the phase thread name, `prompt` = the start line, `model` + `effort` from PLAN.md, `context: fresh`. It runs on its own: say so in one line and STOP, don't wait for it. No: give the block below.
   - **Otherwise** end with:

     **▶ Start a NEW session: 1. folder `<absolute project folder>` · 2. model <Model> (<effort>) · 3. paste:**
     ```
     <Project> — Phase <m> of <total>: <phase name> — START HERE <absolute path to handover>
     ```
     (A part phase repeats its number.) Folder first: it decides which memory loads.
6. **STOP.**
