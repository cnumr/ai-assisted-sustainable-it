# Nommage des skills d'éco-conception — plan d'implémentation

> **Pour les agents :** sous-skill requis : utiliser `executing-plans` pour exécuter ce plan tâche par tâche. Les étapes utilisent des cases à cocher.

**Objectif :** distribuer `ecodesign`, `ecocode` et `audit-ecoconception`, avec des arguments d'audit qui distinguent code statique et navigateur.

**Architecture :** les deux skills automatiques sont renommés depuis `design` et `development`. Le routeur d'audit et ses références sont déplacés de `ecocode` vers `audit-ecoconception`. Un unique test de structure porte le contrat public ; la documentation reprend les mêmes noms et commandes.

**Technologies :** Markdown, Bash, Git, `npx skills`.

## Contraintes globales

- Aucun alias pour `design`, `development` ou l'ancien `ecocode` d'audit.
- Les identifiants publics sont exactement `ecodesign`, `ecocode` et `audit-ecoconception`.
- Le runtime s'exprime par `navigateur <URL>` ; le code statique par `code front`, `code back` ou `code`.
- Mettre à jour le changelog ; ne pas publier ni réinstaller pendant cette migration.

---

### Tâche 1 : Définir le contrat public par un test rouge

**Fichiers :**
- Modifier : `tests/structure/test-skills-only-distribution.sh`

**Produit :** le test attend les trois nouveaux répertoires et rejette les anciens noms publics.

- [ ] **Étape 1 : Modifier les chemins exigés**

Remplacer le début de la boucle par :

```bash
for path in \
  skills/ecodesign/SKILL.md \
  skills/ecocode/SKILL.md \
  skills/audit-ecoconception/SKILL.md \
  skills/audit-ecoconception/references/static-analysis.md \
  skills/audit-ecoconception/references/runtime-analysis.md \
  skills/audit-ecoconception/references/findings-contract.md \
  skills/audit-ecoconception/references/restitution.md; do
  test -f "$root/$path"
done
```

Ajouter ensuite :

```bash
for path in skills/design skills/development; do
  ! test -e "$root/$path"
done
grep -Fq 'skills/ecodesign' "$root/README.md"
grep -Fq 'skills/ecocode' "$root/README.md"
grep -Fq 'skills/audit-ecoconception' "$root/README.md"
grep -Fq 'audit-ecoconception code back' "$root/README.md"
grep -Fq 'audit-ecoconception navigateur' "$root/README.md"
grep -Fq 'name: ecodesign' "$root/skills/ecodesign/SKILL.md"
grep -Fq 'name: ecocode' "$root/skills/ecocode/SKILL.md"
grep -Fq 'name: audit-ecoconception' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'code front' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'code back' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'navigateur' "$root/skills/audit-ecoconception/SKILL.md"
```

- [ ] **Étape 2 : Exécuter le test pour vérifier l'échec**

Exécuter : `bash tests/structure/test-skills-only-distribution.sh`

Attendu : échec sur l'absence de `skills/ecodesign/SKILL.md`.

- [ ] **Étape 3 : Commit de la spécification et du test rouge**

```bash
git add .superpowers/specs/2026-08-26-nommage-skills-design.md tests/structure/test-skills-only-distribution.sh
git commit -m "test: define eco-design skill names"
```

### Tâche 2 : Renommer les skills et préciser le routage d'audit

**Fichiers :**
- Déplacer : `skills/design/` vers `skills/ecodesign/`
- Déplacer : `skills/development/` vers `skills/ecocode/`
- Déplacer : `skills/ecocode/` vers `skills/audit-ecoconception/`

**Produit :** deux skills automatiques et un routeur d'audit aux identifiants validés.

- [ ] **Étape 1 : Déplacer les répertoires dans l'ordre sans collision**

```bash
git mv skills/ecocode skills/audit-ecoconception
git mv skills/development skills/ecocode
git mv skills/design skills/ecodesign
```

- [ ] **Étape 2 : Mettre à jour les frontmatters et les références croisées**

Dans `skills/ecodesign/SKILL.md`, utiliser `name: ecodesign` et remplacer la
référence à `development` par `ecocode`.

Dans `skills/ecocode/SKILL.md`, utiliser :

```yaml
name: ecocode
description: Use when writing or modifying front-end, back-end, build, or cache configuration.
```

Dans `skills/audit-ecoconception/SKILL.md`, utiliser :

```yaml
name: audit-ecoconception
description: Use when requesting an eco-design audit, EcoIndex measurement, Green IT review, static code analysis, or browser journey analysis.
```

Remplacer le titre par `# Audit d'éco-conception` et le paragraphe
d'invocation par une demande naturelle ou les arguments documentés. Dans le
routage, reconnaître exactement : `code front`, `code back`, `code`, et
`navigateur <URL>`. Sans argument, proposer ces quatre périmètres.

- [ ] **Étape 3 : Vérifier le contrat vert**

Exécuter : `bash tests/structure/test-skills-only-distribution.sh`

Attendu : code retour 0.

- [ ] **Étape 4 : Commit de la migration des skills**

```bash
git add skills tests/structure/test-skills-only-distribution.sh
git commit -m "refactor: rename eco-design skills"
```

### Tâche 3 : Documenter l'interface publique

**Fichiers :**
- Modifier : `README.md`
- Modifier : `CLAUDE.md`
- Modifier : `GEMINI.md`
- Modifier : `docs/contributing.md`
- Modifier : `docs/testing.md`
- Modifier : `docs/releasing.md`
- Modifier : `CHANGELOG.md`

**Produit :** chaque document public ne nomme que les trois nouveaux skills.

- [ ] **Étape 1 : Mettre à jour le README**

Remplacer la phrase des skills publics par :

```markdown
Les skills publics sont `ecodesign`, `ecocode` et `audit-ecoconception`.
```

Remplacer la section d'utilisation par les rôles automatiques, puis la table :

````markdown
| Nom exact | Déclenchement | Périmètre |
| --- | --- | --- |
| `ecodesign` | Automatique | Conception produit et technique. |
| `ecocode` | Automatique | Implémentation, build et cache. |
| `audit-ecoconception` | Explicite | Audit du code ou du navigateur. |

```text
$audit-ecoconception code front
$audit-ecoconception code back
$audit-ecoconception code
$audit-ecoconception navigateur https://example.com
```
````

Conserver aussi une phrase indiquant qu'une demande naturelle équivalente est
portable entre hôtes.

- [ ] **Étape 2 : Aligner les documents secondaires et le changelog**

Mettre les arbres de fichiers et les listes de découverte à jour dans les
documents contributeur, tests et release. Ajouter sous `## Unreleased` dans
`CHANGELOG.md` une section `### Changements incompatibles` qui énumère les
trois nouveaux noms et l'absence d'alias.

- [ ] **Étape 3 : Vérifier les documents et la découverte locale**

Exécuter :

```bash
bash tests/structure/test-skills-only-distribution.sh
bash tests/structure/test-yaml-frontmatter.sh
npx skills@latest add . --list
```

Attendu : les deux scripts réussissent et le CLI ne présente que `ecodesign`,
`ecocode` et `audit-ecoconception`.

- [ ] **Étape 4 : Commit de la documentation**

```bash
git add README.md CLAUDE.md GEMINI.md CHANGELOG.md docs
git commit -m "docs: document eco-design skill names"
```
