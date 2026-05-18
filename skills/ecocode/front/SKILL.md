---
name: ecocode-front
description: Use when analyzing the ecological impact of front-end code: assets weight, HTTP requests, JavaScript bundles, CSS, images, fonts, browser rendering, lazy loading, caching, or web performance from a green IT perspective.
---

# EcoCode Front — Analyse éco-conception côté client

## Vue d'ensemble

Sous-skill spécialisé dans l'audit éco-conception front-end. Mappe chaque problème détecté aux bonnes pratiques Green IT correspondantes via le MCP `mcp-greenit`.

**REQUIRED PARENT SKILL:** `ecocode` — ce sous-skill est délégué par le skill parent.

## Sources d'analyse

| Source          | Méthode                                                  |
| --------------- | -------------------------------------------------------- |
| Fichiers locaux | Lire les fichiers source (HTML, JS, CSS, configs)        |
| URL fournie     | Utiliser Playwright pour inspecter le rendu et le réseau |
| Les deux        | Combiner analyse statique + analyse runtime              |

## Axes d'analyse

### 1. Design, UX et conception

**Consulter :** `mcp-greenit : chercher_fiche` avec "mobile", "parcours", "design", "fonctionnalités"

Vérifier :

- [ ] Absence d'approche mobile first → pages non adaptées aux petits écrans (RWEB_0004)
- [ ] Fonctionnalités non essentielles présentes → alourdit inutilement (RWEB_0001, RWEB_0003)
- [ ] Parcours utilisateur non optimisé → trop d'étapes, rechargements inutiles (RWEB_0005)
- [ ] Carrousels lourds avec chargement de toutes les slides (RWEB_0010)
- [ ] Titre de page et metadescription absents ou génériques (RWEB_0011)
- [ ] Design surchargé (effets, ombres, gradients CSS complexes) au lieu d'un design épuré (RWEB_0012)
- [ ] Défilement infini sans pagination → tout chargé en mémoire (RWEB_0013)
- [ ] Autocomplétion sur chaque frappe au lieu de saisie assistée (RWEB_0014)

### 2. Assets images, vidéos, sons et documents

**Consulter :** `mcp-greenit : chercher_fiche` avec "images", "vidéo", "son", "médias", "compression"

Vérifier :

- [ ] Images PNG/JPEG non converties en WebP ou AVIF (RWEB_0049)
- [ ] Images sans attribut `width`/`height` → cause layout shift (RWEB_0048)
- [ ] Images non redimensionnées côté serveur (envoi d'originaux 4K pour affichage 400px) (RWEB_0048)
- [ ] Images matricielles utilisées pour l'interface (icônes, décorations) au lieu de SVG (RWEB_0038)
- [ ] Préférer CSS aux images pour les effets décoratifs (dégradés, ombres, formes) (RWEB_0037)
- [ ] Préférer glyphes (icon fonts, SVG sprites) aux images PNG pour les icônes (RWEB_0050)
- [ ] Images vectorielles SVG non optimisées (SVGO absent) (RWEB_0100)
- [ ] GIFs animés non remplacés par vidéo MP4/WebM (RWEB_0099)
- [ ] Vidéos avec lecture automatique au chargement (RWEB_0106)
- [ ] Vidéos non adaptées aux contextes (même résolution/qualité pour mobile et desktop) (RWEB_0107)
- [ ] Sons avec lecture automatique ou non adaptés au contexte d'écoute (RWEB_0105, RWEB_0106)
- [ ] Sons/vidéos non encodés en dehors du CMS (traitement côté serveur absent) (RWEB_0104)
- [ ] Documents (PDF, Word) affichés directement dans la page via `<iframe>` ou `<embed>` (RWEB_0033)
- [ ] Documents non compressés avant mise en ligne (RWEB_0108)
- [ ] Médias importés dans un CMS sans optimisation préalable (RWEB_0098)
- [ ] Fonts en WOFF au lieu de WOFF2 (RWEB_0032)
- [ ] Fonts avec tous les glyphes chargés au lieu du subset utile (RWEB_0032)
- [ ] Polices web au lieu des polices système standards (RWEB_0032)

### 3. Requêtes HTTP et réseau

**Consulter :** `mcp-greenit : chercher_fiche` avec "requêtes HTTP", "réseau", "domaines", "redirections"

Vérifier :

- [ ] Trop de fichiers JS/CSS séparés sans HTTP/2 → multiplier les connexions (RWEB_0047)
- [ ] Protocole HTTP/1.1 au lieu de HTTP/2 sur le serveur de production (RWEB_0083)
- [ ] Redirections 301 évitables (URLs mal formées, HTTP → HTTPS non géré par HSTS) (RWEB_0084, RWEB_0112)
- [ ] Polices Google Fonts chargées depuis serveurs Google au lieu d'être auto-hébergées (RWEB_0082)
- [ ] Scripts tiers (analytics, widgets, chat) bloquants dans le `<head>` (RWEB_0047)
- [ ] Boutons de partage officiels des réseaux sociaux (Twitter, Facebook, etc.) chargeant des scripts tiers (RWEB_0059)
- [ ] Absence de prefetch/preconnect pour les ressources critiques (RWEB_0047)
- [ ] Requêtes redondantes pour les mêmes données (RWEB_0021)
- [ ] Ressources statiques servies depuis le même domaine que l'application (cookies envoyés inutilement) (RWEB_0081)
- [ ] Trop de domaines différents pour servir les ressources → multiplier les DNS lookups (RWEB_0082)
- [ ] Navigation dans l'historique (bouton Précédent) déclenchant un rechargement complet (bfcache non respecté) (RWEB_0008)
- [ ] Cookies de session trop volumineux envoyés à chaque requête (RWEB_0062)
- [ ] Outils analytics lourds (Google Analytics 4 non optimisé) ou multiples trackers (RWEB_0111)
- [ ] Rechargement de page complet là où un rechargement partiel AJAX suffirait (RWEB_0034)

### 4. JavaScript — bundles et exécution

**Consulter :** `mcp-greenit : chercher_fiche` avec "JavaScript", "bundle", "dépendances", "bibliothèques"

Vérifier :

- [ ] Bundle JS trop lourd (> 200 Ko parsé) pour le chemin critique (RWEB_0015)
- [ ] Bibliothèques importées entièrement sans tree shaking (ex: lodash en entier pour `_.get`) (RWEB_0015)
- [ ] N'utiliser que les portions indispensables des libs et frameworks CSS (RWEB_0015)
- [ ] Librairies surdimensionnées pour des fonctionnalités simples (moment.js pour une date) (RWEB_0015)
- [ ] Polyfills chargés pour des navigateurs modernes (RWEB_0015)
- [ ] Scripts de tracking/ads non différés (`async`/`defer` absent) (RWEB_0053)
- [ ] Imports dynamiques absents pour le code non-critique (RWEB_0046)
- [ ] Traitements JS longs bloquant le thread principal (> 50ms) → Web Workers absents (RWEB_0053)
- [ ] Canvas utilisé pour des rendus simples réalisables en CSS ou SVG (RWEB_0055)
- [ ] Objets/résultats fréquemment accédés recalculés à chaque fois (memoization JS absente) (RWEB_0054)
- [ ] Délégation d'événements absente : listener individuel sur chaque élément d'une liste (RWEB_0056)
- [ ] Site non compatible avec les appareils de génération précédente (encourage remplacement hardware) (RWEB_0058)

### 5. Rendu côté client — DOM et re-renders

**Consulter :** `mcp-greenit : chercher_fiche` avec "DOM", "rendu", "reflow", "repaint"

Vérifier :

- [ ] DOM profond et complexe (> 1500 nœuds) (RWEB_0052)
- [ ] Re-renders excessifs en React/Vue (absence de `memo`, `useMemo`, `computed`) (RWEB_0052)
- [ ] Modifications DOM multiples sans rendre l'élément invisible préalablement (`display:none`) (RWEB_0045)
- [ ] Animations sur des propriétés déclenchant layout (width, height, top) au lieu de `transform`/`opacity` (RWEB_0009, RWEB_0052)
- [ ] Animations et transitions JS là où du CSS pur suffirait (RWEB_0009)
- [ ] Accès au DOM dans des boucles (forcer reflow à chaque itération) (RWEB_0044, RWEB_0057)
- [ ] Scroll infini sans virtualisation de liste (tout le DOM en mémoire) (RWEB_0013)
- [ ] Event listeners non nettoyés → fuites mémoire (RWEB_0056)
- [ ] CSS containment (`contain: layout style paint`) absent sur les composants isolés (RWEB_0039)

### 6. Lazy loading et mise en cache

**Consulter :** `mcp-greenit : chercher_fiche` avec "cache", "lazy loading", "Service Worker"

Vérifier :

- [ ] Images sans `loading="lazy"` (sauf above-the-fold) (RWEB_0051)
- [ ] Code splitting absent (tout le JS chargé dès la page d'accueil) (RWEB_0046)
- [ ] Données chargées au démarrage alors qu'elles ne sont nécessaires qu'à la demande (RWEB_0046)
- [ ] Service Worker absent ou non configuré pour le cache offline (RWEB_0060)
- [ ] Cache-Control headers absents ou trop courts sur les assets statiques (RWEB_0075)
- [ ] Entêtes `Expires` absentes sur les ressources statiques (RWEB_0075)
- [ ] Assets sans hash de contenu dans le nom de fichier → invalidation cache impossible (RWEB_0075)
- [ ] Réponses AJAX non mises en cache alors que les données changent rarement (RWEB_0072)
- [ ] Données statiques non stockées localement (localStorage/IndexedDB) pour éviter les requêtes répétées (RWEB_0064)

### 7. CSS

**Consulter :** `mcp-greenit : chercher_fiche` avec "CSS", "sélecteurs", "feuilles de style"

Vérifier :

- [ ] CSS inutilisé non purgé (PurgeCSS/tree-shaking CSS absent) (RWEB_0036)
- [ ] Trop de fichiers CSS chargés séparément (RWEB_0035)
- [ ] CSS non découpé par page/composant → tout chargé sur chaque page (RWEB_0036)
- [ ] CSS critique non inliné, CSS non-critique chargé en bloquant dans `<head>` (RWEB_0042)
- [ ] Sélecteurs CSS universels ou trop génériques (`.parent .child .elem`) (RWEB_0041)
- [ ] Modifications de propriétés CSS dispersées alors qu'une seule opération suffit (classList, cssText) (RWEB_0040)
- [ ] Notations CSS longues au lieu des raccourcis (`margin-top/right/bottom/left` au lieu de `margin`) (RWEB_0118)
- [ ] Déclarations CSS similaires non regroupées → duplication inutile (RWEB_0119)
- [ ] Absence de CSS print → impression déclenche le rendu de ressources inutiles (RWEB_0031)

### 8. Build, compression et déploiement

**Consulter :** `mcp-greenit : chercher_fiche` avec "minification", "compression", "build", "CDN"

Vérifier :

- [ ] CSS, JS, HTML et SVG non minifiés en production (RWEB_0077)
- [ ] Fichiers CSS et JS non combinés/bundlés (trop de requêtes séparées sans HTTP/2) (RWEB_0078)
- [ ] Absence de compression Gzip ou Brotli sur le serveur (RWEB_0076)
- [ ] CSS et JS non externalisés (inline dans le HTML → non mis en cache par le navigateur) (RWEB_0042)
- [ ] Absence de CDN pour les assets statiques (latence élevée pour les utilisateurs distants) (RWEB_0070)
- [ ] Code non validé par un linter (erreurs silencieuses consommant des ressources inutilement) (RWEB_0043)
- [ ] Pages non validées W3C → parsing plus coûteux pour le navigateur (RWEB_0061)
- [ ] Textes non adaptés au web (trop longs, non scannables → temps de lecture et scrolling augmentés) (RWEB_0110)

## Analyse via Playwright (si URL disponible)

### Protocole d'authentification

Avant toute analyse, détecter et gérer un éventuel mur d'authentification.

**Détection d'un mur d'auth :**

- URL redirigée vers `/login`, `/signin`, `/auth`, `/connexion`, `/sso`, etc.
- Page contient `input[type="password"]`
- Réponse HTTP 401 ou 403
- Redirection vers un provider OAuth externe (Google, Microsoft, Okta…)

**Protocole de gestion :**

```
1. Naviguer vers l'URL cible
2. Prendre un snapshot → vérifier URL + présence d'un formulaire de connexion
3. Si mur d'auth détecté :
   a. Demander à l'utilisateur : identifiant + mot de passe
   b. Remplir le formulaire et soumettre
   c. Prendre un snapshot → vérifier si un 2FA est demandé

4. Détection du type de 2FA :
   - Champ OTP (6 chiffres, label "code", "authenticator", "vérification") → TOTP
   - Mention "SMS" ou "code envoyé par message" → SMS
   - Mention "approbation", "push", "Duo", "notification" → push notification
   - Clé physique / WebAuthn (mention "clé de sécurité", "FIDO") → non automatisable

5. Gestion par type :
   - TOTP / SMS   : demander le code à l'utilisateur, le saisir dans le champ, soumettre
   - Push          : demander à l'utilisateur d'approuver la notification, attendre la redirection (timeout 60s)
   - WebAuthn      : IMPOSSIBLE À AUTOMATISER — prévenir l'utilisateur, proposer de passer l'analyse URL

6. Vérifier le succès : URL revenue sur la cible, absence de formulaire d'auth
7. Reprendre l'analyse normale
```

**Cas non gérés — arrêter et avertir :**

- Clé physique WebAuthn/FIDO2 (impossible d'interagir avec le matériel)
- CAPTCHA visuel ou audio
- Authentification biométrique

### Étapes d'analyse réseau

```
1. Naviguer vers l'URL (après authentification si nécessaire)
2. Intercepter les requêtes réseau → lister ressources, tailles, types, domaines
3. Mesurer DOMContentLoaded, Load, LCP, CLS
4. Capturer le nombre de nœuds DOM
5. Calculer : total des requêtes HTTP + taille totale transférée en KB
6. Appeler mcp-greenit : calculer_ecoindex avec {dom_nodes, requests, size_kb, url}
7. Lister les scripts tiers et leur poids
8. Vérifier les headers de cache (Cache-Control, Expires, ETag)
9. Vérifier le protocole (HTTP/1.1 vs HTTP/2)
10. Détecter les redirections (301, 302)
11. Vérifier la lecture automatique audio/vidéo
12. Contrôler la présence d'un Service Worker
```

## Format de rapport

```markdown
## Analyse Front-end

### EcoIndex

| Métrique          | Valeur mesurée |
| ----------------- | -------------- |
| Nœuds DOM         | XXX            |
| Requêtes HTTP     | XX             |
| Taille transférée | X,X MB         |
| **EcoIndex**      | **XX/100**     |
| **Grade**         | **A**          |
| CO2 / page vue    | X,XX gCO2e     |
| Eau / page vue    | X,XX cl        |

### Problèmes détectés

| #   | Problème                          | Fichier/URL      | Sévérité | Pratique Green IT                                      |
| --- | --------------------------------- | ---------------- | -------- | ------------------------------------------------------ |
| 1   | Images PNG non converties en WebP | /assets/hero.png | Haute    | RWEB_0049 — Optimiser les images                       |
| 2   | Bundle JS 450Ko non splitté       | main.bundle.js   | Haute    | RWEB_0015 — N'utiliser que les portions indispensables |

### Détail par problème

**[Numéro]. [Intitulé du problème]**

- **Pratique Green IT :** RWEB_XXXX — [intitulé officiel]
- **Sévérité :** Haute / Moyenne / Faible
- **Constat :** [Ce qui a été observé]
- **Impact :** [Ressources gaspillées : bande passante, CPU, énergie]
- **Correction proposée :** [Action concrète]

### Bonnes pratiques déjà respectées

- [Liste des points positifs avec RWEB_XXXX correspondant]
```

## Mapping sévérité

| Sévérité    | Critères                                                                |
| ----------- | ----------------------------------------------------------------------- |
| **Haute**   | Impact direct sur réseau ou CPU, visible pour tous les utilisateurs     |
| **Moyenne** | Impact significatif sur une portion des utilisateurs ou des cas d'usage |
| **Faible**  | Optimisation marginale, gain < 5% sur les métriques                     |

## Erreurs fréquentes

- **Analyser sans mcp-greenit** : toujours mapper au numéro RWEB_XXXX officiel
- **Sévérité subjective** : baser la sévérité sur la fréquence d'exposition et le volume de données impliqué
- **Oublier l'analyse runtime** : l'analyse statique seule manque les requêtes dynamiques, les autoplay, les scripts tiers
- **Confondre optimisation image et format** : RWEB_0049 (optimisation/compression) ≠ RWEB_0048 (dimensionnement)
