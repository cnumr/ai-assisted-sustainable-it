# Audit Functional Ecocode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend `audit-ecoconception` so every supported scope distinguishes functional eco-design findings from ecocode findings.

**Architecture:** The skill routes a new `fonctionnel` scope to a dedicated reference and loads it alongside the static or runtime reference for the existing scopes. A shared findings contract keeps functional and ecocode findings separate, while the report combines them only at prioritisation time.

**Tech Stack:** Markdown skills, Bash structural tests, Ruby YAML validation, GreenIT MCP.

## Global Constraints

- `ecodesign` and `ecocode` remain proactive skills and are not audit skills.
- Every proven GreenIT finding cites an RWEB sheet returned by `mcp-greenit`; never invent an RWEB ID.
- Product assumptions without observable evidence remain in `a_verifier` with the data needed to validate them.
- Functional findings do not contain code, hosting, cache, request-count, or performance implementation recommendations.
- Ecocode findings do not replace product, journey, content, or format decisions.
- Preserve the current read-only audit posture and the runtime browser safety rules.

---

### Task 1: Cover The Functional Audit Contract

**Files:**
- Modify: `tests/structure/test-skills-only-distribution.sh`
- Test: `tests/structure/test-skills-only-distribution.sh`

**Interfaces:**
- Consumes: repository skill paths.
- Produces: structural assertions for the functional reference, routing, separate finding lists, evidence rule, and public documentation.

- [ ] **Step 1: Add failing structural assertions**

Append these assertions after the existing reference-file loop and audit-skill checks:

```bash
test -f "$root/skills/audit-ecoconception/references/functional-analysis.md"

grep -Fq 'fonctionnel' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'analyse fonctionnelle' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'constats_fonctionnels' "$root/skills/audit-ecoconception/references/findings-contract.md"
grep -Fq 'constats_ecocode' "$root/skills/audit-ecoconception/references/findings-contract.md"
grep -Fq 'a_verifier' "$root/skills/audit-ecoconception/references/functional-analysis.md"
grep -Fq 'audit-ecoconception fonctionnel' "$root/README.md"
```

- [ ] **Step 2: Run the structural test to verify it fails**

Run: `bash tests/structure/test-skills-only-distribution.sh`

Expected: FAIL because `functional-analysis.md` and the functional-contract strings do not exist yet.

- [ ] **Step 3: Leave the assertions in place**

Do not weaken the assertions or add broad matching patterns. They define the public contract implemented by Tasks 2 through 4.

### Task 2: Add The Functional Analysis Reference And Routing

**Files:**
- Create: `skills/audit-ecoconception/references/functional-analysis.md`
- Modify: `skills/audit-ecoconception/SKILL.md`
- Test: `tests/structure/test-skills-only-distribution.sh`

**Interfaces:**
- Consumes: `mcp-greenit`, optional Playwright, and the shared findings contract.
- Produces: `constats_fonctionnels` and functional entries in `a_verifier`.

- [ ] **Step 1: Write `functional-analysis.md`**

Define these sections and rules:

```markdown
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
```

- [ ] **Step 2: Extend `SKILL.md` routing**

Update the scope list to include `fonctionnel`. Load `functional-analysis.md` for every scope, plus `static-analysis.md` for code scopes and `runtime-analysis.md` for browser scopes. Keep `mcp-greenit` mandatory for all scopes and Playwright mandatory for `fonctionnel` and runtime scopes. Require the final audit to return both functional and ecocode lists when evidence is available.

- [ ] **Step 3: Run the structural test**

Run: `bash tests/structure/test-skills-only-distribution.sh`

Expected: still FAIL until the contract and README changes are implemented.

### Task 3: Separate Findings And Evidence In Static And Runtime Audits

**Files:**
- Modify: `skills/audit-ecoconception/references/findings-contract.md`
- Modify: `skills/audit-ecoconception/references/static-analysis.md`
- Modify: `skills/audit-ecoconception/references/runtime-analysis.md`
- Modify: `skills/audit-ecoconception/references/restitution.md`
- Test: `tests/structure/test-skills-only-distribution.sh`

**Interfaces:**
- Consumes: `functional-analysis.md` evidence rules.
- Produces: a YAML contract with `constats_fonctionnels`, `constats_ecocode`, `bonnes_pratiques`, and `a_verifier`.

- [ ] **Step 1: Replace the single findings list in the contract**

Use this shape:

```yaml
perimetre: fonctionnel | front | back | complet | runtime
limites: [mesure ou zone non accessible]
metriques:
  ecoindex: estimation ou mesure runtime, si disponible
  dom_nodes: nombre ou null
  requests: nombre ou null
  size_kb: nombre ou null
constats_fonctionnels:
  - rweb: identifiant et intitule exact retournes par mcp-greenit, ou null
    localisation: URL, route, composant, endpoint, schema ou document
    preuve: observation verifiable
    impact: reseau, CPU, memoire, stockage, requetes ou parcours
    severite: haute | moyenne | faible
    recommandation: decision produit, parcours, contenu ou format
constats_ecocode:
  - rweb: identifiant et intitule exact retournes par mcp-greenit
    localisation: fichier:ligne, URL ou composant
    preuve: observation ou mesure verifiable
    impact: reseau, CPU, memoire, stockage ou infrastructure
    severite: haute | moyenne | faible
    correction: action adaptee au projet
bonnes_pratiques: [observation liee a une fiche MCP]
a_verifier: [hypothese avec les preuves ou donnees necessaires]
```

- [ ] **Step 2: Add functional-evidence collection to static analysis**

Before the existing front and back technical checks, require inspection of the sources listed in `functional-analysis.md`. Explicitly separate observable functional evidence from inferred business intent, and direct inferred intent to `a_verifier`.

- [ ] **Step 3: Add functional-evidence collection to runtime analysis**

After the existing EcoIndex measurement protocol, require read-only observation of the declared journey: navigation, search, content hierarchy, formats, documents, media, forms, lists and exposed retention choices. Keep the existing protocol as the only EcoIndex measurement source.

- [ ] **Step 4: Update restitution**

Require reports and plans to present `constats_fonctionnels` before `constats_ecocode`, followed by a combined priority order that explains dependencies between a product decision and an implementation change. Retain the current explicit-approval rule before writing, creating issues, or applying corrections.

- [ ] **Step 5: Run the structural test to verify the contract assertions**

Run: `bash tests/structure/test-skills-only-distribution.sh`

Expected: FAIL only on the missing README usage assertion; Tasks 1 through 3 must otherwise satisfy every new assertion.

### Task 4: Document The New Scope

**Files:**
- Modify: `README.md`
- Modify: `AGENTS.md`
- Modify: `CLAUDE.md`
- Test: `tests/structure/test-skills-only-distribution.sh`

**Interfaces:**
- Consumes: the `fonctionnel` audit scope and two-volet output contract.
- Produces: consistent installation and usage guidance for all supported hosts.

- [ ] **Step 1: Add functional usage examples**

Add this command beside the existing audit examples in all three documents:

```text
$audit-ecoconception fonctionnel
```

State that `audit-ecoconception` audits both functional eco-design and ecocode, while `ecodesign` and `ecocode` remain proactive.

- [ ] **Step 2: Run both repository checks**

Run: `bash tests/structure/test-skills-only-distribution.sh && bash tests/structure/test-yaml-frontmatter.sh`

Expected: the structural test exits 0 and the YAML test reports valid front matter.

- [ ] **Step 3: Review changed documentation**

Verify that every document uses the same four code words: `fonctionnel`, `front`, `back`, `navigateur`, and does not call `ecodesign` or `ecocode` an audit.

### Task 5: Final Validation

**Files:**
- Verify: `skills/audit-ecoconception/SKILL.md`
- Verify: `skills/audit-ecoconception/references/functional-analysis.md`
- Verify: `skills/audit-ecoconception/references/findings-contract.md`
- Verify: `README.md`, `AGENTS.md`, `CLAUDE.md`
- Test: `tests/structure/test-skills-only-distribution.sh`
- Test: `tests/structure/test-yaml-frontmatter.sh`

**Interfaces:**
- Consumes: the complete audit-skill documentation set.
- Produces: evidence that public routing, evidence boundaries, and output separation match the approved design.

- [ ] **Step 1: Run the complete test suite**

Run: `for test_file in tests/structure/*.sh; do bash "$test_file"; done`

Expected: exit code 0; the YAML check reports valid front matter.

- [ ] **Step 2: Inspect the diff against the approved design**

Run: `git diff -- skills/audit-ecoconception README.md AGENTS.md CLAUDE.md tests/structure/test-skills-only-distribution.sh`

Confirm the diff includes the functional scope, MCP-backed functional evidence, `a_verifier` for unproven business claims, separate findings lists, and two-volet restitution.

- [ ] **Step 3: Commit the implementation**

Run:

```bash
git add skills/audit-ecoconception README.md AGENTS.md CLAUDE.md tests/structure/test-skills-only-distribution.sh
git commit -m "feat(audit): add functional eco-design analysis"
```

Expected: one commit containing the tested audit-skill extension.

## Plan Self-Review

- Spec coverage: Tasks 2 and 3 implement the two audit volets, Task 4 preserves the proactive role of `ecodesign` and `ecocode`, and Task 5 checks the evidence and output boundaries.
- Placeholder scan: no incomplete requirements or deferred implementation steps.
- Naming consistency: `constats_fonctionnels`, `constats_ecocode`, and `a_verifier` are used consistently across all tasks.
