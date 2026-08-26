# Nommage des skills d'éco-conception — design

## Décision

La distribution expose trois skills aux rôles distincts :

| Nom | Invocation | Rôle |
| --- | --- | --- |
| `ecodesign` | Automatique | Applique les règles d'éco-conception pendant la conception produit, les parcours, les données et les dépendances. |
| `ecocode` | Automatique | Applique les règles d'éco-conception pendant l'implémentation front-end, back-end, build et cache. |
| `audit-ecoconception` | Explicite | Audite un projet ou un parcours web : front statique, back statique ou runtime navigateur. |

Les noms sont les identifiants installés par `npx skills` et les noms de
répertoires sous `skills/`.

## Déclenchement

`ecodesign` et `ecocode` sont model-invoked : leurs descriptions doivent
inclure les conditions de conception et d'implémentation afin qu'un agent les
charge sans demande dédiée.

`audit-ecoconception` reste model-invoked pour les demandes explicites d'audit,
d'EcoIndex, de Green IT ou d'analyse front, back et runtime. Une demande
naturelle suffit ; son nom exact est documenté dans le README pour permettre
une invocation volontaire, sans imposer de syntaxe propre à un hôte.

Les arguments du skill d'audit rendent le support analysé explicite :

| Invocation courte | Périmètre |
| --- | --- |
| `audit-ecoconception code front` | Analyse statique du code client du projet. |
| `audit-ecoconception code back` | Analyse statique du code serveur du projet. |
| `audit-ecoconception code` | Analyse statique front et back du projet. |
| `audit-ecoconception navigateur <URL>` | Analyse runtime d'une URL ou d'un parcours chargé dans le navigateur. |

Dans les hôtes qui le reconnaissent, le préfixe `$` permet l'invocation courte
(par exemple `$audit-ecoconception code back`). Le README présente les noms et
la syntaxe, ainsi qu'une formulation naturelle portable.

## Migration

Cette modification ne conserve aucun alias : `design` et `development` sont
renommés, et l'ancien `ecocode` d'audit devient `audit-ecoconception`. Les
répertoires, les descriptions, le README, les documents de contribution et les
tests de structure emploient uniquement les nouveaux noms.

La modification est incompatible avec `v3.0.0` et nécessite une prochaine
version majeure lors de sa publication.

## Vérification

Avant l'édition, un test de structure doit échouer en attendant les trois
répertoires `skills/ecodesign`, `skills/ecocode` et
`skills/audit-ecoconception`, puis en interdisant les anciens noms publics.
Après l'édition, ce test, le contrôle YAML et la découverte
`npx skills@latest add . --list` doivent réussir et ne présenter que les trois
nouveaux skills.

## Hors périmètre

Le contenu des règles d'éco-conception, les références d'analyse et le contrat
de restitution ne changent pas. Cette itération ne publie pas la prochaine
version majeure et ne réinstalle pas les skills sur les postes.
