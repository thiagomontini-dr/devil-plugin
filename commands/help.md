---
name: help
description: Explain every devil plugin command, when to use each mode, and the intensity dial
argument-hint: "[command name]"
---

# Devil Plugin: Help

Present a compact usage guide for the devil plugin, in the same language the user has been writing in.

If `$ARGUMENTS` contains the name of one of the commands below (for example `debate`), skip the overview and explain only that mode in detail, including its full protocol and output structure. Otherwise present the full guide.

## Full guide contents

1. One-sentence purpose: the plugin counters the assistant's natural tendency to agree (sycophancy) by playing devil's advocate on demand.

2. Command table with three columns - command | what it does | when to use it:
   - `/devil:challenge [intensity] <idea>` - one-shot structured critique: 3 flaws in the reasoning, 1 emotional or cognitive bias, 1 question that could change your mind. Use to test a specific idea, claim, or argument.
   - `/devil:steelman [intensity] <position>` - builds the strongest possible counter-argument first, then critiques your position against it. Use when you want to hear the best version of the other side before deciding.
   - `/devil:debate [intensity] <topic>` - multi-round debate: one new substantive objection per round, no conceding without your pushback, closing table of what survived. Use when you want sustained pressure over several turns.
   - `/devil:decision [intensity] <plan>` - pre-mortem stress test: 5 reasons it will fail, hidden assumptions, unintended consequences, kill criteria. Use before major decisions, before launches, or when everyone agrees too easily (a groupthink warning sign).
   - `/devil:on [intensity]` - enables persistent devil mode for this project: every future prompt gets at least one substantive challenge while the task is still completed. `/devil:off` disables it.
   - `/devil:status` - shows whether persistent devil mode is active for this project and at which intensity.
   - `/devil:help [command]` - this guide, or the detailed protocol of one command.

3. Intensity dial, shared by all modes, always optional as the first argument:
   - `light` - probing questions, respectful tone.
   - `medium` (default) - direct objections, no praise.
   - `brutal` - argues as if you are completely wrong until proven otherwise.
   Example: `/devil:challenge brutal remote work is always better`.

4. One realistic invocation example per command, written in the user's language.

5. Note the two other entry points: natural language activates the devils-advocate skill automatically (for example "poke holes in this", "o que pode dar errado", "aponte falhas"), and the `devil-advocate` agent can be invoked inside workflows to stress-test files and plans.

6. Close with the standing reminder: every critique the plugin produces is structured brainstorming for human verification, not verified counter-evidence.

Requested command: $ARGUMENTS
