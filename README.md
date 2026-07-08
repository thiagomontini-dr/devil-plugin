# devil-plugin

Devil's advocate interactions for Claude Code: structured critique, steelman analysis, adversarial debate, decision stress tests, and a persistent devil mode.

Created: 2026-07-05
Last update: 2026-07-08

## Purpose

LLM assistants have a documented bias toward agreeing with the user (sycophancy), preferring validating answers over truthful but disagreeable ones. Research shows the most effective countermeasure is explicit role assignment: instructing the model to act as a devil's advocate raises genuine disagreement dramatically, provided the prompt also forbids agreement, fixes the output structure, demands concrete falsifiable objections, and re-anchors the instruction in long conversations. This plugin packages those findings as commands, an agent, a skill, and a hook.

## Commands

| Command | Arguments | What it does |
|---------|-----------|--------------|
| `/devil:challenge` | `[light\|medium\|brutal] <idea or claim>` | One-shot critique: 3 flaws in the reasoning, 1 emotional or cognitive bias, 1 question that could change your mind |
| `/devil:steelman` | `[light\|medium\|brutal] <position>` | Builds the strongest possible counter-argument first, then critiques your position against it |
| `/devil:debate` | `[light\|medium\|brutal] <topic>` | Multi-round debate: one new substantive objection per round, no conceding without your pushback, closing table of what survived |
| `/devil:decision` | `[light\|medium\|brutal] <plan>` | Pre-mortem stress test: 5 reasons it will fail, hidden assumptions, unintended consequences, kill criteria |
| `/devil:on` | `[light\|medium\|brutal]` | Enables persistent devil mode for the current project |
| `/devil:off` | - | Disables persistent devil mode |
| `/devil:status` | - | Shows whether persistent devil mode is active for the current project |
| `/devil:help` | `[command]` | Usage guide, or the detailed protocol of one command |

## Intensity dial

Every mode accepts an optional intensity as the first argument (default `medium`):

- `light` - probing questions, respectful tone, concedes genuinely strong points
- `medium` - direct objections, no praise, concedes only under evidence
- `brutal` - argues as if the position is completely wrong until proven otherwise

Intensity changes tone and pressure only; the fixed output structures and objection counts never change (too many objections dilute the strongest ones).

The advocate always responds in the language the user writes in.

## Persistent devil mode

Research shows the devil's advocate effect decays in long conversations as the instruction scrolls out of context. `/devil:on` solves this: a UserPromptSubmit hook re-injects a compact adversarial instruction on every prompt, so each request gets at least one substantive challenge while the task is still completed.

- State lives in `~/.claude/devil-plugin/state/`, one file per project (the file name is the project basename plus a hash of the full path, so distinct projects never collide; line 1 of the file is the intensity, line 2 the project path).
- File present means mode on; file absent means off; invalid content falls back to `medium`.
- A SessionStart hook reminds you when devil mode is active for the project.
- All hook failure paths degrade silently so prompts are never blocked.
- State operations are logged to `~/.claude/devil-plugin/state/devil-mode.log`, rotated to a single `.old` generation past 64 KB.
- Projects that were deleted or moved leave orphaned state files; `sh scripts/devil-mode.sh cleanup` removes every state file whose recorded project directory no longer exists.

## Agent and skill

- `devil-advocate` agent: read-only adversarial critic that other workflows can invoke to stress-test a plan, design, or diff. It reads referenced files and ties every objection to specific lines or facts.
- `devils-advocate` skill: activates automatically on natural language such as "poke holes in this", "play devil's advocate", "o que pode dar errado", "aponte falhas", and routes to the matching critique structure.

## Installation

```
claude plugin install /path/to/devil-plugin
```

Components take effect on the next Claude Code session.

## Limits

- Every critique is structured brainstorming for human review, not verified counter-evidence; factual claims still require independent verification.
- Adversarial interaction measurably improves decision quality but is rated as more effortful and less pleasant; use the intensity dial accordingly.
- Best trigger points: before major decisions, before launches, and whenever there is unanimous agreement.
