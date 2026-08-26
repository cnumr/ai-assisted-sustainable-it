# Guide du contributeur — ai-assisted-sustainable-it

## Architecture

```text
skills/
├── design/SKILL.md
├── development/SKILL.md
└── ecocode/
    ├── SKILL.md
    └── references/
tests/structure/
docs/
```

Chaque skill doit posséder un frontmatter YAML valide avec `name` et
`description`. Les références d'un skill restent dans son dossier et sont
liées explicitement depuis `SKILL.md`.

## Développer un skill

1. Écrire ou mettre à jour le test de structure ou de comportement.
2. Vérifier son échec.
3. Modifier le skill avec la solution minimale.
4. Exécuter les tests et mettre à jour le README, cette documentation et le
   changelog si le comportement public évolue.

## Installation locale

```bash
npx skills@latest add .
```

## Conventions de commit

Utiliser les commits conventionnels, par exemple `feat: add audit rule` ou
`fix(ecocode): correct cache guidance`.
