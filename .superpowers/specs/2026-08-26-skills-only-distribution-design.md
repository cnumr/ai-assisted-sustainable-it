# Distribution EcoCode par skills — design

## Objectif

Distribuer EcoCode exclusivement avec `npx skills@latest add
cnumr/ai-assisted-sustainable-it`. Supprimer les plugins, commandes,
adaptateurs d'agents et installations manuelles propres aux plateformes.

Le produit doit conserver deux capacités :

- appliquer automatiquement l'éco-conception pendant la conception et le
  développement ;
- réaliser à la demande des audits statiques front/back ou runtime dans le
  navigateur, puis poursuivre dans la session, générer un document, préparer
  une issue ou appliquer des corrections.

Cette évolution rompt volontairement la compatibilité avec les installations
Claude Code, OpenCode, Codex, Cursor et Gemini du dépôt actuel.

## Architecture

```text
skills/
├── design/
│   └── SKILL.md
├── development/
│   └── SKILL.md
└── ecocode/
    ├── SKILL.md
    └── references/
        ├── static-analysis.md
        ├── runtime-analysis.md
        ├── findings-contract.md
        └── restitution.md
```

`design` et `development` restent des skills autonomes, déclenchés par le
modèle lorsqu'une solution est conçue ou modifiée. `ecocode` est l'unique
skill d'audit public : il route une demande explicite vers les branches
front, back, complète ou runtime.

Les détails qui ne concernent qu'une branche sont placés dans `references/`.
Le fichier principal ne contient que le routage, les prérequis, les étapes
communes et les critères de fin.

## Parcours d'audit

1. Déterminer le périmètre demandé ou proposer front, back, complet ou
   runtime.
2. Vérifier les MCP nécessaires : `mcp-greenit` pour tout audit et
   `playwright` pour le runtime.
3. Réaliser l'analyse sans écriture ni modification du projet.
4. Restituer les constats dans la conversation.
5. Demander la suite : aucun livrable, document Markdown, brouillon ou
   création d'issue, plan d'action, ou corrections dans la session.
6. Écrire, créer une issue ou corriger uniquement après le choix explicite
   correspondant.

Une demande directe telle que « audite le back-end » utilise la même branche
que le routeur, sans imposer le mot-clé `/ecocode`.

## Contrat de constats

Chaque branche d'analyse produit seulement les données nécessaires à la
restitution :

- périmètre et limites de la mesure ;
- métriques disponibles, dont l'EcoIndex runtime quand il est mesuré ;
- constats prouvés : règle Green IT vérifiée, localisation, preuve, impact,
  sévérité et correction proposée ;
- bonnes pratiques observées ;
- pistes à vérifier, distinctes des constats prouvés.

Le routeur ne reçoit ni journal de recherche, ni extraits redondants, ni
rapport intermédiaire. La référence `findings-contract.md` définit le schéma
exact et est la source unique de ce contrat.

## Sous-agents facultatifs

Lorsqu'un hôte propose des sous-agents, `ecocode` peut déléguer les analyses
front et back en parallèle. Il choisit un modèle économique pour l'inventaire
et la collecte, puis un modèle plus capable seulement lorsqu'une synthèse,
une décision ou une correction complexe le justifie.

Cette consigne est une optimisation : aucun modèle, rôle, sandbox ou
parallélisme ne doit être requis pour terminer un audit. Chaque sous-agent
retourne exclusivement le contrat de constats ; l'agent courant demeure
l'orchestrateur.

## Restitution et écritures

- **Conversation** : résultat par défaut, sans fichier créé.
- **Document** : rapport Markdown dans `docs/ecocode/audits/` seulement après
  demande ou confirmation.
- **Issue** : brouillon par défaut ; création dans un outil externe seulement
  sur demande explicite et si l'intégration est disponible.
- **Plan** : priorisation issue des constats déjà collectés, sans relire les
  sources.
- **Correction** : proposition puis application explicite dans la session.

Les résultats statiques sont qualifiés d'estimations. Seul un audit runtime
peut présenter les métriques navigateur comme mesurées.

## Distribution et documentation

Le README fournit une installation principale :

```bash
npx skills@latest add cnumr/ai-assisted-sustainable-it
```

Il explique les choix interactifs du CLI : agent cible, scope projet/global,
skills sélectionnés et copie ou lien symbolique. Il documente séparément les
MCP requis, car le CLI ne les configure pas.

La documentation de contribution, de tests et de release ne référence plus
de marketplace, manifestes, adaptateurs, bootstrap ou scripts d'installation
par plateforme. Les tests vérifient la structure portable, les prérequis et
les parcours d'audit ; ils testent des comportements, non des phrases
entières.

## Suppressions

Sont supprimés lorsqu'ils sont rendus inutiles par cette architecture :

- `agents/`, `.opencode/`, `.codex/`, `.claude-plugin/`, `.codex-plugin/`,
  `.cursor-plugin/` et `gemini-extension.json` ;
- les hooks et scripts de bootstrap dédiés aux plateformes ;
- les guides d'installation propres à une plateforme et leurs tests ;
- les commandes `/ecocode` enregistrées par les plugins.

## Critères d'acceptation

- `npx skills@latest add cnumr/ai-assisted-sustainable-it --list` découvre
  les trois skills publics `design`, `development` et `ecocode`.
- Chaque skill contient un frontmatter valide et ses références requises.
- Une installation choisie par le CLI fonctionne sans plugin ni profil
  d'agent du dépôt.
- Une demande d'audit direct ou routée couvre les quatre périmètres et propose
  les cinq suites possibles.
- Les opérations d'écriture et les intégrations externes restent opt-in.
- Les tests et les documents du dépôt ne contiennent plus d'instruction
  d'installation spécifique à une plateforme.
