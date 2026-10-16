# ⚔️ ronin-toolkit

**Masterless tools for IT professionals.**
Built by [Samuryann](https://github.com/samuryann), assisted by [Claude](https://claude.com).

In Japanese history, a *ronin* was a samurai with no master. These days they're the sysadmins, MSP techs, network engineers and solo IT departments who keep everything running with no team behind them. ronin-toolkit is a set of [Claude Code](https://claude.com/claude-code) plugins made for that work: change windows, troubleshooting, client sites, and getting the job done without wasting tokens.

| Plugin | What it does |
|---|---|
| [`phased`](#phased) | Runs IT projects and troubleshooting in small, cheap phases, escalating to Opus only when you approve |
| [`fortigate-meraki`](#fortigate-meraki) | A FortiGate & Meraki engineer subagent that knows the silent-fail traps, plans changes with rollback, and reads debug output |
| [`ticket-notes`](#ticket-notes) | Turns rough notes or the work in a conversation into a paste-ready PSA ticket note, with nothing made up |

## Install

In Claude Code, add the marketplace once:

```
/plugin marketplace add samuryann/ronin-toolkit
```

Then install the plugins you want, each on its own:

**phased**: phased projects and troubleshooting
```
/plugin install phased@ronin-toolkit
```

**fortigate-meraki**: firewall engineer subagent
```
/plugin install fortigate-meraki@ronin-toolkit
```

**ticket-notes**: paste-ready PSA ticket notes
```
/plugin install ticket-notes@ronin-toolkit
```

Then turn on updates: `/plugin` → **Marketplaces** → **ronin-toolkit** → **Enable auto-update**.
Install fails? Set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` and retry. Remove a plugin with `/plugin uninstall <name>@ronin-toolkit` (removing phased keeps your `~/phased` project folders). Windows: phased needs Git for Windows (Claude Code's Bash), since its project list uses `find` and `awk`.

## phased

Runs IT projects and troubleshooting in small phases, each on the cheapest model that can do it. **Why:** fewer tokens, everything for a job in one folder, and a guided, evidence-first way through fixes and builds.

### Start it
Pick Sonnet, then type one of these (they all show in the `/` menu):

| Command | What it does |
|---|---|
| `/phased:start` (or `/phased:phased`) | Menu: New project, Resume a project, Status of all projects, Close out a project. Type the job in the Other box to go straight to planning. |
| `/phased:new` | New project. Add the job to skip questions (`/phased:new fix VPN drops at the branch`); otherwise it asks for the job, a project name and a folder (default `~/phased/<job>/`; it offers to create it). |
| `/phased:resume` | Lists your projects with progress (`2/6 done · next: Verify`) and opens the next phase. Finished projects can take more work. |
| `/phased:status` | One line per project, nothing else loaded: the cheapest check. |
| `/phased:close-out` | Ticket note, lesson, then archive or delete the project's sessions. |

Or skip the commands: `Split this into phases: <the job, symptoms, what changed>. Project folder: <path>`.
The commands cost nothing until used (their descriptions stay out of Claude's context). Cheapest starts: `/phased:new <job>` or `/phased:status`; the menu adds one question.

Start that first session from your usual folder (e.g. home). It's named `<Project> — Control` and stays there; ask it "status?" any time and it answers from `PLAN.md` (phases don't message it, which would reload it each time). Each phase then ends with three steps:

1. Open a new session **in the project folder**.
2. Pick the model it names.
3. Paste its START HERE line.

In the Claude desktop app, phased does these three steps for you, in one click: when you confirm a phase is done, the same question offers *Yes, open Phase 2* (recommended when it can start now) · *Yes, open later* (recommended when it waits on client info, a person or a date) · *Not done*. The last phase just asks *Yes, done* · *Not done*. Plan approval works the same way for Phase 1. (Claude may only start a session you asked for, so a click is the minimum.) For a status request or a part-done hand-off it asks "Open Phase 2 on Sonnet?" with three answers:
- **Open it now:** starts the phase in the project folder, already named, on the right model, with the START HERE line. It detaches itself from the thread that opened it, so no other thread is woken (and charged) each time it finishes a turn, and files itself in the project's sidebar group.
- **Later** (recommended when waiting: an opened phase that waits costs tokens to sit idle and more to wake): when ready, "status?" in Control or the resume command offers to open it.
- **Start block:** you get the three steps above. The phase still files itself in the project's group.

Where the app can't start sessions (e.g. the terminal), or opening fails, you get the three steps above.

### Project folders
| Thread | Opened in | Why |
|---|---|---|
| `<Project> — Control` | your usual folder (e.g. home) | planning with your normal memory; status on request |
| `<Project> — Phase n: <step>` | `~/phased/<job>/` | no unrelated memory loads, sessions group by project |

One folder per job holds `PLAN.md`, the handovers and the ticket note. The folder you pick when opening a session decides which memory loads; the START HERE path only says which file to read, so a phase opened elsewhere still works, just heavier. Lost your place? `Next start` is at the top of `PLAN.md`.

Finished projects crowding the list? Move the folder into `~/phased/archive/` and it stops being listed. To close one out or add work later, type its folder in Other.

Desktop app: each project gets its own sidebar group, named after it, holding Control and every phase (phases sit side by side, not nested). Close-out's Archive or Delete also removes a group phased created. Projects planned before this change: add `Group: <id> (existing)` to their `PLAN.md` to keep new phases in your own group.

### How it saves tokens
Every message re-sends the whole conversation, so anything that lands in the chat is paid for again on every later turn. phased keeps bulky material out of it:

- **Haiku reads the bulk.** Logs, exports, inventories and big configs go to a cheap Haiku worker, which answers one precise question in four short lines. Only that answer reaches the main thread. In testing, a 3,000-line export cost about 5k tokens this way, against about 48k pasted into the chat.
- **Reply `copied`, don't paste.** Copy any output, or just a value, and reply `copied`. phased saves your clipboard to the project folder, reads up to ~100 lines itself and hands anything bigger to Haiku. A paste always lands in the main thread at full size.
- **Big commands write a file.** When a command could print more than ~100 lines, phased gives one block that writes a labelled file on the server and prints its line count. In an interactive remote session the file also goes on your clipboard, so you just reply `copied`. Or download it and reply `saved` (phased checks the project folder, then Downloads). The line count catches a copy that got cut off.
- **Drop files in the project folder.** Already have an export, log or config? Save it into the project folder and reply `saved` or name the file. Haiku reads it; the main thread never does.
- **Answers are kept.** Each Haiku answer is added to the project's `FINDINGS.md`. phased searches it before asking again, and handovers point to it instead of copying it.
- **Small, fresh sessions.** Each phase runs in its own session on the cheapest model that can do it, starting from a short handover instead of a long history. In the desktop app the next phase opens with one click, in the project's sidebar group. Phases split only where that pays off, since every new session costs a little to start.
- **A hook guards the thread.** A small script (no model call) checks each message you send in a phase thread. A paste over ~30k characters is stopped before it lands, since it would be re-read on every later message: reply `copied` instead and Haiku reads it from a file. And after about an hour away, when your next message would re-read a long thread uncached at about double the cost, phased offers a fresh session from a handover instead. It needs `jq`, which is built into macOS 15 and later.
- **Opus only when you approve,** for one bounded review or fix, then back to the cheaper model.
- **Notes are searched, not loaded** (next section).

### Memory and past fixes
Phased doesn't load your notes; it searches them. Create `~/phased/SOURCES.md` (it offers to on first run):

```
~/.claude/projects/*/memory
~/phased/*/FINDINGS.md
save: ~/.claude/projects/<your home folder>/memory
```

- **Line 1** searches all your Claude memory, wherever it was saved, including folders created later.
- **Line 2** searches every project's `FINDINGS.md`: every Haiku answer is appended there, so past extracts are found without re-reading.
- **`save:`** (optional) is where close-out writes the lesson as a memory note. Without it, lessons go to `~/phased/LESSONS.md`.

It reads only the 1–3 notes that match the client, device or error, and lists them in `PLAN.md`.

### What it does
- **Plans first:** phases with "done when" checks, estimates and a model each. Splits only where a new session pays: a model change, a wait, ~60k of work, or a risky change.
- **Evidence first:** config and logs before testers or downtime; filtered, paste-safe commands; fact vs inference; a "Ruled out" table.
- **Right model per step:** Haiku for bulk reading, the phase's model for the work, Opus (or a matching specialist agent you've installed) for one hard or risky step, only when you approve. See [How it saves tokens](#how-it-saves-tokens).
- **Safe changes:** backup, rollback and exact scope before anything touches production.
- **Close-out:** a paste-ready ticket note, the lesson saved, and the sessions archived or deleted.

**Footprint:** ~205 tokens per session while installed, ~3.1k when a phase runs.

## fortigate-meraki

A subagent for FortiGate (FortiOS 7.2–7.6) and Meraki MX/MS/MR work. It never touches a device: it gives you firmware-correct commands with a backup, verification and rollback, reads your pasted `diagnose`/`show` output, and labels fact vs inference. It knows the traps that fail silently: `set` replacing whole lists, a policy with the wrong `dstintf` that never matches, local-in not protecting VIPs, session filters that flush everything, dial-up IPsec name and DH-order limits, MX uplink and flow-preference overrides. Use it directly (`@agent-fortigate-meraki:fortigate-meraki-engineer`), or let `phased` offer it as the specialist reviewer on firewall steps. It uses only file, shell and web tools, so it stays cheap to call.

**Footprint:** about 90 tokens per session while installed, and about 4.4k each time it's called.

## ticket-notes

Writes a ticket note you can paste straight into AutoTask, ConnectWise, HaloPSA or any PSA. Give it your rough notes, or just ask for a note at the end of a working conversation: "write a ticket note". You get plain text with `-` bullets (no markdown to clean up), in a fixed layout: a one-line summary, **Work Performed**, then **Root Cause**, **Outcome** (only when the work isn't finished), **Next Steps** and **Optional Improvements**, each only when there's something to put in it.

It's written as a change record, so it sticks to what happened. It never invents routine steps you didn't mention ("backed up the config"). Steps the conversation told you to do count as done unless you said you skipped them. Next Steps holds only what's still open. It never writes passwords, PSKs or keys. Run it as `/ticket-notes:ticket-notes`, or just ask for a ticket note.

**Footprint:** about 65 tokens per session while installed, and about 720 each time it writes a note.

## License

**Free to use, never for sale.** [MIT + Commons Clause](LICENSE): use and modify it freely, including for paid client work; don't sell it or charge for anything built mainly on it.

Changes: [CHANGELOG.md](CHANGELOG.md)
