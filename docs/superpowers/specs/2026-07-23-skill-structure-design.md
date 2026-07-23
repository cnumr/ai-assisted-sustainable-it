# Réorganisation des skills — design

## Objectif

Organiser les skills selon leur phase d'usage : conception, développement et
audit, tout en conservant `/ecocode` comme commande publique des audits.

## Arborescence cible

```text
skills/
├── design/
│   └── SKILL.md
├── development/
│   └── SKILL.md
└── audits/
    ├── SKILL.md
    ├── front/SKILL.md
    ├── back/SKILL.md
    ├── planner/SKILL.md
    ├── report-writer/SKILL.md
    └── resume/SKILL.md
```

## Décisions

- `design` reçoit les règles de cadrage : besoin, parcours, données,
  compatibilité et dépendances.
- `development` reçoit les règles d'implémentation front-end, back-end, build
  et cache HTTP.
- `audits/SKILL.md` remplace le point d'entrée actuel `ecocode/SKILL.md` et
  continue d'orchestrer la commande `/ecocode`.
- Les sous-skills d'audit deviennent des enfants de `audits/`.
- Les agents conservent leurs noms ; leurs références aux skills sont mises à
  jour.
- Les hooks, manifestes, documentation et tests de structure sont alignés sur
  les nouveaux chemins.

## Compatibilité et vérification

Les commandes `/ecocode`, `/ecocode front`, `/ecocode back`, `/ecocode plan`
et `/ecocode fix` conservent leur comportement. Les tests de structure et les
tests Claude Code vérifient les nouveaux chemins et l'absence des anciens.
