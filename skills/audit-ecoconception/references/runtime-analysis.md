# Analyse runtime navigateur

Utiliser cette branche pour une URL HTTP(S) ou un parcours navigateur. Exiger
Playwright et `mcp-greenit`.

## Sécurité et consentement

L'utilisateur s'authentifie lui-même dans le navigateur contrôlé. Ne demander
ni mot de passe, ni jeton, code 2FA, CAPTCHA ou donnée WebAuthn. Les interactions
de lecture seule sont autorisées ; une action pouvant modifier l'état distant
requiert une confirmation explicite avant son exécution. Ne jamais capturer un
écran de connexion ou une donnée sensible.

## Mesure

Pour une mesure EcoIndex, lire et appliquer [la methode navigateur](ecoindex-measurement.md).
Le MCP GreenIT est la seule source de verite de la methode de collecte et du
calcul.

1. Lancer Chrome/Playwright avec un viewport de 1920 x 1080. Fin : le viewport
   effectif est verifie avant la navigation.
2. Pour la premiere page d'un parcours, ouvrir un contexte sans cache, cookies,
   `localStorage` ni `sessionStorage`. Fin : ces stockages sont vides avant le
   chargement.
3. Charger la page et attendre 3 secondes. Fin : l'attente est ecoulee apres le
   chargement.
4. Faire defiler jusqu'en bas de page pour declencher les contenus charges au
   scroll, puis attendre 3 secondes. Fin : le bas est atteint et la seconde
   attente est ecoulee.
5. Collecter `dom_nodes`, `requests` et `size_kb` avec la methode retournee par
   `greenit_obtenir_methodologie_ecoindex`, puis appeler
   `greenit_calculer_ecoindex`. Fin : les trois valeurs, leur methode et le
   resultat sont disponibles, ou l'EcoIndex est explicitement non mesure.
6. Documenter separement les erreurs console pertinentes, redirections, cache,
   tiers et medias observes. Fin : ces observations n'alterent pas les entrees
   EcoIndex.

Dans un parcours multi-pages, conserver le cache pour les pages suivantes afin
de reproduire une navigation utilisateur. Identifier chaque mesure comme
premiere visite ou visite avec cache. Lors d'une comparaison avec une campagne
existante, reutiliser son protocole et ses metriques ; sinon, declarer les
differences de protocole comme une limite de comparabilite.

Pour un grade C à G, expliquer les contributeurs matériels observés ou déclarer
une limite de mesure. Les fiches RWEB, alertes de performance, problèmes de
qualité web et pistes à vérifier restent dans des catégories distinctes.

## Preuves fonctionnelles du parcours

Après le protocole de mesure EcoIndex ci-dessus, observer en lecture seule le
parcours déclaré : navigation, recherche, hiérarchie des contenus, formats,
documents, médias, formulaires, listes et choix de rétention exposés. Distinguer
ces observations des intentions métier inférées ; une intention non prouvée va
dans `a_verifier` avec les preuves ou données nécessaires.

Ces observations ne sont pas une source de mesure EcoIndex et ne modifient pas
la methode MCP appliquee aux metriques runtime.

## Restitution runtime

Chaque rapport documente, pour chaque mesure, le viewport, les deux attentes,
le defilement, la politique de cache et le statut de visite, la source exacte
des trois metriques, ainsi que la date de mesure. Fin : ces champs permettent
de reproduire ou de limiter explicitement toute comparaison.

## Sortie

Produire le [contrat de constats](findings-contract.md), avec les limites et
métriques par page, en séparant `constats_fonctionnels` et `constats_ecocode`.
Ne pas conclure sur l'accessibilité RGAA.
