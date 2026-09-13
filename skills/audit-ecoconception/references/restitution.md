# Restitution après audit

Présenter d'abord les constats dans la conversation, puis demander une seule
suite parmi les options suivantes :

- **conversation** : aucune écriture ;
- **document** : écrire un rapport Markdown dans `docs/ecocode/audits/` ;
- **issue** : préparer un brouillon d'issue ; créer l'issue seulement sur
  demande explicite et si l'intégration est disponible ;
- **plan** : prioriser les constats déjà collectés, sans relire les sources ;
- **correction** : proposer les modifications puis les appliquer seulement
  après demande explicite.

Chaque rapport ou plan présente les sections suivantes dans cet ordre strict :

1. `constats_fonctionnels` ;
2. `constats_ecocode` ;
3. `priorites_combinees`, qui ordonne les actions et explique chaque dépendance
   entre une décision produit et un changement d'implémentation ;
4. `bonnes_pratiques` ;
5. `a_verifier` ;
6. les limites.

Le périmètre, la méthode et les métriques accompagnent le rapport sans modifier
cet ordre. Les recommandations fonctionnelles restent séparées des corrections
EcoCode. N'inventer ni preuve, ni gain chiffré, ni cible numérique.
