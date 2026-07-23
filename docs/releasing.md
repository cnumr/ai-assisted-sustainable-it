# Processus de release

## Bumper la version

```bash
./scripts/bump-version.sh --check
./scripts/bump-version.sh --audit
./scripts/bump-version.sh X.Y.Z
```

Le script met à jour `package.json`, les manifests ecocode de Claude Code,
Codex et Cursor, les marketplaces Claude Code et Codex, ainsi que
`gemini-extension.json`.

Les fichiers versionnés sont déclarés dans `.version-bump.json`.

## Processus obligatoire

Une release est créée exclusivement depuis `main`. Ne pas taguer une branche
de travail : y intégrer les changements validés avant de poursuivre.

1. Vérifier la dernière release publiée :

   ```bash
   gh release list --limit 1
   ```

2. Choisir la version selon [Semantic Versioning](https://semver.org/) : majeure
   pour un changement incompatible, mineure pour une fonctionnalité compatible,
   correctif pour une correction compatible.
3. Mettre à jour les manifests :

   ```bash
   ./scripts/bump-version.sh X.Y.Z
   ./scripts/bump-version.sh --check
   ./scripts/bump-version.sh --audit
   ```

4. Déplacer les notes de `CHANGELOG.md` de `[Unreleased]` vers une section
   `## X.Y.Z — YYYY-MM-DD`.
5. Exécuter les tests de structure, de métadonnées et les tests spécifiques
   aux fichiers modifiés.
6. Créer et pousser le commit de release :

   ```bash
   git add CHANGELOG.md package.json gemini-extension.json \
     .claude-plugin .codex-plugin .cursor-plugin
   git commit -m "chore: prepare version X.Y.Z"
   git push origin main
   ```

7. Créer un tag annoté sur ce commit, le pousser, puis publier la release
   GitHub avec un résumé du changelog :

   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   git push origin vX.Y.Z
   gh release create vX.Y.Z --title "vX.Y.Z" --notes "…"
   ```

8. Vérifier que le tag et la release correspondent au même commit :

   ```bash
   git ls-remote --tags origin vX.Y.Z
   gh release view vX.Y.Z
   ```
