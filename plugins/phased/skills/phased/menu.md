# Start menu (`/phased` or `/phased:start` with no details)

Current folder has a phased PLAN.md? Offer its `Next start`. Otherwise list projects with ONE command, never reading whole plans:
`ls -t ~/phased/*/PLAN.md 2>/dev/null | while IFS= read -r f; do awk -F'|' '/^Project:/{p=substr($0,10)} /^Next start:/{n=substr($0,13)} /^\| *[0-9]+ *\|/{t++; s=$8; gsub(/^ +| +$/,"",s); if(s=="done")d++; else if(c=="")c=$3} END{gsub(/^ +| +$/,"",c); printf "%s | %d/%d done | %s | %s\n",p,d,t,(n~/^none/?"complete":"next: "c),FILENAME}' "$f"; done`
Then one AskUserQuestion, exactly: **New project** (`planning.md`) · **Resume a project** · **Status of all projects** · **Close out a project**. A job typed in Other = manual start: `planning.md` with it. No projects listed: skip the menu, go to `planning.md`.
- **Resume:** second question, up to 4 projects, unfinished first (label = project, description = `2/6 done · next: Verify`), finished ones as "add work"; others via Other (name or folder). Unfinished: its `Next start` (D5: offer to open it, else the ▶ block). Finished: `planning.md` step 2 (revise: add phases).
- **Status:** the list as one line per project. Nothing else read.
- **Close out:** pick an unfinished project the same way, then `closeout.md` on its PLAN.md.
