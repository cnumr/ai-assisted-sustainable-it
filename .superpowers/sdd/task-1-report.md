# Rapport — tâche 1 : contrôles de routage et adaptateurs Codex

## Modifications

- `tests/structure/test-sustainable-it-structure.sh`
  - exige les six adaptateurs `.codex/agents/ecocode-*.toml` ;
  - analyse les TOML avec Python `tomllib` et exige exactement `sandbox_mode = "read-only"` et `model = "gpt-5.6-terra"` pour les analyseurs front et back ;
  - exige que `commands/ecocode.md` indique le routage `/ecocode` vers `ecocode-orchestrator`.
- `tests/claude-code/test-ecocode-skill.sh`
  - demande une explication non mutatrice du routage de `/ecocode front` ;
  - exige que la réponse mentionne explicitement `ecocode-orchestrator`.

## Vérification RED

Commande exécutée :

```bash
bash tests/structure/test-sustainable-it-structure.sh
```

Résultat constaté : code de sortie `1`, avec `52 passés, 11 échoués`. L’échec couvre les six adaptateurs absents, les quatre propriétés requises des deux analyseurs et le routage explicite absent de la commande. Ces éléments seront introduits par les tâches suivantes.

La commande RED correspondant au test Claude est :

```bash
bash tests/claude-code/test-ecocode-skill.sh
```

Exécutée le 24 juillet 2026, elle s’arrête avant l’invocation de la CLI Claude avec le code `127` : l’environnement ne fournit pas la commande système `timeout`, appelée par `tests/claude-code/test-helpers.sh`.

## Fichiers de production

Aucun fichier de production n’a été modifié.

## Commit

`98dd13a65084b8eb31846c67c3f04ab9ccf20e63` — `test: cover Codex audit agent adapters`

## Contrat runtime frontend

- Ajout de la matrice déterministe de sondes runtime et du garde-fou de
  cohérence EcoIndex pour les pages de grade C à G.
- Extension du schéma de page avec `a_verifier` et `couverture`, ainsi que leurs
  règles de qualification strictes.
- Ajout des assertions structurelles associées.

Le cycle TDD initial a produit `136 passés, 7 échoués` avant l'ajout du contrat,
puis `143 passés, 0 échoués` après sa mise en oeuvre. Les garanties existantes
de lecture seule, d'absence de JavaScript fourni par l'entrée et de conservation
des métriques EcoIndex initiales sont maintenues.

## Correction de revue Task 1

La revue a relevé une incohérence producteur/schéma : le schéma déclarait six
tableaux alors que la page en contient sept, et l'exemple JSON canonique
omettait `a_verifier` et `couverture`.

- Correction du compte à sept tableaux dans le schéma de page.
- Ajout d'objets `a_verifier` et `couverture` conformes à leurs définitions dans
  l'exemple JSON de `ecocode-frontend-analyzer`.
- Ajout d'assertions pour la ligne de schéma complète et les deux champs du
  producteur.

## Résultats des tests

```text
RED : Résultat : 143 passés, 3 échoués
GREEN : Résultat : 146 passés, 0 échoués
```
