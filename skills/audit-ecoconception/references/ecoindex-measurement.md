# Mesure EcoIndex navigateur

Utiliser cette reference uniquement pour calculer un EcoIndex runtime. La mesure
est autonome : elle repose sur le navigateur et le MCP GreenIT.

## Source de methode

1. Appeler `greenit_obtenir_methodologie_ecoindex` avant toute mesure. Sa
   reponse est la source de verite pour la collecte de `dom_nodes`, `requests`
   et `size_kb`.
2. Appliquer dans le navigateur l'algorithme et les limites retournes par le
   MCP, sans les remplacer par une heuristique locale.
3. Appeler `greenit_calculer_ecoindex` avec les trois valeurs collectees et
   l'URL mesuree. Le MCP retourne le score, le grade, les GES et l'eau.

Si `greenit_obtenir_methodologie_ecoindex` est indisponible ou ne decrit pas
une des trois mesures, ne pas calculer d'EcoIndex. Continuer les volets
fonctionnel et ecocode, puis enregistrer l'EcoIndex comme non mesure avec la
raison dans `limites`.

## Protocole navigateur

Utiliser Playwright avec le viewport, les attentes, le defilement et la
politique de cache declares pour l'audit. Mesurer apres le chargement et le
defilement prevus par ce protocole. Pour un parcours multi-pages, identifier
chaque mesure comme premiere visite ou visite avec cache.

Documenter pour chaque page : la date, l'URL, le protocole, les trois valeurs
brutes, la methode MCP utilisee et ses limites. Ne comparer deux campagnes que
si leur protocole et leur methode MCP sont identiques ; sinon declarer la
comparaison non equivalente.
