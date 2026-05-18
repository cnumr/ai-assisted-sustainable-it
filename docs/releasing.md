# Processus de release

## Bumper la version

```bash
# Vérifier l'état actuel (détecter les dérives)
./scripts/bump-version.sh --check

# Scanner le repo pour les occurrences non déclarées
./scripts/bump-version.sh --audit

# Bumper tous les manifests en une commande
./scripts/bump-version.sh 1.2.0
```

Le script met à jour automatiquement :

- `package.json`
- `.claude-plugin/plugin.json`
- `.cursor-plugin/plugin.json`
- `.claude-plugin/marketplace.json`
- `gemini-extension.json`

## Fichiers déclarés

Définis dans `.version-bump.json`. Pour ajouter un nouveau manifest versionné :

```json
{ "path": "nouveau-manifest.json", "field": "version" }
```

Les champs imbriqués utilisent la notation pointée : `"plugins.0.version"`.

## Checklist de release

- [ ] `./scripts/bump-version.sh --audit` → aucune occurrence non déclarée
- [ ] `./scripts/bump-version.sh X.Y.Z`
- [ ] Mettre à jour `CHANGELOG.md`
- [ ] Commit : `chore: bump version to X.Y.Z`
- [ ] Tag git : `git tag vX.Y.Z`
- [ ] Push tag : `git push origin vX.Y.Z`

## Versioning sémantique

| Type de changement                      | Incrément |
| --------------------------------------- | --------- |
| Nouveau skill ou agent                  | `minor`   |
| Correction d'une pratique Green IT      | `patch`   |
| Breaking change dans le format de skill | `major`   |
| Ajout d'une plateforme supportée        | `minor`   |
