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

#### Parcours de simples URL

```json
{
  "parcours": [
    {
      "nom": "decouverte",
      "etapes": [
        { "action": "goto", "url": "https://example.com/", "audit": true },
        { "action": "goto", "url": "https://example.com/catalogue", "audit": true },
        { "action": "goto", "url": "https://example.com/contact", "audit": true }
      ]
    }
  ]
}
```

#### Parcours avec interactions Playwright

```json
{
  "parcours": [
    {
      "nom": "commande",
      "etapes": [
        { "action": "goto", "url": "https://example.com/connexion" },
        { "action": "fill", "label": "Adresse e-mail", "value": "audit@example.test" },
        { "action": "fill", "label": "Mot de passe", "value": "${AUDIT_PASSWORD}" },
        { "action": "click", "role": "button", "name": "Se connecter" },
        { "action": "waitFor", "url": "**/compte" },
        { "action": "audit", "nom": "compte-connecte" },
        { "action": "goto", "url": "https://example.com/panier", "audit": true },
        { "action": "click", "role": "button", "name": "Passer la commande" },
        { "action": "audit", "nom": "tunnel-commande" }
      ]
    }
  ]
}
```

Les valeurs `${NOM_DE_VARIABLE}` sont résolues depuis l'environnement de
l'utilisateur au moment de l'exécution. Elles ne sont ni affichées dans le
rapport, ni enregistrées dans les captures, ni demandées à nouveau si elles
sont déjà disponibles.

### Contexte authentifié et en-têtes

Un scénario peut définir des en-têtes à propager à l'ensemble des requêtes du
contexte Playwright. Les secrets restent des références à des variables
d'environnement : aucune valeur sensible n'est écrite dans le JSON, les logs,
les captures ou le rapport.

```json
{
  "contexte": {
    "headers": {
      "Authorization": "Bearer ${AUDIT_TOKEN}",
      "X-Tenant-Id": "${AUDIT_TENANT_ID}"
    }
  },
  "parcours": [
    {
      "nom": "espace-client",
      "etapes": [
        { "action": "goto", "url": "https://example.com/connexion" },
        { "action": "fill", "label": "Adresse e-mail", "value": "${AUDIT_EMAIL}" },
        { "action": "fill", "label": "Mot de passe", "value": "${AUDIT_PASSWORD}" },
        { "action": "click", "role": "button", "name": "Se connecter" },
        { "action": "waitFor", "url": "**/tableau-de-bord" },
        { "action": "audit", "nom": "tableau-de-bord-authentifie" }
      ]
    }
  ]
}
```

Le même contexte navigateur est conservé pendant un parcours afin de propager
cookies et état de session après connexion. Il est isolé des autres exécutions
et n'est pas persisté sur disque. Lorsqu'un écran de 2FA apparaît, l'agent
demande le code temporaire ou l'approbation à l'utilisateur, puis poursuit
après confirmation. Il ne stocke jamais ce code. Une clé physique/WebAuthn,
un CAPTCHA ou tout mécanisme qui exige une action humaine non accessible à
Playwright est signalé comme bloquant pour le parcours concerné, sans tentative
de contournement.

#### Mélange de pages directes et d'étapes interactives

```json
{
  "parcours": [
    {
      "nom": "visiteur",
      "etapes": [
        { "action": "goto", "url": "https://example.com/", "audit": true },
        { "action": "goto", "url": "https://example.com/blog", "audit": true }
      ]
    },
    {
      "nom": "recherche-filtre",
      "etapes": [
        { "action": "goto", "url": "https://example.com/recherche", "audit": true },
        { "action": "fill", "label": "Rechercher", "value": "ordinateur" },
        { "action": "press", "key": "Enter" },
        { "action": "waitFor", "url": "**/recherche?*" },
        { "action": "audit", "nom": "resultats-recherche" },
        { "action": "check", "label": "Disponible" },
        { "action": "click", "role": "button", "name": "Appliquer les filtres" },
        { "action": "audit", "nom": "resultats-filtres" }
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

### Assistance à la création

`/ecocode parcours init` ouvre une assistance textuelle pour produire le fichier
JSON. Elle recueille une information à la fois : nom du parcours, URL de départ,
pages directes à auditer, puis éventuelles interactions et points d'audit. Elle
renvoie le JSON complet, valide les actions et champs autorisés, et explique les
repères accessibles attendus. Elle n'exécute pas le parcours et n'écrit aucun
fichier sans confirmation explicite. L'utilisateur peut ensuite lancer le JSON
renvoyé avec `/ecocode parcours <fichier.json>`.

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
- Documenter les entrées et l'assistance dans `commands/ecocode.md`,
  `.opencode/commands/ecocode.md`,
  `README.md`, `docs/README.opencode.md` et `.codex/INSTALL.md`.
- Ne pas modifier les profils `.codex/agents/*.toml` : ils lisent les agents
  canoniques et conservent les efforts adaptés (orchestrateur élevé, analyseur
  moyen). Claude, Cursor et Gemini réutilisent les fichiers canoniques.

## Vérification

Étendre les tests structurels pour le mode `parcours`, le schéma JSON, les trois
exemples, les variables d'environnement, la propagation d'en-têtes, le 2FA,
l'assistance `parcours init`, le rapport de parcours, la règle SVG/Shadow DOM,
les sections non GreenIT et les copies OpenCode. Étendre le test de routage
Claude Code ou ajouter un test dédié.
Les tests runtime Playwright/MCP restent hors du harness actuel.
