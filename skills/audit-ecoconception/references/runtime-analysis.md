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

Ce protocole est la source de verite de toute mesure runtime EcoIndex.

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
5. Relever les trois metriques des audits Lighthouse du plugin `eco-index-*`,
   ou d'une methode strictement equivalente : noeuds DOM, poids transfere et
   requetes EcoIndex. Fin : les trois valeurs et leur source exacte sont
   disponibles pour chaque page.
6. Appeler `greenit_calculer_ecoindex` uniquement avec ces trois valeurs pour
   calculer score, grade, GES et eau. Fin : aucune autre metrique n'entre dans
   ce calcul.
7. Documenter separement les erreurs console pertinentes, redirections, cache,
   tiers et medias observes. Fin : ces observations n'alterent pas les entrees
   EcoIndex.

`eco-index-requests` est la seule source du nombre de requetes EcoIndex : ne
pas le remplacer par le total des requetes Lighthouse, CDP ou Resource Timing.
Compter les Shadow DOM ouverts ; compter l'element SVG mais pas ses descendants.
Distinguer cette mesure de toute sonde complementaire.

Dans un parcours multi-pages, conserver le cache pour les pages suivantes afin
de reproduire une navigation utilisateur. Identifier chaque mesure comme
premiere visite ou visite avec cache. Lors d'une comparaison avec une campagne
existante, reutiliser son protocole et ses metriques ; sinon, declarer les
differences de protocole comme une limite de comparabilite.

Pour un grade C à G, expliquer les contributeurs matériels observés ou déclarer
une limite de mesure. Les fiches RWEB, alertes de performance, problèmes de
qualité web et pistes à vérifier restent dans des catégories distinctes.

## Restitution runtime

Chaque rapport documente, pour chaque mesure, le viewport, les deux attentes,
le defilement, la politique de cache et le statut de visite, la source exacte
des trois metriques, ainsi que la date de mesure. Fin : ces champs permettent
de reproduire ou de limiter explicitement toute comparaison.

## Sortie

Produire le [contrat de constats](findings-contract.md), avec les limites et
métriques par page. Ne pas conclure sur l'accessibilité RGAA.
