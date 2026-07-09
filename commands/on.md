---
name: on
description: ⚖️ Enable persistent devil mode for this project (optional intensity)
argument-hint: "[light|medium|brutal]"
allowed-tools: 'Bash(sh "${CLAUDE_PLUGIN_ROOT}/scripts/devil-mode.sh":*)'
---

# Devil Mode: On

Enable persistent devil mode for the current project.

## Steps

1. Determine the intensity from `$ARGUMENTS`: valid values are `light`, `medium`, and `brutal`. If empty, use `medium`. If some other word was given, tell the user the valid values and proceed with `medium`.
2. Run exactly, replacing `<project-root>` with the absolute path of the current project's root directory (the directory the session was opened in — never the shell's current working directory, which may have drifted):

```
sh "${CLAUDE_PLUGIN_ROOT}/scripts/devil-mode.sh" on <intensity> "<project-root>"
```

3. Report to the user in their language:
   - Devil mode is now enabled for this project, with the chosen intensity.
   - From the next prompt onward, every request will receive at least one substantive challenge while the task is still completed (the hook fires on prompt submit, so it takes effect starting with the next message).
   - `/devil:off` disables it at any time.

Arguments: $ARGUMENTS
