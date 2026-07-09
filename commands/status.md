---
name: status
description: ⚖️ Show whether persistent devil mode is active for this project
allowed-tools: 'Bash(sh "${CLAUDE_PLUGIN_ROOT}/scripts/devil-mode.sh":*)'
---

# Devil Mode: Status

Report whether persistent devil mode is active for the current project.

## Steps

1. Run exactly, replacing `<project-root>` with the absolute path of the current project's root directory (the directory the session was opened in — never the shell's current working directory, which may have drifted):

```
sh "${CLAUDE_PLUGIN_ROOT}/scripts/devil-mode.sh" status "<project-root>"
```

2. Report the result to the user in their language:
   - If the script prints an ON line, say devil mode is active for this project, state the intensity, and that `/devil:off` disables it.
   - If the script prints nothing, say devil mode is off for this project and that `/devil:on [light|medium|brutal]` enables it.
