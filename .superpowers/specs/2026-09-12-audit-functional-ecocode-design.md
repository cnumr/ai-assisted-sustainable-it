# Extension de l'audit d'ecoconception

## Objectif

Faire de `audit-ecoconception` un audit a deux volets complementaires :

- **ecoconception fonctionnelle** : besoin, parcours, contenus, formats, donnees et cycle de vie ;
- **ecocode** : implementation, architecture, ressources et configuration.

`ecodesign` et `ecocode` restent des skills proactifs. Ils ne deviennent pas des skills d'audit.

## Perimetres

Le skill accepte un perimetre explicite `fonctionnel`, en plus de `code front`, `code back`, `code` et `navigateur <URL>`.

Chaque perimetre produit les deux volets lorsque les preuves le permettent :

| Perimetre | Preuves fonctionnelles | Preuves ecocode |
|---|---|---|
| `fonctionnel` | pages et parcours navigateur, dans le perimetre fourni | aucune, sauf observation strictement necessaire au parcours |
| `code front` | routes, composants, libelles, formulaires, appels API, medias et listes | bundles, rendu, DOM, chargement, cache, tiers et configuration |
| `code back` | endpoints, modeles, donnees collectees, traitements et retention | BDD, API, cache, jobs, stockage, logs et infrastructure |
| `code` | union des preuves front et back | union des constats front et back |
| `navigateur <URL>` | besoins servis, navigation, recherche, contenus, documents, medias et formulaires | EcoIndex runtime et observations de chargement |

## Regle de preuve

Un constat fonctionnel doit etre fonde sur un element observable : page, URL, route, composant, endpoint, schema, libelle ou documentation produit. Une intention metier, une frequence d'usage, une obligation de conservation ou la valeur d'un contenu non prouvee reste dans `a_verifier` avec les donnees necessaires a sa validation.

Chaque constat GreenIT cite une fiche reelle du MCP `mcp-greenit`. Lorsqu'une decision fonctionnelle pertinente n'est pas couverte par une fiche suffisamment precise, elle reste une recommandation de parcours distincte, avec sa preuve et sa limite ; aucun identifiant RWEB n'est invente.

## Structure de sortie

Le contrat de constats conserve les metriques EcoIndex et remplace la liste unique `constats` par :

- `constats_fonctionnels` : decisions de service, de parcours ou de contenu ;
- `constats_ecocode` : implementation, architecture et exploitation technique ;
- `bonnes_pratiques` et `a_verifier` : elements qui ne sont pas des non-conformites prouvees.

La restitution et les rapports presentent ces deux volets separement, puis une priorisation commune. Une correction code ne remplace pas une decision produit, et inversement.

## Fichiers a faire evoluer

- `skills/audit-ecoconception/SKILL.md` : routage et definition des deux volets.
- `skills/audit-ecoconception/references/functional-analysis.md` : methode fonctionnelle applicable au navigateur, au front et au back.
- `skills/audit-ecoconception/references/static-analysis.md` : collecte des preuves fonctionnelles depuis les sources.
- `skills/audit-ecoconception/references/runtime-analysis.md` : collecte des preuves fonctionnelles depuis les pages et parcours.
- `skills/audit-ecoconception/references/findings-contract.md` : contrat a deux listes de constats.
- `skills/audit-ecoconception/references/restitution.md` : rapport et priorisation a deux volets.
- `AGENTS.md`, `CLAUDE.md`, `README.md` : exemples et perimetres documentes.

## Verification

Des tests de contenu verifieront que chaque perimetre route vers l'analyse fonctionnelle, que le contrat separe les deux volets, que les hypotheses produit restent verifiables et que les documents publics decrivent le nouveau perimetre.
