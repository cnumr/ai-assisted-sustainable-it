# Analyse statique front-end et back-end

Lire les sources, configurations, migrations et assets du projet. Ne pas ouvrir
de navigateur dans cette branche.

## Front-end

Examiner les parcours et fonctionnalités nécessaires, les médias, polices,
requêtes et tiers, bundles JavaScript, CSS, DOM, lazy loading, cache, compression
et configuration de production. Rechercher d'abord les pratiques à fort impact
dans `mcp-greenit`, puis obtenir la fiche complète avant de qualifier un écart.

Estimer `dom_nodes`, `requests` et `size_kb` depuis les templates, appels réseau
et fichiers réellement présents. Appeler `greenit_calculer_ecoindex` avec ces
estimations et déclarer explicitement qu'elles ne sont pas des mesures runtime.

## Back-end

Examiner les requêtes et migrations BDD, sur-sélection, pagination, N+1, index,
types et rétention ; le cache serveur et HTTP ; les payloads API ; les traitements
répétés, jobs, workers, logs, stockage temporaire, infrastructure et emails.
Chaque constat doit citer le fichier, la ligne ou la configuration observée.

## Sortie

Produire le [contrat de constats](findings-contract.md). Une absence de preuve
est une entrée `a_verifier`, jamais un écart déclaré.
