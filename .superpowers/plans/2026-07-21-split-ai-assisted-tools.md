# AI-Assisted Tools Split Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `subagent-driven-development` (recommended) or `executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish two independent, single-purpose repositories from `ia-tools@v1.2.0`: `ai-assisted-sustainable-it` and `ai-assisted-a11y`.

**Architecture:** The current repository becomes the Sustainable IT repository after removing the RGAA surface and changing its package and plugin metadata to `2.0.0`. A fresh Git repository is assembled from the RGAA surface of `v1.2.0`, with one-plugin manifests and rewritten documentation, then published as `hrenaud/ai-assisted-a11y` at `1.0.0`.

**Tech Stack:** Git, GitHub CLI, Bash test scripts, JSON manifests, Markdown documentation.

## Global Constraints

- Preserve `ia-tools@v1.2.0`; do not move or alter its tag or release.
- Do not change `/ecocode` or `/rgaa` command names.
- Source repository name: `ai-assisted-sustainable-it`; new repository name: `ai-assisted-a11y`.
- `ai-assisted-a11y` is a new repository with one migration commit and no monorepo history.
- Source repository is version `2.0.0`; new accessibility repository starts at `1.0.0`.
- All user-facing Markdown installation URLs use `https://github.com/hrenaud/<repository>.git`.
- Never use the `rm` command; use `trash` for accidental local files only.

---

### Task 1: Convert the existing repository to Sustainable IT only

**Files:**
- Modify: `README.md`, `CLAUDE.md`, `GEMINI.md`, `CHANGELOG.md`, `docs/*.md`, `package.json`, `gemini-extension.json`, `.version-bump.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/marketplace.json`, `tests/structure/test-multi-tool-structure.sh`, `tests/structure/test-release-metadata.sh`
- Delete from Git: `skills/rgaa/`, `agents/rgaa-*.md`, `commands/rgaa.md`, `.opencode/{agents,commands,plugins}/rgaa*`, `.claude-plugin/plugins/rgaa/`, `.codex-plugin/plugins/rgaa/`, `.cursor-plugin/plugins/rgaa/`
- Create: `tests/structure/test-sustainable-it-structure.sh`

**Interfaces:**
- Consumes: the `ecocode` skill and its existing manifests.
- Produces: a single-plugin repository whose test asserts no RGAA runtime files or configuration remain.

- [ ] **Step 1: Write the failing structure test**

Create `tests/structure/test-sustainable-it-structure.sh` with checks for one plugin in each marketplace, `ecocode` files present, RGAA runtime paths absent, package name `ai-assisted-sustainable-it`, and version `2.0.0` in all declared manifests.

- [ ] **Step 2: Run the test to verify it fails**

Run: `bash tests/structure/test-sustainable-it-structure.sh`

Expected: FAIL because the repository still contains RGAA and is named `ia-tools` at `1.2.0`.

- [ ] **Step 3: Implement the single-purpose repository**

Remove the RGAA runtime files with Git-aware deletion. Reduce all plugin marketplaces to the Ecocode entry. Rename the package and all installation/documentation references to `ai-assisted-sustainable-it`, set declared manifests to `2.0.0`, update the release-metadata test to assert `2.0.0`, and write a breaking-change entry in `CHANGELOG.md` that points to `ai-assisted-a11y` for accessibility.

- [ ] **Step 4: Run source-repository verification**

Run:

```bash
bash tests/structure/test-sustainable-it-structure.sh
bash tests/structure/test-release-metadata.sh
./scripts/bump-version.sh --audit
git diff --check
```

Expected: all commands exit 0 and the audit has no undeclared version occurrence.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: split sustainable IT tooling"
```

### Task 2: Assemble and verify the new accessibility repository

**Files:**
- Create repository: `/Users/renaudheluin/DEV/ia/ai-assisted-a11y`
- Copy from `v1.2.0`: `skills/rgaa/`, `agents/rgaa-*.md`, `commands/rgaa.md`, matching `.opencode/` files, matching Claude/Codex/Cursor plugin manifests, licensing and RGAA test helpers.
- Create: one-plugin marketplace files, `package.json`, `.version-bump.json`, `CHANGELOG.md`, `README.md`, `docs/releasing.md`, `tests/structure/test-a11y-structure.sh`.

**Interfaces:**
- Consumes: RGAA source files exactly as published in `v1.2.0`.
- Produces: a fresh Git repository named `ai-assisted-a11y`, versioned `1.0.0`, ready for GitHub publication.

- [ ] **Step 1: Write the failing repository structure test**

Create `tests/structure/test-a11y-structure.sh` before creating the corresponding manifests. It must require exactly one RGAA plugin in Claude and Codex marketplaces, RGAA skill/agents/command presence, Ecocode runtime path absence, package name `ai-assisted-a11y`, and version `1.0.0`.

- [ ] **Step 2: Run the test to verify it fails**

Run: `bash tests/structure/test-a11y-structure.sh`

Expected: FAIL because the new repository files have not been assembled.

- [ ] **Step 3: Create the new repository from the release snapshot**

Create `/Users/renaudheluin/DEV/ia/ai-assisted-a11y`, initialize Git, and copy only the RGAA source surface from `v1.2.0`. Create minimal manifests, version tooling and documentation. The README must state that the project assists RGAA accessibility work with AI and that it originated from `ia-tools@v1.2.0`.

- [ ] **Step 4: Run new-repository verification**

Run:

```bash
cd /Users/renaudheluin/DEV/ia/ai-assisted-a11y
bash tests/structure/test-a11y-structure.sh
./scripts/bump-version.sh --check
git diff --check
```

Expected: all commands exit 0.

- [ ] **Step 5: Commit and publish the new repository**

```bash
git add -A
git commit -m "feat: initialize AI-assisted accessibility tooling"
gh repo create hrenaud/ai-assisted-a11y --public --source=. --remote=origin --push
```

### Task 3: Publish the source split and rename the existing repository

**Files:**
- Modify remotely: GitHub repository `hrenaud/ia-tools`.
- Modify locally: remote URL in the worktree after the GitHub rename.

**Interfaces:**
- Consumes: the verified source branch from Task 1 and published `hrenaud/ai-assisted-a11y` from Task 2.
- Produces: published `hrenaud/ai-assisted-sustainable-it` with `ai-assisted-a11y` linked from its migration documentation.

- [ ] **Step 1: Push the source branch**

Run:

```bash
git push -u origin codex/chore/split-ai-assisted-tools
```

- [ ] **Step 2: Create a draft pull request for the breaking split**

Run:

```bash
gh pr create --draft --base main --head codex/chore/split-ai-assisted-tools \
  --title "feat: split sustainable IT tooling" \
  --body "## Summary\n\nSplit the released monorepo into dedicated Sustainable IT and accessibility repositories.\n\n## Notable Decisions\n\nThe accessibility repository starts fresh from ia-tools@v1.2.0; the source repository becomes Sustainable IT only."
```

- [ ] **Step 3: Pause for merge approval**

Do not merge the pull request, rename the existing GitHub repository, or rewrite its remote URL until the user explicitly approves the draft pull request.
