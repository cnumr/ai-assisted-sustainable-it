---
name: design
description: Passive eco-design guidelines. Apply them when defining a product, user journey, data model, or dependency. Loaded automatically at session start.
---

# Éco-conception — Règles de conception actives

Applique ces règles automatiquement quand tu définis une solution. Pour son
implémentation, applique aussi le skill `development`.

## Conception

- **Besoin minimal :** privilégie la solution la plus simple qui couvre le besoin ; ne crée pas de fonctionnalité, écran ou donnée sans usage identifié (`RWEB_0001`, `RWEB_0003`).
- **Parcours sobre :** réduis les étapes, rechargements et contenus inutiles ; préfère la pagination au défilement infini (`RWEB_0005`, `RWEB_0013`).
- **Données minimales :** collecte, transfère et conserve seulement les données nécessaires, avec une durée de rétention définie (`RWEB_0017`, `RWEB_0023`, `RWEB_0079`).
- **Compatibilité durable :** conçois d'abord pour les appareils modestes, les réseaux limités et les navigateurs encore utilisés (`RWEB_0004`, `RWEB_0058`).
- **Dépendances justifiées :** évalue le coût d'un service tiers ou d'une bibliothèque avant de l'ajouter ; préfère les capacités natives quand elles suffisent (`RWEB_0015`, `RWEB_0047`).
