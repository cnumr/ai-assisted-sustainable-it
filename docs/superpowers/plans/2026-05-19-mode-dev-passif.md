# Mode développement passif Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Injecter automatiquement un guide compact de 20 règles d'éco-conception à chaque session Claude, so that Claude applique les bonnes pratiques en écrivant du code sans que l'utilisateur ait à appeler `/ecocode`.

**Architecture:** Créer `skills/ecocode/dev-guide/SKILL.md` — un fichier markdown statique avec les 20 pratiques Green IT les plus impactantes au moment du code, formatées comme règles de conduite (pas un workflow d'audit). Modifier `hooks/session-start` pour injecter ce guide à la place du skill d'orchestration complet. Le skill d'orchestration reste disponible via `/ecocode` pour les audits explicites.

**Tech Stack:** Bash (hook), Markdown (skill file), JSON (hook output format).

---

## Structure des fichiers

| Fichier                             | Action   | Responsabilité                                                     |
| ----------------------------------- | -------- | ------------------------------------------------------------------ |
| `skills/ecocode/dev-guide/SKILL.md` | Créer    | 20 règles de codage éco-conception, statiques, groupées par couche |
| `hooks/session-start`               | Modifier | Injecter dev-guide au lieu du skill d'orchestration complet        |
| `README.md`                         | Modifier | Documenter le mode passif                                          |
| `CHANGELOG.md`                      | Modifier | Ajouter l'entrée [Unreleased]                                      |

---

### Task 1: Créer skills/ecocode/dev-guide/SKILL.md

**Files:**

- Create: `skills/ecocode/dev-guide/SKILL.md`

- [ ] **Step 1: Créer le dossier et le fichier**

```bash
mkdir -p /Users/renaudheluin/DEV/ia/ia-tools/skills/ecocode/dev-guide
```

- [ ] **Step 2: Écrire le contenu complet du fichier**

Contenu exact à écrire dans `skills/ecocode/dev-guide/SKILL.md` :

```markdown
---
name: ecocode/dev-guide
description: Passive eco-design coding guidelines. Always apply these rules when writing or modifying code — front-end and back-end. Loaded automatically at session start.
---

# Éco-conception — Règles de codage actives

Applique ces règles **automatiquement** quand tu écris ou modifies du code. Pas besoin qu'on te le demande.

## Front-end

### Chargement

- **Lazy-load** : attribut `loading="lazy"` sur toutes les `<img>` hors viewport ; `import()` dynamique pour le code non critique (`RWEB_0051`, `RWEB_0046`)
- **Imports ciblés** : importe les fonctions, pas les libs entières — `import { debounce } from 'lodash-es'` pas `import _ from 'lodash'` (`RWEB_0015`)
- **Taille images** : utilise `srcset`/`sizes`, format WebP ou AVIF de préférence au JPEG/PNG (`RWEB_0048`, `RWEB_0049`)
- **Pas d'autoplay** : jamais `autoplay` sur `<video>` ou `<audio>` sans contrôle explicite utilisateur (`RWEB_0106`)

### DOM & rendu

- **CSS > JS** : préfère `transition` et `animation` CSS aux animations JavaScript (`RWEB_0009`)
- **CSS > images** : utilise `gradient`, `border-radius`, `clip-path` plutôt que des images décoratives (`RWEB_0037`)
- **Batch DOM** : ne modifie pas le DOM pendant la traversée — regroupe les changements, utilise `DocumentFragment` (`RWEB_0044`)
- **Cache DOM** : stocke les références DOM dans des variables avant les boucles — pas de `querySelector` répété (`RWEB_0054`)
- **Délégation** : un seul event listener sur le parent au lieu de N listeners sur chaque enfant (`RWEB_0056`)
- **Repaint/reflow** : évite de lire `offsetHeight`/`offsetWidth` juste après avoir modifié des styles CSS (`RWEB_0052`)
- **Tâches JS** : découpe les traitements longs en chunks < 50ms — `requestIdleCallback`, `setTimeout(fn, 0)`, Web Workers (`RWEB_0053`)

## Back-end

- **Async** : traite les opérations lourdes de manière asynchrone — jobs, queues, workers — ne bloque pas le thread principal (`RWEB_0007`)
- **Cache calculs** : mémoïse les résultats coûteux — `@lru_cache` (Python), Redis, Memcache — plutôt que de recalculer (`RWEB_0016`)
- **Batch queries** : évite les boucles qui génèrent N requêtes SQL — `select_related`/`prefetch_related` (Django), `include` (Laravel), `JOIN` ou `IN (...)` (`RWEB_0021`)
- **Types DB** : utilise le type le plus petit adapté — `INT` pas `BIGINT`, `VARCHAR(n)` pas `TEXT` sans justification (`RWEB_0063`)
- **Stockage minimal** : ne persiste que les données strictement nécessaires — pas de colonnes "au cas où" (`RWEB_0023`)
- **TTL données** : toute table/collection a une politique d'expiration — TTL Redis, `deleted_at`, job de purge (`RWEB_0079`)

## Build & config

- **Cache-Control** : assets statiques avec content hash → `Cache-Control: max-age=31536000, immutable` (`RWEB_0075`)
- **Minification** : configure le build tool pour minifier CSS, JS, HTML, SVG en production (`RWEB_0077`)
```

- [ ] **Step 3: Vérifier la structure du fichier**

```bash
grep "^##\|^###\|^- \*\*" /Users/renaudheluin/DEV/ia/ia-tools/skills/ecocode/dev-guide/SKILL.md | head -30
```

Sortie attendue : les sections Front-end (Chargement, DOM & rendu), Back-end, Build & config, avec les 20 règles.

- [ ] **Step 4: Compter les règles**

```bash
grep -c "^- \*\*" /Users/renaudheluin/DEV/ia/ia-tools/skills/ecocode/dev-guide/SKILL.md
```

Attendu : `20`

- [ ] **Step 5: Vérifier que les codes RWEB sont présents**

```bash
grep -o "RWEB_[0-9]*" /Users/renaudheluin/DEV/ia/ia-tools/skills/ecocode/dev-guide/SKILL.md | sort -u
```

Attendu : au moins 18 codes RWEB uniques.

- [ ] **Step 6: Commit**

```bash
git add skills/ecocode/dev-guide/SKILL.md
git commit -m "feat(ecocode): ajouter le guide de codage passif (dev-guide)"
```

---

### Task 2: Modifier hooks/session-start pour injecter le dev-guide

**Files:**

- Modify: `hooks/session-start`

Le hook actuel injecte le skill d'orchestration complet (`skills/ecocode/SKILL.md`). On le remplace par le dev-guide compact, avec une ligne de rappel pour `/ecocode`.

- [ ] **Step 1: Lire le hook actuel**

```bash
cat /Users/renaudheluin/DEV/ia/ia-tools/hooks/session-start
```

Repérer la ligne : `skill_content=$(cat "${PLUGIN_ROOT}/skills/ecocode/SKILL.md" ...)`

- [ ] **Step 2: Remplacer le contenu du hook**

Remplacer le fichier `hooks/session-start` par ce contenu exact :

```bash
#!/usr/bin/env bash
# SessionStart hook for ecocode plugin — injects passive dev-guide

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

guide_content=$(cat "${PLUGIN_ROOT}/skills/ecocode/dev-guide/SKILL.md" 2>&1 || echo "Error reading ecocode dev-guide")

escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

guide_escaped=$(escape_for_json "$guide_content")
session_context="<EXTREMELY_IMPORTANT>\nTu as le plugin ecocode chargé. Voici les règles d'éco-conception à appliquer automatiquement quand tu écris ou modifies du code :\n\n${guide_escaped}\n\nPour un audit complet du projet : \`/ecocode\` — analyse le code, génère un rapport horodaté et un plan d'action priorisé.\n</EXTREMELY_IMPORTANT>"

if [ -n "${CURSOR_PLUGIN_ROOT:-}" ]; then
  printf '{\n  "additional_context": "%s"\n}\n' "$session_context"
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -z "${COPILOT_CLI:-}" ]; then
  printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$session_context"
else
  printf '{\n  "additionalContext": "%s"\n}\n' "$session_context"
fi

exit 0
```

- [ ] **Step 3: Vérifier que le hook est exécutable**

```bash
ls -la /Users/renaudheluin/DEV/ia/ia-tools/hooks/session-start
```

Si non exécutable : `chmod +x /Users/renaudheluin/DEV/ia/ia-tools/hooks/session-start`

- [ ] **Step 4: Tester le hook — vérifier la sortie JSON**

```bash
cd /Users/renaudheluin/DEV/ia/ia-tools && CLAUDE_PLUGIN_ROOT=$(pwd) bash hooks/session-start
```

Vérifier :

- La sortie est du JSON valide (pas d'erreur de syntaxe)
- Elle contient `hookSpecificOutput`
- Elle contient `Éco-conception — Règles de codage actives`
- Elle contient `RWEB_0051`
- Elle contient `/ecocode`

- [ ] **Step 5: Vérifier que le JSON est valide**

```bash
cd /Users/renaudheluin/DEV/ia/ia-tools && CLAUDE_PLUGIN_ROOT=$(pwd) bash hooks/session-start | python3 -c "import sys, json; json.load(sys.stdin); print('JSON valide')"
```

Attendu : `JSON valide`

- [ ] **Step 6: Tester pour OpenCode (sans CLAUDE_PLUGIN_ROOT)**

```bash
cd /Users/renaudheluin/DEV/ia/ia-tools && bash hooks/session-start
```

Attendu : JSON avec `additionalContext` (pas `hookSpecificOutput`), contenant les règles.

- [ ] **Step 7: Commit**

```bash
git add hooks/session-start
git commit -m "feat(ecocode): injecter le guide de codage passif au démarrage de session"
```

---

### Task 3: Mettre à jour README.md et CHANGELOG.md

**Files:**

- Modify: `README.md`
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Ajouter la section "Mode développement passif" dans README.md**

Lire le fichier actuel pour trouver le bon emplacement (après la section "Modes d'exécution" ou avant "Installation").

Ajouter cette section :

```markdown
### Mode développement passif

À chaque démarrage de session, le plugin injecte automatiquement un guide compact de 20 règles d'éco-conception. Claude les applique en écrivant du code — sans qu'on ait à appeler `/ecocode`.

Les règles couvrent :

| Couche    | Thèmes                                                                     |
| --------- | -------------------------------------------------------------------------- |
| Front-end | Lazy-loading, imports ciblés, CSS > JS, batch DOM, délégation d'événements |
| Back-end  | Async, cache, batch queries, types DB, TTL données                         |
| Build     | Cache-Control, minification                                                |

Ce mode est actif par défaut. Il est complémentaire aux audits explicites via `/ecocode`.
```

- [ ] **Step 2: Vérifier que la section est présente**

```bash
grep -n "Mode développement passif" /Users/renaudheluin/DEV/ia/ia-tools/README.md
```

Attendu : une ligne avec le numéro de ligne correspondant.

- [ ] **Step 3: Ajouter l'entrée dans CHANGELOG.md**

Dans la section `## [Unreleased]` → `### Ajouté`, ajouter en tête de liste :

```
- Mode développement passif : guide compact de 20 règles Green IT (RWEB_0007 à RWEB_0106) injecté automatiquement à chaque session via le hook `SessionStart` — Claude applique les bonnes pratiques d'éco-conception en écrivant du code sans appel explicite à `/ecocode`
```

- [ ] **Step 4: Vérifier l'entrée CHANGELOG**

```bash
grep -n "Mode développement passif" /Users/renaudheluin/DEV/ia/ia-tools/CHANGELOG.md
```

Attendu : une ligne dans la section `[Unreleased]`.

- [ ] **Step 5: Commit**

```bash
git add README.md CHANGELOG.md
git commit -m "docs: documenter le mode développement passif"
```

---

## Self-Review

**Spec coverage :**

- ✅ Task 1 : dev-guide créé avec 20 règles sur 4 couches
- ✅ Task 2 : hook modifié pour injecter le dev-guide + rappel `/ecocode`
- ✅ Task 3 : README + CHANGELOG mis à jour

**Placeholder scan :** Aucun TBD, aucun "add validation", code complet dans chaque step.

**Type consistency :** Variable renommée de `skill_content`/`skill_escaped` → `guide_content`/`guide_escaped` de manière cohérente dans le hook.
