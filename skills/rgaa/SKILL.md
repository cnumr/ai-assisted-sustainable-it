---
name: rgaa
description: Conduit un audit d'accessibilité RGAA 4.2.1 complet sur une ou plusieurs pages web. Utilise ce skill quand l'utilisateur demande un audit RGAA, un audit d'accessibilité, ou veut vérifier la conformité RGAA d'une page ou d'un échantillon de pages. Génère un rapport structuré avec TOUS les critères (automatiques ET manuels), les violations détectées, et une fourchette de taux de conformité.
license: MIT
metadata:
  author: Renaud Heluin
  version: "1.0"
---

# Audit RGAA 4.2.1

## Workflow principal

### `rgaa-audit <url> --type complet|rapide|complementaire [--playwright] [--save <path>]`

Workflow unique et atomique. Fait tout d'une traite : initialise → analyse → évalue → valide → génère → sauvegarde.

**Paramètres** :

- **url** : une URL ou une liste d'URLs (échantillon)
- **--type** : `complet` (106 critères, obligation légale), `rapide` (25 critères, première analyse), `complementaire` (25 critères) — par défaut `rapide`
- **--playwright** : active Playwright MCP pour vérifications dynamiques (par défaut activé si disponible)
- **--save <path>** : chemin de sauvegarde du rapport — par défaut `audit-rgaa-[domaine]-[date].md` dans le répertoire courant

**Déroulé interne** :

1. `rgaa_types_audit()` → `rgaa_criteres_audit(type)` — charger la liste complète des critères
2. `rgaa_analyser(url)` pour chaque URL — analyse automatique (~57 % des critères)
3. Playwright MCP : contrastes, zoom 200 %, navigation clavier, focus, ARIA, images décoratives
4. Assignation des statuts C / NC / NA / ⚠ pour chaque critère
5. **Validation** : C + NC + NA + ⚠ = total critères (par thème aussi)
6. Calcul des taux avec `rgaa_taux_conformite`
7. Génération du rapport Markdown
8. Sauvegarde si --save fourni

## Commands utilitaires

### `rgaa-assess <url> <theme> <criteres>`

Réévaluer manuellement des critères marqués ⚠ après l'audit.

- **url** : URL concernée
- **theme** : numéro du thème (1-13)
- **criteres** : liste de statuts — ex: `"3.1:NC,3.2:NA,3.3:C"`

Recalcule les taux automatiquement.

### `rgaa-recalculate`

Recalculer uniquement les taux de conformité avec les statuts actuels (sans régénérer le rapport).

## 1. Initialisation

### Collecter les paramètres

Demande à l'utilisateur si ce n'est pas déjà fourni :

- **URL(s)** : une seule page ou un échantillon (liste d'URLs)
- **Type d'audit** : appelle `rgaa_types_audit()` pour afficher les options, puis `rgaa_criteres_audit(type)` pour récupérer la liste complète des critères. Par défaut propose "rapide" (25 critères) pour une première analyse, "complet" pour l'obligation légale.
- **Mode** : Utilise ou non Playwright MCP pour réaliser l'audit et faire de vérifications dynamiques. Par defaut, on utilisera Playwright MCP.

Retiens la liste complète des critères de l'audit — elle sert de colonne vertébrale au rapport.

## 2. Analyse automatique

Pour chaque URL de l'échantillon, appelle `rgaa_analyser(url)`.

Cette analyse couvre ~57 % des critères (thèmes 1, 2, 5, 6, 8, 9, 11, 12). Elle retourne les violations détectées par critère.

Si Playwright MCP est disponible, utilise-le en complément pour les vérifications dynamiques (focus clavier, ARIA live regions, comportement des composants JS).

### Vérification visuelle

Pour les critères non automatisables, utilise les outils suivants pour affiner le rapport :

- **Contrastes (thème 3)** : `rgaa_chercher("contraste")` pour les fiches recommandées. Mesurer les ratios via Playwright :
  1. Extraire les couleurs calculées avec `mcp_plugin_playwright_playwright_browser_evaluate` :
     ```javascript
     () => {
       const elems = document.querySelectorAll("body *");
       const pairs = [];
       elems.forEach((el) => {
         const style = getComputedStyle(el);
         if (
           style.color &&
           style.backgroundColor &&
           style.backgroundColor !== "rgba(0, 0, 0, 0)" &&
           style.backgroundColor !== "transparent"
         ) {
           pairs.push({
             tag: el.tagName,
             text: (el.textContent || "").trim().substring(0, 50),
             fg: style.color,
             bg: style.backgroundColor,
           });
         }
       });
       return pairs;
     };
     ```
  2. Convertir les couleurs CSS (rgb/rgba/hex) en channels R,G,B puis appliquer la formule de luminance relative WCAG :
     - `linearize(c) = c ≤ 0.04045 ? c/12.92 : ((c+0.055)/1.055)^2.4`
     - `luminance = 0.2126*R_lin + 0.7152*G_lin + 0.0722*B_lin`
     - `ratio = (lighter + 0.05) / (darker + 0.05)`
  3. Seuils RGAA : texte normal ≥ 4.5:1 (AA), texte large ≥ 3:1 (AA), composants UI ≥ 3:1 (AA)
- **Zoom 200 % (10.4)** : `mcp_plugin_playwright_playwright_browser_resize` à 1280x768 (ou plus large) puis screenshot pour vérifier texte coupé, débordements
- **Navigation clavier (12.9, 12.11, 10.7)** : `mcp_plugin_playwright_playwright_browser_press_key` pour simuler Tab, Escape, etc. — vérifier focus visible, pièges, ordre de tabulation
- **Styles désactivés (10.2, 10.3)** : inspecter le DOM brut via snapshot pour vérifier que l'information subsiste sans CSS
- **Contenus dynamiques (10.8, 10.13, 10.14)** : `mcp_plugin_playwright_playwright_browser_snapshot` pour vérifier aria-hidden, roles, live regions
- **Images de décoration (1.2)** : vérifier les `img` avec `alt=""` via snapshot Playwright

## 3. Construction du rapport par critère

Pour **chaque critère** du type d'audit choisi, détermine son statut :

| Statut           | Signification                                                        |
| ---------------- | -------------------------------------------------------------------- |
| **C**            | Conforme — vérifié automatiquement ou manuellement, aucune violation |
| **NC**           | Non conforme — violation détectée                                    |
| **NA**           | Non applicable — le critère ne s'applique pas à cette page           |
| **⚠ À vérifier** | Hors périmètre automatisable — nécessite une vérification manuelle   |

Pour obtenir le détail d'un critère ou ses tests, utilise `rgaa_obtenir_critere(id)`.
Pour générer la checklist des tests manuels par thème, utilise `rgaa_checklist(themes=[...])`.

**Règle pour un échantillon de pages** : si un critère est NC sur au moins une page du périmètre, il est NC au niveau global.

## 4. Calcul des taux de conformité

### Page unique

Appelle `rgaa_taux_conformite(resultats)` avec les statuts connus (C, NC, NA). Les critères "À vérifier" ne sont pas inclus dans ce calcul.

Présente une **fourchette** :

- **Taux bas** : suppose que tous les critères "À vérifier" sont NC
- **Taux haut** : suppose que tous les critères "À vérifier" sont C

### Échantillon de pages

Pour chaque page :

- Calcule son taux individuel (fourchette)

Pour le total :

- Agrège selon la règle NC global (un NC sur n'importe quelle page = NC global)
- Affiche le **taux réel global** (critères connus seulement) + la fourchette
- Affiche les **taux moyens par page** en complément

## 4.5. Validation des comptes avant finalisation

**AVANT de générer le rapport, vérifier impérativement que la somme des statuts est égale au nombre total de critères :**

```
C + NC + NA + ⚠ = total critères
```

Exemple pour un audit complet : `44 + 13 + 33 + 16 = 106` ✅
Si la somme ne correspond pas, **ne pas continuer** — re-vérifier chaque compte.

Cette validation s'applique aussi à chaque thème individuellement :

```
Pour chaque thème : C + NC + NA + ⚠ = nombre de critères du thème
```

En cas d'échantillon de pages, vérifier la cohérence du tableau récapitulatif :

- Le nombre de colonnes doit correspondre au nombre de pages + 1 (réf. critère) + 1 (statut global)
- La somme du pied de tableau doit correspondre aux totaux par thème

## 5. Structure du rapport

```
# Rapport d'audit RGAA 4.2.1
Date : [date]
Type d'audit : [rapide / complet / complémentaire] ([N] critères)
Périmètre : [URL ou liste d'URLs]

## Synthèse
- Conformes (C) : N
- Non conformes (NC) : N
- Non applicables (NA) : N
- À vérifier manuellement : N
- Taux de conformité : XX % – YY % (fourchette)

## Résultats par critère

### Thème 1 – Images
| Critère | Titre | Statut | Détail |
|---------|-------|--------|--------|
| 1.1 | Chaque image... | NC | Alt manquant sur 3 images |
| 1.2 | ... | ⚠ À vérifier | Nécessite inspection manuelle |
...

[Répéter pour chaque thème]

## Violations détectées (automatique)
[Liste des violations avec élément HTML concerné et recommandation]

## Checklist des tests manuels restants
[Générée par rgaa_checklist pour les thèmes concernés]

## Taux par page (si échantillon)

| Page | Taux bas | Taux haut |
|------|----------|-----------|
| url1 | XX % | YY % |
| url2 | XX % | YY % |
| **Total** | **XX %** | **YY %** |

## Tableau récapitulatif des résultats (Échantillon)

| Ref Critère | URL 1 | URL 2 | URL 3 | ... | Statut Global |
|-------------|-------|-------|-------|-----|---------------------------|
| [ID (C, NC, NA ou ⚠ À vérifier)] | [Statut]| [Statut]| [Statut]| ... | [Statut Global]             |
| **Total**   |       |       |       |     |                            |
```

## 6. Sauvegarde du rapport

À la fin de l'audit, demande à l'utilisateur où enregistrer le rapport (chemin et nom de fichier `.md`). Si l'utilisateur ne précise pas, propose un nom par défaut du type `audit-rgaa-[domaine]-[date].md` dans le répertoire courant.

Enregistre le rapport complet en Markdown à l'emplacement choisi.

## 7. Bonnes pratiques

- Si une violation est détectée sur un critère, utilise `rgaa_obtenir_critere(id)` pour fournir des recommandations de correction précises.
- Pour les critères "À vérifier", indique toujours les outils recommandés (issus de `rgaa_checklist`).
- Ne marque jamais un critère comme C si tu ne l'as pas effectivement vérifié.
- Si l'utilisateur veut affiner après coup les statuts manuels, recalcule le taux avec `rgaa_taux_conformite` et mets à jour la fourchette.
- **Responsive** : tester TOUJOURS les 3 breakpoints (mobile/tablette/desktop) — un site peut être conforme sur desktop et brisé sur mobile.
- **Focus** : le focus-ring doit être visible sur TOUT élément focusable, pas seulement les liens (inputs, boutons, onglets).
- **Liens** : lister les noms génériques détectés ("cliquer ici", "lire la suite") dans le rapport — c'est une recommendation UX + accessibilité.
- **Formulaires** : tester au moins le premier formulaire trouvé, même s'il n'y en a qu'un.
