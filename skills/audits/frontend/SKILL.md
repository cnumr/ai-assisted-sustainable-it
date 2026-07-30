---
name: ecocode-frontend
description: Audit runtime d’URL et de parcours web avec Playwright et mcp-greenit.
---

# EcoCode Frontend — audit runtime de parcours

Ce skill est réservé à `/ecocode frontend`, jamais `audits/front` ni
`ecocode-front-analyzer`, qui restent l’audit statique du code client.

**REQUIRED PARENT SKILL:** `audits`.

## Outils MCP requis

Ce skill pilote le navigateur exclusivement via les outils MCP d'un serveur
Playwright (jamais via bash, une CLI ou un script shell). Rechercher parmi les
outils MCP disponibles ceux dont le nom contient `playwright` — par exemple,
sous Claude Code : `mcp__plugin_playwright_playwright__browser_navigate`,
`browser_snapshot`, `browser_network_requests`, `browser_network_request`,
`browser_take_screenshot`, `browser_evaluate`, `browser_console_messages`,
`browser_fill_form`, `browser_type`, `browser_click`, `browser_select_option`,
`browser_wait_for`, `browser_press_key`. Le préfixe exact varie selon le
harness (Claude Code, OpenCode, Codex...) ; se fier au nom du serveur MCP
(`playwright`) plutôt qu'à un préfixe figé. Si aucun outil MCP Playwright
n'est disponible, retourner une erreur plutôt que de tenter un contournement
(navigation via bash, curl, ou tout autre moyen hors MCP).

De même, les fiches Green IT et le calcul EcoIndex passent exclusivement par
les outils MCP du serveur `mcp-greenit` (ex. `greenit_calculer_ecoindex`),
jamais par un calcul local.

## Entrées

Accepter :

- une ou plusieurs URL, regroupées dans un parcours implicite `parcours` ;
- un fichier JSON strict décrivant un ou plusieurs parcours.
- `init`, qui lance une assistance textuelle et produit un fichier conforme au
  schéma ci-dessous sans l’exécuter.

Une URL passée directement ou dans `goto.url` doit être une URL absolue
`http://` ou `https://`. Refuser `file:`, `data:`, `javascript:` et `ftp:`,
ainsi que toute redirection vers un protocole autre que HTTP(S), avant d’y
envoyer des en-têtes ou d’y poursuivre le parcours. Refuser aussi toute URL
dont `username` ou `password` non vide, y compris une entrée directe, un
`goto.url`, une redirection ou une `url_cible`.

### Assistance `init`

Pour `/ecocode frontend init`, demander une information à la fois : chemin du
fichier à créer, nom unique du parcours, URL HTTP(S) de départ, points d’audit,
puis éventuelles interactions. Afficher le JSON final et demander confirmation
avant de l’écrire. Ne jamais naviguer ni lancer l’audit dans ce mode.

## Schéma d’entrée strict

JSON strict signifie : objet racine, clés et types documentés uniquement,
champs obligatoires présents et aucune action inconnue. Toute clé non listée
est interdite. Un `string` requis est non vide.

| Objet           | Clés autorisées                 | Clés requises           | Types exacts                                                                          |
| --------------- | ------------------------------- | ----------------------- | ------------------------------------------------------------------------------------- |
| racine          | `contexte`, `parcours`          | `parcours`              | `contexte`: object ; `parcours`: array non vide                                       |
| `contexte`      | `originesHeaders`, `headers`    | aucune                  | deux arrays ; si `headers` est non vide, `originesHeaders` l’est aussi                |
| origine         | aucune sous-clé                 | —                       | string, origine HTTPS sans chemin, requête, fragment ni identifiants                  |
| header          | `nom`, `valeur`                 | `nom`, `valeur`         | deux strings                                                                          |
| parcours        | `nom`, `etapes`                 | `nom`, `etapes`         | `nom`: string unique ; `etapes`: array non vide                                       |
| étape `goto`    | `action`, `url`, `audit`, `nom` | `action`, `url`         | `action`: `"goto"` ; `url`: string HTTP(S) absolue ; `audit`: boolean ; `nom`: string |
| étape `click`   | `action` et un repère           | `action` et un repère   | `action`: `"click"` ; repère: strings                                                 |
| étape `fill`    | `action`, un repère, `value`    | les trois               | `action`: `"fill"` ; repère et `value`: strings                                       |
| étape `select`  | `action`, un repère, `value`    | les trois               | `action`: `"select"` ; repère et `value`: strings                                     |
| étape `check`   | `action` et un repère           | `action` et un repère   | `action`: `"check"` ; repère: strings                                                 |
| étape `press`   | `action`, `key`                 | `action`, `key`         | `action`: `"press"` ; `key`: string                                                   |
| étape `waitFor` | `action` et une attente         | `action` et une attente | `action`: `"waitFor"` ; attente: string                                               |
| étape `audit`   | `action`, `nom`                 | `action`, `nom`         | `action`: `"audit"` ; `nom`: string unique dans le parcours                           |

Un repère est exactement l’une de ces formes : `role` + `name`, `label`, ou
`text`. Les clés de repère autorisées sont donc `role`, `name`, `label` et
`text`, toutes de type string. Une attente est exactement une clé `url` ou
`text`, de type string. Les seules valeurs d’`action` sont `goto`, `click`,
`fill`, `select`, `check`, `press`, `waitFor` et `audit`.

La première étape de chaque parcours est obligatoirement un `goto`, afin de
définir la cible HTTP(S) avant toute interaction ou confirmation.

Pour un `goto` avec `audit: true`, `nom` est facultatif ; s’il manque, le nom
de page stable est `etape-{index}`, où `index` est l’index zéro-based de cette
étape. Les noms produits par les `goto` et les actions `audit` doivent être
uniques dans le parcours. Pour une liste d’URL directe, utiliser `url-{index}`
avec un index zéro-based.

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
2. retourner immédiatement au skill parent le statut `auth_required`, l'URL
   cible et l'index `reprise_etape` de la dernière étape non exécutée ;
3. laisser le parent demander à l’utilisateur de terminer la connexion dans le
   navigateur ;
4. lorsque le parent rappelle l'analyseur, vérifier que l’URL cible est de
   nouveau accessible et reprendre à `reprise_etape`.

Le sous-agent ne dialogue jamais directement avec l'utilisateur. Le parent
conserve les pages déjà mesurées dans `frontendData` pendant cette reprise.

`reprise_etape` est un index basé à zéro et désigne toujours la prochaine étape
non exécutée. Lors d’une reprise, vérifier
`0 <= reprise_etape < nombre d’étapes`, que le nom du parcours existe une seule
fois dans l’entrée initiale et que l’étape précédente est déjà reflétée dans
`frontendData` lorsqu’elle produisait une mesure.

Les en-têtes de `contexte.headers` sont facultatifs et non sensibles. Avant de
les appliquer :

- exiger des origines HTTPS explicites dans `originesHeaders` ;
- vérifier que la cible est dans cette liste ;
- limiter les en-têtes à ces origines, y compris après redirection ;
- refuser `Authorization`, `Cookie`, `Proxy-Authorization`, `Set-Cookie` et
  toute valeur ressemblant à un jeton, mot de passe ou clé.

Si Playwright ne permet pas ce cloisonnement par origine, refuser le parcours
avec ses en-têtes. Ne jamais les appliquer globalement au contexte navigateur.

## Lecture seule et confirmation distante

L’audit est en lecture seule par défaut : `goto`, `waitFor` et `audit`
n’autorisent aucune écriture locale, aucun appel HTTP construit manuellement et
aucune exécution de JavaScript fourni. Les actions `click`, `fill`, `select`,
`check` et `press` peuvent modifier l’état distant.

Une capture effectuée par l’outil Playwright, explicitement utile comme preuve,
est la seule exception d’écriture locale : conserver uniquement son chemin
relatif PNG dans `capture`. Ne créer aucun autre fichier pendant l’analyse.

Une URL saisie directement dans la commande autorise uniquement la navigation
HTTP(S) exacte demandée et son audit ; elle n’autorise aucune interaction
supplémentaire. Un fichier JSON ne peut jamais autoriser ses propres actions.
Avant sa première étape, retourner `confirmation_required` avec l’index `0`
dans `reprise_etape` et la première URL `goto` dans `url_cible`, sans naviguer.

Le parent affiche le parcours complet, les index, les URL, les actions et leurs
repères, en signalant que `goto`, `click`, `fill`, `select`, `check` et `press`
peuvent produire un effet distant, puis demande une confirmation explicite.
Après accord, il rappelle l’analyseur avec le nom du parcours confirmé ; cette
autorisation expire à la fin du parcours et devient invalide si l’entrée change.
Sans accord, marquer seulement ce parcours `erreur`. Ne jamais confirmer à la
place de l’utilisateur.

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
`dom_nodes`, `requests`, `size_kb` et l'`url` finale. Reprendre tels quels le
score EcoIndex, le grade, les GES et l’eau retournés par `mcp-greenit`. Ne pas
les recalculer localement.

### Matrice de sondes fixe

Après la mesure initiale et avant la qualification des constats, exécuter les
sondes internes et déterministes suivantes. Ne jamais exécuter de JavaScript
fourni par l'entrée ; les évaluations Playwright servent uniquement à lire l'état
de la page.

| Domaine                   | Preuves à collecter                                                                                                                                                                                                                                     |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Réseau                    | Type, domaine, statut, protocole, redirection, en-têtes de cache et compression, taille transférée, timings et erreurs. Inspecter les en-têtes de réponse d'une ressource nécessaire avec `browser_network_request`, sans restituer d'en-tête sensible. |
| Scripts et styles         | URLs, doublons, tiers, modules CMS identifiables, erreurs console et ressources en échec.                                                                                                                                                               |
| Images et médias          | Source servie, format, dimensions naturelles et affichées, `srcset`, `sizes`, `loading`, position dans le viewport, iframe, vidéo, audio et autoplay.                                                                                                   |
| Composants                | Carrousels Swiper/Slick/Splide/Owl ou équivalents ARIA, instances, diapositives, contrôles, animations actives et canvas.                                                                                                                               |
| Analytics et consentement | Domaines et scripts d'analytics, publicité, gestionnaire de balises et consentement effectivement chargés.                                                                                                                                              |
| Qualité web               | Erreurs console, réponses 4xx/5xx, IDs dupliqués, médias cassés et dimensions intrinsèques manquantes.                                                                                                                                                  |

Une sonde peut déclencher un défilement progressif, sans clic ni saisie, pour
observer les médias situés sous la ligne de flottaison. Cette phase est séparée
de la fenêtre de collecte initiale et ne modifie jamais les entrées EcoIndex.

### Garde-fou de cohérence EcoIndex

EcoIndex est un résultat, pas la preuve d'une fiche RWEB précise. Pour chaque page de grade C à G, l'audit doit expliquer les contributeurs matériels aux nœuds DOM, requêtes et octets transférés. Chacun doit produire un écart GreenIT prouvé, une alerte Performance ou Développement web, une entrée `a_verifier`, ou une limite de mesure explicite.

Si la première passe est insuffisante, exécuter toute la matrice puis le
défilement progressif autorisé. Si le score reste inexpliqué, retourner une
limite `analyse_inconcluante` décrivant le périmètre non mesuré. Ne jamais
inventer un écart GreenIT pour remplir le rapport.

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

### À vérifier

Preuves observées dans le navigateur qui exigent une validation métier ou du
code source, et non un constat GreenIT.

Un domaine ou script d'analytics, de publicité, de gestionnaire de balises ou de
consentement chargé est une preuve d'exécution, pas une preuve d'inutilité. Ne
le qualifier RWEB_0111 que si cette fiche a été retournée par le MCP et que la
preuve mesurée correspond à son exigence; sinon le placer dans `a_verifier`.
Ne jamais recommander de supprimer un mécanisme de consentement pour réduire le
poids de la page.

Lorsqu'une instance Swiper est initialisée, consigner son nombre d'instances et
de diapositives; produire un écart RWEB_0010 seulement si la fiche MCP a été
retournée. Pour une image sous la ligne de flottaison sans `loading="lazy"`,
conserver l'URL source et la preuve de viewport; produire un écart RWEB_0051
seulement si la fiche MCP a été retournée.

## Erreurs et déduplication

Un JSON invalide empêche son exécution. Une action inconnue, un élément
introuvable, une navigation ou une mesure impossible arrête seulement le parcours concerné.
Conserver ses pages déjà mesurées et ajouter une erreur structurée avec
parcours, étape, action et message. Aucune mesure n’est inventée pour une étape
échouée. Une redirection vers une authentification
n'est pas une erreur : elle produit `auth_required` et confie la reprise au
parent comme décrit plus haut.

Dédupliquer globalement sur tous les parcours les problèmes de composant,
en-tête, pied de page, script, police ou asset partagé. Détailler la première
occurrence avec une clé stable ; aux suivantes, retourner une référence vers
cette clé. Ne jamais dédupliquer les métriques de chaque page, son EcoIndex,
ses GES, son eau ni ses erreurs propres.

## Schéma de sortie strict

Retourner un objet JSON strict conforme aux clés et types ci-dessous ainsi qu’à
l’exemple de `ecocode-frontend-analyzer`. La sortie interdit toute clé
supplémentaire. Utiliser `null` et des tableaux vides pour les valeurs absentes ;
ne jamais omettre une clé.

| Objet              | Clés exactes                                                                                                                                                   | Types exacts                                                           |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| racine             | `scope`, `rapport`, `parcours`, `limites_globales`                                                                                                             | deux strings constantes, deux arrays                                   |
| parcours           | `nom`, `statut`, `reprise_etape`, `url_cible`, `pages`, `erreurs_execution`                                                                                    | string ; enum ; integer ou null ; string HTTP(S) ou null ; deux arrays |
| page               | `nom`, `url`, `metriques`, `ecoindex`, `ecarts_greenit`, `performance`, `developpement_web`, `a_verifier`, `couverture`, `deduplication`, `capture`, `limites` | deux strings ; deux objects ; sept arrays ; string ou null             |
| métriques          | `dom_nodes`, `requests`, `size_kb`                                                                                                                             | trois numbers finis >= 0                                               |
| EcoIndex           | `score`, `grade`, `ges`, `eau`                                                                                                                                 | number, string, number, number                                         |
| écart GreenIT      | `deduplication_key`, `practice_id`, `practice_title`, `severity`, `observation`, `preuve`, `impact`, `localisation`, `code_observe`, `correction`              | huit strings, puis deux strings ou null                                |
| performance        | `categorie`, `deduplication_key`, `severity`, `observation`, `preuve`, `impact`, `localisation`, `correction`                                                  | sept strings, puis string ou null                                      |
| développement web  | `categorie`, `deduplication_key`, `severity`, `observation`, `preuve`, `impact`, `localisation`, `code_observe`, `correction`                                  | sept strings, puis deux strings ou null                                |
| à vérifier         | `deduplication_key`, `severity`, `observation`, `preuve`, `impact`, `localisation`, `correction`                                                               | six strings, puis string ou null                                       |
| couverture         | `domaine`, `statut`, `message`                                                                                                                                 | trois strings                                                          |
| déduplication      | `deduplication_key`, `premiere_occurrence`                                                                                                                     | deux strings                                                           |
| limite             | `code`, `scope`, `message`                                                                                                                                     | trois strings                                                          |
| erreur d’exécution | `etape`, `action`, `message`                                                                                                                                   | integer >= 0 et deux strings                                           |

`scope` vaut `"frontend"` et `rapport` vaut `"audit-frontend"`. `statut` vaut
`termine`, `erreur`, `auth_required` ou `confirmation_required`. Pour les deux
statuts `*_required`, `reprise_etape` et `url_cible` sont non nuls ; pour les
autres statuts, ils valent `null`. `categorie` vaut respectivement
`"performance"` ou `"developpement_web"`.

`capture` non nul est un string contenant le chemin relatif d’un fichier PNG
créé comme preuve, jamais une image en base64. `code_observe` non nul est un
string contenant un extrait textuel observé, expurgé de toute donnée sensible.
`correction` non nulle est un string contenant la correction proposée, sans
l’appliquer. Ces trois champs ne sont jamais des objets ou des arrays.

`a_verifier` contient les observations crédibles dont l'utilité métier, la cause
racine ou la nécessité légale ne peut pas être établie depuis le navigateur. Une
ressource nommée n'est jamais qualifiée d'inutilisée par sa seule présence.

`couverture` contient une ligne par domaine de la matrice : `reseau`,
`scripts_styles`, `images_medias`, `composants`, `analytics_consent` et
`qualite_web`. `statut` vaut `measured`, `not_applicable`, `not_measurable` ou `failed`. Une page de grade C à G ne peut pas avoir toutes ses listes de constats vides sans une limite `analyse_inconcluante`.

## Contrat transmis au rédacteur

Le rédacteur reçoit cette sortie seulement lorsque tous les parcours sont
`termine` ou `erreur`. Il crée un seul fichier :

`docs/ecocode/audits/{timestamp}-audit-frontend.md`

Le rapport applique exactement le modèle détaillé d’`audits/report-writer`,
dans cet ordre :

1. `## Synthèse exécutive` ;
2. `## Parcours exécutés` ;
3. `## Périmètre, méthode et couverture` ;
4. `## Comparatif des pages` ;
5. `## Résultats par page`, incluant les preuves, extraits, corrections,
   déduplications et limites disponibles ;
6. `## Constats transverses` ;
7. `## Écarts GreenIT consolidés`, avec les identifiants et intitulés MCP
   exacts ;
8. `## Performance` ;
9. `## Développement web` ;
10. `## Résumé des gains potentiels` ;
11. `## Plan d’action priorisé` ;
12. `## Conclusion` ;
13. `## Annexe des preuves et mesures` ;
14. `## Erreurs d’exécution et limites`.

Ajouter une capture uniquement lorsqu’elle constitue une preuve utile. Ne
jamais capturer un écran de connexion ou une donnée sensible.
