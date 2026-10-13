# claude-toolkit

Skills and subagents for [Claude Code](https://claude.com/claude-code), packaged as a plugin marketplace so you can install them with one command and receive updates.

| Plugin | What it does |
|---|---|
| [`phased`](#phased--token-efficient-phased-projects) | Splits a project into small phases, runs one phase per thread with a handover file, picks the cheapest model that can do each phase, and escalates single steps to Opus only with your approval |

---

## phased: token-efficient phased projects

Long Claude Code threads get expensive: every turn re-reads the whole context. Opus is far more expensive than Sonnet or Haiku, but most steps don't need it. `phased` keeps both costs down:

- **Plans before building.** It writes `PLAN.md` with phases small enough to finish in one thread. Each phase has a "done when" check, a token estimate and the cheapest model + effort that suits it. Then it waits for your approval.
- **One phase per thread.** Each phase ends with a `HANDOFF-<date>-PHASE-<n>.md` written so the thread could be deleted. The next thread reads only `PLAN.md`, the handover and the files it names, never the whole project.
- **Starts light, escalates only one step, only when you say so.** The session runs on Haiku or Sonnet. When it hits a trigger, it stops and asks you. If you approve, the included `opus-escalation` subagent handles that single step and reports back, and the session carries on with the lighter model.
- **Tracks estimate vs actual.** PLAN.md records the measured peak context beside each estimate, and every escalation in a log. If usage can't be measured, it writes `not measured` rather than guessing.
- **Built for troubleshooting too.** Investigations get evidence-based phases and a "Ruled out" table that every later thread checks, so nobody re-tests a dead end. It also works when you run the commands yourself on systems Claude can't reach and paste the output back.
- **Hard to lose your place.** PLAN.md always carries the next START HERE line, handovers never overwrite each other, and a handover is checked against the real files before it's trusted. Tiny jobs are told to skip the ceremony.

**Footprint:** about 200 tokens added to each session while installed (the skill and agent descriptions), plus about 3k tokens when the skill runs and about 1k when the Opus subagent is called.

### How escalation works

Triggers, in priority order:

1. **Before a risky change**: anything hard to undo (production config, deleting data, sending or publishing, credentials).
2. **Low confidence**: the model wouldn't bet on the step being right.
3. **Stuck**: an attempt at a working solution failed twice.

At a trigger you choose one of four options:

| Option | What happens |
|---|---|
| **Opus review** | Opus checks the plan and returns GO / GO WITH CHANGES / STOP. No changes made. |
| **Opus solve** | Opus does the stuck step itself, verifies it, and hands back. |
| **Carry on** | The current model keeps going. |
| **Stop** | Nothing more happens until you decide. |

Opus returns a short, fixed-format handback (verdict, what changed, files touched, verification, what it ruled out, next step), and the lighter model continues from it. If its brief is missing something essential, it answers NEEDS INFO instead of guessing or searching the whole project. Review mode is strictly read-only. After two escalations on the same step, the thread stops and recommends running the next thread on Opus rather than looping.

Why a subagent rather than switching the session's model? A session can't (and shouldn't) re-price its own turns mid-thread. A subagent with `model: opus` runs that one step on Opus while the main thread stays on the cheaper model.

### Example flow

```
You:    Split this into phases: a CLI that audits stale DNS records. Project folder: ~/projects/dns-audit
Claude: Recommends Sonnet for planning, asks 2 clarifying questions,
        writes PLAN.md (4 phases), waits for approval.

[new thread, model set to Sonnet]
You:    DNS Audit — Phase 1 of 4: Collector — START HERE ~/projects/dns-audit/HANDOFF-2026-10-14-PHASE-0.md
Claude: Builds phase 1. Before deleting test records it stops:
        "Risky change: deletes records. Approve Opus review?"
You:    Approve Opus review
Claude: Opus says GO WITH CHANGES (add a dry-run first). Carries on with Sonnet,
        shows the done-when check, writes the handover, gives you the next START HERE line.
```

---

## Install

Works in Claude Code: the CLI, the desktop app's Code tab, and the IDE extensions.

### As a plugin (recommended)

In a Claude Code session:

```
/plugin marketplace add samuryann/claude-toolkit
```

```
/plugin install phased@claude-toolkit
```

On Claude Code 2.1.275 or later, one line does both:

```
/plugin install phased --marketplace samuryann/claude-toolkit
```

From a shell instead of a session:

```bash
claude plugin marketplace add samuryann/claude-toolkit && claude plugin install phased@claude-toolkit
```

> **No GitHub SSH key?** Claude Code clones over SSH when it can. If installs or updates fail, set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` in your environment so it uses HTTPS.

### Get updates automatically

Auto-update is **off** by default for third-party marketplaces. Turn it on once: run `/plugin`, go to **Marketplaces**, select **claude-toolkit**, then **Enable auto-update**. Claude Code then picks up new commits in the background when a session starts.

To update by hand instead:

```
/plugin marketplace update claude-toolkit
```

### Manual install (no plugin system)

Copy the two files into your personal Claude Code folders. With a manual install the command is plain `/phased`, and there are no automatic updates.

macOS / Linux:

```bash
git clone https://github.com/samuryann/claude-toolkit.git /tmp/claude-toolkit
```

```bash
mkdir -p ~/.claude/skills ~/.claude/agents && cp -R /tmp/claude-toolkit/plugins/phased/skills/phased ~/.claude/skills/ && cp /tmp/claude-toolkit/plugins/phased/agents/opus-escalation.md ~/.claude/agents/
```

Windows (PowerShell):

```powershell
git clone https://github.com/samuryann/claude-toolkit.git "$env:TEMP\claude-toolkit"
```

```powershell
New-Item -ItemType Directory -Force "$HOME\.claude\skills","$HOME\.claude\agents" | Out-Null; Copy-Item -Recurse -Force "$env:TEMP\claude-toolkit\plugins\phased\skills\phased" "$HOME\.claude\skills\"; Copy-Item -Force "$env:TEMP\claude-toolkit\plugins\phased\agents\opus-escalation.md" "$HOME\.claude\agents\"
```

Use one method or the other, not both, or you'll have two copies of the skill.

---

## Usage

**Start a project.** Select Sonnet (planning rarely needs Opus), then either ask in plain words:

```
Split this project into phases: <what you want built>. Project folder: <full path>
```

or run the skill directly: `/phased:phased <description>` (plugin install) or `/phased <description>` (manual install).

**Run each phase in a fresh thread.** At the end of every phase Claude tells you which model to select and gives a line in its own box. Start a new thread, select that model (`/model` in the CLI, or the model menu in the app), and paste the line exactly:

```
<Project> — Phase 2 of 4: <phase name> — START HERE /full/path/HANDOFF-YYYY-MM-DD-PHASE-1.md
```

**Force an escalation** any time: "get an Opus review of this" or "escalate this step to Opus".

### Tips
- A new thread per phase is where the savings come from. Don't keep going in a long thread.
- Usage figures are filled in automatically only where your Claude Code surface exposes a usage tool to the model (the desktop app does). Elsewhere, run `/context` or `/cost` and give Claude the number, or it records `not measured`.
- The model tiers in `SKILL.md` are just defaults. Fork the repo and edit the table to match your plan or preferences.

## Uninstall

Plugin:

```
/plugin uninstall phased@claude-toolkit
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
  skills/phased/SKILL.md              the workflow
  agents/opus-escalation.md           the Opus escalation subagent
```

## License

[MIT](LICENSE)
