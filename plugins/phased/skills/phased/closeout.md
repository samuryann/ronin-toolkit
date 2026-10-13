# Close-out (project complete)

Ask one multi-select question with exactly these 4 options, in this order (no "nothing more": Skip covers it): **Ticket note** · **Save the lesson** · **Archive the sessions** · **Delete the sessions**. Both archive and delete picked: delete. Do only what's picked, then step 5:

1. **Ticket note.** Write `TICKET-NOTE.md` in the project folder and show it in one code block, ready to paste. Telegraphic: fewest words that keep every fact (names, paths, codes, counts, dates), with abbreviations and arrows; no prose. Lines: `Issue:` · `Cause:` · `Fix:` · `Verified:` · `Ruled out:` · `Follow-up:` (omit empty ones). Build it from PLAN.md and the last handover; read earlier handovers only for a missing fact. No secrets.
2. **Save the lesson.** Content: date · project · symptom keywords · root cause or outcome (fact) · the fix · any gotcha. No secrets. Where:
   - `~/phased/SOURCES.md` has a `save:` folder: write it there as one note in the same format as that folder's existing notes (if a note already covers it, update that instead), and add a one-line pointer to its index (e.g. `MEMORY.md`) if there is one.
   - Otherwise: append 3–5 lines to `LESSONS.md` in the folder that holds the project folder (e.g. `~/phased/LESSONS.md`), no client names.
3. **Archive the sessions** (reversible) **or 4. delete them** (permanent; the app asks the user to confirm each). Covers this project's phase sessions and its control thread; do this session last. Pinned or on-screen sessions may be refused: list those for the user. Without the tools, list the names. PLAN.md and the handovers hold everything either way.
5. **Project folder**: not an option; say where it is and that it's kept. Remove it only if the user then asks.

Send the final `PHASED STATUS — <Project> — complete` to the control thread **before** archiving or deleting anything, then stop.
