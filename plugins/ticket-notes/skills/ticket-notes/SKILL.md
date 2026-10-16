---
name: ticket-notes
description: Drafts paste-ready PSA ticket notes (AutoTask, ConnectWise, HaloPSA) as change records from rough notes or the work in this conversation. Use for "ticket note", "write a note", or writing up, logging or documenting work done.
---

Draft a PSA ticket note (AutoTask, ConnectWise, HaloPSA or similar) for an IT tech or MSP engineer. The note is a change record read by other techs and auditors: what changed, how, and why.

## Content rules

- Use only what the user stated or what is in the conversation. Do not add routine steps they did not mention (logging in, backups, verification, documentation updates).
- Steps the conversation told the user to do count as done: people rarely confirm each one. Leave a step out of Work Performed only if they said they skipped it.
- Next Steps holds only what is still open: waiting on someone else or a later event, or something the user said is not done.
- Never put passwords, PSKs, keys, or tokens in a note. Refer to them generically ("PSK updated").
- If the input is too sparse to write from, ask one short question ("What did you work on and what changed?"), then draft. Otherwise draft immediately and do not ask follow-ups.

## Output

Reply with the note only, inside one ```text code block so it copies exactly (loose text renders as markdown: "- " becomes bullet symbols and lines merge). Nothing before or after the block. Inside it: plain text, no ** or #. No date or title line; the PSA stamps the note.

Every list item starts with "- " (ASCII hyphen, space). Never use bullet characters, asterisks, or numbers.

Structure:

[One sentence: what was done, on what system/device, at which client/site if known]

Work Performed:
- [action, config change, command, or test result]

Root Cause: (only if stated)
- [cause]

Outcome: (only if the work was not fully completed)
- [one line: what works and what does not]

Next Steps: (only if there are open items)
- [follow-up]

Optional Improvements: (only if the conversation suggested extra work outside this ticket)
- [suggestion]

Omit any section that has no content.

## Style

- Past tense, plain and professional, like a tech handing off a ticket.
- Specific over vague: interface names, product names, protocols, subnets, VLAN IDs.
- No filler ("as per the request", "please note that").
- As short as the facts allow.

## Examples

Input: "fixed vpn on abc corp, sonicwall was blocking traffic after ISP changed our IP block, updated the NAT policies and tested"

Output:
```text
Updated SonicWall NAT policies at ABC Corp to restore VPN connectivity after an ISP IP block change.

Work Performed:
- Updated NAT policies on the SonicWall for the new ISP IP block
- Tested VPN connectivity after the change

Root Cause:
- ISP changed the IP block and the SonicWall was blocking traffic
```

Input: "swapped the fw at abc, new fortigate 60f in, wan is up, vpn to site b not up yet, waiting on their psk"

Output:
```text
Replaced the firewall at ABC with a FortiGate 60F.

Work Performed:
- Installed the FortiGate 60F in place of the old firewall
- Confirmed WAN is up

Outcome:
- Not complete: site-to-site VPN to Site B is not established

Next Steps:
- Obtain the PSK from Site B and bring up the VPN
```
