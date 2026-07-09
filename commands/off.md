---
name: off
description: ⚖️ Disable persistent devil mode for this project
allowed-tools: 'Bash(sh "${CLAUDE_PLUGIN_ROOT}/scripts/devil-mode.sh":*)'
---

# Devil Mode: Off

Disable persistent devil mode for the current project.

## Steps

1. Run exactly, replacing `<project-root>` with the absolute path of the current project's root directory (the directory the session was opened in — never the shell's current working directory, which may have drifted):

```
sh "${CLAUDE_PLUGIN_ROOT}/scripts/devil-mode.sh" off "<project-root>"
```

2. Report the result to the user in their language:
   - If the script confirms deactivation, say devil mode is off and prompts will no longer be challenged.
   - If the script reports that devil mode was not on, say that plainly.
