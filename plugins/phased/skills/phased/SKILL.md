---
name: phased
description: Token-efficient phased workflow for IT projects and troubleshooting. Small phases, one per thread with handovers, cheapest viable model, Opus escalation only with approval. Use for /phased, "split this into phases", a pasted "START HERE <path>" line, a "PHASED STATUS" message, or resuming a phased PLAN.md.
---

# Phased

Core file. Read the others in this skill's base directory (if it wasn't shown, glob `**/phased/planning.md` under `~/.claude`) only when needed:
- `planning.md`: a new project.
- `escalation.md`: an escalation trigger fires.
- `closeout.md`: the last phase is done.

**Tools may need loading.** Session tools (get/rename session, usage, send message, `start_session`/`hand_off_to_session`, archive/delete) may be deferred: search for them before deciding you don't have them.

## Entry
- **New project or problem**, or no details given (`/phased`, `/phased:start`): follow `planning.md`.
- **`START HERE` + a path** (match loosely; dashes may be altered): run a phase (**B**). The path is a handover, or PLAN.md for phase 1.
- **`PHASED STATUS` message**: you're the control thread; see Control in `planning.md`.
- **Resume, no start line**: use the `Next start` line in the folder's PLAN.md. A PLAN.md without one isn't a phased plan: don't adopt it. No PLAN.md: ask for the folder.

## Models
| Tier | Use for | Effort |
|---|---|---|
| Haiku | lookups, summarising, boilerplate, formatting, simple scripts | low |
| Sonnet | most building, configs, docs, debugging with a clear error | medium |
| Opus | design trade-offs, ambiguous/dead-end debugging, security-sensitive work, risky-change review | high |

Use the cheapest tier that does the work well; when torn, go lighter. A session can't reliably switch its own model, and every new session rebuilds the baseline cache, so switch models inside a phase instead: bulk reading goes down to the Haiku worker (B7), one hard step goes up to Opus (`escalation.md`).

## Token rules (every turn)
- **Budget**: tokens count above the session's starting context (baseline). ~60k of work per phase; check at ~60k, hand over by ~100k (B10).
- **Evidence ladder**: free evidence first (config, existing logs, current state), analysed before asking for more. Live tests, other people or downtime only if that didn't settle it. Batch within a step.
- **Past fixes: search, never bulk-load.** `grep -ril` 2–4 keywords (client, device, error text; try synonyms) across `~/phased/LESSONS.md` and the paths in `~/phased/SOURCES.md` (one per line, globs ok, `#` comments, `save:` prefix allowed), then read only the 1–3 best notes. No hits: scan the index (e.g. `MEMORY.md`) titles once. Past notes are leads, not facts: confirm against current output.
- **Read narrowly**: search first; read line ranges, not whole files.
- **Filter at the source** (`grep`, `Select-String`, `tail`, time windows). Never dump a full config, log or listing.
- **User-run commands**: one block per device sequence where the CLI takes multi-line pastes; PowerShell/shells one paste-safe line per block. Ask for **only** the relevant output.
- **Platform syntax**: device CLIs aren't Linux (e.g. reduced `grep`). Use only syntax verified for that platform, else it's low confidence. Before giving device commands, grep any installed agent file for that platform (e.g. `grep -ril --include='*.md' fortios ~/.claude/agents ~/.claude/plugins/cache`, then grep it for the command): its traps are verified syntax, for a few hundred tokens instead of a call. **Every verification must be able to fail** (case-insensitive or substring matches can hit the old value).
- **Short replies**: don't restate the plan, echo files, or summarise the user.

## Ground rules
- Absolute paths in PLAN.md, handovers and start lines. Use the `Project:` short name from PLAN.md everywhere.
- **No secrets in any file or brief**; ask the user to mask keys, PSKs, hashes and tokens before pasting. If the folder is shared or public, keep client names, IPs and hostnames out too.
- **Every choice is an AskUserQuestion** (selectable options, recommended first; multi-select for close-out ticks): plan approval, model check, escalation, continue here, opening a session, close-out. Search for the tool if it's deferred; use a text list only if it doesn't exist.
- **Systems you can't reach**: give exact commands, treat pasted output as evidence, and label conclusions **fact** (seen in output) or **inference**.

## B. Run a phase
1. **Name the thread** `<Project> — Phase <n>: <phase name>` with a rename tool and check it took; if not, tell the user the exact name. Open with one roadmap line: `Phase 2/3 · 1 Evidence ✓ · 2 Root cause ← · 3 Fix`.
2. **Model check**: if yours differs from PLAN.md's pick, say so in one line and ask whether to continue.
3. **Baseline**: if a usage tool exists, record the context size and plan usage now.
4. **Read only** PLAN.md, the given handover (never older ones) and the files it names. Phase 1: PLAN.md alone. Read `Notes:` paths only when the step needs them; new keywords (e.g. a fresh error) justify a new past-fix search.
5. **Check the handover against reality** (not for phase 1): do the named files exist, and is the state as described? If not, stop and say what differs.
6. **Mark the phase `in progress`** (if another phase is already in progress, ask first), then work it.
   - **Troubleshooting**: check the Ruled out table first, test the cheapest and most likely hypothesis first, and log each one ruled out with its evidence.
   - **Evidence answers a later phase early?** Propose merging or skipping the phase rather than working through it.
7. **Bulk reading goes to Haiku, no approval needed.** When a step needs more than ~10k of raw material (logs, inventories, exports, large configs) but only an extract or answer, call the Agent tool with `subagent_type` `phased:haiku-worker` (or `haiku-worker`; if neither exists, `model: "haiku"`). Brief: the absolute file paths, one precise question, what to quote. Treat its answer as evidence to spot-check, not a verdict. Not for judgement calls or risky-change review.
8. **Escalation triggers, in priority order** (read `escalation.md` when one fires):
   1. **A risky change is next**: anything hard to undo, e.g. production or device config, deleting or overwriting data, migrations, credentials, security or identity changes, sending or publishing, client-facing documents.
   2. **Low confidence**: guessing a command, flag or syntax; several causes fit the evidence; changing something you haven't read; or acting on memory rather than output seen in this thread.
   3. **Stuck**: the same fix, or attempts at a working solution, failed twice.
9. **Before any approved risky change**: capture the current state (config backup or current values), have the rollback ready, and restate exactly what will change.
10. **Session size.** At ~60k of work above the baseline, check what's left: more than ~15 messages, hand over as `part done` now (a fresh session repays its cache rebuild in about that many); nearly done, finish here. Always hand over past ~100k (or 60% of the window), or if the context was compacted or an earlier decision has been lost.
11. **No other subagents or parallel work** (beyond B7 and approved escalations) without approval; say why it's worth the tokens first.

## D. End of phase (or part phase)
1. **Show the "done when" check passing** with real output, and **wait for the user to confirm.** A failing check means not done: fix it if there's room, otherwise hand over as `part done`. For a part phase, say what's left.
   **Continue here?** If the next phase uses the same model, needs no wait (overnight, a scheduled window) and this thread's work plus its estimate stays under ~60k, ask in the same message. On yes: record the actual and status in PLAN.md, send the status (D5), rename this thread to the next phase, and carry on at B6. No handover file.
2. **Record the actual** in PLAN.md as work above the baseline: `~<k> work, plan +<x>%` ("approx" if other sessions ran), plus escalation tokens. Write `not measured` if there's no usage tool or the context was compacted. Never guess.
3. **Write `HANDOFF-<YYYY-MM-DD>-PHASE-<n>.md`** (add `-2`, `-3`... if it exists). **Under ~500 words, facts not narrative**, because the next thread pays for every line: built/found · decisions + why, one line each · files touched (absolute) · how to test, including user-run commands · ruled out · key log or output lines quoted, not whole logs · open faults and questions · escalations + verdicts · uncommitted changes if it's a git repo (offer to commit, never unasked) · **next start: first action + the only files it needs**.
4. **Update PLAN.md**: the status (`done`, `part done` or `blocked`) and `Next start`. If a `CLAUDE.md` or memory note exists for this project, point it at the handover.
5. **Report to the control thread** (the `Control:` session id in PLAN.md, or `parent`) if you can message sessions, max 5 lines. If it can't be delivered, say so in one line:
   ```
   PHASED STATUS — <Project> — Phase <n>: done | part done | blocked
   <key result, fact/inference>
   Next: Phase <m> <name>, <model> (<effort>)
   Start: <start line>
   ```
6. **Hand off the next phase.** If the project is complete, follow `closeout.md` instead.
   - **Can start sessions:** ask "Open Phase <m> on <Model>?"; on yes, start it with the start line as its first message, set its model, name it, open it.
   - **Otherwise** end with:

     **▶ Start a NEW session: 1. folder `<absolute project folder>` · 2. model <Model> (<effort>) · 3. paste:**
     ```
     <Project> — Phase <m> of <total>: <phase name> — START HERE <absolute path to handover>
     ```
     (A part phase repeats its own number.) Pick the folder first: it sets where the session runs and which memory loads; the START HERE path only tells it which file to read.
7. **STOP.**

