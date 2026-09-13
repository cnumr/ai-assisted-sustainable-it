# Contrat de constats

Retourner uniquement ces données à l'orchestrateur :

```yaml
perimetre: fonctionnel | front | back | complet | runtime
limites: [mesure ou zone non accessible]
metriques:
  ecoindex: estimation ou mesure runtime, si disponible
  dom_nodes: nombre ou null
  requests: nombre ou null
  size_kb: nombre ou null
constats_fonctionnels:
  - rweb: identifiant et intitulé exact retournés par mcp-greenit, ou null
    localisation: URL, route, composant, endpoint, schema ou document
    preuve: observation vérifiable
    impact: réseau, CPU, mémoire, stockage, requêtes ou parcours
    severite: haute | moyenne | faible
    recommandation: décision produit, parcours, contenu ou format
constats_ecocode:
  - rweb: identifiant et intitulé exact retournés par mcp-greenit
    localisation: fichier:ligne, URL ou composant
    preuve: observation ou mesure vérifiable
    impact: réseau, CPU, mémoire, stockage ou infrastructure
    severite: haute | moyenne | faible
    correction: action adaptée au projet
bonnes_pratiques: [observation liée à une fiche MCP]
a_verifier: [hypothèse avec les preuves ou données nécessaires]
```

Un constat EcoCode exige une fiche effectivement retournée par `mcp-greenit`.
Ne jamais inventer un identifiant RWEB. Les constats fonctionnels peuvent avoir
`rweb: null` lorsque le référentiel ne couvre pas précisément la recommandation.
Les alertes de performance ou de qualité web sans fiche vérifiée restent séparées
des constats Green IT.

Toute intention métier, fréquence d'usage, obligation légale ou valeur éditoriale
non prouvée est une entrée `a_verifier`, avec les preuves ou données à recueillir.

Pour une analyse statique, qualifier l'EcoIndex d'estimation calculée à partir
des sources. Pour le runtime, conserver les metriques brutes, la methode
retournee par `greenit_obtenir_methodologie_ecoindex` et les limites de mesure
par page. Si cette methode est indisponible ou incomplete, qualifier l'EcoIndex
de non mesure.
