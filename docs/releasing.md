# Processus de release

Une release est créée depuis `main`, après mise à jour du changelog et
vérification complète :

```bash
bash tests/structure/test-skills-only-distribution.sh
bash tests/structure/test-yaml-frontmatter.sh
npx skills@latest add cnumr/ai-assisted-sustainable-it --list
```

Choisir la version selon Semantic Versioning, créer le commit de release,
pousser le tag annoté puis publier les notes de `CHANGELOG.md`.
