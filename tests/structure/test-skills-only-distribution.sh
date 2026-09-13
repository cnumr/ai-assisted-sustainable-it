#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for path in \
  skills/ecodesign/SKILL.md \
  skills/ecocode/SKILL.md \
  skills/audit-ecoconception/SKILL.md \
  skills/audit-ecoconception/references/static-analysis.md \
  skills/audit-ecoconception/references/runtime-analysis.md \
  skills/audit-ecoconception/references/ecoindex-measurement.md \
  skills/audit-ecoconception/references/findings-contract.md \
  skills/audit-ecoconception/references/restitution.md; do
  test -f "$root/$path"
done

for path in skills/design skills/development; do
  ! test -e "$root/$path"
done

for path in \
  agents \
  commands \
  hooks \
  .claude-plugin \
  .codex-plugin \
  .cursor-plugin \
  .codex \
  .opencode \
  gemini-extension.json; do
  ! test -e "$root/$path"
done

grep -Fq 'npx skills@latest add cnumr/ai-assisted-sustainable-it' "$root/README.md"
grep -Fq 'skills/ecodesign' "$root/README.md"
grep -Fq 'skills/ecocode' "$root/README.md"
grep -Fq 'skills/audit-ecoconception' "$root/README.md"
grep -Fq 'audit-ecoconception code back' "$root/README.md"
grep -Fq 'audit-ecoconception navigateur' "$root/README.md"
grep -Fq 'mcp-greenit' "$root/README.md"
grep -Fq 'playwright' "$root/README.md"
! grep -Fq '/plugin install' "$root/README.md"

for path in README.md AGENTS.md CLAUDE.md; do
  grep -Fqx -- '- MCP `playwright` : requis pour les audits fonctionnels et runtime dans le navigateur.' "$root/$path"
done

grep -Fq 'name: ecodesign' "$root/skills/ecodesign/SKILL.md"
grep -Fq 'name: ecocode' "$root/skills/ecocode/SKILL.md"
grep -Fq 'name: audit-ecoconception' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'code front' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'code back' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'navigateur' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'mcp-greenit' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'sous-agents' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'retourne exclusivement le contrat de constats' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'greenit_obtenir_methodologie_ecoindex' "$root/skills/audit-ecoconception/references/ecoindex-measurement.md"
! grep -Eiq 'eco-index-\*|Lighthouse|plugin' "$root/skills/audit-ecoconception/references/runtime-analysis.md"
grep -Fq "brouillon d'issue" "$root/skills/audit-ecoconception/references/restitution.md"
grep -Fq 'demande explicite' "$root/skills/audit-ecoconception/references/restitution.md"

test -f "$root/skills/audit-ecoconception/references/functional-analysis.md"

grep -Fq 'fonctionnel' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'analyse fonctionnelle' "$root/skills/audit-ecoconception/SKILL.md"
runtime_routing_lines="$(grep -F 'references/runtime-analysis.md' "$root/skills/audit-ecoconception/SKILL.md")"
grep -Fq 'navigateur' <<<"$runtime_routing_lines"
if grep -Fq 'fonctionnel' <<<"$runtime_routing_lines"; then
  exit 1
fi
grep -Fq 'constats_fonctionnels' "$root/skills/audit-ecoconception/references/findings-contract.md"
grep -Fq 'constats_ecocode' "$root/skills/audit-ecoconception/references/findings-contract.md"
grep -Fqx -- 'metier non prouvee devient une entree `a_verifier`, accompagnee des donnees a recueillir.' "$root/skills/audit-ecoconception/references/functional-analysis.md"
grep -Fq -- 'a_verifier: [hypothèse avec les preuves ou données nécessaires]' "$root/skills/audit-ecoconception/references/findings-contract.md"
grep -Fq -- 'Interroger `mcp-greenit` pour les fiches produit et conception pertinentes.' "$root/skills/audit-ecoconception/references/functional-analysis.md"
grep -Fq -- 'Citer une fiche RWEB seulement lorsqu' "$root/skills/audit-ecoconception/references/functional-analysis.md"
grep -Fq -- 'sans inventer de fiche.' "$root/skills/audit-ecoconception/references/functional-analysis.md"
grep -Fq -- 'Ne jamais inventer un identifiant RWEB.' "$root/skills/audit-ecoconception/references/findings-contract.md"
grep -Fq -- 'priorites_combinees`, qui ordonne les actions et explique chaque dépendance' "$root/skills/audit-ecoconception/references/restitution.md"
grep -Fq -- 'entre une décision produit et un changement d'"'"'implémentation' "$root/skills/audit-ecoconception/references/restitution.md"
grep -Fq 'audit-ecoconception fonctionnel' "$root/README.md"
grep -Fq 'audit-ecoconception fonctionnel' "$root/AGENTS.md"
grep -Fq 'audit-ecoconception fonctionnel' "$root/CLAUDE.md"
grep -Fq '`ecodesign` et `ecocode` restent proactifs' "$root/README.md"
grep -Fq '`ecodesign` et `ecocode` restent proactifs' "$root/AGENTS.md"
grep -Fq '`ecodesign` et `ecocode` restent proactifs' "$root/CLAUDE.md"
grep -Fq "\`audit-ecoconception\` audite l'eco-conception fonctionnelle et l'ecocode." "$root/README.md"
grep -Fq "\`audit-ecoconception\` audite l'eco-conception fonctionnelle et l'ecocode." "$root/AGENTS.md"
grep -Fq "\`audit-ecoconception\` audite l'eco-conception fonctionnelle et l'ecocode." "$root/CLAUDE.md"
