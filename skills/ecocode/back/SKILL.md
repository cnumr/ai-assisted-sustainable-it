---
name: ecocode-back
description: Use when analyzing the ecological impact of back-end code: database queries, API payloads, server-side cache, background jobs, data transfers, N+1 queries, missing indexes, or server energy consumption from a green IT perspective.
---

# EcoCode Back — Analyse éco-conception côté serveur

## Vue d'ensemble

Sous-skill spécialisé dans l'audit éco-conception back-end. Mappe chaque problème détecté aux bonnes pratiques Green IT correspondantes via le MCP `mcp-greenit`.

**REQUIRED PARENT SKILL:** `ecocode` — ce sous-skill est délégué par le skill parent.

## Collecte précise (obligatoire pendant l'analyse)

Pendant toute l'analyse, pour chaque problème détecté, noter immédiatement dans le contexte :

- **Localisation exacte** : `orders/controller.py:45`, `api/products.js:23-31`
- **Pattern problématique** : le code ou la requête exacte qui pose problème
- **Valeurs mesurées** : nombre de requêtes dans une boucle, taille du payload, absence de TTL
- **Contexte** : taille estimée de la table, fréquence d'appel, données chaudes ou froides

Ces données ne sont pas affichées dans le rapport light mais servent à générer le guide de correction complet si l'utilisateur le demande — sans relire les fichiers.

## Axes d'analyse

### 1. Requêtes BDD — efficacité et sur-sélection

**Consulter :** `mcp-greenit : greenit_chercher_fiche` avec "base de données", "requêtes SQL", "SGBD"

Vérifier :

- [ ] **Problème N+1** : boucle qui exécute une requête par itération au lieu d'une jointure (RWEB_0066)
- [ ] `SELECT *` au lieu de sélectionner uniquement les colonnes nécessaires (RWEB_0017)
- [ ] Absence d'index sur les colonnes utilisées en `WHERE`, `JOIN`, ou `ORDER BY` (RWEB_0066)
- [ ] Requêtes non paginées renvoyant des milliers de lignes (RWEB_0017)
- [ ] Agrégations calculées en mémoire applicative au lieu d'être déléguées à la BDD (RWEB_0066)
- [ ] Transactions inutilement longues bloquant des ressources (RWEB_0066)
- [ ] Jointures cartésiennes non intentionnelles (RWEB_0066)
- [ ] Requêtes BDD non regroupées alors qu'un batch ou une jointure suffirait (RWEB_0065)
- [ ] Types de données non optimisés en BDD (ex: TEXT pour stocker un booléen, FLOAT pour un entier) (RWEB_0063)
- [ ] Format de données inadapté au cas d'usage (JSON dans un champ TEXT au lieu d'un type JSON natif) (RWEB_0063)
- [ ] Logs binaires BDD activés sans nécessité (réplication inactive) → écriture disque inutile (RWEB_0113)
- [ ] Volume de données stockées non réduit au strict nécessaire (champs obsolètes, doublons) (RWEB_0023)

### 2. Cache serveur

**Consulter :** `mcp-greenit : greenit_chercher_fiche` avec "cache", "mémoire", "Redis"

Vérifier :

- [ ] Absence de cache sur les données fréquemment lues et rarement modifiées (RWEB_0016)
- [ ] Cache sans TTL (Time To Live) défini → données obsolètes en mémoire indéfiniment (RWEB_0016)
- [ ] Cache-aside non implémenté : même calcul répété à chaque requête (RWEB_0016)
- [ ] Absence de cache HTTP (ETag, Last-Modified, Cache-Control) sur les endpoints GET (RWEB_0074)
- [ ] Cache stocké en base de données ou sur disque au lieu d'être entièrement en RAM (Redis/Memcached) (RWEB_0073)
- [ ] Invalidation de cache trop agressive (tout invalider à chaque écriture) (RWEB_0016)
- [ ] Cache applicatif/CMS non configuré (cache de pages, cache d'objets) (RWEB_0071)
- [ ] Réponses AJAX non mises en cache alors que les données sont stables (RWEB_0072)
- [ ] Entêtes `Cache-Control` et `Expires` absentes sur les ressources servies (RWEB_0075)

### 3. Transferts de données

**Consulter :** `mcp-greenit : greenit_chercher_fiche` avec "données", "transfert", "API", "payload"

Vérifier :

- [ ] Payloads JSON surdimensionnés (renvoyer des objets entiers au lieu des champs demandés) (RWEB_0017)
- [ ] Absence de pagination sur les endpoints de liste (RWEB_0017)
- [ ] Absence de compression Gzip/Brotli sur les réponses API (RWEB_0076)
- [ ] Données binaires (images, PDF) servies via l'API au lieu d'un CDN ou S3 (RWEB_0070)
- [ ] Sérialisation sans filtrage (exposer tous les champs d'un ORM, y compris champs sensibles) (RWEB_0017)
- [ ] Polling côté client au lieu de WebSocket ou SSE pour les données temps-réel (RWEB_0007)
- [ ] Redirections HTTP évitables (301, 302 inutiles) augmentant le nombre de requêtes (RWEB_0112)
- [ ] Request collapsing absent : plusieurs requêtes identiques simultanées traitées séparément (RWEB_0025)
- [ ] Absence de CDN pour les assets statiques → latence élevée (RWEB_0070)
- [ ] HTTP/2 non activé sur le serveur → multiplexing absent (RWEB_0083)
- [ ] HSTS non configuré → redirections HTTP→HTTPS à chaque première visite (RWEB_0084)

### 4. Traitements redondants

**Consulter :** `mcp-greenit : greenit_chercher_fiche` avec "traitement", "calcul", "redondant"

Vérifier :

- [ ] Calculs statiques répétés à chaque requête (pré-calculer et mettre en cache) (RWEB_0016)
- [ ] Recalcul de valeurs dérivées disponibles en BDD (RWEB_0066)
- [ ] Parsing de fichiers de configuration à chaque requête (RWEB_0016)
- [ ] Appels API externes synchrones et bloquants pour des données non-critiques (RWEB_0021)
- [ ] Absence de memoization sur les fonctions pures coûteuses (RWEB_0016)
- [ ] Nombre d'appels aux API HTTP non limité (microservices bavards, appels en cascade) (RWEB_0021)
- [ ] Traitements synchrones long-running au lieu d'être déplacés en tâche asynchrone (RWEB_0007)

### 5. Tâches de fond et workers

**Consulter :** `mcp-greenit : greenit_chercher_fiche` avec "tâche", "worker", "background", "asynchrone"

Vérifier :

- [ ] Jobs de fond sans limite de concurrence → saturation CPU (RWEB_0007)
- [ ] Tâches planifiées sans stratégie de retry avec backoff exponentiel (RWEB_0007)
- [ ] Polling de queue trop fréquent (toutes les secondes vs toutes les 10s) (RWEB_0007)
- [ ] Absence de dead-letter queue → messages en erreur retraités indéfiniment (RWEB_0007)
- [ ] Traitement asynchrone non proposé pour les opérations longues (envoi d'email, génération PDF) (RWEB_0007)

### 6. Architecture et résilience

**Consulter :** `mcp-greenit : greenit_chercher_fiche` avec "architecture", "technologie", "circuit breaker", "élastique"

Vérifier :

- [ ] Microservices pour des fonctionnalités simples → surcoût réseau interne (RWEB_0028)
- [ ] ORM générant des requêtes inefficaces non vérifiées (RWEB_0067)
- [ ] Absence de circuit breaker → appels vers services défaillants répétés indéfiniment (RWEB_0026)
- [ ] Architecture non élastique → ressources provisionnées pour le pic permanent (RWEB_0027)
- [ ] Technologies inadaptées au cas d'usage (ex: Node.js synchrone pour du CPU-bound) (RWEB_0067)
- [ ] Version ancienne du langage ou du framework → performances dégradées vs version récente (RWEB_0029)
- [ ] Pages dynamiques régénérées à chaque requête alors que le contenu est statique (SSG non utilisé) (RWEB_0018)
- [ ] Rate limiting absent → calculs inutiles pour les requêtes abusives ou les bots (RWEB_0021)
- [ ] Health checks trop fréquents sur les services internes (RWEB_0021)
- [ ] Architecture modulaire absente → modifications en cascade énergivores à déployer (RWEB_0028)

### 7. Gestion des ressources

**Consulter :** `mcp-greenit : greenit_chercher_fiche` avec "ressources", "connexions", "sessions"

Vérifier :

- [ ] Connexions BDD non poolées (nouvelle connexion par requête) (RWEB_0024)
- [ ] Nombre de connexions simultanées BDD non limité (RWEB_0024)
- [ ] Fichiers/streams non fermés après utilisation (RWEB_0094)
- [ ] Absence de timeout sur les appels externes (thread bloqué indéfiniment) (RWEB_0027)
- [ ] Sessions utilisateur sans expiration (RWEB_0079)
- [ ] Données temporaires jamais nettoyées (accumulation en BDD ou disque) (RWEB_0079)
- [ ] Politique d'expiration et de suppression des données absente (RWEB_0079)

### 8. Infrastructure et hébergement

**Consulter :** `mcp-greenit : greenit_chercher_fiche` avec "serveur", "hébergement", "infrastructure", "énergie"

Vérifier :

- [ ] Serveur HTTP synchrone et bloquant au lieu d'un serveur asynchrone (RWEB_0086)
- [ ] DNS Lookup activé côté serveur HTTP (résolution inverse inutile à chaque requête) (RWEB_0085)
- [ ] Apache : `AllowOverride All` activé sur les Vhosts de production (lecture .htaccess à chaque requête) (RWEB_0089)
- [ ] Trop de modules/packages installés sur le serveur (surface d'attaque + consommation RAM) (RWEB_0094)
- [ ] Serveurs non virtualisés ou non conteneurisés → gaspillage de capacité physique (RWEB_0092)
- [ ] Hébergeur sans engagement éco-responsable (énergie renouvelable, PUE optimisé) (RWEB_0096)
- [ ] Fournisseur d'électricité non écoresponsable pour l'infrastructure on-premise (RWEB_0095)
- [ ] Efficacité énergétique des serveurs non optimisée (CPU idle élevé) (RWEB_0093)
- [ ] Services managés non utilisés alors qu'ils optimisent mieux les ressources (RWEB_0097)
- [ ] Niveau de disponibilité (SLA 99,999%) disproportionné par rapport au besoin réel (RWEB_0091)

### 9. Production, logs et maintenance

**Consulter :** `mcp-greenit : greenit_chercher_fiche` avec "logs", "maintenance", "production", "sitemap"

Vérifier :

- [ ] Logs excessifs en production (niveau DEBUG en prod → écriture disque intensive) (RWEB_0087)
- [ ] Warnings et notices non supprimés en production → traitement inutile à chaque requête (RWEB_0088)
- [ ] Logs binaires de réplication BDD non désactivés (si réplication non utilisée) (RWEB_0113)
- [ ] Sitemap absent ou mal structuré → crawlers explorent des pages inutiles (RWEB_0090)
- [ ] Stratégie de fin de vie des contenus absente (contenu obsolète jamais supprimé) (RWEB_0114)
- [ ] Plan de fin de vie du site absent (décommissionnement non planifié) (RWEB_0115)
- [ ] Site non entretenu régulièrement (dépendances obsolètes, fichiers orphelins) (RWEB_0116)

### 10. Emails et communications

**Consulter :** `mcp-greenit : greenit_chercher_fiche` avec "email", "communication"

Vérifier :

- [ ] Emails envoyés sans double consentement (opt-in) → base de destinataires non engagés (RWEB_0101)
- [ ] Emails avec pièces jointes lourdes au lieu de liens (RWEB_0102)
- [ ] Emails en HTML riche avec images embarquées non optimisées (RWEB_0102)
- [ ] Emails redondants ou non pertinents envoyés en masse (RWEB_0103)
- [ ] Newsletters envoyées à des listes non nettoyées (adresses invalides) (RWEB_0101)

## Détection des patterns N+1

```
Chercher dans le code :
1. Boucle for/foreach avec appel ORM/BDD à l'intérieur
2. .map() + await avec query individuelle par élément
3. Relation ORM chargée en lazy dans un loop

Solution type :
- SQL : JOIN ou IN (ids)
- ORM : eager loading, include/preload/with
- GraphQL : DataLoader (batching)
```

## Format de rapport

```markdown
## Analyse Back-end

### Problèmes détectés

| #   | Problème                       | Localisation            | Sévérité | Pratique Green IT                                    |
| --- | ------------------------------ | ----------------------- | -------- | ---------------------------------------------------- |
| 1   | N+1 sur la liste des commandes | orders/controller.py:45 | Haute    | RWEB_0066 — Optimiser les requêtes BDD               |
| 2   | SELECT \* sans pagination      | api/products.js:23      | Haute    | RWEB_0017 — Éviter le transfert de grandes quantités |

### Détail par problème

**[Numéro]. [Intitulé du problème]**

- **Pratique Green IT :** RWEB_XXXX — [intitulé officiel]
- **Sévérité :** Haute / Moyenne / Faible
- **Constat :** [Code ou comportement observé]
- **Impact :** [Ressources gaspillées : BDD, CPU, réseau, énergie]
- **Correction proposée :** [Code corrigé ou approche recommandée]

### Bonnes pratiques déjà respectées

- [Liste des points positifs avec RWEB_XXXX correspondant]
```

## Mapping sévérité

| Sévérité    | Critères                                                                                                    |
| ----------- | ----------------------------------------------------------------------------------------------------------- |
| **Haute**   | Requêtes sans index sur tables > 10K lignes, N+1 en production, absence totale de cache sur données chaudes |
| **Moyenne** | SELECT \* sur tables larges, TTL manquant, payloads non paginés, logs DEBUG en prod                         |
| **Faible**  | Optimisations marginales, gain < 5% sur les ressources, bonnes pratiques infra/hébergement                  |

## Erreurs fréquentes

- **Analyser sans mcp-greenit** : toujours mapper au numéro RWEB_XXXX officiel
- **Ignorer l'ORM** : l'ORM peut générer des requêtes très inefficaces invisibles dans le code applicatif
- **Confondre cache applicatif et cache HTTP** : les deux sont nécessaires et complémentaires (RWEB_0016 ≠ RWEB_0074)
- **Oublier les migrations** : vérifier aussi les fichiers de migration pour les index manquants et les types inadaptés
- **Négliger l'infrastructure** : les axes 8 et 9 ont souvent un fort impact mais sont moins visibles dans le code

## Format du guide de correction complet

> Généré uniquement si l'utilisateur le demande, depuis les données collectées. Ne pas relire les fichiers.

Pour chaque problème du rapport light, produire une section dans cet ordre :

### Problème N — [Titre du problème]

**Pratique :** RWEB_XXXX — [intitulé officiel de la fiche Green IT]
**Sévérité :** Haute / Moyenne / Faible

**Éléments trouvés dans ton code :**

- `chemin/exact/fichier.py:45` — [description du pattern trouvé]
- `chemin/exact/autre.js:23` — [idem]

**Impact estimé :** [ex: N requêtes BDD par page vue au lieu de 1, +X ms latence]

**Avant :**

```[langage]
[code exact trouvé dans le projet, avec le chemin en commentaire]
```

**Après :**

```[langage]
[code corrigé, adapté au framework/ORM utilisé dans le projet]
```

**Étapes :**

1. [Action précise sur les fichiers et lignes listés]
   ```bash
   [commande exacte si applicable]
   ```
2. [Étape suivante]
3. [Vérification : requête EXPLAIN, log de requêtes, test de perf]

**Outils recommandés :**

- `[nom-outil]` — [description en une ligne] : `[commande d'installation ou de config]`

**Règles impératives :**

- Les fichiers et numéros de ligne sont ceux réellement trouvés, jamais des exemples génériques
- Le code "Avant" est extrait du projet, le code "Après" est adapté à son ORM/framework (Prisma, SQLAlchemy, ActiveRecord, etc.)
- Si plusieurs occurrences du même problème existent, les lister toutes
