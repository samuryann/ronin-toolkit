---
name: phased
description: Token-efficient phased workflow for IT projects and troubleshooting. Small phases, one per thread with handovers, cheapest viable model, Opus escalation only with approval. Use for /phased, "split this into phases", a pasted "START HERE <path>" line, a "PHASED STATUS" message, or resuming a phased PLAN.md.
---

# Phased

Core file. Read the other two in this skill's base directory (if it wasn't shown, glob `**/phased/planning.md` under `~/.claude`) only when needed:
- `planning.md`: a new project.
- `escalation.md`: an escalation trigger fires.

**Tools may need loading.** Session tools (rename, usage, message, start session) may be deferred: search for them before deciding you don't have them.

## Entry
- **New project or problem**: follow `planning.md`.
- **`START HERE` + a path** (match loosely; dashes may be altered): run a phase (**B**). The path is a handover, or PLAN.md for phase 1.
- **`PHASED STATUS` message**: you're the control thread; see Control in `planning.md`.
- **Resume, no start line**: use the `Next start` line in the folder's PLAN.md. A PLAN.md without one isn't a phased plan: don't adopt it. No PLAN.md: ask for the folder.

## Models
| Tier | Use for | Effort |
|---|---|---|
| Haiku | lookups, summarising, boilerplate, formatting, simple scripts | low |
| Sonnet | most building, configs, docs, debugging with a clear error | medium |
| Opus | design trade-offs, ambiguous/dead-end debugging, security-sensitive work, risky-change review | high |

Use the cheapest tier that does the work well; when torn, go lighter. A session can't reliably switch its own model: a new phase gets a new session on the right model, and within a phase you escalate one step (`escalation.md`).

## Token rules (every turn)
- **Budget**: tokens count above the session's starting context (baseline). ~60k of work per phase; stop early past ~100k (B9).
- **Evidence ladder**: free evidence first (config, existing logs, current state), analysed before asking for more. Live tests, other people or downtime only if that didn't settle it. Batch within a step.
- **Read narrowly**: search first; read line ranges, not whole files.
- **Filter at the source** (`grep`, `Select-String`, `tail`, time windows). Never dump a full config, log or listing.
- **User-run commands**: one block per device sequence where the CLI takes multi-line pastes; PowerShell/shells one paste-safe line per block. Ask for **only** the relevant output.
- **Platform syntax**: device CLIs aren't Linux (e.g. reduced `grep`). Use only syntax verified for that platform, else it's low confidence. **Every verification must be able to fail** (case-insensitive or substring matches can hit the old value).
- **Short replies**: don't restate the plan, echo files, or summarise the user.

## Ground rules
- Absolute paths in PLAN.md, handovers and start lines. Use the `Project:` short name from PLAN.md everywhere.
- **No secrets in any file or brief**; ask the user to mask keys, PSKs, hashes and tokens before pasting. If the folder is shared or public, keep client names, IPs and hostnames out too.
- **Systems you can't reach**: give exact commands, treat pasted output as evidence, and label conclusions **fact** (seen in output) or **inference**.

## B. Run a phase
1. **Name the thread** `<Project> — Phase <n>` (rename tool, else tell the user). Open with one roadmap line: `Phase 2/3 · 1 Evidence ✓ · 2 Root cause ← · 3 Fix`.
2. **Model check**: if yours differs from PLAN.md's pick, say so in one line and ask whether to continue.
3. **Baseline**: if a usage tool exists, record the context size and plan usage now.
4. **Read only** PLAN.md, the given handover (never older ones) and the files it names. Phase 1: PLAN.md alone.
5. **Check the handover against reality** (not for phase 1): do the named files exist, and is the state as described? If not, stop and say what differs.
6. **Mark the phase `in progress`** (if another phase is already in progress, ask first), then work it.
   - **Troubleshooting**: check the Ruled out table first, test the cheapest and most likely hypothesis first, and log each one ruled out with its evidence.
   - **Evidence answers a later phase early?** Propose merging or skipping the phase rather than working through it.
7. **Escalation triggers, in priority order** (read `escalation.md` when one fires):
   1. **A risky change is next**: anything hard to undo, e.g. production or device config, deleting or overwriting data, migrations, credentials, security or identity changes, sending or publishing, client-facing documents.
   2. **Low confidence**: guessing a command, flag or syntax; several causes fit the evidence; changing something you haven't read; or acting on memory rather than output seen in this thread.
   3. **Stuck**: the same fix, or attempts at a working solution, failed twice.
8. **Before any approved risky change**: capture the current state (config backup or current values), have the rollback ready, and restate exactly what will change.
9. **Stop early and hand over as `part done`** if work passes ~100k above the baseline (or 60% of the window, whichever comes first), the context was compacted, an earlier decision has been lost, or the phase has outgrown its plan.
10. **No other subagents or parallel work** without approval; say why it's worth the tokens first.

## D. End of phase (or part phase)
1. **Show the "done when" check passing** with real output, and **wait for the user to confirm.** A failing check means not done: fix it if there's room, otherwise hand over as `part done`. For a part phase, say what's left.
2. **Record the actual** in PLAN.md as work above the baseline: `~<k> work, plan +<x>%` ("approx" if other sessions ran), plus escalation tokens. Write `not measured` if there's no usage tool or the context was compacted. Never guess.
3. **Write `HANDOFF-<YYYY-MM-DD>-PHASE-<n>.md`** (add `-2`, `-3`... if it exists). **Under ~500 words, facts not narrative**, because the next thread pays for every line: built/found · decisions + why, one line each · files touched (absolute) · how to test, including user-run commands · ruled out · key log or output lines quoted, not whole logs · open faults and questions · escalations + verdicts · uncommitted changes if it's a git repo (offer to commit, never unasked) · **next start: first action + the only files it needs**.
4. **Update PLAN.md**: the status (`done`, `part done` or `blocked`) and `Next start`. If a `CLAUDE.md` or memory note exists for this project, point it at the handover.
5. **Report to the control thread** if you can message sessions (`parent`, or the one titled `<Project> — Control`), max 5 lines:
   ```
   PHASED STATUS — <Project> — Phase <n>: done | part done | blocked
   <key result, fact/inference>
   Next: Phase <m> <name>, <model> (<effort>)
   Start: <start line>
   ```
6. **Hand off the next phase.** If the project is complete, say so in one line and skip this step.
   - **Can start sessions:** ask "Open Phase <m> on <Model>?"; on yes, start it with the start line as its first message, set its model, name it, open it.
   - **Otherwise** end with:

     **▶ Start a NEW session on <Model> (<effort>) and paste:**
     ```
     <Project> — Phase <m> of <total>: <phase name> — START HERE <absolute path to handover>
     ```
     (A part phase repeats its own number.)
7. **STOP.**

