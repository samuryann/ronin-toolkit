# Big output (>~100 lines predicted)

Never into chat. One file per step, then Haiku.

1. **Predict when writing the step's commands.** Big: recursion (`-Recurse`, `/T`, `/S`), unfiltered lists (all users, shares, policies), per-object dumps across many objects, full configs or logs.
2. **One block, one file**: all of the step's big commands, `== <label>` headers, creating the folder first and ending with the line count (it shows in an RMM job's output too).
   - Windows: `New-Item -ItemType Directory -Force C:\Temp | Out-Null; & { "== shares"; Get-SmbShare; "== acl"; icacls D:\Shares /T } *>&1 | Out-File C:\Temp\phased-<step>.txt -Width 400; (Get-Content C:\Temp\phased-<step>.txt).Count`
   - Linux: `{ echo "== disk"; df -h; echo "== log"; journalctl -u <unit> --since -1d; } > /tmp/phased-<step>.txt 2>&1; wc -l < /tmp/phased-<step>.txt`
3. **The user brings it over**, either way:
   - select all, copy, reply `copied`: save it to `<project folder>/phased-<step>.txt` with the clipboard command for this machine: macOS `pbpaste > <file>` · Windows `powershell -NoProfile -Command "Get-Clipboard | Set-Content '<file>'"` (works from Git Bash too) · Linux `wl-paste > <file>` or `xclip -o -selection clipboard > <file>`;
   - or pull the file with the remote tool's file transfer (e.g. RMM remote session), drop it into the project folder in Finder or Explorer, and reply `saved`. Not into the chat: that becomes an @-mention and inlines it.
4. **Confirm** with its line count and first and last line, then hand it to the Haiku worker (SKILL.md B7).

Device CLIs that can't write files: filter harder; still big, the same copy route.
