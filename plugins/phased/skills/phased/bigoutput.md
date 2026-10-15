# Big output (>~100 lines predicted)

Never into chat. One file per step, then Haiku.

1. **Predict when writing the step's commands.** Big: recursion (`-Recurse`, `/T`, `/S`), unfiltered lists (all users, shares, policies), per-object dumps across many objects, full configs or logs.
2. **One block, one file**: all of the step's big commands, `== <label>` headers, creating the folder first and ending with the line count (it shows in an RMM job's output too).
   - Windows: `New-Item -ItemType Directory -Force C:\Temp | Out-Null; & { "== shares"; Get-SmbShare; "== acl"; icacls D:\Shares /T } *>&1 | Out-File C:\Temp\phased-<step>.txt -Width 400 -Encoding utf8; (Get-Content C:\Temp\phased-<step>.txt).Count`
   - Linux: `{ echo "== disk"; df -h; echo "== log"; journalctl -u <unit> --since -1d; } > /tmp/phased-<step>.txt 2>&1; wc -l < /tmp/phased-<step>.txt`
   - **Interactive remote session** (PLAN.md `Access:`), Windows: also end with `; Get-Content C:\Temp\phased-<step>.txt -Raw | Set-Clipboard` (PowerShell 4 or older: `| clip`), so the remote tool's clipboard sync brings it over and the user just replies `copied`.
3. **The user brings it over**, either way:
   - `copied` (already on the clipboard after an interactive block; otherwise open the file in the remote session, e.g. `notepad C:\Temp\phased-<step>.txt`, select all, copy): save it to `<project folder>/phased-<step>.txt` with the clipboard command for this machine: macOS `pbpaste > <file>` · Windows `powershell -NoProfile -Command "Get-Clipboard | Set-Content '<file>'"` (works from Git Bash too) · Linux `wl-paste > <file>` or `xclip -o -selection clipboard > <file>`;
   - or download the file with the remote tool's file transfer (e.g. RMM remote session) and reply `saved`: look in the project folder, then `~/Downloads`, for the newest `phased-<step>*.txt` (no command pending: the file the user names, else the newest file there) and move it into the project folder; quote paths, globs inside `sh -c`. Never via the chat: dropping a file there becomes an @-mention and inlines it.
4. **Confirm** its line count matches the one the command printed, ±1 (short: the clipboard sync cut it off, use `saved`) and show the first and last line, then hand it to the Haiku worker (SKILL.md B7).

Device CLIs that can't write files: filter harder; still big, the same copy route.
