# Start menu (`/phased` or `/phased:start` with no details)

A start menu option named (a `new`/`resume`/`status`/`close-out` command): go straight to it, no step-3 question. New project: `planning.md` at once. Others: step 1 first; a project or folder given: use it.

1. One command, never reading whole plans:
`grep -H '^Next start:' PLAN.md 2>/dev/null; find ~/phased -mindepth 2 -maxdepth 2 -name PLAN.md -exec ls -t {} + 2>/dev/null | while IFS= read -r f; do awk -F'|' '/^Project:/{p=substr($0,10)} /^Next start:/{n=substr($0,13)} /^\| *[0-9]+ *\|/{t++; s=$8; gsub(/^ +| +$/,"",s); if(s~/^(done|skipped)/)d++; else if(c==""){x=$3; gsub(/^ +| +$/,"",x); c=x (s~/^not started/?"":" ("s")")}} END{printf "%s | %d/%d done | %s | %s\n",p,d,t,(n~/^none/?"complete":"next: "c),FILENAME}' "$f"; done`
2. Current folder has a PLAN.md: still ask step 3, with **Resume a project** first and recommended, its description naming this folder's project and next phase; picked: resume that project directly (SKILL.md Entry **Resume**; `none`: offer to add work).
3. One AskUserQuestion, exactly: **New project** · **Resume a project** · **Status of all projects** · **Close out a project**, even with no projects listed. A job typed in Other = manual start (`planning.md` with it). More than 4 projects: print the list above the question. Projects outside `~/phased`: their folder via Other.
- **New project:** `planning.md` (Guided start).
- **Resume:** second question, up to 4 projects, unfinished first (label = project, description = `2/6 done · next: Verify`), finished ones as "add work"; others via Other. Unfinished: its `Next start` (D5: offer to open it, else the ▶ block). Finished: rename this thread `<Project> — Control`, then `planning.md` from step 3, revising its PLAN.md (append phases, keep done rows); step 7 resets `Next start`.
- **Status:** the list, one line per project. Then stop.
- **Close out:** pick any project the same way. Unfinished: confirm its remaining phases are dropped, mark them `skipped (closed out)`. Then `closeout.md` on its PLAN.md; this session isn't one of its sessions, so leave it out of archive/delete.
