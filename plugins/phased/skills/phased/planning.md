# A. Plan (no building)

1. **Triage**, in 3 lines max: what the job is, the model and effort for planning it, and the model most phases will need.
   - **Fits in one thread?** Say so and offer to just do it. Phasing costs more than it saves on small jobs.
   - **Is the current model wrong for planning?** Say so and wait.
2. **Is there already a PLAN.md in the folder?** Don't overwrite it. Ask: resume it, revise it, or start new (rename the old one to `PLAN-<date>-old.md`).
3. **If anything is unclear, ask** before planning, at most 4 questions. For troubleshooting, ask for the symptoms, when it started, what changed, the scope (who and what is affected), and what's already been tried.
4. **Pick the shape:**
   - **Build**: phases deliver working pieces.
   - **Troubleshoot**: gather evidence > hypotheses > test (cheapest and most likely first) > fix > verify it holds.
     - An investigation's "done when" is evidence: e.g. "root cause shown by <output>", or "A–C ruled out with evidence".
     - A fix isn't done until its verification has been seen.
     - Put the fix in its own phase, so the risky change gets a clean thread and an approval.
5. **Split into phases** small enough for one thread: an expected peak context of at most ~40% of the model's window. Fewer, well-sized phases beat many tiny ones, because every thread pays the startup cost again.
6. **Write `PLAN.md`** from the template below, keeping it terse: every phase thread reads it. Show it, then **wait for approval**. Revise and show it again if asked. Build nothing.
7. **Once it's approved:**
   - Fill in `Next start` (phase 1's start line points at PLAN.md itself, with no handover file).
   - Give the phase 1 model and the start line, alone in a code block.
   - Then **stop**, unless the user asks you to continue in this thread.

## Estimating
The unit is the **peak context of the thread, in k tokens**, because that's what can be measured at the end. Add up:
- the starting context (measure it if you can, otherwise ~20k),
- the files to read (1 token ≈ 4 characters),
- the output you'll write,
- about 1–2k per tool round trip,
- about 1–3k per filtered command output the user pastes.

Give a range and one line of working.

## PLAN.md template
```markdown
# <Project>
Next start: <START HERE line for the next phase>
Goal: <one line> · Shape: build|troubleshoot · Folder: <abs path> · Created: <date> · Models: <available>

## Decisions
- <answers to clarifying questions and constraints, one line each>

| # | Phase | Done when | Est. peak | Actual | Model (effort) | Status |
|---|---|---|---|---|---|---|
| 1 | <name> | <check> | 30–45k | | Sonnet (medium) | not started |

Status: not started · in progress · part done · done · blocked

## Phase notes
1. <goal, one line> · Risky: <steps or none> · Needs: <inputs> · Why this model: <one line>

## Ruled out
| Hypothesis | Evidence | Phase |
|---|---|---|

## Escalations
| Date | Phase | Trigger | Mode | Opus tokens | Verdict |
|---|---|---|---|---|---|
```
