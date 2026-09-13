# Analyse fonctionnelle

## Preuves

Observer les besoins servis, les etapes de parcours, les resultats de recherche,
les contenus, les formats, les formulaires, les listes, les documents, les medias,
les donnees demandees et le cycle de vie visible. Utiliser uniquement les routes,
composants, endpoints, schemas, libelles, documentation produit ou pages dans le
perimetre fourni.

Une frequence d'usage, une obligation legale, une valeur editoriale ou une intention
metier non prouvee devient une entree `a_verifier`, accompagnee des donnees a recueillir.

## Par perimetre

- `fonctionnel` et `navigateur <URL>` : utiliser Playwright en lecture seule et rester dans le perimetre fourni.
- `code front` : examiner routes, composants, libelles, formulaires, appels API, medias et listes.
- `code back` : examiner endpoints, schemas, donnees collectees, traitements et retention.
- `code` : reunir les preuves front et back sans deduire de parcours absent des sources.

## Qualification

Interroger `mcp-greenit` pour les fiches produit et conception pertinentes. Citer une fiche RWEB seulement lorsqu'elle soutient le constat observe. Si le referentiel ne couvre pas assez precisement une recommandation de parcours, la presenter separement avec sa preuve et sa limite, sans inventer de fiche.
