# Frontend Runtime Audit Depth Design

## Status

Approved design. This specification defines the next evolution of `/ecocode frontend`.

## Goal

Make the runtime audit complete within its primary ecodesign scope, while using
the browser data already available through Playwright and Chrome DevTools to
produce precise, structured and actionable performance and web-development
findings.

The result must help a team decide what to correct first. It must not turn
unproven hypotheses into GreenIT findings.

## Constraints

- Keep the existing Playwright and `mcp-greenit` stack. Do not add Lighthouse,
  a second Chrome instance, or an external audit service.
- Preserve the current read-only, authentication, URL validation, sensitive-data
  and interaction-confirmation rules.
- Do not execute user-supplied JavaScript. The auditor may execute only its own
  fixed diagnostic probes through Playwright.
- Keep EcoIndex based on the initial, fresh-context navigation. A progressive
  scroll may inspect lazy resources separately and must never change the
  EcoIndex input values.
- A GreenIT finding must retain an exact, MCP-returned `RWEB_XXXX` identifier
  and title.
- Keep first-party measurements small: collect only data needed by the fixed
  probes and avoid screenshots unless they are useful evidence.

## Audit Model

Each audit point has two phases.

### Initial-load measurement

Use a fresh browser context when compatible with the user session. Record the
existing DOM count, request count and transferred bytes, then call the GreenIT
EcoIndex calculator. Keep observable request metadata: resource type, domain,
protocol, redirect, response status, cache headers, encoded size and timing.

### Diagnostic inspection

Run a deterministic probe matrix after the page is stable. A separate,
read-only progressive scroll can inspect below-the-fold images and media. It
must not click, fill, submit, check, select or press any control.

Each probe produces one of four outcomes:

| Outcome | Meaning | Report destination |
| --- | --- | --- |
| Confirmed GreenIT | Measured evidence maps to an exact returned RWEB fiche. | Ecarts GreenIT |
| Performance | A measured runtime concern has no verified RWEB mapping. | Performance |
| Web development | An observed browser, DOM, API or resource-quality concern has no verified RWEB mapping. | Developpement web |
| Verify | The browser exposes a credible lead, but cannot establish business necessity or root cause. | A verifier |

The report must list probes that could not run or were not applicable. This
prevents an absence of finding from being interpreted as a successful check.

### EcoIndex coherence gate

EcoIndex is a result metric, not a direct mapping to a specific RWEB fiche. A
low grade must therefore trigger deeper evidence collection, not an invented
GreenIT finding. For every page graded C through G, the report must contain:

- the measured contributors to its DOM, request and transferred-size values;
- a finding, verification lead or stated measurement limitation for each
  material contributor; and
- the coverage status of every probe domain.

If the initial probe matrix yields no actionable evidence for a C-to-G page,
the auditor escalates to the full diagnostic inspection and progressive-scroll
inspection where allowed. If it still cannot explain the score, the report
states that the analysis is inconclusive and identifies the unmeasured scope.
It must never return a near-empty audit that implies the page is ecodesigned.

Grades A and B do not imply absence of findings; grades C through G do not
permit the auditor to fabricate one. They require a proportionate explanation
of the measured impact and the remaining uncertainty.

## Fixed Probe Matrix

| Domain | Evidence collected | Candidate RWEB mappings |
| --- | --- | --- |
| Network | Request count and type, domains, response status, redirects, protocol, cache and compression headers, transfer size and slow or failed resources. | RWEB_0047, RWEB_0074, RWEB_0075, RWEB_0082, RWEB_0112 |
| Scripts and styles | External and inline script/style inventory, duplicate URLs, third parties, named CMS/plugin modules, console errors and failed resources. | RWEB_0001 and RWEB_0015 only when necessity is independently evidenced; otherwise Verify. |
| Images and media | Current source format, natural and rendered dimensions, `srcset`, `sizes`, `loading`, position relative to the viewport, iframe/video/audio loading and autoplay. | RWEB_0048, RWEB_0049, RWEB_0051, RWEB_0106 |
| Components | Swiper/Slick/Splide/Owl or ARIA carousel patterns, number of instances and slides, navigation controls, active animations and canvas elements. | RWEB_0009, RWEB_0010, RWEB_0055 |
| Analytics and consent | Analytics, advertising, tag-manager and consent domains/scripts actually loaded. | RWEB_0111 |
| Web quality | Console warnings/errors, 4xx/5xx requests, duplicate DOM IDs, broken media, missing intrinsic image dimensions, and unsupported resource responses. | Development web unless an exact RWEB fiche is verified. |

The agent must retrieve the relevant fiches before asserting an RWEB mapping.
It must not infer that all libraries, forms, tracking scripts or consent tools
are useless. Usage and legal necessity are business-context questions.

## Output Contract

The strict runtime JSON contract is extended with structured probe results and
an `a_verifier` collection per page. Every entry contains a stable
deduplication key, severity, observation, proof, impact, location and optional
correction. The data model also carries a per-page coverage list with
`measured`, `not_applicable`, `not_measurable` or `failed` status and a reason.

Existing `ecarts_greenit`, `performance`, `developpement_web`, `deduplication`
and limits remain available for compatibility with the report writer. The
runtime report writer consumes the richer data but never reads source files or
performs another audit.

## Report Structure

The one-file `/ecocode frontend` report follows this structure:

1. Executive summary with top actions and per-page EcoIndex.
2. Scope, method, coverage matrix and limitations.
3. Page comparison table: DOM, requests, transferred size, EcoIndex, GES and water.
4. Per-page findings: GreenIT, performance, web development, verification leads and proof.
5. Cross-page findings: scripts, third parties, fonts, images, media, carousels, cache and redirects.
6. Consolidated GreenIT findings grouped by exact RWEB fiche.
7. Performance findings.
8. Web-development findings.
9. Potential-gains summary.
10. Prioritized action plan.
11. Text conclusion.
12. Evidence and measurement appendix.

Potential gains use a `current / target / expected gain / confidence` table.
Numerical targets are allowed only when the measured inventory supports them;
otherwise the gain is qualitative and the report states that validation needs a
before/after measure.

Each action is prioritized P1 through P4 using the existing effort/impact grid,
names the responsible area when possible (content, frontend, CMS, marketing or
infrastructure), and specifies the verification to run after correction.

## Accessibility Guardrail

The runtime ecodesign report may identify observable component evidence, such
as an unlabeled carousel container, but must not claim RGAA compliance. It
refers such cases to a dedicated RGAA audit. It must never recommend removing a
consent mechanism solely to reduce page weight.

## Acceptance Criteria

- A page with initialized `Swiper` instances produces an RWEB_0010 finding
  with instance and slide counts when the fiche has been returned by the MCP.
- An image below the fold without `loading="lazy"` produces an RWEB_0051
  finding with source URL and viewport evidence when the fiche has been
  returned by the MCP.
- The auditor never treats a named resource as unused solely from its presence.
  When its business necessity cannot be established from runtime evidence, it
  appears only in `A verifier`.
- The report always includes Performance, Developpement web, Potential-gains
  summary, action plan and conclusion sections, even when their finding lists
  are empty.
- The report exposes coverage and limitations for every probe domain.
- The EcoIndex values remain derived only from the initial-load measurement.
- A page graded C through G cannot produce a near-empty report: each material
  EcoIndex contributor has a finding, a verification lead or an explicit
  measurement limitation, and every probe domain has a coverage status.
- No additional browser, external audit service or Lighthouse dependency is
  required.
