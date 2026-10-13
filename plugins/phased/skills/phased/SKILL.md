---
name: phased
description: |
  Token-efficient phased project workflow with model routing. Use when the user runs /phased,
  asks to split a project or investigation into phases, pastes a line containing "START HERE"
  and a path to a HANDOFF-...md or PLAN.md file, or asks to resume a phased project. Recommends
  the cheapest viable model, plans phases into PLAN.md, runs ONE phase per thread with a
  handover, and escalates single steps to the opus-escalation subagent only with the user's
  approval, then continues on the lighter model.
metadata:
  version: "1.1.0"
---

# Phased: cheapest model that does the job well

## Entry points
- **New project**: the user describes a project or problem. Go to **A. Plan**.
- **Next phase**: the message contains `START HERE` and a path. Go to **B. Run a phase**. Match loosely: the dashes may have been changed and the box formatting stripped. The path is what matters.
- **Resume without a start line**: the user names a project or folder. Read its `PLAN.md` and use the `Next start` line at the top. If there is no PLAN.md, ask for the folder.

## Models

Use the latest model in each tier the user's plan offers. If you don't know which ones they have, ask once and record the answer in PLAN.md.

| Tier | Use for | Typical effort |
|---|---|---|
| **Haiku** | Lookups, reading/summarising, boilerplate, renames, formatting, simple single-file scripts | low |
| **Sonnet** | Most building: multi-file edits, scripts, configs, docs, debugging with a clear error | medium |
| **Opus** | Architecture and trade-offs, ambiguous or dead-end debugging, security-sensitive work, reviewing risky changes | high |

Pick the **cheapest** tier that can do the phase well. When torn, pick the lighter one: escalation catches the cases where it isn't enough.

**Switching models.** A session can't reliably change its own model. Between phases, tell the user which model and effort to select (`/model` in the CLI, or the model menu in the app). Within a phase, escalate one step to the subagent (section C) while the session stays on the lighter model.

## Ground rules (every thread)
- **Absolute paths everywhere** in PLAN.md, handovers and start lines.
- **Never write secrets** (passwords, keys, tokens, PSKs) into PLAN.md, handovers or briefs. Write `<stored in: where>` instead.
- **One active phase at a time.** If PLAN.md shows another phase `in progress` and this thread isn't continuing it, ask before starting.
- **Systems you can't reach.** When the work runs on machines you can't access, give the user exact commands to run (one per code block) and treat their pasted output as the evidence. Record those commands in the handover.
- **Asking the user.** Use AskUserQuestion when available. Otherwise ask in plain text and stop until they answer.
- **Today's date.** Take it from the environment. If you don't have it, run `date`.

## A. Plan (no building)

1. **Triage**, 3 lines max: what the job is, the model + effort for *planning* it, and the model most phases will need.
   - **Too small to phase?** If it fits comfortably in one thread, say so and offer to just do it. The workflow's overhead isn't worth it for small jobs.
   - **Is the current model wrong for planning?** Say so and wait.
2. **Is there already a PLAN.md in the folder?** Don't overwrite it. Ask: resume it, revise it, or start a new plan (rename the old one to `PLAN-<YYYY-MM-DD>-old.md`).
3. **If anything is unclear, ask before planning.** At most 4 questions. Don't plan on guesses.
4. **Pick the shape:**
   - **Build**: phases deliver working pieces.
   - **Troubleshoot**: phases follow the evidence. Gather facts > form hypotheses > test them (cheapest and most likely first) > fix > verify it holds. "Done when" for an investigation phase is evidence-based, e.g. "root cause shown by <log/output>", or "hypotheses A–C ruled out with evidence". A fix is never "done" until its verification has been seen.
5. **Split into phases**, each small enough for one thread: an expected peak context of at most ~40% of the model's context window. Split anything bigger. For each phase:
   - Name and one-line goal
   - **Done when**: what the user will see or test
   - **Estimate** (see below) and how you got there
   - **Model + effort**, and one line on why it's the cheapest that works
   - **Risky steps**, flagged now (they will trigger escalation)
   - What it needs from earlier phases
6. **Write `PLAN.md`** (template below). Show it and **wait for approval**. If the user asks for changes, revise it and show it again. Build nothing.
7. **Once approved, close the planning thread:**
   - Write `HANDOFF-<YYYY-MM-DD>-PHASE-0.md`: the answers to the clarifying questions, the decisions made, the constraints, and where phase 1 starts.
   - Fill in `Next start` in PLAN.md.
   - Give the phase 1 model and start line as in **D**, then **stop**. Don't start phase 1 in the planning thread unless the user asks.

### Estimating
The unit is the **peak context of the thread, in k tokens**, because that's what can be measured at the end. Add up:
- the starting context (measure it if a usage tool exists, otherwise assume ~20k),
- files to read (about 1 token per 4 characters, so 10 KB ≈ 2.5k),
- output you'll write,
- about 1–2k per tool round trip.

Give a range. Billed usage is higher than peak context because each turn re-reads the context. That's why phases stay small.

### PLAN.md template
```markdown
# <Project name>

Next start: <the full START HERE line for the next phase>
Goal: <one line>
Shape: build | troubleshoot
Folder: <absolute path>
Created: <YYYY-MM-DD>
Models available: <e.g. Haiku, Sonnet, Opus>

| # | Phase | Est. peak ctx | Actual | Model (effort) | Status |
|---|---|---|---|---|---|
| 1 | <name> | 30–45k | | Sonnet (medium) | not started |

Status values: not started · in progress · part done · done · blocked

## Phases
### 1. <name>
Goal: ...
Done when: ...
Estimate working: ...
Model why: ...
Risky steps: ...
Needs: ...

## Ruled out (troubleshooting)
| Hypothesis | Evidence that ruled it out | Phase |
|---|---|---|

## Escalation log
| Date | Phase | Trigger | Mode | Opus tokens | Verdict / outcome |
|---|---|---|---|---|---|
```

## B. Run a phase

1. **Name the thread** `<Project name> — Phase <n>`. Use a session-rename tool if you have one; otherwise tell the user the name.
2. **Check the model.** If yours differs from PLAN.md's pick for this phase, say so in one line and ask whether to continue.
3. **Baseline.** If a usage tool exists, record the current context size and plan usage. If not, note that actuals will be `not measured` unless the user supplies them (e.g. from `/context` or `/cost`).
4. **Read only** PLAN.md, the handover, and the files the handover names. Ask before reading anything wider.
5. **Check the handover still matches reality.** Do the named files exist, and does the state look as described? If not, stop and say what differs before building on it.
6. **Set the phase to `in progress`** in PLAN.md and work the phase. For troubleshooting, check the Ruled out table before testing anything, and add every newly ruled-out hypothesis with its evidence as you go.
7. **Escalation triggers, in priority order** (section C):
   1. **Before a risky change**: anything hard to undo. Production or device config, deleting or overwriting data, sending or publishing anything, credentials, security or identity changes, schema or data migrations, client-facing documents.
   2. **Low confidence**: before acting, you would not bet on it. Concrete signals:
      - you're guessing a command, flag, API or syntax you haven't verified,
      - several causes fit the evidence and you can't tell them apart,
      - you're about to change something you haven't read,
      - you're acting on memory rather than on output you've seen in this thread.
   3. **Stuck**: the same fix, or attempts at a working solution, failed twice.
8. **Stop early and hand over** (mark it `part done`) when any of these happens:
   - the context passes ~60% of the window,
   - the context was compacted during the phase,
   - you notice you've lost an earlier decision,
   - the phase turns out to be bigger than planned.

   Don't push through.
9. **No other subagents or parallel work** unless the user approves. Say why it's worth the extra tokens first.

## C. Escalate one step (only with approval)

1. **Stop and tell the user**, 3 lines max: the trigger, what's at stake, and the proposed mode.
   - **REVIEW**: Opus checks the plan or approach and returns a verdict. It makes no changes. This is the default for risky changes and low confidence.
   - **SOLVE**: Opus does the stuck step itself and hands back. This is the default for "failed twice".

   Add a rough cost (usually 10–40k tokens, depending on how many files it reads).
2. **Ask:** *Approve Opus review* / *Approve Opus to solve this step* / *Carry on with the current model* / *Stop here*.
   - At a **risky-change** trigger, *Carry on* means the user approves making the risky change without a review. Restate exactly what will change before you do it.
3. **If approved,** call the Agent tool in the foreground with the escalation subagent: `subagent_type: "phased:opus-escalation"` when installed as a plugin, or `"opus-escalation"` when installed manually. Use whichever appears in your available agents. If neither does, tell the user the subagent is missing and stop. The brief must stand alone:
   ```
   MODE: REVIEW | SOLVE
   TRIGGER: risky change | low confidence | failed twice
   PROJECT: <name>, phase <n>: <goal>. Done when: <check>
   STEP: <the one step in question>
   PLANNED / TRIED: <the plan, or each failed attempt with its exact error/output>
   RULED OUT: <hypotheses already eliminated, with evidence> (troubleshooting)
   FILES (absolute paths; read only these unless you have a specific reason): <paths>
   CAN RUN: <what it may execute, or "nothing: user runs commands">
   CONSTRAINTS: <decisions that must hold>
   ```
4. **After the handback:**
   - **SOLVED or files touched**: re-read the touched files (only those) before continuing. Your earlier view of them is stale.
   - **NEEDS INFO**: get the missing information, from the user if needed. A second call for the same step counts toward the limit below.
   - **STOP on a risky change**: don't make the change. Tell the user and wait.
   - **Confidence low, or "still needs the heavier model"**: tell the user. Don't continue blindly.
5. **Relay the result in short form**: the verdict, what changed, and the next step. Don't paste the whole handback.
6. **Log it** in PLAN.md's escalation log. Take the Opus tokens from the Agent result's usage figure; if none is shown, write `not measured`.
7. **Limit: 2 escalations per step.** If the step is still unresolved after two, stop: write the handover, mark the phase `blocked` or `part done`, and recommend running the next thread on Opus.
8. **Otherwise carry on with the lighter model** from the handback's next step.

## D. End of phase (or part phase)

1. **Show the "done when" check passing**, with the actual output or what to look at, and **wait for the user to confirm.**
   - **The check fails, or the user says it doesn't work?** The phase isn't done. Fix it if the thread has room; otherwise hand over as `part done` with the failure recorded.
   - **Part phase?** Skip the check and say what's left.
2. **Record the actual** in PLAN.md: `~<peak context>k ctx, plan +<x>%`, measured against the B3 baseline, plus any escalation tokens. Mark plan percentages "approx" if other sessions were running. Write `not measured` if there's no usage tool or the context was compacted. **Never guess.**
3. **Write the handover**, `HANDOFF-<YYYY-MM-DD>-PHASE-<n>.md`. If that name already exists, add `-2`, `-3` and so on. Write it so this thread could be deleted:
   - What was built or found
   - Decisions made, and why
   - Files touched (absolute paths)
   - How to run or test it, including commands the user runs on systems you can't reach
   - Hypotheses ruled out this phase, with their evidence (also copied into PLAN.md)
   - Known faults and open questions
   - Escalations this phase, with their verdicts
   - Uncommitted changes, if the folder is a git repository. Offer to commit them; don't commit without asking.
   - **Exactly where the next phase starts**: the first action, and the only files it must read
4. **Update PLAN.md**: the phase status (`done`, `part done` or `blocked`), and the `Next start` line.
5. **Update pointers.** If the project has a `CLAUDE.md`, or Claude Code memory holds a note for this project, point it at the new handover. Don't create either unless asked.
6. **Tell the user which model and effort to select** for the next thread, with one line on why.
7. **Give the start line** alone in its own code block, in exactly this format:
   ```
   <Project name> — Phase <n> of <total>: <phase name> — START HERE <absolute path to handover>
   ```
   For a part phase, `<n>` is the same phase again.
8. **STOP.** Do not start the next phase.

## Style
Lead with the answer. Keep replies short. One command per code block. Never print or store secrets.
