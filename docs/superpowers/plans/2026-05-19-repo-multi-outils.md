# Repo Multi-Outils (ecocode + rgaa) — Plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactoriser le repo `ia-tools` pour héberger plusieurs outils indépendants (ecocode + rgaa) avec sélection native à l'install via `/plugin marketplace add` et `npx skills add`.

**Architecture:** Les manifestes par plateforme migrent dans des sous-dossiers `plugins/<outil>/` ; `skills/`, `agents/`, `commands/` restent partagés avec namespacing par préfixe. Les `marketplace.json` listent les deux outils — les assistants IA et la CLI Vercel présentent alors le choix nativement.

**Tech Stack:** JSON (manifestes), Markdown (skills/agents/commands), JavaScript ESM (plugin OpenCode), Bash (tests de structure)

---

## Carte des fichiers

| Action    | Fichier                                        |
| --------- | ---------------------------------------------- |
| Supprimer | `.claude-plugin/plugin.json`                   |
| Créer     | `.claude-plugin/plugins/ecocode/plugin.json`   |
| Créer     | `.claude-plugin/plugins/rgaa/plugin.json`      |
| Modifier  | `.claude-plugin/marketplace.json`              |
| Supprimer | `.codex-plugin/plugin.json`                    |
| Créer     | `.codex-plugin/plugins/ecocode/plugin.json`    |
| Créer     | `.codex-plugin/plugins/rgaa/plugin.json`       |
| Créer     | `.codex-plugin/marketplace.json`               |
| Supprimer | `.cursor-plugin/plugin.json`                   |
| Créer     | `.cursor-plugin/plugins/ecocode/plugin.json`   |
| Créer     | `.cursor-plugin/plugins/rgaa/plugin.json`      |
| Créer     | `skills/rgaa/SKILL.md`                         |
| Créer     | `agents/rgaa-auditor.md`                       |
| Créer     | `agents/rgaa-reporter.md`                      |
| Créer     | `commands/rgaa.md`                             |
| Créer     | `.opencode/plugins/rgaa.js`                    |
| Modifier  | `CLAUDE.md`                                    |
| Modifier  | `README.md`                                    |
| Créer     | `tests/structure/test-multi-tool-structure.sh` |

---

## Task 1 : Écrire le test de structure (TDD — doit échouer)

**Files:**

- Create: `tests/structure/test-multi-tool-structure.sh`

- [ ] **Step 1 : Créer le script de test**

```bash
#!/usr/bin/env bash
# Vérifie que la structure multi-outils est en place
# Note: pas de set -e — ce script gère ses propres erreurs
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PASS=0; FAIL=0

check() {
  local desc="$1"; local path="$2"
  if [ -e "$ROOT/$path" ]; then
    echo "✓ $desc"; PASS=$(( PASS + 1 ))
  else
    echo "✗ $desc — manquant : $path"; FAIL=$(( FAIL + 1 ))
  fi
}

absent() {
  local desc="$1"; local path="$2"
  if [ ! -e "$ROOT/$path" ]; then
    echo "✓ $desc (supprimé)"; PASS=$(( PASS + 1 ))
  else
    echo "✗ $desc — doit être supprimé : $path"; FAIL=$(( FAIL + 1 ))
  fi
}

json_check() {
  local desc="$1"; local path="$2"; local jq_expr="$3"; local expected="$4"
  local actual
  actual=$(jq -r "$jq_expr" "$ROOT/$path" 2>/dev/null || echo "ERROR")
  if [ "$actual" = "$expected" ]; then
    echo "✓ $desc"; PASS=$(( PASS + 1 ))
  else
    echo "✗ $desc — attendu '$expected', obtenu '$actual'"; FAIL=$(( FAIL + 1 ))
  fi
}

echo "=== Test structure multi-outils ==="

# plugin.json ecocode dans sous-dossiers
check "Claude Code ecocode plugin.json"  ".claude-plugin/plugins/ecocode/plugin.json"
check "Codex ecocode plugin.json"        ".codex-plugin/plugins/ecocode/plugin.json"
check "Cursor ecocode plugin.json"       ".cursor-plugin/plugins/ecocode/plugin.json"

# plugin.json rgaa stubs
check "Claude Code rgaa plugin.json"    ".claude-plugin/plugins/rgaa/plugin.json"
check "Codex rgaa plugin.json"          ".codex-plugin/plugins/rgaa/plugin.json"
check "Cursor rgaa plugin.json"         ".cursor-plugin/plugins/rgaa/plugin.json"

# anciens plugin.json supprimés
absent "Ancien .claude-plugin/plugin.json supprimé"  ".claude-plugin/plugin.json"
absent "Ancien .codex-plugin/plugin.json supprimé"   ".codex-plugin/plugin.json"
absent "Ancien .cursor-plugin/plugin.json supprimé"  ".cursor-plugin/plugin.json"

# marketplace.json contient 2 plugins
json_check "Claude Code marketplace: 2 plugins" \
  ".claude-plugin/marketplace.json" ".plugins | length" "2"
json_check "Codex marketplace existe et contient 2 plugins" \
  ".codex-plugin/marketplace.json" ".plugins | length" "2"

# skills
check "skills/ecocode/SKILL.md"  "skills/ecocode/SKILL.md"
check "skills/rgaa/SKILL.md"     "skills/rgaa/SKILL.md"

# agents rgaa
check "agents/rgaa-auditor.md"   "agents/rgaa-auditor.md"
check "agents/rgaa-reporter.md"  "agents/rgaa-reporter.md"

# commands rgaa
check "commands/rgaa.md"         "commands/rgaa.md"

# opencode rgaa
check ".opencode/plugins/rgaa.js" ".opencode/plugins/rgaa.js"

# chemins relatifs Codex corrigés
json_check "Codex ecocode skills path corrigé" \
  ".codex-plugin/plugins/ecocode/plugin.json" ".skills" "../../../skills/"
json_check "Cursor ecocode skills path corrigé" \
  ".cursor-plugin/plugins/ecocode/plugin.json" ".skills" "../../../skills/"

echo ""
echo "Résultat : $PASS passés, $FAIL échoués"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
```

- [ ] **Step 2 : Rendre le script exécutable et le faire échouer**

```bash
chmod +x tests/structure/test-multi-tool-structure.sh
bash tests/structure/test-multi-tool-structure.sh
```

Résultat attendu : plusieurs `✗` et `exit 1` — la structure n'est pas encore en place.

- [ ] **Step 3 : Commit**

```bash
git add tests/structure/test-multi-tool-structure.sh
git commit -m "test: ajouter le test de structure multi-outils"
```

---

## Task 2 : Migrer les plugin.json Claude Code

**Files:**

- Create: `.claude-plugin/plugins/ecocode/plugin.json`
- Delete: `.claude-plugin/plugin.json`

Le `plugin.json` Claude Code n'a pas de chemins relatifs vers `skills/` ou `assets/` — aucune correction de chemin nécessaire.

- [ ] **Step 1 : Créer le dossier et déplacer le fichier**

```bash
mkdir -p .claude-plugin/plugins/ecocode
```

Créer `.claude-plugin/plugins/ecocode/plugin.json` avec ce contenu exact (identique à l'original) :

```json
{
  "name": "ecocode",
  "description": "Audit d'éco-conception web selon les 115 bonnes pratiques Green IT. Analyse front-end et back-end avec agents spécialisés.",
  "version": "1.0.0",
  "author": {
    "name": "Renaud Heluin",
    "email": "renaud.heluin@novagaia.fr"
  },
  "homepage": "https://github.com/your-org/ecocode-plugin",
  "repository": "https://github.com/your-org/ecocode-plugin",
  "license": "MIT",
  "keywords": [
    "ecocode",
    "green-it",
    "eco-conception",
    "sustainability",
    "web-performance"
  ]
}
```

- [ ] **Step 2 : Supprimer l'ancien fichier**

```bash
trash .claude-plugin/plugin.json
```

- [ ] **Step 3 : Vérifier**

```bash
ls .claude-plugin/plugins/ecocode/
# attendu : plugin.json
ls .claude-plugin/plugin.json 2>/dev/null && echo "ERREUR: fichier doit être supprimé" || echo "OK: supprimé"
```

- [ ] **Step 4 : Commit**

```bash
git add .claude-plugin/
git commit -m "refactor: migrer plugin.json Claude Code dans plugins/ecocode/"
```

---

## Task 3 : Migrer le plugin.json Codex + corriger les chemins

**Files:**

- Create: `.codex-plugin/plugins/ecocode/plugin.json`
- Delete: `.codex-plugin/plugin.json`

Le `plugin.json` Codex a `"skills": "./skills/"` et des chemins d'assets dans `interface`. Après déplacement vers `.codex-plugin/plugins/ecocode/`, il faut remonter 3 niveaux (`../../../`).

- [ ] **Step 1 : Créer le dossier**

```bash
mkdir -p .codex-plugin/plugins/ecocode
```

- [ ] **Step 2 : Créer `.codex-plugin/plugins/ecocode/plugin.json` avec les chemins corrigés**

```json
{
  "name": "ecocode",
  "version": "1.0.0",
  "description": "Audit d'éco-conception web selon les 115 bonnes pratiques Green IT. Analyse front-end et back-end avec agents spécialisés.",
  "author": {
    "name": "Renaud Heluin",
    "email": "renaud.heluin@novagaia.fr"
  },
  "homepage": "https://github.com/your-org/ecocode-plugin",
  "repository": "https://github.com/your-org/ecocode-plugin",
  "license": "MIT",
  "keywords": [
    "ecocode",
    "green-it",
    "eco-conception",
    "sustainability",
    "web-performance",
    "accessibility"
  ],
  "skills": "../../../skills/",
  "interface": {
    "displayName": "EcoCode — Audit Green IT",
    "shortDescription": "Audit d'éco-conception web basé sur les 115 bonnes pratiques Green IT",
    "longDescription": "EcoCode analyse votre projet web selon les 115 bonnes pratiques Green IT du référentiel CNUMR. Il identifie automatiquement le périmètre front-end et back-end, délègue l'analyse à des agents spécialisés, et produit un rapport hiérarchisé avec des recommandations actionnables.",
    "developerName": "Renaud Heluin",
    "category": "Coding",
    "capabilities": ["Interactive", "Read"],
    "defaultPrompt": [
      "Lance un audit éco-conception sur ce projet.",
      "Analyse le front-end de ce projet selon les bonnes pratiques Green IT."
    ],
    "websiteURL": "https://github.com/your-org/ecocode-plugin",
    "brandColor": "#22C55E",
    "composerIcon": "../../../assets/ecocode-small.svg",
    "logo": "../../../assets/app-icon.png",
    "screenshots": []
  }
}
```

- [ ] **Step 3 : Supprimer l'ancien fichier**

```bash
trash .codex-plugin/plugin.json
```

- [ ] **Step 4 : Vérifier les chemins résolus**

```bash
# Depuis .codex-plugin/plugins/ecocode/, ../../../skills/ doit pointer vers skills/ à la racine
ls .codex-plugin/plugins/ecocode/../../../skills/
# attendu : ecocode/
```

- [ ] **Step 5 : Commit**

```bash
git add .codex-plugin/
git commit -m "refactor: migrer plugin.json Codex dans plugins/ecocode/ + corriger chemins"
```

---

## Task 4 : Migrer le plugin.json Cursor + corriger les chemins

**Files:**

- Create: `.cursor-plugin/plugins/ecocode/plugin.json`
- Delete: `.cursor-plugin/plugin.json`

Le `plugin.json` Cursor a 4 chemins relatifs : `skills`, `agents`, `commands`, `hooks`. Tous passent à `../../../`.

- [ ] **Step 1 : Créer le dossier**

```bash
mkdir -p .cursor-plugin/plugins/ecocode
```

- [ ] **Step 2 : Créer `.cursor-plugin/plugins/ecocode/plugin.json`**

```json
{
  "name": "ecocode",
  "displayName": "Ecocode",
  "description": "Audit d'éco-conception web selon les 115 bonnes pratiques Green IT. Analyse front-end et back-end avec agents spécialisés.",
  "version": "1.0.0",
  "author": {
    "name": "Renaud Heluin",
    "email": "renaud.heluin@novagaia.fr"
  },
  "license": "MIT",
  "keywords": [
    "ecocode",
    "green-it",
    "eco-conception",
    "sustainability",
    "web-performance"
  ],
  "skills": "../../../skills/",
  "agents": "../../../agents/",
  "commands": "../../../commands/",
  "hooks": "../../../hooks/hooks-cursor.json"
}
```

- [ ] **Step 3 : Supprimer l'ancien fichier**

```bash
trash .cursor-plugin/plugin.json
```

- [ ] **Step 4 : Vérifier**

```bash
ls .cursor-plugin/plugins/ecocode/../../../hooks/hooks-cursor.json
# attendu : hooks/hooks-cursor.json
```

- [ ] **Step 5 : Commit**

```bash
git add .cursor-plugin/
git commit -m "refactor: migrer plugin.json Cursor dans plugins/ecocode/ + corriger chemins"
```

---

## Task 5 : Mettre à jour les marketplace.json

**Files:**

- Modify: `.claude-plugin/marketplace.json`
- Create: `.codex-plugin/marketplace.json`

Le champ `source` est relatif à l'emplacement du `marketplace.json`. Le marketplace Claude Code est dans `.claude-plugin/`, donc `source` pointe vers `"./plugins/ecocode"` (et non `"./.claude-plugin/plugins/ecocode"`).

- [ ] **Step 1 : Mettre à jour `.claude-plugin/marketplace.json`**

```json
{
  "name": "ia-tools",
  "description": "Outils d'audit qualité web : éco-conception et accessibilité",
  "owner": {
    "name": "Renaud Heluin",
    "email": "renaud.heluin@novagaia.fr"
  },
  "plugins": [
    {
      "name": "ecocode",
      "description": "Audit éco-conception web, 115 bonnes pratiques Green IT",
      "source": "./plugins/ecocode",
      "category": "development",
      "version": "1.0.0",
      "author": {
        "name": "Renaud Heluin",
        "email": "renaud.heluin@novagaia.fr"
      }
    },
    {
      "name": "rgaa",
      "description": "Audit accessibilité RGAA 4.2.1",
      "source": "./plugins/rgaa",
      "category": "development",
      "version": "1.0.0",
      "author": {
        "name": "Renaud Heluin",
        "email": "renaud.heluin@novagaia.fr"
      }
    }
  ]
}
```

- [ ] **Step 2 : Créer `.codex-plugin/marketplace.json`** (même contenu, source identique)

```json
{
  "name": "ia-tools",
  "description": "Outils d'audit qualité web : éco-conception et accessibilité",
  "owner": {
    "name": "Renaud Heluin",
    "email": "renaud.heluin@novagaia.fr"
  },
  "plugins": [
    {
      "name": "ecocode",
      "description": "Audit éco-conception web, 115 bonnes pratiques Green IT",
      "source": "./plugins/ecocode",
      "category": "development",
      "version": "1.0.0",
      "author": {
        "name": "Renaud Heluin",
        "email": "renaud.heluin@novagaia.fr"
      }
    },
    {
      "name": "rgaa",
      "description": "Audit accessibilité RGAA 4.2.1",
      "source": "./plugins/rgaa",
      "category": "development",
      "version": "1.0.0",
      "author": {
        "name": "Renaud Heluin",
        "email": "renaud.heluin@novagaia.fr"
      }
    }
  ]
}
```

- [ ] **Step 3 : Vérifier le JSON et le nombre de plugins**

```bash
jq '.plugins | length' .claude-plugin/marketplace.json
# attendu : 2
jq '.plugins | length' .codex-plugin/marketplace.json
# attendu : 2
```

- [ ] **Step 4 : Commit**

```bash
git add .claude-plugin/marketplace.json .codex-plugin/marketplace.json
git commit -m "feat: étendre marketplace.json pour 2 plugins (ecocode + rgaa)"
```

---

## Task 6 : Créer les stubs rgaa

**Files:**

- Create: `.claude-plugin/plugins/rgaa/plugin.json`
- Create: `.codex-plugin/plugins/rgaa/plugin.json`
- Create: `.cursor-plugin/plugins/rgaa/plugin.json`
- Create: `skills/rgaa/SKILL.md`
- Create: `agents/rgaa-auditor.md`
- Create: `agents/rgaa-reporter.md`
- Create: `commands/rgaa.md`
- Create: `.opencode/plugins/rgaa.js`

Les stubs sont fonctionnels mais minimaux — ils déclenchent le skill et indiquent que le contenu est à développer dans un spec séparé.

- [ ] **Step 1 : Créer les dossiers**

```bash
mkdir -p .claude-plugin/plugins/rgaa
mkdir -p .codex-plugin/plugins/rgaa
mkdir -p .cursor-plugin/plugins/rgaa
mkdir -p skills/rgaa
```

- [ ] **Step 2 : Créer `.claude-plugin/plugins/rgaa/plugin.json`**

```json
{
  "name": "rgaa",
  "description": "Audit d'accessibilité web selon le référentiel RGAA 4.2.1.",
  "version": "0.1.0",
  "author": {
    "name": "Renaud Heluin",
    "email": "renaud.heluin@novagaia.fr"
  },
  "homepage": "https://github.com/your-org/ia-tools",
  "repository": "https://github.com/your-org/ia-tools",
  "license": "MIT",
  "keywords": ["rgaa", "accessibilite", "a11y", "audit"]
}
```

- [ ] **Step 3 : Créer `.codex-plugin/plugins/rgaa/plugin.json`**

```json
{
  "name": "rgaa",
  "version": "0.1.0",
  "description": "Audit d'accessibilité web selon le référentiel RGAA 4.2.1.",
  "author": {
    "name": "Renaud Heluin",
    "email": "renaud.heluin@novagaia.fr"
  },
  "homepage": "https://github.com/your-org/ia-tools",
  "repository": "https://github.com/your-org/ia-tools",
  "license": "MIT",
  "keywords": ["rgaa", "accessibilite", "a11y", "audit"],
  "skills": "../../../skills/",
  "interface": {
    "displayName": "RGAA — Audit Accessibilité",
    "shortDescription": "Audit d'accessibilité web selon le référentiel RGAA 4.2.1",
    "longDescription": "Conduit un audit d'accessibilité complet selon le RGAA 4.2.1. Analyse les critères d'accessibilité, identifie les non-conformités et produit un rapport avec recommandations priorisées.",
    "developerName": "Renaud Heluin",
    "category": "Coding",
    "capabilities": ["Interactive", "Read"],
    "defaultPrompt": [
      "Lance un audit accessibilité RGAA sur ce projet.",
      "Analyse l'accessibilité de cette page selon le RGAA 4.2.1."
    ],
    "websiteURL": "https://github.com/your-org/ia-tools",
    "brandColor": "#3B82F6",
    "screenshots": []
  }
}
```

- [ ] **Step 4 : Créer `.cursor-plugin/plugins/rgaa/plugin.json`**

```json
{
  "name": "rgaa",
  "displayName": "RGAA — Audit Accessibilité",
  "description": "Audit d'accessibilité web selon le référentiel RGAA 4.2.1.",
  "version": "0.1.0",
  "author": {
    "name": "Renaud Heluin",
    "email": "renaud.heluin@novagaia.fr"
  },
  "license": "MIT",
  "keywords": ["rgaa", "accessibilite", "a11y", "audit"],
  "skills": "../../../skills/",
  "agents": "../../../agents/",
  "commands": "../../../commands/",
  "hooks": "../../../hooks/hooks-cursor.json"
}
```

- [ ] **Step 5 : Créer `skills/rgaa/SKILL.md`**

```markdown
---
name: rgaa
description: Conduit un audit accessibilité RGAA 4.2.1 complet. Utiliser quand
  on demande un audit accessibilité, une analyse RGAA, ou une revue a11y.
license: MIT
metadata:
  author: Renaud Heluin
  version: "0.1"
---

# RGAA — Audit Accessibilité

> Ce skill est en cours de développement. Le contenu fonctionnel sera ajouté dans une prochaine itération.

## Usage
```

/rgaa # Audit complet du projet courant
/rgaa https://example.com # Analyse d'une URL (requiert playwright)

```

```

- [ ] **Step 6 : Créer `agents/rgaa-auditor.md`**

```markdown
---
name: rgaa-auditor
description: Agent d'audit accessibilité RGAA 4.2.1. Analyse les pages web selon les critères RGAA et identifie les non-conformités.
---

# rgaa-auditor

> Stub — contenu à développer dans le spec rgaa.
```

- [ ] **Step 7 : Créer `agents/rgaa-reporter.md`**

```markdown
---
name: rgaa-reporter
description: Agent de rapport RGAA. Agrège les résultats d'audit et produit un rapport structuré avec taux de conformité et recommandations priorisées.
---

# rgaa-reporter

> Stub — contenu à développer dans le spec rgaa.
```

- [ ] **Step 8 : Créer `commands/rgaa.md`**

```markdown
# /rgaa

Lance un audit d'accessibilité RGAA 4.2.1 sur le projet courant ou une URL donnée.

## Usage
```

/rgaa # Audit complet du projet courant
/rgaa front # Analyse front-end uniquement
/rgaa https://example.com # Analyse d'une URL (requiert playwright)

```

> Commande en cours de développement.
```

- [ ] **Step 9 : Créer `.opencode/plugins/rgaa.js`**

```javascript
/**
 * RGAA plugin for OpenCode.ai — stub
 * Contenu fonctionnel à développer dans le spec rgaa.
 */

import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rgaaSkillsDir = path.resolve(__dirname, "../../skills");

export const RgaaPlugin = async ({ client, directory }) => {
  return {
    config: async (config) => {
      config.skills = config.skills || {};
      config.skills.paths = config.skills.paths || [];
      if (!config.skills.paths.includes(rgaaSkillsDir)) {
        config.skills.paths.push(rgaaSkillsDir);
      }
    },
  };
};
```

- [ ] **Step 10 : Commit**

```bash
git add .claude-plugin/plugins/rgaa/ .codex-plugin/plugins/rgaa/ .cursor-plugin/plugins/rgaa/ \
        skills/rgaa/ agents/rgaa-auditor.md agents/rgaa-reporter.md \
        commands/rgaa.md .opencode/plugins/rgaa.js
git commit -m "feat: ajouter stubs rgaa (plugin.json, skill, agents, command, opencode)"
```

---

## Task 7 : Mettre à jour CLAUDE.md et README.md

**Files:**

- Modify: `CLAUDE.md`
- Modify: `README.md`

- [ ] **Step 1 : Mettre à jour `CLAUDE.md`**

Remplacer le tableau des Skills et Agents dans `CLAUDE.md` pour refléter les deux outils. La section concernée commence après `## Skills` et `## Agents`.

Nouveau contenu de la section Skills :

```markdown
## Skills

- **`ecocode`** — Orchestration principale éco-conception : identifie le périmètre, délègue aux sous-skills, écrit les fichiers d'audit
- **`ecocode/front`** — Analyse front-end : assets, JS, CSS, HTTP, DOM, cache, build
- **`ecocode/back`** — Analyse back-end : BDD, cache serveur, API, workers, infrastructure
- **`rgaa`** — Audit accessibilité RGAA 4.2.1 (stub — en développement)
```

Nouveau contenu de la section Agents :

```markdown
## Agents

| Agent                    | Outil   | Rôle                                | Permissions               |
| ------------------------ | ------- | ----------------------------------- | ------------------------- |
| `ecocode-orchestrator`   | ecocode | Coordonne l'audit éco-conception    | Lecture seule             |
| `ecocode-front-analyzer` | ecocode | Analyse le code client              | Lecture seule             |
| `ecocode-back-analyzer`  | ecocode | Analyse le code serveur             | Lecture seule             |
| `ecocode-report-writer`  | ecocode | Écrit les fichiers d'audit          | Écriture sur docs/        |
| `ecocode-planner`        | ecocode | Génère le plan d'action priorisé    | Écriture sur docs/        |
| `ecocode-fix-suggester`  | ecocode | Propose et applique les corrections | Écriture sur confirmation |
| `rgaa-auditor`           | rgaa    | Audit RGAA (stub)                   | Lecture seule             |
| `rgaa-reporter`          | rgaa    | Rapport RGAA (stub)                 | Lecture seule             |
```

Nouveau contenu de la section Utilisation :

```markdown
## Utilisation
```

/ecocode # Audit éco-conception complet du projet courant
/ecocode front # Analyse front-end uniquement
/ecocode back # Analyse back-end uniquement
/ecocode https://example.com # Analyse d'une URL (requiert playwright)

/rgaa # Audit accessibilité RGAA (en développement)

```

```

- [ ] **Step 2 : Mettre à jour `README.md`**

Ajouter une section "Outils disponibles" en début de README (après le titre/description) :

```markdown
## Outils disponibles

| Outil     | Description                                             | Statut           |
| --------- | ------------------------------------------------------- | ---------------- |
| `ecocode` | Audit éco-conception web, 115 bonnes pratiques Green IT | Stable           |
| `rgaa`    | Audit accessibilité RGAA 4.2.1                          | En développement |
```

Mettre à jour la section "Installation Claude Code" pour mentionner le choix d'outil :

````markdown
## Installation Claude Code

```bash
# Installe un outil spécifique (choisir ecocode ou rgaa)
/plugin marketplace add <owner>/ia-tools
```
````

## Installation via CLI

```bash
npx skills add <owner>/ia-tools
# La CLI liste les outils disponibles et demande lequel installer
```

````

- [ ] **Step 3 : Commit**

```bash
git add CLAUDE.md README.md
git commit -m "docs: mettre à jour CLAUDE.md et README pour le repo multi-outils"
````

---

## Task 8 : Lancer le test de structure et vérifier

- [ ] **Step 1 : Lancer le test**

```bash
bash tests/structure/test-multi-tool-structure.sh
```

Résultat attendu :

```
=== Test structure multi-outils ===
✓ Claude Code ecocode plugin.json
✓ Codex ecocode plugin.json
✓ Cursor ecocode plugin.json
✓ Claude Code rgaa plugin.json
✓ Codex rgaa plugin.json
✓ Cursor rgaa plugin.json
✓ Ancien .claude-plugin/plugin.json supprimé
✓ Ancien .codex-plugin/plugin.json supprimé
✓ Ancien .cursor-plugin/plugin.json supprimé
✓ Claude Code marketplace: 2 plugins
✓ Codex marketplace existe et contient 2 plugins
✓ skills/ecocode/SKILL.md
✓ skills/rgaa/SKILL.md
✓ agents/rgaa-auditor.md
✓ agents/rgaa-reporter.md
✓ commands/rgaa.md
✓ .opencode/plugins/rgaa.js
✓ Codex ecocode skills path corrigé
✓ Cursor ecocode skills path corrigé

Résultat : 19 passés, 0 échoués
```

- [ ] **Step 2 : Si des tests échouent**, identifier le fichier manquant ou le chemin incorrect et corriger avant de continuer.

- [ ] **Step 3 : Commit final**

```bash
git add -A
git commit -m "chore: finaliser la migration repo multi-outils — tous les tests passent"
```
