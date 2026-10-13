---
name: phased
description: Token-efficient phased workflow for IT projects and troubleshooting. Small phases, one per thread with handovers, cheapest viable model, Opus escalation only with approval. Use for /phased, "split this into phases", a pasted "START HERE <path>" line, or resuming a phased PLAN.md.
---

# Phased

Core file. Read the other two in this skill's base directory (if it wasn't shown, glob `**/phased/planning.md` under `~/.claude`) only when needed:
- `planning.md`: a new project.
- `escalation.md`: an escalation trigger fires.

## Entry
- **New project or problem**: follow `planning.md`.
- **`START HERE` + a path** (match loosely; dashes may be altered): run a phase (**B**). The path is a handover, or PLAN.md for phase 1.
- **Resume, no start line**: use the `Next start` line in the folder's PLAN.md. A PLAN.md without one isn't a phased plan: don't adopt it. No PLAN.md: ask for the folder.

## Models
| Tier | Use for | Effort |
|---|---|---|
| Haiku | lookups, summarising, boilerplate, formatting, simple scripts | low |
| Sonnet | most building, configs, docs, debugging with a clear error | medium |
| Opus | design trade-offs, ambiguous/dead-end debugging, security-sensitive work, risky-change review | high |

Cheapest tier that does the work well; when torn, go lighter. A session can't reliably switch its own model: between phases, tell the user what to select (`/model` or the model menu); within a phase, escalate one step (`escalation.md`).

## Token rules (every turn)
- **Read narrowly**: search before reading; read line ranges, not whole files.
- **Filter output at the source** (`grep`, `Select-String`, `tail`, time windows, `head`). Never dump a full config, log or listing.
- **User-run commands**: give the whole diagnostic set at once, one paste-safe line per code block, and ask for **only** the relevant output.
- **Short replies**: don't restate the plan, echo files, or summarise what the user just said.

## Ground rules
- Absolute paths in PLAN.md, handovers and start lines.
- **No secrets in any file or brief**; ask the user to mask keys, PSKs, hashes and tokens before pasting. If the folder is shared or public, keep client names, IPs and hostnames out too.
- **Systems you can't reach**: give exact commands, treat pasted output as evidence, and label conclusions **fact** (seen in output) or **inference**.

## B. Run a phase
1. **Name the thread** `<Project> — Phase <n>` with a rename tool if you have one; otherwise tell the user the name.
2. **Model check**: if yours differs from PLAN.md's pick, say so in one line and ask whether to continue.
3. **Baseline**: if a usage tool exists, record the context size and plan usage now.
4. **Read only** PLAN.md, the given handover (never older ones) and the files it names. Phase 1: PLAN.md alone.
5. **Check the handover against reality** (not for phase 1): do the named files exist, and is the state as described? If not, stop and say what differs.
6. **Mark the phase `in progress`** (if another phase is already in progress, ask first), then work it.
   - **Troubleshooting**: check the Ruled out table first, test the cheapest and most likely hypothesis first, and log each one ruled out with its evidence.
7. **Escalation triggers, in priority order** (read `escalation.md` when one fires):
   1. **A risky change is next**: anything hard to undo, e.g. production or device config, deleting or overwriting data, migrations, credentials, security or identity changes, sending or publishing, client-facing documents.
   2. **Low confidence**: guessing a command, flag or syntax; several causes fit the evidence; changing something you haven't read; or acting on memory rather than output seen in this thread.
   3. **Stuck**: the same fix, or attempts at a working solution, failed twice.
8. **Before any approved risky change**: capture the current state (config backup or current values), have the rollback ready, and restate exactly what will change.
9. **Stop early and hand over as `part done`** if the context passes ~60%, the context was compacted, an earlier decision has been lost, or the phase has outgrown its plan.
10. **No other subagents or parallel work** without approval; say why it's worth the tokens first.

## D. End of phase (or part phase)
1. **Show the "done when" check passing** with real output, and **wait for the user to confirm.** A failing check means not done: fix it if there's room, otherwise hand over as `part done`. For a part phase, say what's left.
2. **Record the actual** in PLAN.md: `~<peak>k ctx, plan +<x>%` ("approx" if other sessions ran), plus escalation tokens. Write `not measured` if there's no usage tool or the context was compacted. Never guess.
3. **Write `HANDOFF-<YYYY-MM-DD>-PHASE-<n>.md`** (add `-2`, `-3`... if it exists). **Under ~500 words, facts not narrative**, because the next thread pays for every line: built/found · decisions + why, one line each · files touched (absolute) · how to test, including user-run commands · ruled out · key log or output lines quoted, not whole logs · open faults and questions · escalations + verdicts · uncommitted changes if it's a git repo (offer to commit, never unasked) · **next start: first action + the only files it needs**.
4. **Update PLAN.md**: the status (`done`, `part done` or `blocked`) and `Next start`. If a `CLAUDE.md` or memory note exists for this project, point it at the handover.
5. **Name the model and effort** for the next thread, with one line on why.
6. **Give the start line** alone in a code block (a part phase repeats its `<n>`):
   ```
   <Project> — Phase <n> of <total>: <phase name> — START HERE <absolute path to handover>
   ```
7. **STOP.**
