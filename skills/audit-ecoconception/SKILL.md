---
name: audit-ecoconception
description: Use when requesting an eco-design audit, EcoIndex measurement, Green IT review, static code analysis, or browser journey analysis.
---

# Audit d'éco-conception

Utilise ce skill lorsqu'une personne demande un audit éco-conception, Green IT,
EcoIndex, du code ou un parcours navigateur. Une demande naturelle suffit. Les
arguments `code front`, `code back`, `code` et `navigateur <URL>` rendent le
périmètre explicite.

## Routage

1. Déterminer le périmètre demandé : **code front** (analyse statique client),
   **code back** (analyse statique serveur), **code** (analyse statique
   complète), ou **navigateur <URL>** (analyse runtime). Si aucun périmètre
   n'est explicite, proposer ces quatre choix.
2. Vérifier `mcp-greenit` avant toute analyse. Pour le runtime, vérifier aussi
   Playwright ; sans l'un de ces prérequis, expliquer ce qui manque et arrêter
   la branche concernée.
3. Lire la référence adaptée :
   - front, back ou complet : [analyse statique](references/static-analysis.md) ;
   - URL ou parcours navigateur : [analyse runtime](references/runtime-analysis.md).
4. Analyser sans écrire ni modifier le projet, puis construire le seul objet
   décrit dans le [contrat de constats](references/findings-contract.md).
5. Présenter les constats, puis suivre le choix de [restitution](references/restitution.md).

## Sous-agents facultatifs

Si l'hôte sait déléguer, il peut confier front et back à deux sous-agents en
parallèle. Utiliser un modèle économique et rapide pour l'inventaire et la
collecte ; réserver un modèle plus capable à la synthèse, aux décisions ou aux
corrections complexes. Chaque sous-agent retourne exclusivement le contrat de
constats, sans journal de recherche ni rapport intermédiaire.

L'agent courant reste l'orchestrateur et réalise l'audit séquentiellement si
les sous-agents, le choix de modèle ou le parallélisme ne sont pas disponibles.

## Critère de fin

L'audit est terminé lorsque le périmètre est couvert ou limité explicitement,
que chaque écart Green IT est prouvé par une fiche MCP, et que la personne a
choisi ou refusé une suite de restitution.
