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

## Checklist de release

- [ ] `./scripts/bump-version.sh --audit`
- [ ] Mettre à jour `CHANGELOG.md`
- [ ] Commit : `chore: bump version to X.Y.Z`
- [ ] Tag : `git tag vX.Y.Z`
- [ ] Push du tag : `git push origin vX.Y.Z`
