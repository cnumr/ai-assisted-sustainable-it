# Agents d'audit multi-plateformes — plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Déclencher automatiquement les mêmes rôles EcoCode depuis `/ecocode` dans Claude Code, OpenCode et Codex, avec des profils Codex adaptés à chaque tâche.

**Architecture:** Les agents Markdown existants restent la référence commune. Six adaptateurs TOML Codex portent le nom de leur rôle existant et chargent le document Markdown correspondant. La commande et le skill `audits` explicitent le routage orchestrateur → analyseurs → rédacteur → planificateur/correcteur.

**Tech Stack:** Markdown, TOML, scripts Bash de structure.

## Global Constraints

- Conserver les rôles et les règles métier existants dans `agents/*.md`.
- Utiliser `gpt-5.6-terra` pour les analyses, rapports et plans bornés.
- Garder les analyseurs Codex en lecture seule.
- Créer les nouveaux artefacts Superpowers dans `.superpowers/`.

---

### Task 1: Ajouter les contrôles de routage et des adaptateurs Codex

**Files:**
- Modify: `tests/structure/test-sustainable-it-structure.sh`
- Modify: `tests/claude-code/test-ecocode-skill.sh`

**Interfaces:**
- Consumes: les six rôles sous `agents/ecocode-*.md`.
- Produces: des assertions sur les six fichiers `.codex/agents/*.toml` et le routage `/ecocode`.

- [ ] **Step 1: Écrire les assertions en échec**

Ajouter une boucle qui exige les fichiers `ecocode-orchestrator.toml`,
`ecocode-front-analyzer.toml`, `ecocode-back-analyzer.toml`,
`ecocode-report-writer.toml`, `ecocode-planner.toml` et
`ecocode-fix-suggester.toml` sous `.codex/agents/`. Vérifier que les deux
analyseurs contiennent `sandbox_mode = "read-only"` et
`model = "gpt-5.6-terra"`.

- [ ] **Step 2: Exécuter le test pour constater l'échec**

Run: `bash tests/structure/test-sustainable-it-structure.sh`

Expected: échec car `.codex/agents/` est absent.

### Task 2: Créer les adaptateurs Codex

**Files:**
- Create: `.codex/agents/ecocode-orchestrator.toml`
- Create: `.codex/agents/ecocode-front-analyzer.toml`
- Create: `.codex/agents/ecocode-back-analyzer.toml`
- Create: `.codex/agents/ecocode-report-writer.toml`
- Create: `.codex/agents/ecocode-planner.toml`
- Create: `.codex/agents/ecocode-fix-suggester.toml`

**Interfaces:**
- Consumes: `agents/ecocode-<role>.md`.
- Produces: profils Codex nommés `ecocode-<role>`.

- [ ] **Step 1: Définir les profils**

Chaque profil contient `name`, `description` et `developer_instructions`.
Les instructions demandent de lire `agents/ecocode-<role>.md` avant d'agir.
Configurer `gpt-5.6-sol`/`high` pour l'orchestrateur et le correcteur, et
`gpt-5.6-terra`/`medium` pour les quatre rôles bornés.

- [ ] **Step 2: Restreindre les analyseurs**

Ajouter `sandbox_mode = "read-only"` aux profils front et back. Les autres
profils héritent du sandbox de la tâche parente afin de respecter les droits
de l'utilisateur.

- [ ] **Step 3: Exécuter le test de structure**

Run: `bash tests/structure/test-sustainable-it-structure.sh`

Expected: PASS.

### Task 3: Rendre le routage explicite dans les entrées d'audit

**Files:**
- Modify: `commands/ecocode.md`
- Modify: `skills/audits/SKILL.md`
- Modify: `README.md`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: profils `ecocode-<role>` et agents Markdown de même nom.
- Produces: une documentation et des instructions indiquant le déclenchement
  de l'orchestrateur et les délégations conditionnelles.

- [ ] **Step 1: Décrire le point d'entrée**

Dans `commands/ecocode.md`, préciser que `/ecocode` délègue à
`ecocode-orchestrator`, qui choisit les analyseurs selon l'argument.

- [ ] **Step 2: Compléter le skill parent**

Dans `skills/audits/SKILL.md`, indiquer que les noms des agents sont communs
à Claude Code, OpenCode et Codex et que le front et le back s'exécutent en
parallèle pour un audit complet.

- [ ] **Step 3: Documenter la compatibilité**

Ajouter au README le routage et l'optimisation de modèles Codex. Ajouter une
entrée dans `CHANGELOG.md`.

- [ ] **Step 4: Vérifier**

Run: `bash tests/structure/test-sustainable-it-structure.sh && bash tests/claude-code/test-ecocode-bootstrap.sh`

Expected: PASS.
