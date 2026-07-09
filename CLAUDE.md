# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Created: 2026-07-06
Last update: 2026-07-08

## What this is

A Claude Code plugin (`devil`, marketplace `devil-marketplace`) that packages devil's advocate interactions: slash commands, a read-only agent, an auto-triggering skill, and hooks implementing a persistent "devil mode". There is no build system, package manager, linter, or test suite — everything is markdown prompt files, JSON manifests, and POSIX sh scripts.

## Commands

- Install locally for testing: `claude plugin install /Users/thiagomontini/PROJECTS/devil-plugin` (components take effect on the next Claude Code session)
- Syntax-check shell scripts: `sh -n scripts/devil-mode.sh scripts/devil-mode-context.sh scripts/devil-mode-common.sh`
- Test the state manager directly: `sh scripts/devil-mode.sh on brutal /some/project`, `... status /some/project`, `... off /some/project` (project dir falls back to `CLAUDE_PROJECT_DIR`, then cwd)
- Remove state files of deleted/moved projects: `sh scripts/devil-mode.sh cleanup`
- Test the hook injection: `CLAUDE_PROJECT_DIR=/some/project sh scripts/devil-mode-context.sh < /dev/null` (prints the `<devil-mode>` block only if that project's state file exists)

## Architecture

### Component layout

- `.claude-plugin/plugin.json` + `marketplace.json` — plugin manifest and marketplace entry. Bump `version` in plugin.json when releasing changes. The plugin description lives only in plugin.json (the marketplace entry inherits it); marketplace.json's own `description` describes the marketplace, not the plugin.
- `commands/*.md` — eight slash commands (`challenge`, `steelman`, `debate`, `decision`, `on`, `off`, `status`, `help`). Critique commands embed their full protocol; `on`/`off`/`status` are thin wrappers that run `scripts/devil-mode.sh` via Bash, passing the project root explicitly.
- `agents/devil-advocate.md` — read-only subagent (Read, Grep, Glob only) for other workflows to invoke; must ground objections in specific file lines.
- `skills/devils-advocate/SKILL.md` — auto-triggers on natural language ("poke holes in this", "o que pode dar errado") and routes to one of four modes (Challenge, Steelman, Debate, Decision) matching the command structures.
- `hooks/hooks.json` + `scripts/` — UserPromptSubmit hook re-injects the adversarial instruction every prompt (the effect decays as instructions scroll out of context); SessionStart hook announces active devil mode.

### Intentional duplication

The critique protocol (rules, output structures, intensity semantics, mandatory footer) is repeated across commands, the agent, and the skill. This is deliberate: each component loads standalone into a fresh context, so none can reference another's file. When changing the protocol, update all copies: `commands/challenge.md`, `commands/steelman.md`, `commands/debate.md`, `commands/decision.md`, `agents/devil-advocate.md`, `skills/devils-advocate/SKILL.md`, plus the tables in `docs/USER_GUIDE.md` (the user-facing docs are in pt-BR: engaging README at the root, full reference in `docs/USER_GUIDE.md`).

### Design invariants

- Intensity (`light|medium|brutal`, default `medium`) changes tone and pressure only — never the output structure or objection counts (too many objections dilute the strongest ones). Every mode parses intensity as an optional first argument.
- Fixed objection counts are part of the design (exactly 3 flaws, exactly 5 failure reasons, etc.); do not make them open-ended.
- Every critique ends with the mandatory footer stating it is unverified brainstorming.
- All components respond in the user's language.
- Hook scripts must never block a prompt: every failure path degrades to silent `exit 0`, and `devil-mode-context.sh` must drain stdin (`cat > /dev/null`) before producing output.

### Devil mode state

State lives outside the plugin at `~/.claude/devil-plugin/state/` because installed plugin directories are read-only. One file per project: the file name is the sanitized project basename plus a hash of the full path (plain character substitution is not injective and caused cross-project collisions). Line 1 of the file is the intensity — the only line hooks read — and line 2 is the project path, used by `cleanup` to detect orphaned state. File present = on, absent = off, invalid content falls back to `medium`. All key logic lives in `scripts/devil-mode-common.sh`, sourced by both entry-point scripts, so they always resolve the same state file. Project resolution order: explicit argument, then `CLAUDE_PROJECT_DIR`, then `pwd`. The `on`/`off`/`status` commands MUST pass the project root explicitly — the Bash tool does not export `CLAUDE_PROJECT_DIR` and its cwd can drift; only hooks receive the env var. The shared `log()` writes to `devil-mode.log` in the state dir, rotating a single `.old` generation past `LOG_MAX_BYTES` (64 KB).

## Conventions

- Shell scripts are POSIX sh (`#!/bin/sh`), not bash-specific.
- Command/agent/skill frontmatter follows Claude Code plugin conventions (`name`, `description`, `argument-hint`, `allowed-tools`/`tools`).
- `.dr_ai/` is DR_AI framework workspace (logs, settings) — not part of the plugin; do not ship or edit it as plugin content.
