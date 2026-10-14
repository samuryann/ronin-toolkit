# A. Plan (no building)

**Guided start** (no details given): current folder holds a phased PLAN.md? Offer its `Next start` (`none`: say the project is complete). Otherwise explain in ≤3 lines (small phases, one session each, cheapest model, asks before risky changes or Opus), then ask for the job in one line and the project folder (suggest `~/phased/<slug>/`, offer to create it). Once it exists, one line: phase sessions open **in this folder** (folder picker), which groups them and skips unrelated memory. Then continue below.

1. **Triage**, 3 lines max: the job, the model and effort for planning it, the model most phases need. No folder given: propose `~/phased/<project-slug>/` in the same message.
   - **Seen before?** Search past fixes (SKILL.md token rules); one line per match; useful paths go under `Notes:` in PLAN.md so phases don't search again. `~/phased/SOURCES.md` missing and `ls -d ~/.claude/projects/*/memory` finds notes? Offer once to create it with the line `~/.claude/projects/*/memory` (all Claude memory, future folders too).
   - **Fits in one thread?** Offer to just do it: phasing costs more than it saves on small jobs.
   - **Is the current model wrong for planning?** Say so and wait.
2. **PLAN.md already in the folder?** Never overwrite it. (No `Next start` line: not a phased plan; pick another folder.) Ask: resume, revise, or start new (old one renamed `PLAN-<date>-old.md`).
3. **Unclear? Ask** before planning, at most 4 questions. Don't ask what a config or output paste would answer: ask for the paste. Troubleshooting: symptoms, when it started, what changed, scope (who and what), what's been tried. Remote systems: how commands reach them (RMM job, remote session, SSH, RDP) and their OS, unless obvious.
4. **Pick the shape:**
   - **Build**: phases deliver working pieces.
   - **Troubleshoot**: gather evidence > hypotheses > test (cheapest and most likely first) > fix > verify it holds.
     - An investigation's "done when" is evidence: e.g. "root cause shown by <output>", or "A–C ruled out with evidence".
     - A fix isn't done until its verification has been seen.
     - Put the fix in its own phase, so the risky change gets a clean thread and an approval.
5. **Split into phases** of about 60k of work or less each (see Estimating), each with a 1–2 word name (e.g. Evidence, Fix, Verify). Every new session rebuilds the ~baseline cache, so **split only where it pays**: a model change, a wait (overnight, a scheduled window), the ~60k limit, or a risky change that needs its own approval thread. Otherwise merge. Mechanical phases (verify against a clear check, cleanup, docs from notes) go to Haiku; bulk reading inside any phase goes to the Haiku worker.
6. **Name the project**: 1–4 words for the job (e.g. `File server migration`); reuse this thread's title if it already says that. Rename this thread `<Project> — Control` now and check it took (if not, give the user the exact name). Every phase thread carries the project name.
   **Write `PLAN.md`** from the template below, keeping it terse: every phase thread reads it. Show it, then ask *Approve* / *Revise* (AskUserQuestion). Build nothing until approved.
7. **Once it's approved:**
   - Fill in `Next start` (phase 1's start line points at PLAN.md itself, with no handover file).
   - Record `Control: <this session's id>` (get session `self`) in PLAN.md; this is the control thread (see Control below).
   - Hand off phase 1 as in SKILL.md D5, then **stop**. If the user asks to continue here instead: keep the Control name, note current usage as phase 1's start for its Actual (B10 counts from the session baseline), run phase 1 from SKILL.md B2.

## Control
The planning thread, `<Project> — Control`: a dashboard, not a workspace. Phases don't message it (each message would wake and reload it); PLAN.md is the record. Asked for status: read PLAN.md's table and `Next start`, reply in 2 lines (progress, next start line), and offer to open the next phase if you can start sessions (SKILL.md D5).

## Estimating
Unit: **k tokens of work above the session's baseline** (what D2 measures). Sum: files to read (1 token ≈ 4 chars) + output written + ~1–2k per tool round trip + ~1–3k per filtered user paste. Give a range and one line of working. Real phases so far: recon/evidence with pastes 7–30k · build 25–60k · verify 5–15k; they ran above estimate more often than below. Escalations are logged separately.

## PLAN.md template
```markdown
# <Project>: <one-line title>
Project: <the project name from step 6, without "— Control">
Control: <this session's id, or none>
Next start: <START HERE line for the next phase>
Goal: <one line> · Shape: build|troubleshoot · Folder: <abs path> · Created: <date> · Models: <available>
Access: <how commands reach the systems + OS, e.g. Datto RMM job (SYSTEM) on Windows Server 2022, or local>
Notes: <abs paths of matching past notes, or none>

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
| Date | Phase | Trigger | Mode | Tokens | Verdict |
|---|---|---|---|---|---|
```
