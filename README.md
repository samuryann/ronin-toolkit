# ⚔️ ronin-toolkit

**Masterless tools for IT professionals.**
Built by [Samuryann](https://github.com/samuryann), assisted by [Claude](https://claude.com).

In Japanese history, a *ronin* was a samurai with no master. These days they're the sysadmins, MSP techs, network engineers and solo IT departments who keep everything running with no team behind them. ronin-toolkit is a set of [Claude Code](https://claude.com/claude-code) plugins made for that work: change windows, troubleshooting, client sites, and getting the job done without wasting tokens.

| Plugin | What it does |
|---|---|
| [`phased`](#phased) | Runs IT projects and troubleshooting in small, cheap phases, escalating to Opus only when you approve |
| [`fortigate-meraki`](#fortigate-meraki) | A FortiGate & Meraki engineer subagent that knows the silent-fail traps, plans changes with rollback, and reads debug output |

## Install

In Claude Code:

```
/plugin marketplace add samuryann/ronin-toolkit
```

```
/plugin install phased@ronin-toolkit
```

Want the firewall agent too? `/plugin install fortigate-meraki@ronin-toolkit`

Then turn on updates: `/plugin` → **Marketplaces** → **ronin-toolkit** → **Enable auto-update**.
Install fails? Set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` and retry. Remove with `/plugin uninstall phased@ronin-toolkit`.

## phased

Runs IT projects and troubleshooting in small phases, each on the cheapest model that can do it. **Why:** fewer tokens, everything for a job in one folder, and a guided, evidence-first way through fixes and builds.

### Start it
Pick Sonnet, then either:
- **Guided:** `/phased:start`. It asks for the job, a project name and a folder (default `~/phased/<job>/`, created for you), then plans.
- **Manual:** `Split this into phases: <the job, symptoms, what changed>. Project folder: <path>`.

Start that first session from your usual folder (e.g. home). It's named `<Project> — Control` and stays there; ask it "status?" any time and it answers from `PLAN.md` (phases don't message it, which would reload it each time). Each phase then ends with three steps:

1. Open a new session **in the project folder**.
2. Pick the model it names.
3. Paste its START HERE line.

### Project folders
| Thread | Opened in | Why |
|---|---|---|
| `<Project> — Control` | your usual folder (e.g. home) | planning with your normal memory; status on request |
| `<Project> — Phase n: <step>` | `~/phased/<job>/` | no unrelated memory loads, sessions group by project |

One folder per job holds `PLAN.md`, the handovers and the ticket note. The folder you pick when opening a session decides which memory loads; the START HERE path only says which file to read, so a phase opened elsewhere still works, just heavier. Lost your place? `Next start` is at the top of `PLAN.md`.

### Memory and past fixes
Phased doesn't load your notes; it searches them. Create `~/phased/SOURCES.md` (it offers to on first run):

```
~/.claude/projects/*/memory
~/phased/*/FINDINGS.md
save: ~/.claude/projects/<your home folder>/memory
```

- **Line 1** searches all your Claude memory, wherever it was saved, including folders created later.
- **Line 2** searches every project's `FINDINGS.md`: each Haiku answer is appended there, so past extracts are found without re-reading.
- **`save:`** (optional) is where close-out writes the lesson as a memory note. Without it, lessons go to `~/phased/LESSONS.md`.

It reads only the 1–3 notes that match the client, device or error, and lists them in `PLAN.md`.

### What it does
- **Plans first:** phases with "done when" checks, estimates and a model each. Splits only where a new session pays: a model change, a wait, ~60k of work, or a risky change.
- **Evidence first:** config and logs before testers or downtime; filtered, paste-safe commands; fact vs inference; a "Ruled out" table.
- **Right model per step:** a Haiku worker reads big logs and exports (big outputs come back as a file, copied or downloaded, never pasted into the chat); Opus (or a matching specialist agent you've installed) reviews one hard or risky step, only when you approve.
- **Safe changes:** backup, rollback and exact scope before anything touches production.
- **Close-out:** a paste-ready ticket note, the lesson saved, and the sessions archived or deleted.

**Footprint:** ~175 tokens per session while installed, ~2.2k when a phase runs.

## fortigate-meraki

A subagent for FortiGate (FortiOS 7.2–7.6) and Meraki MX/MS/MR work. It never touches a device: it gives you firmware-correct commands with a backup, verification and rollback, reads your pasted `diagnose`/`show` output, and labels fact vs inference. It knows the traps that fail silently: `set` replacing whole lists, a policy with the wrong `dstintf` that never matches, local-in not protecting VIPs, session filters that flush everything, dial-up IPsec name and DH-order limits, MX uplink and flow-preference overrides. Use it directly (`@agent-fortigate-meraki:fortigate-meraki-engineer`), or let `phased` offer it as the specialist reviewer on firewall steps. It uses only file, shell and web tools, so it stays cheap to call.

**Footprint:** about 90 tokens per session while installed, and about 4.4k each time it's called.

## License

**Free to use, never for sale.** [MIT + Commons Clause](LICENSE): use and modify it freely, including for paid client work; don't sell it or charge for anything built mainly on it.

Changes: [CHANGELOG.md](CHANGELOG.md)
