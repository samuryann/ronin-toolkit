# ⚔️ ronin-toolkit

**Masterless tools for IT professionals.**
Built by [Samuryann](https://github.com/samuryann), assisted by [Claude](https://claude.com).

In Japanese history, a *ronin* was a samurai with no master. These days they're the sysadmins, MSP techs, network engineers and solo IT departments who keep everything running with no team behind them. ronin-toolkit is a set of [Claude Code](https://claude.com/claude-code) plugins made for that work: change windows, troubleshooting, client sites, and getting the job done without wasting tokens.

| Plugin | What it does |
|---|---|
| 🗡️ [`phased`](#phased) | Runs IT projects and troubleshooting in small, cheap phases, escalating to Opus only when you approve |
| 🛡️ [`fortigate-meraki`](#fortigate-meraki) | A FortiGate & Meraki engineer subagent that knows the silent-fail traps, plans changes with rollback, and reads debug output |
| 📜 [`ticket-notes`](#ticket-notes) | Turns rough notes or the work in a conversation into a paste-ready PSA ticket note, with nothing made up |
| 🏯 [`shogun`](#shogun) | Turns a thread into a commander that never blocks: work goes to background agents on the cheapest model, tracked in a ledger |

## Install

In Claude Code, add the marketplace once:

```
/plugin marketplace add samuryann/ronin-toolkit
```

Then install the plugins you want, each on its own:

🗡️ **phased**: phased projects and troubleshooting
```
/plugin install phased@ronin-toolkit
```

🛡️ **fortigate-meraki**: firewall engineer subagent
```
/plugin install fortigate-meraki@ronin-toolkit
```

📜 **ticket-notes**: paste-ready PSA ticket notes
```
/plugin install ticket-notes@ronin-toolkit
```

🏯 **shogun**: background agent commander
```
/plugin install shogun@ronin-toolkit
```

Then turn on updates: `/plugin` → **Marketplaces** → **ronin-toolkit** → **Enable auto-update**.
Install fails? Set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` and retry. Remove a plugin with `/plugin uninstall <name>@ronin-toolkit` (removing phased keeps your `~/phased` project folders). Windows: phased needs Git for Windows (Claude Code's Bash), since its project list uses `find` and `awk`.

<a id="phased"></a>
## 🗡️ phased

Runs IT projects and troubleshooting in small phases, each on the cheapest model that can do it. **Why:** fewer tokens, everything for a job in one folder, and a guided, evidence-first way through fixes and builds.

### The idea
Every message re-sends the whole conversation, so a long thread gets expensive (a 200k thread pays for 200k on every message) and forgetful. phased runs a job like a relay race: short legs (phases), each in a fresh thread, each passing a short handover to the next.

### The parts
| Part | What it is |
|---|---|
| **Control thread** | `<Project> — Control`. Plans the job and answers "status?". It never does the work. Start it from your usual folder (e.g. home), so planning has your normal memory. |
| **Phase threads** | `<Project> — Phase n: <step>`. One leg each, on the model the plan names, opened in the project folder so no unrelated memory loads. |
| **Project folder** | `~/phased/<job>/`: `PLAN.md` (phases, status, the `Next start` line), `HANDOFF-*.md` (the baton, under 500 words), `FINDINGS.md` (past Haiku answers), and your saved output. |
| **Haiku worker** | Reads big logs, exports and configs for one question and returns a few lines. Only that answer reaches the thread. |
| **Opus or a specialist** | Reviews one risky or hard step, only when you approve, then hands back. |
| **The hook** | A small script (no model call) that checks each message you send in a phased thread. See [The hook](#the-hook). |

### A project, start to finish
1. **Plan.** Pick Sonnet and run `/phased:new <the job>`. Control asks up to 4 questions, searches your past fixes, and writes `PLAN.md`: phases with "done when" checks, an estimate and a model each. It splits only where a new session pays: a model change, a wait, ~60k of work, or a risky change.
2. **Approve.** Choose *Approve, open Phase 1* and the phase opens in one click.
3. **Work.** On its first turn a phase names itself, files itself in the project's sidebar group, and reads only `PLAN.md` and the latest handover. Then evidence first: one command block at a time, config and logs before testers or downtime, a backup and rollback before any change. Before a risky change, when it is guessing, or after the same fix fails twice, it stops and offers an Opus or specialist review (or carry on, or stop).
4. **Hand over.** It shows the "done when" check passing and asks you to confirm: *Yes, open Phase 2* · *Yes, open later* (recommended when waiting on client info, a person or a date) · *Not done*. It writes the handover, updates `PLAN.md` and opens the next phase on its model. A thread that grows past ~100k hands over early as `part done`.
5. **Close out.** After the last phase: a paste-ready ticket note, the lesson saved, the sessions archived or deleted.

Claude may only start a session you asked for, so one click is the minimum. In the terminal, or if opening fails, you get a START HERE block instead: open a new session in the project folder, pick the model it names, paste the line.

### Status and resume
- **"status?" in Control:** two lines from `PLAN.md` (progress and what's next), then it offers to open the next phase. Phases don't message Control, since each message would wake it and re-read its whole thread.
- **`/phased:status`:** one line per project, from any thread. The cheapest check.
- **`/phased:resume`:** lists projects with progress (`2/6 done · next: Verify`) and opens the next phase. Finished projects can take more work.
- **Lost your place?** `Next start` is at the top of `PLAN.md`.

### The hook
It runs on every message you send but stays silent outside phased threads (a project folder with `PLAN.md`, or a thread that started phased). Inside one it does two things:
- **Stops big pastes.** A message over ~30k characters isn't sent, because it would be re-read on every later message. Reply `copied` instead (phased saves your clipboard to a file and Haiku reads it), or save it in the project folder and reply `saved`.
- **Catches breaks.** Claude's cache lasts about an hour. Come back later to a long thread (over ~40k) and your next message re-reads all of it at about double the cost. The hook flags it and phased offers a fresh session from a handover instead.

It needs `jq`, built into macOS 15 and later. Without it the hook does nothing.

### Commands
All show in the `/` menu and cost nothing until used.

| Command | What it does |
|---|---|
| `/phased:new` | New project. Add the job to skip questions (`/phased:new fix VPN drops at the branch`). |
| `/phased:status` | One line per project. |
| `/phased:resume` | Pick a project and open its next phase. |
| `/phased:close-out` | Ticket note, lesson, then archive or delete the sessions. |
| `/phased:start` | A menu of the four above. Type a job in Other to go straight to planning. |

Or skip the commands: `Split this into phases: <the job, symptoms, what changed>. Project folder: <path>`.

### More ways it saves tokens
- **Big commands write a file.** When a command could print more than ~100 lines, phased gives one block that writes a labelled file and prints its line count (which catches a cut-off copy). Copy it and reply `copied`, or download it and reply `saved`.
- **Drop files in the project folder.** Already have an export or log? Save it there and reply `saved`. Haiku reads it; the main thread never does.
- **Answers are kept.** Each Haiku answer goes into `FINDINGS.md`, which phased searches before asking again.

### Memory and past fixes
phased searches your notes instead of loading them. Create `~/phased/SOURCES.md` (it offers to on first run):

```
~/.claude/projects/*/memory
~/phased/*/FINDINGS.md
save: ~/.claude/projects/<your home folder>/memory
```

The first two lines are where it searches (all your Claude memory, and every project's findings). `save:` (optional) is where close-out writes the lesson; without it, lessons go to `~/phased/LESSONS.md`. It reads only the 1–3 notes that match the client, device or error.

### Housekeeping
- **Sidebar (desktop app):** each project gets its own group holding Control and every phase. Close-out's Archive or Delete also removes it. Projects planned before groups existed: add `Group: <id> (existing)` to `PLAN.md` to keep new phases in your own group.
- **Finished projects crowding the list?** Move the folder into `~/phased/archive/`. To work on one again, type its folder in Other.

**Footprint:** ~205 tokens per session while installed, ~3.1k when a phase runs.

<a id="fortigate-meraki"></a>
## 🛡️ fortigate-meraki

A subagent for FortiGate (FortiOS 7.2–7.6) and Meraki MX/MS/MR work. It never touches a device: it gives you firmware-correct commands with a backup, verification and rollback, reads your pasted `diagnose`/`show` output, and labels fact vs inference. It knows the traps that fail silently: `set` replacing whole lists, a policy with the wrong `dstintf` that never matches, local-in not protecting VIPs, session filters that flush everything, dial-up IPsec name and DH-order limits, MX uplink and flow-preference overrides. Use it directly (`@agent-fortigate-meraki:fortigate-meraki-engineer`), or let `phased` offer it as the specialist reviewer on firewall steps. It uses only file, shell and web tools, so it stays cheap to call.

**Footprint:** about 90 tokens per session while installed, and about 4.4k each time it's called.

<a id="ticket-notes"></a>
## 📜 ticket-notes

Writes a ticket note you can paste straight into AutoTask, ConnectWise, HaloPSA or any PSA. Give it your rough notes, or just ask for a note at the end of a working conversation: "write a ticket note". You get plain text with `-` bullets (no markdown to clean up), in a fixed layout: a one-line summary, **Work Performed**, then **Root Cause**, **Outcome** (only when the work isn't finished), **Next Steps** and **Optional Improvements**, each only when there's something to put in it.

It's written as a change record, so it sticks to what happened. It never invents routine steps you didn't mention ("backed up the config"). Steps the conversation told you to do count as done unless you said you skipped them. Next Steps holds only what's still open. It never writes passwords, PSKs or keys. Run it as `/ticket-notes:ticket-notes`, or just ask for a ticket note.

**Footprint:** about 65 tokens per session while installed, and about 720 each time it writes a note.

<a id="shogun"></a>
## 🏯 shogun

Type `/shogun:shogun` (optionally followed by your first tasks) and the thread becomes a commander. It splits what you ask into independent tasks, sends each to a background agent, and answers you in seconds while they work, so you keep talking instead of waiting. Say `status`, `stop <name>`, `redirect <name> to ...`, or `stand down` to end it.

It picks the cheapest model that can do each job: Haiku for lookups and reading, Sonnet for real work, Opus only when you say yes. A miss gets one follow-up, then one step up a model, then it comes back to you. At most 4 agents run at once. A ledger in `~/.claude/shogun/` tracks every agent, survives context compaction, and flags any agent that has gone quiet.

Every brief ends with a fixed rules block: agents never run anything on client systems or write to your PSA, RMM, documentation or M365, and they hand you paste-ready commands with a verify step and a rollback instead, copied to you word for word. Works with `phased` (uses its Haiku worker; inside a phase, phased's rules win) and `fortigate-meraki`.

**Credit:** shogun is a reimagined take on [orchestrator-skill](https://github.com/olivieropinotti/orchestrator-skill) by [Oliviero Pinotti](https://github.com/olivieropinotti), rebuilt for our own purpose: cheapest model first, IT safety rules in every brief, and a ledger built for client work. The original is MIT licensed; its licence ships with the plugin as `LICENSE-upstream`.

**Footprint:** about 50 tokens per session while installed, and about 1.3k when you start it.

## License

**Free to use, never for sale.** [MIT + Commons Clause](LICENSE): use and modify it freely, including for paid client work; don't sell it or charge for anything built mainly on it.

Changes: [CHANGELOG.md](CHANGELOG.md)
