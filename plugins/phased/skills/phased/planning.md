# A. Plan (no building)

1. **Triage**, in 3 lines max: what the job is, the model and effort for planning it, and the model most phases will need. If no folder was given, propose `~/phased/<project-slug>/` in the same message (common for network or remote-system work with no codebase).
   - **Seen before?** If `LESSONS.md` exists in the projects' parent folder (e.g. `~/phased/`), grep it for 2–3 keywords from the problem. Mention any match in one line; don't read the whole file.
   - **Fits in one thread?** Say so and offer to just do it. Phasing costs more than it saves on small jobs.
   - **Is the current model wrong for planning?** Say so and wait.
2. **Is there already a PLAN.md in the folder?** Don't overwrite it. (If it has no `Next start` line, it isn't a phased plan: pick another folder or file name.) Ask: resume it, revise it, or start new (rename the old one to `PLAN-<date>-old.md`).
3. **If anything is unclear, ask** before planning, at most 4 questions. Don't ask what a config or output paste would answer: ask for the paste instead. For troubleshooting, ask about the symptoms, when it started, what changed, the scope (who and what is affected), and what's already been tried.
4. **Pick the shape:**
   - **Build**: phases deliver working pieces.
   - **Troubleshoot**: gather evidence > hypotheses > test (cheapest and most likely first) > fix > verify it holds.
     - An investigation's "done when" is evidence: e.g. "root cause shown by <output>", or "A–C ruled out with evidence".
     - A fix isn't done until its verification has been seen.
     - Put the fix in its own phase, so the risky change gets a clean thread and an approval.
5. **Split into phases** of about 60k of work or less each (see Estimating), each with a 1–2 word name (e.g. Evidence, Fix, Verify). Fewer, well-sized phases beat many tiny ones, because every thread pays the startup cost again.
6. **Write `PLAN.md`** from the template below, keeping it terse: every phase thread reads it. Show it, then **wait for approval**. Revise and show it again if asked. Build nothing.
7. **Once it's approved:**
   - Fill in `Next start` (phase 1's start line points at PLAN.md itself, with no handover file).
   - Rename this thread `<Project> — Control`: it becomes the control thread (see Control below).
   - Hand off phase 1 as in SKILL.md D6, then **stop**, unless the user asks you to continue here.

## Control
The planning thread, renamed `<Project> — Control`: a dashboard, not a workspace. On a `PHASED STATUS` message, reply with one progress line, don't re-read files, and offer to open the next phase if you can start sessions (SKILL.md D6).

## Estimating
Unit: **k tokens of work above the session's baseline** (what D2 measures; the baseline is setup overhead and varies by machine). Sum: files to read (1 token ≈ 4 chars) + output written + ~1–2k per tool round trip + ~1–3k per filtered user paste. Give a range and one line of working.

## PLAN.md template
```markdown
# <Project>: <one-line title>
Project: <short name, 1–3 words, used in thread names and start lines>
Next start: <START HERE line for the next phase>
Goal: <one line> · Shape: build|troubleshoot · Folder: <abs path> · Created: <date> · Models: <available>

## Decisions
- <answers to clarifying questions and constraints, one line each>

| # | Phase | Done when | Est. work | Actual | Model (effort) | Status |
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
