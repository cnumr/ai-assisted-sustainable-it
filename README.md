# ai-assisted-sustainable-it

Des skills pour concevoir, développer et auditer des services numériques
éco-conçus.

## Installation

```bash
npx skills@latest add cnumr/ai-assisted-sustainable-it
```

Le CLI choisit l'agent cible, l'installation globale ou dans le projet, les
skills à installer et le mode copie ou lien symbolique. Les skills publics
sont `ecodesign`, `ecocode` et `audit-ecoconception`.

## Prérequis des audits

- MCP `mcp-greenit` : requis pour tous les audits ;
- MCP `playwright` : requis pour les audits runtime dans le navigateur.

Le CLI d'installation ne configure pas ces MCP.

## Utilisation

`ecodesign` et `ecocode` s'appliquent automatiquement lorsque vous concevez
ou modifiez une solution. Aucun appel explicite n'est requis.

| Nom exact | Déclenchement | Périmètre |
| --- | --- | --- |
| `ecodesign` | Automatique | Conception produit et technique. |
| `ecocode` | Automatique | Implémentation, build et cache. |
| `audit-ecoconception` | Explicite | Audit du code ou du navigateur. |

Les répertoires distribués sont `skills/ecodesign`, `skills/ecocode` et
`skills/audit-ecoconception`.

Pour un audit explicite, les hôtes qui reconnaissent le préfixe `$` acceptent :

```text
$audit-ecoconception code front
$audit-ecoconception code back
$audit-ecoconception code
$audit-ecoconception navigateur https://example.com
```

Une demande naturelle équivalente est portable entre les hôtes.

Après l'analyse, choisissez la suite : résultat dans la conversation,
document Markdown, brouillon ou création d'issue, plan d'action, ou
corrections dans la session. Les écritures et intégrations externes demandent
toujours votre accord explicite.
