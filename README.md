# ⚔️ ronin-toolkit

**Masterless tools for IT professionals.**
Built by [Samuryann](https://github.com/samuryann), assisted by [Claude](https://claude.com).

In Japanese history, a *ronin* was a samurai with no master. These days they're the sysadmins, MSP techs, network engineers and solo IT departments who keep everything running with no team behind them. ronin-toolkit is a set of [Claude Code](https://claude.com/claude-code) plugins made for that work: change windows, troubleshooting, client sites, and getting the job done without wasting tokens.

| Plugin | What it does |
|---|---|
| [`phased`](#phased) | Runs IT projects and troubleshooting in small, cheap phases, escalating to Opus only when you approve |

## Install

In Claude Code:

```
/plugin marketplace add samuryann/ronin-toolkit
```

```
/plugin install phased@ronin-toolkit
```

Then turn on updates: `/plugin` → **Marketplaces** → **ronin-toolkit** → **Enable auto-update**.
Install fails? Set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` and retry. Remove with `/plugin uninstall phased@ronin-toolkit`.

## phased

Long Claude threads get expensive, because every turn re-reads the whole context. `phased` keeps work in small phases on the cheapest model that can do them:

- **Plan first.** It writes a terse `PLAN.md` with phases, "done when" checks, estimates and a model for each, and waits for your approval.
- **One phase per session.** Each phase ends with a short handover; the next session reads only that. The planning thread becomes `<Project> — Control` and gets a 5-line status from each phase.
- **Evidence first.** It reads config and logs before asking for testers or downtime. It gives filtered, paste-safe commands for systems it can't reach, labels conclusions fact or inference, and keeps a "Ruled out" table so nobody re-tests a dead end.
- **Opus only when it counts.** Before a risky change, when it's not confident, or after two failed fixes, it stops and asks. An approved Opus subagent reviews or solves that one step, then the cheap model carries on.
- **Safe changes.** Backup, rollback and exact scope before anything touches production.

**Use it:** select Sonnet, then say `Split this into phases: <the job>. Project folder: <path>`. At the end of each phase you get **▶ Start a NEW session on <Model> and paste:** plus a START HERE line. Lost it? The next one is always at the top of `PLAN.md`.

**Footprint:** about 115 tokens per session while installed, and about 1.8k when a phase runs.

## License

**Free to use, never for sale.** [MIT + Commons Clause](LICENSE): use and modify it freely, including for paid client work; don't sell it or charge for anything built mainly on it.

Changes: [CHANGELOG.md](CHANGELOG.md)
