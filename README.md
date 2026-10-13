# ⚔️ ronin-toolkit

**Masterless tools for IT professionals.**
Built by [Samuryann](https://github.com/samuryann), assisted by [Claude](https://claude.com).

In Japanese history, a *ronin* was a samurai with no master. These days they're the sysadmins, MSP techs, network engineers and solo IT departments who keep everything running with no team behind them. ronin-toolkit is a set of [Claude Code](https://claude.com/claude-code) plugins made for that work: change windows, troubleshooting, client sites, and getting the job done without wasting tokens.

Each plugin installs with one command and updates itself when new versions land here.

| Plugin | What it does |
|---|---|
| [`phased`](#phased-token-efficient-projects-and-troubleshooting) | Splits a project or investigation into small phases, runs one phase per thread with a handover file, picks the cheapest model that can do each phase, and escalates single steps to Opus only with your approval |

More plugins will be added over time.

---

## phased: token-efficient projects and troubleshooting

Long Claude Code threads get expensive: every turn re-reads the whole context, and Opus costs far more than Sonnet or Haiku even though most steps don't need it. `phased` attacks both:

- **Plans before building.** It writes a terse `PLAN.md` with phases small enough to finish in one thread. Each phase has a "done when" check, an estimate and the cheapest model + effort that suits it. Then it waits for your approval.
- **One phase per thread.** Each phase ends with a short, factual `HANDOFF-<date>-PHASE-<n>.md`. The next thread reads only `PLAN.md`, that handover and the files it names: never the whole project, never older handovers.
- **Starts light, escalates one step, only when you say so.** The session runs on Haiku or Sonnet. When it hits a trigger it stops and asks. If you approve, the included `opus-escalation` subagent handles that single step and reports back, and the session carries on with the lighter model.
- **Spends tokens like they're yours.** It searches before reading, reads line ranges instead of whole files, filters command output at the source, batches diagnostic commands into one round trip, and pulls the few lines that matter out of big log pastes. The skill itself loads in pieces: the planning and escalation rules are only read when needed.
- **Built for troubleshooting.** Investigations get evidence-based phases (gather, hypothesise, test, fix, verify) and a "Ruled out" table that every later thread checks, so nobody re-tests a dead end. Conclusions are labelled fact or inference.
- **Works on systems Claude can't reach.** For firewalls, servers and client networks it gives you exact, paste-safe commands and treats your output as the evidence. It asks you to mask secrets before pasting, and never writes them to a file.
- **Careful with production.** Risky changes (device config, deletions, migrations, credentials, anything sent or published) trigger an approval and an optional Opus review. Before an approved change it captures the current state, prepares the rollback and restates exactly what will change.
- **Tracks estimate vs actual.** PLAN.md records the measured peak context beside each estimate, plus every escalation. If usage can't be measured, it writes `not measured` rather than guessing.
- **Hard to lose your place.** PLAN.md always carries the next START HERE line, handovers never overwrite each other, and a handover is checked against the real files before it's trusted. Jobs small enough for one thread are told to skip the ceremony.

**Footprint** (measured with `claude plugin details`): about 150 tokens added to each session while installed. Running a phase loads about 1.6k. The planning rules (about 0.8k) and escalation rules (about 0.6k) are read only when needed, and the Opus subagent's instructions are about 0.6k.

### How escalation works

Triggers, in priority order:

1. **Before a risky change**: anything hard to undo (production or device config, deleting data, migrations, credentials, sending or publishing).
2. **Low confidence**: it's guessing a command or flag, several causes fit the evidence, it hasn't read what it's about to change, or it's acting on memory instead of output.
3. **Stuck**: an attempt at a working solution failed twice.

At a trigger you choose one of four options:

| Option | What happens |
|---|---|
| **Opus review** | Opus checks the plan and returns GO / GO WITH CHANGES / STOP. Read-only, no changes made. |
| **Opus solve** | Opus does the stuck step itself, verifies it, and hands back. |
| **Carry on** | The current model keeps going. At a risky-change trigger this is your explicit approval of the change. |
| **Stop** | Nothing more happens until you decide. |

The brief sent to Opus carries exact error lines and file ranges rather than whole logs. Opus answers in a fixed handback of under 200 words: verdict, what changed, files touched, verification, what it ruled out, next step. If the brief is missing something essential it answers NEEDS INFO instead of guessing or searching the whole project. After two escalations on the same step, the thread stops and recommends running the next thread on Opus rather than looping.

Why a subagent rather than switching the session's model? A session can't (and shouldn't) re-price its own turns mid-thread. A subagent with `model: opus` runs that one step on Opus while the main thread stays on the cheaper model.

### Example flow

```
You:    Split this into phases: users at the branch office drop off the VPN every
        afternoon. Project folder: ~/projects/branch-vpn-drops
Claude: Recommends Sonnet, asks what changed recently and who is affected,
        writes PLAN.md (troubleshoot shape, 4 phases), waits for approval,
        then gives you the phase 1 start line.

[new thread, model set to Sonnet]
You:    Branch VPN Drops — Phase 1 of 4: Gather evidence — START HERE ~/projects/branch-vpn-drops/PLAN.md
Claude: Gives you one batch of filtered log and debug commands, reads your pasted
        output, rules out ISP loss and DHCP lease expiry with evidence, and
        narrows it to a phase 2 rekey mismatch. Before touching the tunnel config:
        "Risky change: live VPN config. Approve Opus review?"
You:    Approve Opus review
Claude: Opus says GO WITH CHANGES (back up the config first, do it after hours).
        Carries on with Sonnet, shows the done-when check, writes the handover,
        gives you the next START HERE line.
```

---

## Install

Works in Claude Code: the CLI, the desktop app's Code tab, and the IDE extensions.

### As a plugin (recommended)

In a Claude Code session:

```
/plugin marketplace add samuryann/ronin-toolkit
```

```
/plugin install phased@ronin-toolkit
```

On Claude Code 2.1.275 or later, one line does both:

```
/plugin install phased --marketplace samuryann/ronin-toolkit
```

From a shell instead of a session:

```bash
claude plugin marketplace add samuryann/ronin-toolkit && claude plugin install phased@ronin-toolkit
```

> **No GitHub SSH key?** Claude Code clones over SSH when it can. If installs or updates fail, set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` in your environment so it uses HTTPS.

### Get updates automatically

Auto-update is **off** by default for third-party marketplaces. Turn it on once: run `/plugin`, go to **Marketplaces**, select **ronin-toolkit**, then **Enable auto-update**. Claude Code then picks up new commits in the background when a session starts.

To update by hand instead:

```
/plugin marketplace update ronin-toolkit
```

### Manual install (no plugin system)

Copy the skill folder (all three files) and the agent into your personal Claude Code folders. With a manual install the command is plain `/phased`, and there are no automatic updates.

macOS / Linux:

```bash
git clone https://github.com/samuryann/ronin-toolkit.git /tmp/ronin-toolkit
```

```bash
mkdir -p ~/.claude/skills ~/.claude/agents && cp -R /tmp/ronin-toolkit/plugins/phased/skills/phased ~/.claude/skills/ && cp /tmp/ronin-toolkit/plugins/phased/agents/opus-escalation.md ~/.claude/agents/
```

Windows (PowerShell):

```powershell
git clone https://github.com/samuryann/ronin-toolkit.git "$env:TEMP\ronin-toolkit"
```

```powershell
New-Item -ItemType Directory -Force "$HOME\.claude\skills","$HOME\.claude\agents" | Out-Null; Copy-Item -Recurse -Force "$env:TEMP\ronin-toolkit\plugins\phased\skills\phased" "$HOME\.claude\skills\"; Copy-Item -Force "$env:TEMP\ronin-toolkit\plugins\phased\agents\opus-escalation.md" "$HOME\.claude\agents\"
```

Use one method or the other, not both, or you'll have two copies of the skill.

---

## Usage

**Start a project or investigation.** Select Sonnet (planning rarely needs Opus), then either ask in plain words:

```
Split this into phases: <what you want built or fixed>. Project folder: <full path>
```

or run the skill directly: `/phased:phased <description>` (plugin install) or `/phased <description>` (manual install).

**Run each phase in a fresh thread.** At the end of every phase Claude tells you which model to select and gives a line in its own box. Start a new thread, select that model (`/model` in the CLI, or the model menu in the app), and paste the line exactly:

```
<Project> — Phase 2 of 4: <phase name> — START HERE /full/path/HANDOFF-YYYY-MM-DD-PHASE-1.md
```

Lost the line? Tell Claude the project folder; the next start line is always at the top of `PLAN.md`.

**Force an escalation** any time: "get an Opus review of this" or "escalate this step to Opus".

### Tips
- A new thread per phase is where the savings come from. Don't keep going in a long thread.
- Paste only the output Claude asks for. A full debug log can cost more than the rest of the phase.
- Usage figures are filled in automatically only where your Claude Code surface exposes a usage tool to the model (the desktop app does). Elsewhere, run `/context` or `/cost` and give Claude the number, or it records `not measured`.
- The model tiers in `SKILL.md` are just defaults. Fork the repo and edit the table to match your plan or preferences.

## Uninstall

Plugin:

```
/plugin uninstall phased@ronin-toolkit
```

Remove the whole marketplace and everything installed from it:

```
/plugin marketplace remove ronin-toolkit
```

Manual install:

```bash
rm -rf ~/.claude/skills/phased ~/.claude/agents/opus-escalation.md
```

## Repository layout

```
.claude-plugin/marketplace.json       marketplace catalog
plugins/phased/
  .claude-plugin/plugin.json          plugin manifest (no version: every commit is a release)
  skills/phased/SKILL.md              core workflow: run a phase, token rules, handover
  skills/phased/planning.md           read only when planning a new project
  skills/phased/escalation.md         read only when an escalation trigger fires
  agents/opus-escalation.md           the Opus escalation subagent
  LICENSE                             same licence, shipped with the plugin
```

## License

**Free to use, never for sale.** ronin-toolkit is released under the [MIT License with the Commons Clause](LICENSE).

- ✅ **Use it freely**, at home or at work, including on paid client and employer projects.
- ✅ **Modify it, fork it, and share it**, as long as the licence and credit to Samuryann go with it.
- ❌ **Don't sell it.** You may not charge for these plugins, or for a product or service whose value comes entirely or substantially from them. That includes repackaging them, putting them behind a paywall, or selling hosting or support for them.

Because of the Commons Clause, this is "source-available" rather than OSI open source. Copies obtained before 2026-10-13 were released under plain MIT.

---

Built by **Samuryann**, assisted by **Claude**. Questions, bugs or ideas: [open an issue](https://github.com/samuryann/ronin-toolkit/issues).
