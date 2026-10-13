---
name: phased
description: |
  Token-efficient phased project workflow with model routing. Use when the user runs /phased,
  asks to split a project into phases, or starts a thread with a line containing
  "— START HERE <path to HANDOFF-...md>". Recommends the cheapest viable model, plans phases
  into PLAN.md, runs ONE phase per thread with a handover, and escalates single steps to the
  opus-escalation subagent only with the user's approval, then continues on the lighter model.
metadata:
  version: "1.0.0"
---

# Phased: cheapest model that does the job well

Two entry points:
- **New project**: the user describes a project (or runs `/phased <description>`). Go to **A. Plan**.
- **Next phase**: the thread starts with `<Project> — Phase <n> of <total>: <name> — START HERE <path>`. Go to **B. Run a phase**.

## Models

Use the latest model in each tier that the user's plan offers. If you don't know which ones they have, ask once and note the answer in PLAN.md.

| Tier | Use for | Typical effort |
|---|---|---|
| **Haiku** | Lookups, reading/summarising files, boilerplate, renames, formatting, simple single-file scripts | low |
| **Sonnet** | Most building: multi-file edits, scripts, configs, docs, debugging with a clear error | medium |
| **Opus** | Architecture and design trade-offs, ambiguous or dead-end debugging, security-sensitive work, reviews of risky changes | high |

Pick the **cheapest** tier that can do the phase well. When torn between two, pick the lighter one: escalation exists to catch the cases where it is not enough.

**Switching models.** A session should not change its own model, and you cannot rely on being able to. So:
- Between phases: tell the user which model and effort to select (`/model` in the CLI, or the model menu in the desktop app) before they paste the next START HERE line.
- Within a phase: escalate a single step to the **opus-escalation** subagent (section C). The session itself stays on the lighter model.
- If the current session runs a heavier model than this step needs, say so in one line and let the user decide whether to switch.

## A. Plan (no building)

1. **Triage first.** In 3 lines max: what the project is, the model + effort you recommend for *planning* it, and the model you expect most phases to need. If the current model is wrong for planning, say so and wait.
2. **If anything is unclear, ask before planning.** Ask at most 4 questions (use AskUserQuestion if available). Don't plan on guesses.
3. **Split into phases**, each small enough to finish in one thread. If a phase would need two threads, split it. For each phase:
   - Name and one-line goal
   - **Done when**: what the user will be able to see or test
   - **Estimated tokens** and how you got there (see Estimating)
   - **Model + effort**, and one line on why it is the cheapest that works
   - **Risky steps** in this phase, flagged in advance (they will trigger escalation)
   - What it needs from earlier phases
4. **Write `PLAN.md` in the project folder** (template below). If the user gave no folder, ask. Show the plan and **wait for approval**. Build nothing.

### Estimating
Rough range, show the working: files to read (about 1 token per 4 characters, so 10 KB ≈ 2.5k tokens) + expected output written + about 1–2k per tool round trip + the session's starting context. Each turn re-reads the context, so long threads cost far more than their final size: that is why phases stay small.

### PLAN.md template
```markdown
# <Project name>

Goal: <one line>
Folder: <full path>
Created: <YYYY-MM-DD>
Models available: <e.g. Haiku, Sonnet, Opus>

| # | Phase | Est. tokens | Actual | Model (effort) | Status |
|---|---|---|---|---|---|
| 1 | <name> | 20–35k | | Sonnet (medium) | not started |

Status values: not started · in progress · part done · done

## Phases
### 1. <name>
Goal: ...
Done when: ...
Estimate working: ...
Model why: ...
Risky steps: ...
Needs: ...

## Escalation log
| Date | Phase | Trigger | Mode | Opus tokens | Outcome |
|---|---|---|---|---|---|
```

## B. Run a phase

1. **Name the thread** `<Project name> — Phase <n>`. If you have a tool that renames the current session, use it; otherwise tell the user the name to give it.
2. **Check the model.** If the session's model differs from PLAN.md's pick for this phase, say so in one line and ask whether to continue.
3. **Baseline.** If you have a tool that reports context or plan usage, record the starting figures. Otherwise note that usage will be "not measured" unless the user supplies it (e.g. from `/context` or `/cost` in the CLI).
4. **Read only** PLAN.md, the handover, and the files the handover names. Ask before reading anything wider.
5. **Work the phase.** Set PLAN.md status to `in progress`.
6. **Escalation triggers, checked in this priority order** (section C):
   1. **Before a risky change**: anything hard to undo, such as production or device config, deleting data, sending or publishing anything, client-facing documents, credentials, or security/identity changes.
   2. **Low confidence**: before acting, if you would not bet on this step working or being right, rate it low and stop.
   3. **Stuck**: the same fix, or attempts at a working solution, failed twice.
7. **Keep the thread short.** If it is getting long, or you notice you've lost an earlier decision, stop now: write the handover, mark the phase `part done`.
8. **No other subagents or parallel work** unless the user approves. Say why it's worth the extra tokens first.

## C. Escalate one step (only with approval)

1. **Stop and tell the user**, 3 lines max: the trigger, what's at stake, and which mode you propose:
   - **REVIEW**: Opus checks the plan or approach and returns a verdict, no changes. Default for risky changes and low confidence.
   - **SOLVE**: Opus does the stuck step itself and hands back. Default for "failed twice".
   Add a rough cost (a focused escalation is usually 10–40k tokens, depending on files read).
2. **Ask**: *Approve Opus review* / *Approve Opus to solve this step* / *Carry on with the current model* / *Stop here*.
3. **If approved**, call the Agent tool in the foreground (the next step depends on it) with the escalation subagent: `subagent_type: "phased:opus-escalation"` when installed as a plugin, or `"opus-escalation"` when installed manually. Use whichever appears in your list of available agents. If neither does, tell the user the subagent is missing and stop. The brief must stand alone and stay tight:
   ```
   MODE: REVIEW | SOLVE
   TRIGGER: risky change | low confidence | failed twice
   PROJECT: <name>, phase <n>: <goal>. Done when: <check>
   STEP: <the one step in question>
   PLANNED / TRIED: <the plan, or each failed attempt and its exact error>
   FILES (read only these unless you have a specific reason): <full paths>
   CONSTRAINTS: <anything the user decided that must hold>
   ```
4. **Relay the handback in short form**: verdict, what changed, the next step. Don't paste it whole.
5. **Log it** in PLAN.md's escalation log. Take the Opus tokens from the Agent result's usage figure; if none is shown, write `not measured`.
6. **Carry on with the lighter model** from the handback's "NEXT FOR THE LIGHTER MODEL". If it says the heavier model is still needed for the rest of the phase, stop, write the handover, and recommend that model for the next thread.
7. A STOP verdict on a risky change means do not do it. Tell the user and wait.

## D. End of phase (or part phase)

1. **Show the "done when" check passing** (actual output or what to look at) and **wait for the user to confirm.** Skip for a part phase: say what's left.
2. **Record actual use in PLAN.md** next to the estimate, measured against the B3 baseline, plus any escalation tokens. If it can't be measured, write `not measured`. **Never guess.**
3. **Write `HANDOFF-<YYYY-MM-DD>-PHASE-<n>.md`** in the project folder, complete enough that this thread could be deleted:
   - What was built
   - Decisions made, and why
   - Files touched (full paths)
   - How to run or test it
   - Known faults and open questions
   - Escalations this phase, with their verdicts
   - **Exactly where the next phase starts**: first action, and the files it must read (only those)
4. **Update pointers.** If the project has a `CLAUDE.md`, or Claude Code memory holds a note for this project, point it at the new handover. Don't create one unless asked.
5. **Set the phase status** in PLAN.md (`done` or `part done`).
6. **Tell the user which model and effort to select** for the next thread, and why in one line.
7. **Give the start line**, alone in its own code block, in exactly this format:
   ```
   <Project name> — Phase <n> of <total>: <phase name> — START HERE <full path to handover>
   ```
   For a part phase, `<n>` is the same phase again.
8. **STOP.** Do not start the next phase.

## Style
Lead with the answer. Keep replies short. One command per code block. Never print or store secrets.
