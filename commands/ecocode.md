---
name: ecocode
description: Lance un audit éco-conception web selon les 115 bonnes pratiques Green IT
---

Use the `ecocode` skill to perform an eco-design audit.

Arguments:

- (none) — full audit of the current project
- `front` — front-end analysis only
- `back` — back-end analysis only
- `<url>` — runtime analysis of a URL (requires playwright MCP)

Load the skill and follow its instructions:

```
Use skill: audits
```

Pass any arguments from `$ARGUMENTS` to determine the audit scope.
