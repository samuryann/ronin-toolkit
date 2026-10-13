# claude-toolkit

Skills and subagents for [Claude Code](https://claude.com/claude-code), kept here so anyone can drop them into their own setup.

| Item | Type | What it does |
|---|---|---|
| [`phased`](#phased--token-efficient-phased-projects) | Skill | Splits a project into small phases, runs one phase per thread with a handover file, and picks the cheapest model that can do each phase |
| [`opus-escalation`](#how-escalation-works) | Subagent | Brought in by `phased`, only with your approval, when the lighter model is about to do something risky, isn't confident, or is stuck. Opus handles that one step, then hands back |

---

## phased: token-efficient phased projects

Long Claude Code threads get expensive: every turn re-reads the whole context. Opus is far more expensive than Sonnet or Haiku, but most steps don't need it. `phased` keeps both costs down:

- **Plans before building.** It writes `PLAN.md` with phases small enough to finish in one thread. Each phase has a "done when" check, a token estimate and the cheapest model + effort that suits it. Then it waits for your approval.
- **One phase per thread.** Each phase ends with a `HANDOFF-<date>-PHASE-<n>.md` written so the thread could be deleted. The next thread reads only `PLAN.md`, the handover and the files it names, never the whole project.
- **Starts light, escalates only one step, only when you say so.** The session runs on Haiku or Sonnet. When it hits a trigger, it stops and asks you. If you approve, the `opus-escalation` subagent handles that single step and reports back, and the session carries on with the lighter model.
- **Tracks estimate vs actual.** PLAN.md records the actual usage beside each estimate, and every escalation in a log. If usage can't be measured, it writes `not measured` rather than guessing.

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

Opus returns a short, fixed-format handback (verdict, what changed, files touched, verification, next step), and the lighter model continues from it.

Why a subagent rather than switching the session's model? A session can't (and shouldn't) re-price its own turns mid-thread. A subagent with `model: opus` runs that one step on Opus while the main thread stays on the cheaper model.

### Example flow

```
You:    /phased Build a CLI that audits stale DNS records — project folder: ~/projects/dns-audit
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

You need Claude Code (CLI, desktop app or IDE extension). Claude Code loads skills from a `skills` folder and subagents from an `agents` folder:

| Scope | Skills | Subagents |
|---|---|---|
| **Personal** (all your projects) | `~/.claude/skills/<name>/SKILL.md` | `~/.claude/agents/<name>.md` |
| **One project** (shared with that repo) | `.claude/skills/<name>/SKILL.md` | `.claude/agents/<name>.md` |

`phased` needs **both** files: the skill and the `opus-escalation` subagent.

### macOS / Linux

```bash
git clone https://github.com/samuryann/claude-toolkit.git /tmp/claude-toolkit
```

```bash
mkdir -p ~/.claude/skills ~/.claude/agents && cp -R /tmp/claude-toolkit/skills/phased ~/.claude/skills/ && cp /tmp/claude-toolkit/agents/opus-escalation.md ~/.claude/agents/
```

### Windows (PowerShell)

```powershell
git clone https://github.com/samuryann/claude-toolkit.git "$env:TEMP\claude-toolkit"
```

```powershell
New-Item -ItemType Directory -Force "$HOME\.claude\skills","$HOME\.claude\agents" | Out-Null; Copy-Item -Recurse -Force "$env:TEMP\claude-toolkit\skills\phased" "$HOME\.claude\skills\"; Copy-Item -Force "$env:TEMP\claude-toolkit\agents\opus-escalation.md" "$HOME\.claude\agents\"
```

### Without git

Download [`skills/phased/SKILL.md`](skills/phased/SKILL.md) into `~/.claude/skills/phased/` and [`agents/opus-escalation.md`](agents/opus-escalation.md) into `~/.claude/agents/`.

### Check it worked

Start a new Claude Code session (or restart the CLI), then:
- type `/` and look for **phased** in the list
- run `/agents` in the CLI and look for **opus-escalation**

---

## Usage

**Start a project.** Pick Sonnet (planning rarely needs Opus), then:

```
/phased <what you want built> — project folder: <full path>
```

**Run each phase in a fresh thread.** At the end of every phase Claude tells you which model to select and gives a line in its own box. Start a new thread, select that model (`/model` in the CLI, or the model menu in the app), and paste the line exactly:

```
<Project> — Phase 2 of 4: <phase name> — START HERE /full/path/HANDOFF-YYYY-MM-DD-PHASE-1.md
```

**Force an escalation** any time: "get an Opus review of this" or "escalate this step to Opus".

### Tips
- A new thread per phase is where the savings come from. Don't keep going in a long thread.
- Usage figures are filled in automatically only where your Claude Code surface exposes a usage tool to the model (the desktop app does). Elsewhere, run `/context` or `/cost` and give Claude the number, or it records `not measured`.
- The model tiers in `SKILL.md` are just defaults. Edit the table to match your plan or preferences.

## Uninstall

```bash
rm -rf ~/.claude/skills/phased ~/.claude/agents/opus-escalation.md
```

## License

[MIT](LICENSE)
