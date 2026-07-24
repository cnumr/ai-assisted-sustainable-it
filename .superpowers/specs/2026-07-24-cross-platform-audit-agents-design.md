# Agents d'audit multi-plateformes — design

## Objectif

Rendre les rôles d'audit EcoCode utilisables avec Claude Code, OpenCode et
Codex, tout en réservant les modèles Codex les plus exigeants aux décisions et
aux corrections.

## Architecture

Les fichiers `agents/*.md` restent la source fonctionnelle des six rôles :
orchestrateur, analyseurs front et back, rédacteur de rapport, planificateur
et agent de correction. Les adaptateurs de plateforme ne définissent que leur
format et leurs capacités.

- Claude Code utilise les fichiers `agents/*.md`.
- OpenCode utilise les fichiers `.opencode/agents/*.md` existants.
- Codex ajoute un fichier `.codex/agents/*.toml` par rôle. Chaque fichier
  charge le document Markdown correspondant avant d'exécuter sa tâche.

## Modèles Codex

| Rôle | Modèle | Raisonnement | Sandbox |
| --- | --- | --- | --- |
| Orchestrateur | `gpt-5.6-sol` | high | workspace-write |
| Analyseur front/back | `gpt-5.6-terra` | medium | read-only |
| Rédacteur, planificateur | `gpt-5.6-terra` | medium | workspace-write |
| Correcteur | `gpt-5.6-sol` | high | workspace-write |

Le rédacteur et le planificateur ne peuvent écrire que les livrables d'audit
dans `docs/ecocode/`. Les autres règles d'écriture restent celles de l'agent
Markdown de référence.

## Compatibilité et vérification

Les consignes métier restent centralisées dans `agents/*.md`. Les tests de
structure vérifient que chaque rôle commun dispose d'un adaptateur Codex et
que les profils d'analyse utilisent un sandbox en lecture seule et
`gpt-5.6-terra`.
