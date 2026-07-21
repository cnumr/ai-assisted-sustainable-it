---
name: dev-guide
description: Passive eco-design design and coding guidelines. Always apply these rules when designing, writing, or modifying a solution — front-end and back-end. Loaded automatically at session start.
---

# Éco-conception — Règles de conception et de codage actives

Applique ces règles **automatiquement** quand tu conçois, écris ou modifies une solution. Pas besoin qu'on te le demande.

## Conception

- **Besoin minimal :** privilégie la solution la plus simple qui couvre le besoin ; ne crée pas de fonctionnalité, écran ou donnée sans usage identifié (`RWEB_0001`, `RWEB_0003`).
- **Parcours sobre :** réduis les étapes, rechargements et contenus inutiles ; préfère la pagination au défilement infini (`RWEB_0005`, `RWEB_0013`).
- **Données minimales :** collecte, transfère et conserve seulement les données nécessaires, avec une durée de rétention définie (`RWEB_0017`, `RWEB_0023`, `RWEB_0079`).
- **Compatibilité durable :** conçois d'abord pour les appareils modestes, les réseaux limités et les navigateurs encore utilisés (`RWEB_0004`, `RWEB_0058`).
- **Dépendances justifiées :** évalue le coût d'un service tiers ou d'une bibliothèque avant de l'ajouter ; préfère les capacités natives quand elles suffisent (`RWEB_0015`, `RWEB_0047`).

## Front-end

### Chargement

- **Lazy-load** : attribut `loading="lazy"` sur toutes les `<img>` hors viewport ; `import()` dynamique pour le code non critique (`RWEB_0051`, `RWEB_0046`)
- **Imports ciblés** : importe les fonctions, pas les libs entières — `import { debounce } from 'lodash-es'` pas `import _ from 'lodash'` (`RWEB_0015`)
- **Taille images** : utilise `srcset`/`sizes`, format WebP ou AVIF de préférence au JPEG/PNG (`RWEB_0048`, `RWEB_0049`)
- **Pas d'autoplay** : jamais `autoplay` sur `<video>` ou `<audio>` sans contrôle explicite utilisateur (`RWEB_0106`)

### DOM & rendu

- **CSS > JS** : préfère `transition` et `animation` CSS aux animations JavaScript (`RWEB_0009`)
- **CSS > images** : utilise `gradient`, `border-radius`, `clip-path` plutôt que des images décoratives (`RWEB_0037`)
- **Batch DOM** : ne modifie pas le DOM pendant la traversée — regroupe les changements, utilise `DocumentFragment` (`RWEB_0044`)
- **Cache DOM** : stocke les références DOM dans des variables avant les boucles — pas de `querySelector` répété (`RWEB_0054`)
- **Délégation** : un seul event listener sur le parent au lieu de N listeners sur chaque enfant (`RWEB_0056`)
- **Repaint/reflow** : évite de lire `offsetHeight`/`offsetWidth` juste après avoir modifié des styles CSS (`RWEB_0052`)
- **Tâches JS** : découpe les traitements longs en chunks < 50ms — `requestIdleCallback`, `setTimeout(fn, 0)`, Web Workers (`RWEB_0053`)

## Back-end

- **Async** : traite les opérations lourdes de manière asynchrone — jobs, queues, workers — ne bloque pas le thread principal (`RWEB_0007`)
- **Cache calculs** : mémoïse les résultats coûteux — `@lru_cache` (Python), Redis, Memcache — plutôt que de recalculer (`RWEB_0016`)
- **Batch queries** : évite les boucles qui génèrent N requêtes SQL — `select_related`/`prefetch_related` (Django), `include` (Laravel), `JOIN` ou `IN (...)` (`RWEB_0021`)
- **Types DB** : utilise le type le plus petit adapté — `INT` pas `BIGINT`, `VARCHAR(n)` pas `TEXT` sans justification (`RWEB_0063`)
- **Stockage minimal** : ne persiste que les données strictement nécessaires — pas de colonnes "au cas où" (`RWEB_0023`)
- **TTL données** : toute table/collection a une politique d'expiration — TTL Redis, `deleted_at`, job de purge (`RWEB_0079`)

## Build & config

- **Cache-Control** : assets statiques avec content hash → `Cache-Control: max-age=31536000, immutable` (`RWEB_0075`)
- **Minification** : configure le build tool pour minifier CSS, JS, HTML, SVG en production (`RWEB_0077`)
