# Distribution EcoCode par skills — plan d'implémentation

> **Pour les agents :** suivre ce plan tâche par tâche, avec les cases à cocher comme état d'avancement.

**Objectif :** distribuer trois skills portables (`design`, `development`, `ecocode`) via `npx skills`, sans plugin, agent spécialisé ni installation propre à une plateforme.

**Architecture :** remplacer l'arborescence `skills/audits/` par un seul skill public `skills/ecocode/`. Ses références locales portent les contrats et règles propres aux audits statiques, runtime et à la restitution. Le routeur demeure exécutable par l'agent courant ; les sous-agents ne sont qu'une optimisation optionnelle.

**Technologies :** Markdown avec frontmatter YAML, scripts de tests Bash, Node.js pour `npx skills`.

## Contraintes globales

- L'installation documentée est exclusivement `npx skills@latest add cnumr/ai-assisted-sustainable-it`.
- Les MCP `mcp-greenit` et `playwright` restent des prérequis externes documentés, sans installation automatique.
- Les écritures locales, les corrections et la création d'issues restent opt-in.
- Les analyses statiques sont des estimations ; seules les métriques runtime sont présentées comme mesurées.
- Aucun adaptateur d'agent, plugin, commande enregistrée ou hook de plateforme ne subsiste.
- Les fichiers Superpowers restent dans `.superpowers/`.

---

### Tâche 1 : Écrire le test de la distribution portable

**Fichiers :**

- Créer : `tests/structure/test-skills-only-distribution.sh`
- Supprimer : `tests/structure/test-sustainable-it-structure.sh`
- Supprimer : `tests/structure/test-install-instructions.sh`
- Supprimer : `tests/structure/test-frontend-runtime-contract.sh`
- Supprimer : `tests/structure/test-multi-tool-structure.sh`
- Supprimer : `tests/structure/test-release-metadata.sh`
- Supprimer : `tests/claude-code/`

**Produit :** un unique test de structure qui définit la nouvelle surface publique avant son implémentation.

- [ ] Écrire `tests/structure/test-skills-only-distribution.sh` avec `set -euo pipefail` et les assertions suivantes :

  ```bash
  test -f "$root/skills/design/SKILL.md"
  test -f "$root/skills/development/SKILL.md"
  test -f "$root/skills/ecocode/SKILL.md"
  test -f "$root/skills/ecocode/references/static-analysis.md"
  test -f "$root/skills/ecocode/references/runtime-analysis.md"
  test -f "$root/skills/ecocode/references/findings-contract.md"
  test -f "$root/skills/ecocode/references/restitution.md"
  ! test -e "$root/agents"
  ! test -e "$root/commands"
  ! test -e "$root/hooks"
  ! test -e "$root/.claude-plugin"
  ! test -e "$root/.codex-plugin"
  ! test -e "$root/.cursor-plugin"
  ! test -e "$root/.codex"
  ! test -e "$root/.opencode"
  ! test -e "$root/gemini-extension.json"
  grep -Fq 'npx skills@latest add cnumr/ai-assisted-sustainable-it' "$root/README.md"
  grep -Fq 'mcp-greenit' "$root/README.md"
  grep -Fq 'playwright' "$root/README.md"
  ```

- [ ] Exécuter `bash tests/structure/test-skills-only-distribution.sh` et constater l'échec attendu : `skills/ecocode/SKILL.md` est absent et les surfaces historiques existent encore.

- [ ] Commit : `test: define portable skills distribution`.

### Tâche 2 : Construire le skill public `ecocode`

**Fichiers :**

- Créer : `skills/ecocode/SKILL.md`
- Créer : `skills/ecocode/references/static-analysis.md`
- Créer : `skills/ecocode/references/runtime-analysis.md`
- Créer : `skills/ecocode/references/findings-contract.md`
- Créer : `skills/ecocode/references/restitution.md`
- Supprimer : `skills/audits/`

**Produit :** un point d'entrée portable, utilisable avec une demande naturelle ou `/ecocode` si l'hôte interprète ce raccourci.

- [ ] Écrire d'abord dans le test de la tâche 1 les assertions de contenu qui doivent échouer : `ecocode` doit contenir `mcp-greenit`, `sous-agents` et `retourne exclusivement le contrat de constats`; `restitution.md` doit contenir `brouillon d'issue` et `demande explicite`.
- [ ] Exécuter le test et constater l'échec sur ces contenus absents.
- [ ] Écrire `skills/ecocode/SKILL.md` avec le frontmatter `name: ecocode` et une description française qui déclenche les audits explicites Green IT, front, back, runtime et EcoIndex. Il route : périmètre → prérequis MCP → analyse sans écriture → constats → choix de restitution.
- [ ] Déplacer les détails d'analyse statique dans `static-analysis.md`, le protocole navigateur et les contraintes de sécurité dans `runtime-analysis.md`, le schéma de sortie minimal dans `findings-contract.md`, et les branches conversation/document/issue/plan/correction dans `restitution.md`.
- [ ] Inclure une règle positive de sous-agents facultatifs : l'hôte peut paralléliser front et back et choisir un modèle économique pour la collecte ; chaque sous-agent retourne exclusivement le contrat de constats. L'agent courant doit fonctionner seul si cette capacité est absente.
- [ ] Exécuter le test de structure et vérifier qu'il passe avant les suppressions de la tâche 3.
- [ ] Commit : `feat: add portable ecocode skill`.

### Tâche 3 : Retirer l'infrastructure historique

**Fichiers :**

- Supprimer : `agents/`, `commands/`, `hooks/`, `.claude-plugin/`, `.codex-plugin/`, `.cursor-plugin/`, `.codex/`, `.opencode/`, `gemini-extension.json`
- Supprimer : `scripts/bump-version.sh`, `.version-bump.json`

**Produit :** le dépôt ne distribue plus de plugins, de profils ou de bootstrap par plateforme.

- [ ] Placer les répertoires et fichiers listés dans la corbeille avec `trash`, sans utiliser `rm`.
- [ ] Exécuter `bash tests/structure/test-skills-only-distribution.sh` et vérifier que les assertions d'absence passent.
- [ ] Vérifier `rg -n 'ecocode-orchestrator|\.claude-plugin|\.codex-plugin|\.opencode|gemini-extension' --glob '!CHANGELOG.md' --glob '!.superpowers/**' .` ; conserver seulement les mentions de migration nécessaires dans le changelog et les documents Superpowers historiques.
- [ ] Commit : `refactor: remove platform-specific distribution`.

### Tâche 4 : Mettre à jour la documentation et la release

**Fichiers :**

- Modifier : `README.md`
- Modifier : `CLAUDE.md`
- Modifier : `GEMINI.md`
- Modifier : `docs/contributing.md`
- Modifier : `docs/testing.md`
- Modifier : `docs/releasing.md`
- Modifier : `CHANGELOG.md`

**Produit :** une seule documentation d'installation et de maintenance, sans parcours obsolète.

- [ ] Écrire d'abord les assertions du test portable qui exigent la commande `npx skills@latest add cnumr/ai-assisted-sustainable-it`, les trois skills publics, les MCP requis et l'absence de `/plugin install` dans `README.md`.
- [ ] Exécuter le test et constater l'échec attendu contre la documentation historique.
- [ ] Réécrire le README : valeur produit, installation unique, options `npx skills` (agent, scope, lien/copie), prérequis MCP, exemples de demandes naturelles et les cinq suites de l'audit.
- [ ] Réduire `CLAUDE.md` et `GEMINI.md` aux trois skills et aux prérequis portables ; retirer la table d'agents, les slash commands et les liens manuels.
- [ ] Réécrire la contribution, les tests et la release autour de `SKILL.md`, du test portable et de `npx skills`; supprimer les références aux manifests, marketplaces et version bump multi-plateforme.
- [ ] Ajouter au changelog une entrée incompatible expliquant la distribution via `npx skills` et la suppression des intégrations historiques.
- [ ] Exécuter `bash tests/structure/test-skills-only-distribution.sh` et vérifier que les règles documentaires passent.
- [ ] Commit : `docs: document skills-only installation`.

### Tâche 5 : Vérifier l'installation réelle et la cohérence finale

**Fichiers :**

- Modifier si nécessaire : `tests/structure/test-skills-only-distribution.sh`

**Produit :** une preuve que le dépôt est découvrable par le CLI et que le test local couvre sa surface publique.

- [ ] Exécuter `npx skills@latest add cnumr/ai-assisted-sustainable-it --list` depuis le worktree ; vérifier que seuls `design`, `development` et `ecocode` sont proposés.
- [ ] Exécuter `bash tests/structure/test-skills-only-distribution.sh` et `bash tests/structure/test-yaml-frontmatter.sh` ; corriger tout échec avec un nouveau cycle rouge-vert.
- [ ] Relire `README.md`, `CLAUDE.md`, `GEMINI.md`, `docs/contributing.md`, `docs/testing.md` et `docs/releasing.md` en regard de la spécification, puis consigner tout écart corrigé dans le commit concerné.
- [ ] Mettre à jour le commentaire et le statut Orca à `in-review` avec les commandes de vérification exécutées.
- [ ] Commit : `test: verify skills-only package`.
