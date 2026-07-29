---
name: ecocode
description: Lance un audit éco-conception web selon les 115 bonnes pratiques Green IT
---

Use the `audits` skill to perform an eco-design audit.

/ecocode délègue à `ecocode-orchestrator`. Cet orchestrateur choisit les analyseurs selon l'argument, puis coordonne le rapport et le plan d'action.

Arguments:

- (none) — full audit of the current project
- `front` — front-end analysis only
- `frontend` — audit runtime des parcours front-end uniquement (requiert le MCP `playwright`)
- `back` — back-end analysis only
- `<url>` — runtime analysis of a URL (requires playwright MCP)

Load the skill and follow its instructions:

```
Use skill: audits
```

Pass any arguments from `$ARGUMENTS` to determine the audit scope.
Le routage utilise le premier token exact de `$ARGUMENTS` : `frontend` doit
être traité avant et séparément de `front`.
