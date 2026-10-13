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

Long Claude threads get expensive, because every turn re-reads the whole context. `phased` keeps work in small phases on the cheapest model that can do them:

- **Plan first.** It writes a terse `PLAN.md` with phases, "done when" checks, estimates and a model for each, and waits for your approval.
- **One phase per session.** Each phase ends with a short handover; the next session reads only that. The planning thread keeps its name, acts as the control thread and gets a 5-line status from each phase.
- **Evidence first.** It reads config and logs before asking for testers or downtime. It gives filtered, paste-safe commands for systems it can't reach, labels conclusions fact or inference, and keeps a "Ruled out" table so nobody re-tests a dead end.
- **Opus only when it counts.** Before a risky change, when it's not confident, or after two failed fixes, it stops and asks. An approved Opus subagent (or a better-matched specialist agent you have installed, e.g. a firewall expert) reviews or solves that one step, then the cheap model carries on.
- **Safe changes.** Backup, rollback and exact scope before anything touches production.
- **Learns across projects.** At the end it offers to save a short lesson to `~/phased/LESSONS.md`, to write a paste-ready ticket note, and to archive or delete the project's sessions.
- **Finds past fixes without loading them.** It searches `LESSONS.md` plus any notes folders listed in `~/phased/SOURCES.md` (e.g. your Claude memory folder) and reads only the notes that match, so project folders stay clean and nothing loads until it's relevant. Add a `save:` line to write lessons into that folder instead.

**Start it** (select Sonnet first):
- **Guided:** run `/phased:start`. It explains itself in three lines, asks for the job and a project folder (and creates it), then plans. Run it inside an existing project folder to resume the next phase.
- **Direct:** say `Split this into phases: <the job, symptoms, what changed>. Project folder: <path>`.

Each phase ends with **▶ Start a NEW session on <Model> and paste:** plus a START HERE line. Phase threads are named after the first thread (`<Project> — Phase 2: Fix`) so they group together. Lost the line? It's always at the top of `PLAN.md`.

**Footprint:** about 130 tokens per session while installed, and about 1.8k when a phase runs.

## fortigate-meraki

A subagent for FortiGate (FortiOS 7.2–7.6) and Meraki MX/MS/MR work. It never touches a device: it gives you firmware-correct commands with a backup, verification and rollback, reads your pasted `diagnose`/`show` output, and labels fact vs inference. It knows the traps that fail silently: `set` replacing whole lists, a policy with the wrong `dstintf` that never matches, local-in not protecting VIPs, session filters that flush everything, dial-up IPsec name and DH-order limits, MX uplink and flow-preference overrides. Use it directly (`@agent-fortigate-meraki:fortigate-meraki-engineer`), or let `phased` offer it as the specialist reviewer on firewall steps. It uses only file, shell and web tools, so it stays cheap to call.

**Footprint:** about 90 tokens per session while installed, and about 4.4k each time it's called.

## License

**Free to use, never for sale.** [MIT + Commons Clause](LICENSE): use and modify it freely, including for paid client work; don't sell it or charge for anything built mainly on it.

Changes: [CHANGELOG.md](CHANGELOG.md)
