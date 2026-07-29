# Conception — audit EcoCode de parcours front-end

## Objectif

Ajouter à `/ecocode` un audit front-end d'une liste de pages ou de plusieurs
parcours. Chaque page fournit l'EcoIndex, les impacts GES et eau, les écarts
aux seules fiches retournées par `mcp-greenit` et, si utile, une capture et une
correction de code contextualisée.

## Périmètre et exclusions

- `/ecocode parcours <url...>` audite une liste d'URL.
- `/ecocode parcours <fichier.json>` audite un ou plusieurs parcours nommés,
  composés d'URL et, exceptionnellement, d'interactions Playwright.
- Le calcul EcoIndex repose sur les métriques runtime de Playwright et le
  calculateur de `mcp-greenit`.
- Un rapport Markdown unique est structuré par parcours puis par page.

Le premier incrément n'accepte ni JavaScript arbitraire, ni scripts Playwright
TypeScript/JavaScript, ni YAML, ni dépendance de parsing supplémentaire.

## Entrées

### Liste d'URL

`/ecocode parcours <url1> <url2> ...` crée un parcours implicite nommé
`parcours`. Chaque URL est une navigation et un point d'audit.

### Fichier JSON

JSON est le seul format structuré initial : il est natif dans les environnements
des agents et suffit aux cas rares d'interaction.

```json
{
  "parcours": [
    {
      "nom": "recherche-produit",
      "etapes": [
        { "action": "goto", "url": "https://example.com/catalogue", "audit": true },
        { "action": "click", "role": "button", "name": "Filtres" },
        { "action": "check", "label": "En stock" },
        { "action": "click", "role": "button", "name": "Appliquer" },
        { "action": "audit", "nom": "catalogue-filtre" }
      ]
    }
  ]
}
```

Les actions autorisées sont `goto`, `click`, `fill`, `select`, `check`,
`press`, `waitFor` et `audit`. Les interactions indiquent un repère accessible
(`role` + `name`, `label` ou texte), résolu depuis le snapshot Playwright.
`goto` est audité avec `audit: true`; `audit` mesure l'écran courant.

Un JSON invalide, une action inconnue ou un élément introuvable arrête seulement
le parcours concerné, conserve les pages déjà mesurées et crée une erreur
d'exécution dans le rapport. Aucune mesure n'est inventée pour une étape échouée.

## Exécution

1. L'orchestrateur reconnaît `parcours` avant une URL isolée, puis délègue le
   périmètre au seul analyseur front.
2. L'analyseur consulte d'abord `mcp-greenit`, exécute les étapes via
   Playwright et prend un snapshot avant les interactions ou mesures utiles.
3. À chaque point d'audit, il collecte DOM, requêtes HTTP et poids transféré
   dans un contexte neuf lorsque possible.
4. Il appelle le calculateur EcoIndex de `mcp-greenit` avec ces valeurs et
   l'URL réellement affichée. Ce MCP est l'unique source du score, grade, GES
   et eau.
5. Un écart d'éco-conception exige une fiche effectivement retournée par
   `mcp-greenit`. Les alertes de performance ou de développement sans fiche
   GreenIT apparaissent dans des sections distinctes.

## Mesure du DOM

Le compteur doit : compter `<svg>` mais jamais ses descendants; parcourir les
Shadow DOM ouverts; propager l'exclusion SVG dans une Shadow Root sous SVG.
`document.querySelectorAll('*')` est donc interdit car il ignore les Shadow DOM.

Le parcours récursif suit les enfants d'un `Document`, `Element` ou `ShadowRoot`.
Chaque élément non descendant d'un SVG est compté, puis ses enfants légers et
son `shadowRoot` ouvert sont parcourus. Les Shadow DOM fermés sont inaccessibles
par l'API DOM standard : le rapport signale cette limite lorsqu'elle est
identifiable, sans prétendre les avoir comptés.

## Déduplication globale

La déduplication couvre tous les parcours de l'exécution. Un problème lié à un
en-tête, pied de page, script, police, asset ou composant partagé est détaillé
à sa première occurrence; les autres pages ne contiennent qu'une référence.
Les métriques EcoIndex, GES, eau et les erreurs propres à une page restent
toujours affichées pour chaque point d'audit.

## Rapport

Le rédacteur crée `docs/ecocode/audits/{timestamp}-audit-parcours.md` avec :

1. les parcours exécutés et un sommaire des scores;
2. une section par parcours, puis par point d'audit : URL finale, métriques
   brutes, EcoIndex, grade, GES et eau;
3. les écarts GreenIT avec identifiant et intitulé exacts;
4. pour les écarts non dédupliqués dont le code est disponible, le code observé
   et une correction adaptée au projet;
5. des sections distinctes « Performance » et « Développement web »;
6. les erreurs d'exécution et limites de mesure.

Une capture est ajoutée seulement comme preuve visuelle utile. L'analyseur
retourne les pages, preuves, références de déduplication, observations GreenIT,
observations non GreenIT, extraits et corrections; le rédacteur ne relit pas le
projet.

## Fichiers et compatibilité

- Étendre les skills `skills/audits/SKILL.md`, `skills/audits/front/SKILL.md`
  et `skills/audits/report-writer/SKILL.md`.
- Mettre à jour les agents canoniques orchestrateur, analyseur front et
  rédacteur, ainsi que leurs copies `.opencode/agents/`.
- Documenter l'entrée dans `commands/ecocode.md`, `.opencode/commands/ecocode.md`,
  `README.md`, `docs/README.opencode.md` et `.codex/INSTALL.md`.
- Ne pas modifier les profils `.codex/agents/*.toml` : ils lisent les agents
  canoniques et conservent les efforts adaptés (orchestrateur élevé, analyseur
  moyen). Claude, Cursor et Gemini réutilisent les fichiers canoniques.

## Vérification

Étendre les tests structurels pour le mode `parcours`, le schéma JSON, le
rapport de parcours, la règle SVG/Shadow DOM, les sections non GreenIT et les
copies OpenCode. Étendre le test de routage Claude Code ou ajouter un test dédié.
Les tests runtime Playwright/MCP restent hors du harness actuel.
