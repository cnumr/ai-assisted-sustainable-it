# ai-assisted-sustainable-it

Des skills pour concevoir, développer et auditer des services numériques
éco-conçus.

## Installation

```bash
npx skills@latest add cnumr/ai-assisted-sustainable-it
```

Le CLI choisit l'agent cible, l'installation globale ou dans le projet, les
skills à installer et le mode copie ou lien symbolique. Les skills publics
sont `design`, `development` et `ecocode`.

## Prérequis des audits

- MCP `mcp-greenit` : requis pour tous les audits ;
- MCP `playwright` : requis pour les audits runtime dans le navigateur.

Le CLI d'installation ne configure pas ces MCP.

## Utilisation

`design` et `development` s'appliquent automatiquement lorsque vous concevez
ou modifiez une solution. Aucun appel explicite n'est requis.

Demandez explicitement un audit pour utiliser `ecocode`, par exemple :

```text
Audite l'éco-conception de ce projet.
Audite le front-end statiquement.
Audite le back-end et propose les corrections prioritaires.
Mesure cette URL dans le navigateur et calcule son EcoIndex.
```

Après l'analyse, choisissez la suite : résultat dans la conversation,
document Markdown, brouillon ou création d'issue, plan d'action, ou
corrections dans la session. Les écritures et intégrations externes demandent
toujours votre accord explicite.
