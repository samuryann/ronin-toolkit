---
name: phased
description: Token-efficient phased workflow for IT projects and troubleshooting. Use for /phased, "split this into phases", a pasted "START HERE <path>" line, or resuming a project that has a PLAN.md. Plans small phases, runs one per thread with handovers, uses the cheapest viable model, and escalates single steps to Opus only with approval.
metadata:
  version: "1.2.0"
---

# Phased

This file is the core. Two more files sit in this skill's directory (the base directory shown when the skill loaded; if unknown, glob `**/phased/planning.md` under `~/.claude`). **Read them only when needed:**
- `planning.md`: when starting a new project (section A).
- `escalation.md`: when an escalation trigger fires.

## Entry
- **New project or problem**: read `planning.md` and follow it.
- **The message contains `START HERE` and a path** (match loosely, the dashes may be altered): run a phase (**B**). The path is a handover, or PLAN.md for phase 1.
- **Resume with no start line**: read the folder's `PLAN.md`; its `Next start` line says where to begin. A PLAN.md **without** a `Next start` line belongs to something else: don't adopt it. No PLAN.md? Ask for the folder.

## Models
| Tier | Use for | Effort |
|---|---|---|
| Haiku | lookups, summarising, boilerplate, formatting, simple scripts | low |
| Sonnet | most building, configs, docs, debugging with a clear error | medium |
| Opus | design trade-offs, ambiguous/dead-end debugging, security-sensitive work, risky-change review | high |

Use the cheapest tier that can do the work well; when torn, go lighter. A session can't reliably change its own model: between phases, tell the user what to select (`/model` or the model menu). Within a phase, escalate one step instead (`escalation.md`).

## Token rules (the whole point: follow them every turn)
- **Read narrowly.** Grep or search before you read; read line ranges, not whole files. Never re-read a file already in context unless it changed.
- **Keep output out of context.** Filter at the source: `grep`, `Select-String`, `tail`, time windows, `| head`. Never dump a full config, log or directory listing.
- **Batch.** Run independent tool calls together. When the user runs commands for you, give the whole diagnostic set at once (one command per code block, each paste-safe on one line) and ask for **only** the relevant output.
- **Big pastes.** If the user pastes a large log or config, extract the few lines that matter, note them in the handover, and work from those.
- **Short replies.** Don't restate the plan, echo file contents, or summarise what the user just said. Edit files in place rather than rewriting them.
- **Usage tool**: if one exists, call it only at the start and end of a phase.

## Ground rules
- Absolute paths in PLAN.md, handovers and start lines.
- If the project folder is shared or public (e.g. a pushed repo), keep client-identifying details (names, IPs, hostnames) out of PLAN.md and handovers.
- **Never write secrets** to any file or brief. Ask the user to mask secrets (keys, PSKs, hashes, tokens) before pasting config.
- **One active phase at a time.** If PLAN.md shows another phase `in progress`, ask first.
- **Systems you can't reach**: give exact commands, and treat the user's pasted output as the evidence. Label each conclusion as **fact** (seen in output) or **inference**.
- **Ask** with AskUserQuestion when available; otherwise ask in plain text and stop.
- **Date**: take it from the environment, or run `date` (`Get-Date` on Windows).

## B. Run a phase
1. **Name the thread** `<Project> — Phase <n>`, using a rename tool if you have one. Otherwise tell the user the name.
2. **Check the model.** If yours differs from PLAN.md's pick for this phase, say so in one line and ask whether to continue.
3. **Baseline.** If a usage tool exists, record the context size and plan usage now.
4. **Read only** PLAN.md, the given handover (never older ones), and the files it names. Phase 1 starts from PLAN.md alone.
5. **Check the handover against reality** (skip for phase 1). Do the named files exist, and is the state as described? If not, stop and say what differs.
6. **Mark the phase `in progress`** in PLAN.md, then work it.
   - **Troubleshooting:** check PLAN.md's Ruled out table first. Test the cheapest and most likely hypothesis first. Log each ruled-out hypothesis with its evidence.
7. **Escalation triggers, in priority order.** On any of these, read `escalation.md`:
   1. **A risky change is next**: anything hard to undo, e.g. production or device config, deleting or overwriting data, migrations, credentials, security or identity changes, sending or publishing anything, client-facing documents.
   2. **Low confidence**: you're guessing a command, flag or syntax; several causes fit the evidence; you're about to change something you haven't read; or you're acting on memory, not on output seen in this thread.
   3. **Stuck**: the same fix, or attempts at a working solution, failed twice.
8. **Before any approved risky change:** capture the current state (config backup or current values), have the rollback commands ready, and restate exactly what will change.
9. **Stop early** and hand over as `part done` when any of these happens: context passes ~60%, the context was compacted, an earlier decision has been lost, or the phase has outgrown its plan.
10. **No other subagents or parallel work** without the user's approval. Say why it's worth the tokens first.

## D. End of phase (or part phase)
1. **Show the "done when" check passing** with real output, and **wait for the user to confirm.** A failing check means not done: fix it if there's room, otherwise hand over as `part done`. For a part phase, say what's left.
2. **Record the actual** in PLAN.md: `~<peak>k ctx, plan +<x>%` (mark it "approx" if other sessions were running), plus any escalation tokens. Write `not measured` if there's no usage tool or the context was compacted. Never guess.
3. **Write the handover**, `HANDOFF-<YYYY-MM-DD>-PHASE-<n>.md` (add `-2`, `-3` and so on if the name exists). **Under ~500 words, facts not narrative** (the next thread pays for every line): built/found · decisions + why, one line each · files touched (absolute) · how to test, incl. user-run commands · ruled out · open faults/questions · escalations + verdicts · uncommitted changes if a git repo (offer to commit, never unasked) · **next start: first action + the only files it needs**.
4. **Update PLAN.md**: the status (`done`, `part done` or `blocked`) and the `Next start` line. If a `CLAUDE.md` or a memory note exists for this project, point it at the handover.
5. **Name the model and effort** for the next thread, with one line on why.
6. **Give the start line**, alone in a code block (for a part phase, `<n>` is the same phase again):
   ```
   <Project> — Phase <n> of <total>: <phase name> — START HERE <absolute path to handover>
   ```
7. **STOP.**
