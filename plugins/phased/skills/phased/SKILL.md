---
name: phased
description: Token-efficient phased workflow for IT projects and troubleshooting. Small phases, one per thread with handovers, cheapest viable model, Opus escalation only with approval. Use for /phased, "split this into phases", a pasted "START HERE <path>" line, a "PHASED STATUS" message, or resuming a phased PLAN.md.
---

# Phased

Core file. Read the others in this skill's base directory (if it wasn't shown, glob `**/phased/planning.md` under `~/.claude`) only when needed: `planning.md` for a new project, `escalation.md` when a trigger fires, `closeout.md` when the last phase is done.

**Load tools first, in one search.** Rename/get session, usage (`get_usage`), AskUserQuestion, send message, `start_session`/`hand_off_to_session` and archive/delete are often deferred: fetch them all in one tool search on your first turn, before deciding any is missing.

## Entry
- **New project or problem**, or no details (`/phased`, `/phased:start`): `planning.md`.
- **`START HERE` + a path** (match loosely): run a phase (**B**). The path is a handover, or PLAN.md for phase 1.
- **`PHASED STATUS` message**: you're the control thread (Control in `planning.md`).
- **Resume, no start line**: use the `Next start` line in the folder's PLAN.md. No `Next start` line means it isn't a phased plan: don't adopt it. No PLAN.md: ask for the folder.

## Models
| Tier | Use for | Effort |
|---|---|---|
| Haiku | lookups, summarising, boilerplate, formatting, simple scripts | low |
| Sonnet | most building, configs, docs, debugging with a clear error | medium |
| Opus | design trade-offs, ambiguous/dead-end debugging, security-sensitive work, risky-change review | high |

Cheapest tier that does the work well; when torn, go lighter. New sessions rebuild the baseline cache, so switch models inside a phase: bulk reading down to the Haiku worker (B7), one hard step up to Opus (`escalation.md`).

## Token rules (every turn)
- **Budget**: work = tokens above the session's starting context. ~60k per phase; check at ~60k, hand over by ~100k (B10).
- **Evidence ladder**: free evidence first (config, existing logs, current state), analysed before asking for more; live tests, other people or downtime only if that didn't settle it. Batch within a step.
- **Past fixes: search, never bulk-load.** `grep -ril` 2–4 keywords (client, device, error; try synonyms) across `~/phased/LESSONS.md` and the paths in `~/phased/SOURCES.md` (one per line, globs ok, `#` comments, `save:` prefix); read only the 1–3 best notes. No hits: scan the index titles (e.g. `MEMORY.md`) once. Notes are leads: confirm against current output.
- **Read narrowly; filter at the source** (`grep`, `Select-String`, `tail`, time windows). Never dump a full file, config, log or listing.
- **User-run commands**: one block per device sequence where the CLI takes multi-line pastes; shells one paste-safe line per block. Ask for **only** the relevant output.
- **Big output (>~100 lines) never goes in chat**: ask the user to copy it and reply `copied`, save it with `pbpaste > <project folder>/out-<step>.txt` (Windows: `Get-Clipboard | Set-Content`), and hand the file to the Haiku worker (B7).
- **Platform syntax**: device CLIs aren't Linux. Before giving device commands, grep installed agent files for the platform (`grep -ril --include='*.md' <platform> ~/.claude/agents ~/.claude/plugins/cache`, then the command): their traps are verified syntax. Unverified syntax = low confidence. **Every verification must be able to fail** (case-insensitive or substring matches can hit the old value).
- **Short replies**: don't restate the plan, echo files, or summarise the user.

## Ground rules
- Absolute paths in PLAN.md, handovers and start lines; the `Project:` name from PLAN.md everywhere.
- **No secrets in any file or brief**; ask the user to mask keys, PSKs, hashes and tokens before pasting. Shared or public folder: no client names, IPs or hostnames either.
- **Every choice is an AskUserQuestion** (recommended first; multi-select for close-out): plan approval, model check, escalation, continue here, opening a session, close-out. Max 4 options; never add Other/None/Skip (the tool has them). Text list only if the tool doesn't exist.
- **Systems you can't reach**: exact commands, pasted output is evidence, conclusions labelled **fact** (seen) or **inference**.

## B. Run a phase
1. **First turn, before any work**, in one batch: load tools, rename the thread `<Project> — Phase <n>: <phase name>` (plus ` (part <k>)` if PLAN.md shows the phase `part done`; k = its HANDOFF files + 1) and record the baseline (context size, plan usage). Check the rename took; if not, give the user the exact name. Then one roadmap line: `Phase 2/3 · 1 Evidence ✓ · 2 Root cause ← · 3 Fix`.
2. **Model check**: yours differs from PLAN.md's pick? Ask whether to continue.
3. **Usage**: re-check every ~10 turns, after any agent call, and before D2. `not measured` only if no usage tool exists.
4. **Read only** PLAN.md, the given handover (never older ones) and the files it names (phase 1: PLAN.md alone). `Notes:` paths only when a step needs them; a fresh error justifies a new past-fix search.
5. **Check the handover against reality** (not phase 1): named files exist, state as described? If not, stop and say what differs.
6. **Mark the phase `in progress`** (another already in progress? ask first), then work it.
   - **Troubleshooting**: Ruled out table first; cheapest, most likely hypothesis first; log each ruled out with its evidence.
   - **Evidence answers a later phase early?** Propose merging or skipping it.
7. **Bulk reading goes to Haiku, no approval needed.** Any step that needs >~5k of raw material (logs, inventories, exports, large configs, saved pastes, long docs) but only an extract, count or comparison: Agent tool, `subagent_type` `phased:haiku-worker` (or `haiku-worker`; neither: `model: "haiku"`). Brief: absolute paths, one precise question, what to quote. Spot-check the answer; never use it for judgement calls or risky-change review.
8. **Escalation triggers, in priority order** (then read `escalation.md`):
   1. **Risky change next**: hard to undo, e.g. production or device config, deleting or overwriting data, migrations, credentials, security or identity, sending or publishing, client-facing documents.
   2. **Low confidence**: guessing a command, flag or syntax; several causes fit; changing something unread; acting on memory rather than output seen here.
   3. **Stuck**: the same fix, or attempts at a working solution, failed twice.
9. **Before an approved risky change**: capture current state (backup or current values), have the rollback ready, restate exactly what will change.
10. **Session size.** At ~60k work: more than ~15 messages left, hand over `part done` now (a fresh session repays its rebuild in about that many); nearly done, finish. Always hand over past ~100k (or 60% of the window), after compaction, or if an earlier decision was lost.
11. **Other subagents or parallel work** (beyond B7 and approved escalations) need approval with the cost: an agent listed with "All tools" carries every tool, ~50k+ per call; one with a tool list is far cheaper. Pass `model` at the cheapest tier that fits.

## D. End of phase (or part phase)
1. **Show the "done when" check passing** with real output; **wait for the user to confirm.** Failing = not done: keep working. Approvals, pastes or choices the user can give now aren't blockers: ask and continue. `part done` only for B10, a wait, or something unavailable this session; say what's left.
   **Continue here?** Next phase on the same model, no wait (overnight, a scheduled window), this thread's work plus its estimate under ~60k: ask now. On yes: record actual and status in PLAN.md, send D5, rename this thread to the next phase, carry on at B6. No handover file.
2. **Record the actual** in PLAN.md: `~<k> work, plan +<x>%` ("approx" if other sessions ran), plus escalation tokens; `not measured` if no usage tool or the context was compacted. Never guess.
3. **Write `HANDOFF-<YYYY-MM-DD>-PHASE-<n>.md`** (add `-2`, `-3`... if it exists). **Under ~500 words, facts not narrative**: built/found · decisions + why, one line each · files touched (absolute) · how to test, incl. user-run commands · ruled out · key output lines quoted, not whole logs · open faults and questions · escalations + verdicts · uncommitted git changes (offer to commit, never unasked) · **next start: first action + the only files it needs**.
4. **Update PLAN.md**: status (`done`, `part done` or `blocked`) and `Next start`. If a `CLAUDE.md` or memory note exists for this project, point it at the handover.
5. **Report to the control thread** (`Control:` session id in PLAN.md, or `parent`), max 5 lines; if it can't be delivered, say so in one line:
   ```
   PHASED STATUS — <Project> — Phase <n>: done | part done | blocked
   <key result, fact/inference>
   Next: Phase <m> <name>, <model> (<effort>)
   Start: <start line>
   ```
6. **Hand off.** Project complete: `closeout.md` instead.
   - **Can start sessions:** ask "Open Phase <m> on <Model>?"; on yes, start it with the start line, set its model, name it, open it.
   - **Otherwise** end with **Why a new session:** <phase done · size ~<k> work · waiting for <what/when> · blocked on <what> · model change to <Model>>, then:

     **▶ Start a NEW session: 1. folder `<absolute project folder>` · 2. model <Model> (<effort>) · 3. paste:**
     ```
     <Project> — Phase <m> of <total>: <phase name> — START HERE <absolute path to handover>
     ```
     (A part phase repeats its number.) Folder first: it decides which memory loads.
7. **STOP.**
