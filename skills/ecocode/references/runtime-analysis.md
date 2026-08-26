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

Pour chaque page, relever le DOM, les requêtes, les octets transférés, les
erreurs console pertinentes, les redirections, cache, tiers et médias. Appeler
`greenit_calculer_ecoindex` avec les métriques mesurées. Compter les Shadow DOM
ouverts ; compter l'élément SVG mais pas ses descendants. Distinguer la mesure
initiale de toute sonde complémentaire.

Pour un grade C à G, expliquer les contributeurs matériels observés ou déclarer
une limite de mesure. Les fiches RWEB, alertes de performance, problèmes de
qualité web et pistes à vérifier restent dans des catégories distinctes.

## Sortie

Produire le [contrat de constats](findings-contract.md), avec les limites et
métriques par page. Ne pas conclure sur l'accessibilité RGAA.
