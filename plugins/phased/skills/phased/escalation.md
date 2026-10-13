# C. Escalate one step (only with approval)

1. **Tell the user**, in 3 lines max: the trigger, what's at stake, and the mode you propose.
   - **REVIEW**: Opus judges the plan. Read-only, no changes. The default for a risky change or low confidence.
   - **SOLVE**: Opus does the step and hands back. The default for "failed twice".

   Add a rough cost: usually 10–40k tokens, depending on what it has to read.
2. **Ask:** *Opus review* / *Opus solve* / *Carry on with the current model* / *Stop*.
   - At a risky-change trigger, *Carry on* is the user's explicit approval of the change. Do the B8 prep, then proceed.
3. **If approved,** call the Agent tool in the foreground. Use `subagent_type: "phased:opus-escalation"` for a plugin install, or `"opus-escalation"` for a manual one, whichever is in your available agents. If neither is, say so and stop.

   **Keep the brief lean:** give exact error lines and file paths with line ranges rather than whole files or logs. Opus re-reads anything you only point it to.
   ```
   MODE: REVIEW | SOLVE
   TRIGGER: risky change | low confidence | failed twice
   GOAL: <project>, phase <n>: <goal>. Done when: <check>
   STEP: <the one step>
   PLANNED / TRIED: <the plan, or each attempt + exact error/output lines>
   RULED OUT: <hypothesis: evidence>, if any
   FILES: <absolute paths, with line ranges where useful>
   CAN RUN: <what it may execute, or "nothing: user runs commands">
   CONSTRAINTS: <decisions that must hold>
   ```
4. **After the handback:**
   - **Files touched:** re-read only those files (your copy is stale).
   - **NEEDS INFO:** get it, from the user if necessary. A second call counts toward the limit.
   - **STOP on a risky change:** don't make it. Tell the user and wait.
   - **Low confidence, or "still needs the heavier model":** tell the user. Don't continue blindly.
5. **Relay in short form**: the verdict, what changed, and the next step. Then log one row in PLAN.md's Escalations table. Opus tokens come from the Agent result's usage figure; if none is shown, write `not measured`.
6. **Limit: 2 escalations per step.** If the step is still unresolved, write the handover, mark the phase `blocked` or `part done`, and recommend Opus for the next thread.
7. **Otherwise continue on the lighter model** from the handback's next step.
