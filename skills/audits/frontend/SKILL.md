---
name: ecocode-frontend
description: Audit runtime d’URL et de parcours web avec Playwright et mcp-greenit.
---

# EcoCode Frontend — audit runtime de parcours

Ce skill est réservé à `/ecocode frontend`, jamais `audits/front` ni
`ecocode-front-analyzer`, qui restent l’audit statique du code client.

**REQUIRED PARENT SKILL:** `audits`.

## Entrées

Accepter :

- une ou plusieurs URL, regroupées dans un parcours implicite `parcours` ;
- un fichier JSON strict décrivant un ou plusieurs parcours.

JSON strict signifie : objet racine, clés et types documentés uniquement, champs
obligatoires présents, aucune clé supplémentaire et aucune action inconnue. Le
document contient `parcours` et, facultativement, `contexte`.

- `contexte` contient uniquement `originesHeaders` (tableau d’origines) et
  `headers` (tableau d’objets `{ "nom": string, "valeur": string }`).
- `parcours` est un tableau non vide d’objets contenant uniquement `nom` et
  `etapes`.
- `etapes` est un tableau non vide. Les seules actions autorisées sont
  `goto`, `click`, `fill`, `select`, `check`, `press`, `waitFor`, `audit`.
- `goto` exige `url` et accepte `audit: true`.
- `audit` exige un `nom` non vide et mesure l’écran courant.
- Les interactions utilisent un repère accessible : `role` + `name`, `label`
  ou `text`. `fill` et `select` exigent aussi `value`, `press` exige `key`, et
  `waitFor` exige `url` ou `text`.

Refuser le document avant navigation si son JSON est invalide, si une clé ou
action est inconnue, si un type est incorrect, si un champ requis manque ou si
une interaction contient un secret. Ne jamais exécuter de JavaScript fourni
dans l’entrée.

## Session utilisateur et en-têtes

L’utilisateur se connecte lui-même dans le navigateur contrôlé. Ne jamais
demander, lire, saisir, journaliser ou restituer identifiant, mot de passe,
jeton, code 2FA, graine TOTP, CAPTCHA, donnée WebAuthn ou clé physique. Ne jamais
lire, créer ni persister de fichier `storageState`.

Si la page cible redirige vers une authentification :

1. suspendre le parcours avant toute capture ou mesure de cet écran ;
2. demander à l’utilisateur de terminer la connexion dans le navigateur ;
3. vérifier que l’URL cible est de nouveau accessible ;
4. reprendre à la dernière étape non exécutée.

Les en-têtes de `contexte.headers` sont facultatifs et non sensibles. Avant de
les appliquer :

- exiger des origines HTTPS explicites dans `originesHeaders` ;
- vérifier que la cible est dans cette liste ;
- limiter les en-têtes à ces origines, y compris après redirection ;
- refuser `Authorization`, `Cookie`, `Proxy-Authorization`, `Set-Cookie` et
  toute valeur ressemblant à un jeton, mot de passe ou clé.

Si Playwright ne permet pas ce cloisonnement par origine, refuser le parcours
avec ses en-têtes. Ne jamais les appliquer globalement au contexte navigateur.

## Exécution Playwright

Pour chaque parcours :

1. consulter d’abord les fiches pertinentes de `mcp-greenit` ;
2. prendre un snapshot avant chaque interaction afin de résoudre son repère
   accessible ;
3. exécuter les étapes dans l’ordre ;
4. collecter chaque point marqué par `goto.audit` ou `audit` ;
5. conserver les mesures déjà acquises si une étape suivante échoue.

Utiliser un contexte réseau neuf lorsque cela ne détruit pas la session ouverte
par l’utilisateur. À défaut, isoler explicitement la fenêtre de collecte entre
deux points d’audit et signaler la limite.

### Métriques runtime

À chaque point d’audit, collecter sans estimation :

- `url` : URL finale réellement affichée ;
- `dom_nodes` : nombre de nœuds DOM selon l’algorithme ci-dessous ;
- `requests` : nombre de requêtes HTTP de la fenêtre de collecte ;
- `size_kb` : octets réellement transférés pendant cette fenêtre, convertis en
  kilo-octets.

Conserver aussi, lorsqu’elles sont effectivement observables, les ressources,
domaines, protocoles, redirections, statuts, en-têtes de cache, scripts tiers,
timings et erreurs console nécessaires aux preuves. Ne jamais inclure les
valeurs de cookies ou d’en-têtes sensibles.

Appeler obligatoirement `greenit_calculer_ecoindex` pour chaque page avec
`dom_nodes`, `requests`, `size_kb` et l’`url` finale. Reprendre tels quels le
score EcoIndex, le grade, les GES et l’eau retournés par `mcp-greenit`. Ne pas
les recalculer localement.

### Comptage DOM, Shadow DOM et SVG

Compter les Shadow DOM ouverts. Ne pas utiliser
`document.querySelectorAll('*')`. Parcourir récursivement les
enfants d’un `Document`, d’un `Element` ou d’une `ShadowRoot` :

1. compter chaque élément rencontré ;
2. parcourir ses enfants du DOM léger ;
3. parcourir aussi sa `shadowRoot` lorsqu’elle est ouverte ;
4. compter un élément `<svg>`, mais ignorer tous les descendants de `<svg>`,
   y compris ceux d’une Shadow Root placée sous ce SVG.

Les Shadow DOM fermés ne sont pas accessibles. Mentionner cette limite
lorsqu’elle est identifiable, sans prétendre les avoir comptés.

## Qualification des constats

Un écart GreenIT n’existe que si `mcp-greenit` a réellement retourné une fiche
correspondante. Conserver son identifiant et son intitulé exacts. Ne jamais
inventer un identifiant RWEB.

Classer séparément :

### Écarts GreenIT

Observations reliées à une fiche retournée par le MCP, avec preuve, impact,
localisation et, si le code est disponible, extrait observé et correction
adaptée au projet.

### Performance

Alertes runtime mesurées qui n’ont pas de fiche GreenIT vérifiée.

### Développement web

Erreurs de console, HTML, API ou qualité de code observées qui n’ont pas de
fiche GreenIT vérifiée.

## Erreurs et déduplication

Un JSON invalide empêche son exécution. Une action inconnue, un élément
introuvable, une navigation ou une mesure impossible arrête seulement le parcours concerné.
Conserver ses pages déjà mesurées et ajouter une erreur
structurée avec parcours, étape, action et message. Aucune mesure n’est inventée
pour une étape échouée.

Dédupliquer globalement sur tous les parcours les problèmes de composant,
en-tête, pied de page, script, police ou asset partagé. Détailler la première
occurrence avec une clé stable ; aux suivantes, retourner une référence vers
cette clé. Ne jamais dédupliquer les métriques de chaque page, son EcoIndex,
ses GES, son eau ni ses erreurs propres.

## Contrat transmis au rédacteur

Retourner un objet JSON strict conforme au contrat de
`ecocode-frontend-analyzer`. Le rédacteur crée un seul fichier :

`docs/ecocode/audits/{timestamp}-audit-frontend.md`

Le rapport contient, dans cet ordre :

1. les parcours exécutés et le sommaire des scores ;
2. une section par parcours puis par point d’audit avec URL finale, métriques
   brutes, EcoIndex, grade, GES et eau ;
3. `### Écarts GreenIT`, avec identifiants et intitulés MCP exacts ;
4. les extraits et corrections disponibles pour les écarts non dédupliqués ;
5. `### Performance` ;
6. `### Développement web` ;
7. les erreurs d’exécution et limites de mesure.

Ajouter une capture uniquement lorsqu’elle constitue une preuve utile. Ne
jamais capturer un écran de connexion ou une donnée sensible.
