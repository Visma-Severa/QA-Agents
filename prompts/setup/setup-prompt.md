# Project Setup — Interactive Flow

Analysis logic for the Setup Agent. For orchestration, see `agents/vscode-chat-participants/setup.md`.

---

## Context

This framework provides 7 QA AI agents designed for multi-repository projects. All project-specific references (repository names, ticket prefixes, agent identifiers, domain knowledge) must be replaced before the agents can work with a new project.

The framework is ~70% generic (prompts, templates, scoring models, analysis logic) and ~30% project-specific (names, prefixes, repos, domains). This setup flow collects the project-specific 30% and applies it systematically.

---

## Phase 1: Interactive Questions

Ask questions one group at a time. After each group, summarize what was collected before moving to the next.

### Group 1: Project Identity

```
Welcome to QA Agents Setup!

I'll help you adapt this framework to your project.
This takes about 5 minutes — I'll ask a few questions,
then update all configuration files automatically.

Let's start with the basics.
```

**Q1.1** — Project name
```
What is your project name?
This will be used in file names, extension title, and documentation.
Example: "Acme Platform", "Falcon ERP", "MediTrack"
```

**Q1.2** — Agent chat prefix
```
What prefix do you want for VS Code chat agents?
Keep it short (2-4 chars). This creates agents like @<prefix>-code-review.
Example: "acme", "fal", "mt"
```

### Group 2: Repositories

**CRITICAL RULES FOR THIS GROUP:**
- **DO NOT ask the user about technology stack** — you will auto-detect it after cloning
- **DO NOT ask the user about default branch** — you will auto-detect it after cloning
- **DO NOT ask the user about release/hotfix branch conventions** — you will auto-detect from git history
- **ONLY ask for clone URLs and categories** — then CLONE, then AUTO-DETECT everything else

**Q2.1** — Repository clone URLs
```
List your repository clone URLs (HTTPS or SSH).
One per line, empty line when done.

Example:
  https://github.com/acme-corp/acme-backend.git
  git@github.com:acme-corp/acme-frontend.git
  https://github.com/acme-corp/acme-e2e-tests.git
```

**Q2.2** — Categorize repositories
```
For each repo, which category?
  - Core (main product repos)
  - Microservice (API services)
  - E2E (test automation)
```

**Q2.3** — IMMEDIATELY clone and auto-detect

**STOP asking questions. Clone ALL repositories NOW before continuing to Group 3.**

```
Cloning your repositories now...
```

Execute these steps — do NOT skip any:

**Step A: Clone each repo**
```bash
git clone <url> <workspace-root>/<repo-name>
```
If a repo already exists locally, skip cloning but still run detection.

**Step B: Auto-detect technology** (scan project files in the cloned repo)
| File Found | Technology |
|------------|-----------|
| `.csproj` or `.sln` | C# / .NET Core |
| `package.json` with `react` | TypeScript / React |
| `package.json` with `playwright` or `cypress` | TypeScript / Test Automation |
| `pubspec.yaml` | Flutter / Dart |
| `requirements.txt` or `pyproject.toml` | Python |
| `pom.xml` or `build.gradle` | Java / Spring |

**Step C: Auto-detect default branch**
```bash
git -C <repo-path> remote show origin | grep "HEAD branch"
```

**Step D: Auto-detect branch conventions**
```bash
git -C <repo-path> branch -r --list "*release*"
git -C <repo-path> branch -r --list "*hotfix*" "*bugfix*" "*fix*"
```

**Step E: Present ALL findings for confirmation**
```
Cloned and detected:

  acme-backend:    C# / .NET Core     main     [Core]
  acme-frontend:   TypeScript / React  main     [Core]
  acme-e2e-tests:  TypeScript          main     [E2E]

Release branch convention: release/v*  (found: release/v2.0.0, release/v2.1.0)
Hotfix branch convention:  hotfix/*    (found: hotfix/ACM-1234, hotfix/ACM-1567)

Is this correct? (yes / edit)
```

- If auto-detection fails for a repo, ask the user for that repo only
- If no release/hotfix branches found, ask the user for the convention
- The repo name is extracted from the clone URL (e.g., `acme-backend` from `https://github.com/acme-corp/acme-backend.git`)

### Group 3: JIRA Configuration

**Q3.1** — Ticket prefixes
```
What JIRA ticket prefixes does your project use?
Enter each prefix on a separate line (without the dash).
Empty line when done.

Example:
  ACME
  ACMP
```

**Q3.2** — For each prefix, ask:
```
Which repositories use the prefix "<PREFIX>-*"?
(comma-separated)
```

### Group 4: E2E Test Frameworks

**Q4.1** — Frameworks used
```
What E2E test frameworks do you use?
Comma-separated. Example: "Playwright, Selenium, Cypress, Appium"
Type "none" if no E2E tests yet.
```

**Q4.2** — For each framework, ask:
```
Which repository contains <framework> tests?
```

### Group 5: Business Domains

**Q5.1** — Functional domains
```
What are your main business/functional domains?
These become domain context files with regulatory rules and business logic
that help agents understand your product area.

One per line, empty line when done.
Example:
  Payments & Billing
  User Management
  Inventory
  Order Processing
```

### Group 6: Development Context Docs (Optional)

**Q6.1** — Architectural docs
```
Do any of your repositories have architectural or development guideline
docs that QA agents should reference during analysis?

If yes, provide the path pattern (e.g., "Acme-Backend/docs/AGENTS-*.md").
If no, type "none" — agents will work without them.
```

---

## Phase 1 Summary

After all questions, present a summary:

```
──── Configuration Summary ────

Project:        <name>
Agent Prefix:   @<prefix>-*
Workspace File: <name>.code-workspace

Repositories (<count> total, already cloned):
  Core:          <name> — <tech> — <default-branch>
  Microservices: <name> — <tech> — <default-branch>
  E2E Tests:     <name> — <tech> — <default-branch>

Release Branch:  <detected-pattern or user-provided or "none">
Hotfix Branch:   <detected-pattern or user-provided or "default">

Ticket Prefixes:
  <PREFIX-1>-* → <repo1>, <repo2>
  <PREFIX-2>-* → <repo3>

E2E Frameworks:
  <framework1> → <repo>
  <framework2> → <repo>

Business Domains: <list>

Dev Context Docs: <path or "none">

────────────────────────────────

Shall I proceed with updating all files? (yes / no / edit)
```

If user says "edit", ask which group to revisit. If "no", save answers and exit gracefully. If "yes", proceed to Phase 2.

---

## Phase 2: File Update Logic

### Update Strategy

For each file, use find-and-replace with the collected configuration. The replacements are systematic:

### 2.1 Global Find-and-Replace Pairs

Build these replacement pairs from the collected answers:

| Find | Replace With | Scope |
|------|-------------|-------|
| `HealthBridge` | `<project-name>` | All files including agents, prompts, and templates (case-sensitive) |
| `healthbridge` | `<project-name-lowercase>` | URLs, extension IDs |
| `@hb-` | `@<prefix>-` | All files: agent definitions, package.json, extension.ts, prompts, setup scripts, bootstrap scripts |
| `@hb ` (without dash) | `@<prefix> ` | Setup scripts, README (e.g., "type @hb in Copilot Chat") |
| `hb-qa-agents` | `<prefix>-qa-agents` | All files: package.json, extension.ts, commands, setup scripts, bootstrap scripts |
| `hb-qa-` | `<prefix>-` | Chat participant IDs |
| `HM-14200` | `<first-prefix>-1001` | Example ticket IDs (all files) |
| `HBP-5001` | `<second-prefix>-2001` (if exists) | Example ticket IDs (all files) |
| `HMM-3200` | `<third-prefix>-3001` (if exists) | Example ticket IDs (all files) |
| `HealthBridge.code-workspace` | `<project-name>.code-workspace` | Setup scripts, README |
| `release/Release-04/2026` | `<release-branch-pattern-example>` | README, CLAUDE.md, release agent, prompts |
| `hotfix/` (branch convention) | `<hotfix-branch-pattern>` | CLAUDE.md, bugfix-rca agent, generate-bugfix-patterns prompt |
| `3 frameworks` | `<N> framework(s)` where N = count from Q4.1 | README.md, CHANGELOG.md, context/e2e-test-coverage-map.md |
| `all 3 frameworks` | `all <N> frameworks` or `the <framework-name> framework` (if N=1) | README.md, CHANGELOG.md |
| `Selenium, Playwright, Mobile` | Comma-separated list of actual framework names from Q4.1 | README.md, CHANGELOG.md, CLAUDE.md, .cursorrules, .github/copilot-instructions.md, prompts, agents |
| `Selenium/Playwright/Mobile` | Slash-separated list of actual framework names from Q4.1 | Prompts, templates, context files |
| `Selenium (Python)`, `Playwright (TypeScript)`, `Mobile (WebdriverIO)` | Actual framework names with their technologies from Q4.2 | context/e2e-test-coverage-map.md |
| `4-row format (Selenium UI + Selenium Integration + Playwright + Mobile)` | Rebuild with actual frameworks from Q4.1 | context/e2e-test-coverage-map.md |
| `Selenium UI / Selenium Integration / Playwright / Mobile` | Rebuild coverage table rows with actual frameworks from Q4.1 | All template files with E2E coverage tables |
| `3 test automation frameworks (Selenium, Playwright E2E, Mobile)` | `<N> test automation framework(s) (<comma-separated list>)` | CHANGELOG.md |

**Note on E2E framework references:** The DEMO template hardcodes "3 frameworks" and "Selenium/Playwright/Mobile" throughout. When a project has fewer (or more) E2E frameworks, ALL these references must be dynamically replaced with the actual count and names. Search for `3 framework`, `Selenium`, `Playwright`, and `Mobile` across all files to catch every occurrence.

### 2.2 Structured Updates (Not Simple Find-Replace)

These require rebuilding sections, not just string replacement:

**`.claude/CLAUDE.md` — Multi-Repository Workspace table:**
Replace the entire table with repos from Phase 1:
```markdown
| Branch Prefix | Repository | Technology | Base Branch |
|---------------|------------|------------|-------------|
| `<PREFIX-1>-*` | `<repo-1>` | <tech-1> | `<branch-1>` |
...
```

**`.claude/CLAUDE.md` — JIRA Ticket ID section:**
Replace prefix table and examples with collected data.

**`setup/setup.sh` and `setup/setup.ps1` — REPOS associative array:**
Replace the array with collected repositories using clone URLs:
```bash
# Associative array: repo-name=clone-url
REPOS=(
    # Core application repositories
    "repo-1=https://github.com/org/repo-1.git"
    "repo-2=git@github.com:org/repo-2.git"
    # Microservice API repositories
    "repo-3=https://github.com/other-org/repo-3.git"
    # Test automation repositories
    "repo-4=https://github.com/org/repo-4.git"
)
```
This allows repos from different GitHub organizations to be cloned in one setup.

**`.code-workspace` file:**
Rename file and replace folder entries.

**`.vscode-extension/package.json` — chatParticipants array:**
Rebuild with new prefix and correct agent IDs.

**`.vscode-extension/src/extension.ts`:**
- Update `AGENTS` array IDs and prompt file names
- Update `findRepoRoot()` to check for one of the new core repo names
- Update activation message

**`.claude/CLAUDE.md`, `.github/copilot-instructions.md`, `.cursorrules` — Development Context Section:**

These three instruction files share an identical "Development Context for QA Agents" section that contains healthcare-specific architecture patterns. This section requires **conditional structured updates** based on Q6.1:

**If Q6.1 = "none" (no dev context docs):**
Remove these sections entirely from all three files:
- "HealthBridge-Web Development Context for QA Agents" header and intro paragraph
- "Agent-to-Document Mapping" table
- "How to Read" code block
- "When to read" paragraph
- "Key Knowledge per Document" table

**If Q6.1 = path provided (e.g., "Severa-BackEnd/docs/AGENTS-*.md"):**

1. **Section header** — Replace `HealthBridge-Web` with the repo name from Q6.1 path:
   ```
   ## <repo-name> Development Context for QA Agents
   ```

2. **Intro paragraph** — Replace `HM-*` with appropriate prefix, `HealthBridge-Web` with repo name, and `HealthBridge-Web/docs/` with actual path from Q6.1.

3. **Agent-to-Document Mapping table** — Scan the actual doc path for existing `AGENTS-*.md` files. Rebuild the table with only files that exist. Remove rows for non-existent docs.

4. **"How to Read" path** — Replace with actual path from Q6.1:
   ```
   Read: <repo-name>/docs/AGENTS-<name>.md
   ```

5. **"When to read" paragraph** — Replace prefix references with collected prefixes.

6. **"Key Knowledge per Document" table** — This is the most critical update. The DEMO table contains healthcare-specific class names and patterns:

   | DEMO Pattern | What to Do |
   |-------------|------------|
   | `HBException hierarchy` | Read the actual `AGENTS-errorhandling.md` and extract the real exception class names |
   | `HBForm/HBModal` | Read the actual `AGENTS-frontend.md` and extract real UI component names |
   | `HealthBridge JS library` | Replace with actual frontend library/framework name |
   | `TenantID filtering` | Read `AGENTS-development-guidelines.md` and extract the real multi-tenancy term |
   | `Accessor (CRUD) vs Report (read-only)` | Read `AGENTS-datalayer.md` and extract the real data access pattern names |
   | `Validator class, ValidatorField types` | Read `AGENTS-validation.md` and extract real validation class names |
   | `API integration patterns, data node interfaces` | Read `AGENTS-api.md` and extract real API pattern names |
   | `BackgroundServiceInitializer` | Read `AGENTS-backgroundservices.md` and extract real background service class |

   **Strategy:** For each existing `AGENTS-*.md` file found in Q6.1 path:
   1. Read the file (first 100 lines or summary section)
   2. Extract key class names, patterns, and concepts
   3. Write a one-line summary for the "Key Knowledge" column
   4. If a file doesn't exist, remove its row from the table

**`prompts/` — All prompt and template files:**

The global find-and-replace (Section 2.1) handles most references automatically. Additionally, these files need structured updates:

| File | Structured Changes |
|------|-------------------|
| `prompts/bug-report/bug-report-prompt.md` | Rebuild repo detection table with repos from Phase 1. Replace healthcare severity examples (patient safety, clinical workflow, prescription dosage) with project-relevant examples. Replace healthcare JIRA component paths (`*/prescriptions/*`, `*/patients/*`) with project paths. Replace healthcare area labels with project domains |
| `prompts/bug-report/bug-report-template.md` | Rebuild E2E coverage table with frameworks and repos from Phase 1 |
| `prompts/bug-report/severity-criteria.md` | **Heavy healthcare content.** Replace all healthcare-specific examples throughout: "patient safety" → project-relevant safety concern, "prescription processing" → core business process, "clinical workflow" → domain workflow, "HIPAA" → applicable regulations. Replace user personas (physicians, nurses, patients) with project personas. Replace example scenarios (prescription dosage, lab results, patient records) with project scenarios |
| `prompts/code-review-qa/code-review-template.md` | Update E2E repo paths to match Phase 1 test repos. Replace "Patient Safety Impact" row with project-relevant impact category. Replace "clinical logic" references with project domain terms |
| `prompts/code-review-qa/code-review-qa.md` | Update project description and technology stack. Replace "patient safety" and "clinical" references with project-relevant terms |
| `prompts/code-review-qa/findings-detailed-template.md` | Replace healthcare example scenarios ("Patient with no allergy records", "self-pay patients", "prescription") with project-relevant examples |
| `prompts/dev-estimation/dev-estimation-template.md` | Rebuild per-repo sections (2.1, 2.2, etc.) using repos from Phase 1 with their technologies |
| `prompts/release-assessment/release-assessment-template.md` | Rebuild E2E test sections with framework names and repos from Phase 1 |
| `prompts/release-assessment/release-assessment-prompt.md` | Replace project description ("health management platform", "patient data accuracy", "clinical safety"). Replace healthcare risk categories ("patient-facing features", "patient safety"). Replace priority definitions ("clinical calculations", "core clinical logic") with project-relevant terms |
| `prompts/release-assessment/release-notes-prompt.md` | Replace healthcare category mapping table (Prescription/Patient/Chart keywords) with project domain categories. Replace "patient-safety items" with project-relevant priority term |
| `prompts/requirements-analysis/requirements-analysis-template.md` | Rebuild cross-repo impact table with repos from Phase 1. Replace "healthcare regulations" in Domain Compliance criteria with project-relevant compliance. Replace "National e-Prescription Registry" integration example |
| `prompts/requirements-analysis/requirements-analysis.md` | Replace healthcare user personas (physicians, nurses, patients) with project personas. Replace "clinical limits/thresholds", "prescription validity", "patient data" examples with project-relevant examples. Replace healthcare edge case table (patient records, prescription expiry) and integration references (HL7/FHIR, EHR) |
| `prompts/setup/generate-bugfix-patterns.md` | Replace "patient query" example with project-relevant code pattern example |

**`agents/vscode-chat-participants/` — All agent definition files:**

The global find-and-replace handles project name, prefix, and ticket IDs. No additional structured updates needed beyond Section 2.1.

### 2.3 Context File Generation

**Domain context files** — For each domain from Q5.1:
1. Read `context/domain-context-template.md`
2. Replace `[Area Name]` with domain name
3. Replace trigger keywords placeholder with domain-relevant terms
4. Save as `context/domain-<slugified-name>.md`
5. Content sections remain as template placeholders — user fills in later

**Repository dependencies** — Create `context/<project-lowercase>-repository-dependencies.md`:
```markdown
# <Project> Repository Dependencies

| Provider | Consumer | Integration | Shared DB |
|----------|----------|-------------|-----------|
| <repo-1> | <repo-2> | [describe] | [yes/no] |
...
(Fill in actual dependencies)
```

**E2E coverage map** — Create/update `context/e2e-test-coverage-map.md`:
```markdown
# E2E Test Coverage Map

| Functional Area | <framework-1> | <framework-2> |
|-----------------|---------------|---------------|
| <domain-1>      | [ ]           | [ ]           |
| <domain-2>      | [ ]           | [ ]           |
...
(Mark with [x] as you add test coverage)
```

**Historical bugfix patterns** — Create `context/historical-bugfix-patterns.md`:
```markdown
# Historical Bugfix Patterns

Track your hotfix patterns here. After analyzing real bugfixes,
update percentages and detection focus per repository type.

## <tech-1> Repositories (<repo-list>)

| Pattern | % | Detection Focus |
|---------|---|-----------------|
| Edge Cases | ?% | [Add after analyzing real hotfixes] |
| NULL Handling | ?% | [Add after analyzing real hotfixes] |
| Logic Errors | ?% | [Add after analyzing real hotfixes] |
...
```

**JIRA field mappings** — Create `context/jira-field-mappings.md`:
```markdown
# JIRA Field Mappings

Auto-detect JIRA ticket components from file paths.

| File Path Pattern | JIRA Component |
|-------------------|---------------|
| <repo-1>/src/** | [Component name] |
| <repo-2>/src/** | [Component name] |
...
(Fill in as you learn your component structure)
```

### 2.4 Report Directory Creation

Create all report subdirectories:
```
reports/acceptance-tests/
reports/bug-report/
reports/bugfix-rca/
reports/code-review/
reports/feedback/
reports/release-analysis/
reports/requirements-analysis/
```

Add `.gitkeep` to each empty directory.

### 2.5 Cleanup DEMO Artifacts

After all file updates are complete, delete leftover files from the DEMO template that are no longer needed:

| Delete | Reason |
|--------|--------|
| `.vscode-extension/hb-qa-agents-*.vsix` | Old DEMO extension package — replaced by new `<prefix>-qa-agents-*.vsix` after rebuild |
| `.vscode-extension/node_modules/` | Will be regenerated by `npm install` during extension rebuild |
| `.vscode-extension/dist/` | Will be regenerated by `npm run compile` during extension rebuild |
| `.vscode-extension/package-lock.json` | Will be regenerated by `npm install` |
| `HealthBridge.code-workspace` | Old workspace file — already renamed to `<project>.code-workspace` |
| `context/domain-prescriptions.md` | DEMO healthcare domain file — replaced by project domains from Q5.1 |
| `context/domain-patient-records.md` | DEMO healthcare domain file — replaced by project domains from Q5.1 |
| `context/domain-staff-scheduling.md` | DEMO healthcare domain file — replaced by project domains from Q5.1 |
| `context/healthbridge-repository-dependencies.md` | DEMO dependencies file — replaced by `context/<project>-repository-dependencies.md` |

```bash
# Remove old VSIX files (any that don't match new prefix)
rm -f .vscode-extension/hb-qa-agents-*.vsix

# Remove build artifacts (will be regenerated)
rm -rf .vscode-extension/node_modules/ .vscode-extension/dist/
rm -f .vscode-extension/package-lock.json

# Remove old workspace file if it was renamed
# (only if new name differs from HealthBridge.code-workspace)
```

**Report:** "Cleaned up X DEMO artifacts"

### 2.6 Update README (Last)

**Update README.md as the final step** — after all other files are updated, context skeletons are created, and DEMO artifacts are cleaned up. The README reflects the final state of the project.

- Update project name throughout
- Rebuild repository tables with repos, technologies, and default branches from Phase 1
- Update setup command examples
- Update agent usage examples with new prefix and ticket IDs
- Update release branch convention examples with detected/collected pattern
- **Remove DEMO-only sections:**
  - Remove "This is a demo project" banner (top of file)
  - Remove "Adapt to Your Project" section and all subsections (Steps 1-7, What Gets Customized, What Stays Generic, Context Files guidance, Building Your Historical Bugfix Patterns)
  - Remove "Note" section ("This is a demo/reference implementation...")
  - Remove "Maintained by: HealthBridge QA Team" footer
  - Remove "Created by" link (or replace with user's team name if provided)

### 2.7 No-E2E Mode

**When Q4.1 answer is "none" (no E2E test frameworks), apply the following adjustments:**

#### 2.5.1 Context File: `context/e2e-test-coverage-map.md`

Generate a simplified version instead of the full framework-based coverage map:

```markdown
# E2E Test Coverage Map

**Status:** No E2E test automation is currently configured for this project.

## Functional Areas

Reference table for manual test planning. When E2E automation is added later, use this to track coverage.

| Functional Area | Manual Test Priority | Notes |
|-----------------|---------------------|-------|
| <domain-1> | High / Medium / Low | [Add notes] |
| <domain-2> | High / Medium / Low | [Add notes] |
...

## Adding E2E Automation Later

When you add E2E test automation:
1. Re-run setup (`@<prefix>-setup`) and provide framework details for Q4.1/Q4.2
2. Or manually update this file with framework columns and the CLAUDE.md E2E sections
3. Update report templates to use the framework-specific E2E coverage tables
```

#### 2.5.2 CLAUDE.md E2E Sections

Replace all framework-specific E2E instructions with no-E2E equivalents:

- **"E2E Framework Selection by Functional Area"** section — Replace with:
  ```
  **No E2E test automation repositories are configured for <project-name>.** E2E coverage analysis is not available.

  Report "N/A — No E2E automation configured" for all E2E coverage sections in every agent report.
  ```

- **"E2E Test Search Strategy"** section — Replace with:
  ```
  **No E2E test automation repositories are configured for <project-name>.** Skip all E2E search steps. Report "N/A — No E2E automation" in coverage tables.
  ```

- **"E2E Repository — Fetch Latest Before Coverage Analysis"** section — Replace with:
  ```
  **No E2E test automation repositories are configured.** Skip E2E fetch and coverage analysis steps. Report "N/A — No E2E automation configured" for all E2E coverage sections.
  ```

- Remove E2E test repositories from the **Multi-Repository Workspace** table (keep only application repos).

#### 2.5.3 Report Templates — E2E Coverage Tables

In ALL template files that contain the 4-row framework coverage table (Selenium UI / Selenium Integration / Playwright / Mobile), replace with a conditional block:

```markdown
**If E2E automation is configured:**
[4-row framework table populated from collected answers]

**If NO E2E automation (Q4.1 = "none"):**
> N/A — No E2E test automation configured for this project.
```

Affected template files:
- `prompts/code-review-qa/code-review-template.md` (Section 4.2)
- `prompts/bugfix-rca/bugfix-rca-e2e-template.md` (Section 2)
- `prompts/acceptance-tests/acceptance-tests-template.md` (E2E Coverage section)
- `prompts/bug-report/bug-report-template.md` (E2E section)

#### 2.5.4 Prompt Validation Checklists

In prompts that validate "Coverage table has 4 rows", add a conditional:
- If E2E configured: "Coverage table has N rows (one per framework)"
- If no E2E: "E2E section shows N/A note"

Affected:
- `prompts/bugfix-rca/bugfix-rca-prompt.md`
- `prompts/bug-report/bug-report-prompt.md`

#### 2.5.5 Acceptance Tests Prompt

In `prompts/acceptance-tests/acceptance-tests-prompt.md`, the "E2E Coverage Analyzer" sub-agent section should note: "If `context/e2e-test-coverage-map.md` indicates no E2E automation, skip the full scan and report 'N/A — No E2E automation configured' for all coverage sections."

---

## Phase 3: Verification Logic

### 3.1 Legacy Reference Scan (Automated)

Run the legacy reference scanner script to detect leftover DEMO/HealthBridge content:

```bash
chmod +x scripts/check-legacy-demo.sh
./scripts/check-legacy-demo.sh --fix-plan
```

The script checks 6 categories: project names, ticket prefixes, repository names, domain terms, DEMO template references, and E2E/mobile framework references (including hardcoded framework counts like "3 frameworks"). It also detects deleted files still referenced in active documentation.

**Interpret the output:**
- **0 hits** → Phase 3 passes, proceed to consistency checks (3.2)
- **>0 hits** → Auto-fix what you can (find-and-replace failures, stale references), then **re-run the script** to verify. Repeat until clean or only intentional references remain.

**Auto-fix strategy by category:**

| Category | Auto-Fix Action |
|----------|----------------|
| `PROJECT_NAME` | Re-run global find-and-replace from Section 2.1 on affected files |
| `TICKET_PREFIX` | Replace old prefixes with collected prefixes in affected files |
| `REPO_NAME` | Replace old repo names with collected repo names in affected files |
| `DOMAIN_TERM` | Replace healthcare examples with project-relevant examples (use domains from Q5.1) |
| `DEMO_REF` | Remove or rewrite DEMO-specific instructions in affected files |
| `E2E_LEGACY` | If no-E2E mode (Q4.1 = "none"): apply Section 2.7 to affected files. If E2E configured: replace DEMO framework names with collected framework names AND replace hardcoded counts ("3 frameworks", "4-row") with actual counts from Q4.1 |

**After auto-fix, re-run:**
```bash
./scripts/check-legacy-demo.sh
```

If hits remain that cannot be auto-fixed (e.g., in setup agent's own files), report them to the user with file:line references.

### 3.2 Consistency Validation

| Check | Method | Expected |
|-------|--------|----------|
| Agent prefix | Read all 7 agent .md files, extract `@<prefix>-` from header | All match collected prefix |
| Package.json IDs | Read chatParticipants array | All IDs start with collected prefix |
| Extension.ts IDs | Read AGENTS array | All IDs match package.json |
| Workspace folders | Parse .code-workspace JSON | Folder count = repo count |
| Setup script repos | Parse REPOS array in setup.sh | Same repos as workspace file |
| Context file refs | Read CLAUDE.md Shared Context table | All referenced files exist |

### 3.3 Skeleton File Report

List all context files that contain template placeholders:
```
Skeleton files created — Phase 4 will populate these with real data:
  → context/domain-<name>.md
  → context/<project>-repository-dependencies.md
  → context/historical-bugfix-patterns.md
  → context/jira-field-mappings.md
  → context/e2e-test-coverage-map.md

Proceeding to Phase 4: Context Customization...
```

---

## Phase 4: Context Customization

**This phase runs interactively after verification.** The agent guides the user through populating context files with real project data instead of leaving empty skeletons.

**Note:** Repositories were already cloned during Phase 1 (Q3.4). No additional cloning step is needed.

### 4.1 Repository Dependencies (Auto-Generated)

Execute `prompts/setup/generate-repository-dependencies.md`:

```
Scanning your repositories for API connections, shared databases,
and package dependencies...
```

- Scan all cloned repos for: HTTP client calls, DB connection strings, shared NuGet/npm packages
- Generate `context/<project>-repository-dependencies.md` with actual data
- Show summary and ask user to confirm or adjust

### 4.2 E2E Coverage Map (Auto-Generated)

**Skip if user answered "none" for E2E frameworks in Phase 1.**

Execute `prompts/setup/generate-e2e-coverage-map.md`:

```
Scanning your test repositories for E2E coverage by functional area...
```

- Scan test repos, group test files by functional area
- Generate `context/e2e-test-coverage-map.md` with actual coverage
- Show summary to user

### 4.3 Historical Bugfix Patterns (Conditional)

```
Do your repositories have hotfix history I can analyze?
This helps agents predict which code patterns are most likely to cause bugs.
I'll analyze up to 100 recent hotfixes for reliable category percentages.

  1. Yes, scan my repos now
  2. Skip — I'll run this later when we have more history
```

If 1: Execute `prompts/setup/generate-bugfix-patterns.md`
If 2: Leave skeleton, note in completion summary

### 4.4 JIRA Field Mappings (Guided)

```
Let me scan your repository structures to suggest JIRA component mappings.
These help agents auto-populate bug report fields from file paths.
```

- Scan repo directory structures (top-level folders, namespaces)
- Propose mappings: `<repo>/src/Payments/** → Payments component`
- Ask user to confirm or adjust each mapping
- Write `context/jira-field-mappings.md`

### 4.5 Domain Context Files (Interactive)

For each domain skeleton created in Phase 2, ask:

```
Let's fill in domain knowledge for: [Domain Name]

1. What are the main business rules for [domain]?
   (e.g., "prescription refills require doctor approval")

2. Are there regulatory or compliance requirements?
   (e.g., HIPAA, GDPR, SOX, industry-specific rules)

3. What are the common edge cases or tricky scenarios?
   (e.g., "leap year dates", "currency rounding", "timezone handling")

4. What external system integrations does this domain have?
   (e.g., "bank API for payments", "tax authority reporting")
```

- Write answers into `context/domain-<name>.md`
- If user says "skip", leave as skeleton

### 4.6 False Positive Prevention (Optional)

```
Do you have any known code patterns that look suspicious but are actually safe?
These prevent agents from flagging false issues during code review.

Examples:
  - "We use raw SQL in Reports/ — it's parameterized via our ORM wrapper"
  - "Empty catch blocks in BackgroundJobs/ are intentional — errors logged upstream"

Type your patterns (one per line), or "skip" to fill in later.
```

If provided: Update `context/code-review-false-positive-prevention.md`
If skipped: Leave existing default file

### 4.7 Final Validation (Automated)

Run the legacy reference scanner one final time to catch any leftovers introduced during Phase 4 (context generation can re-introduce domain terms or repo names from templates):

```bash
./scripts/check-legacy-demo.sh
```

**Interpret the output:**
- **0 hits** → Setup is fully clean. Proceed to completion summary.
- **>0 hits** → Fix remaining references. These are typically:
  - Domain terms in newly generated context files (replace healthcare examples with project domains)
  - DEMO template references copied into generated content
  - E2E framework names in generated coverage maps (if no-E2E mode)

After fixing, re-run until clean:
```bash
./scripts/check-legacy-demo.sh
```

**Report to user:**
```
Final validation: ✓ Clean — no legacy DEMO references found.

OR

Final validation: ⚠ X references remain in Y files.
These are [intentional/need manual review]:
  <file>:<line> — "<matched text>"
```

---

## What This Agent Does NOT Change

These aspects of files should be preserved — only project-specific references (names, repos, prefixes) are replaced, not the underlying logic:

| What to Preserve | Examples |
|-----------------|----------|
| Scoring models and thresholds | 7/10 requirements gate, severity criteria scales |
| Analysis methodology and checklists | Code review checklist items, RCA analysis steps |
| Report section structure and formatting | Section headers, markdown layout, collapsible sections |
| Template placeholder syntax | `{placeholder}`, `[X.X hours]`, `High/Medium/Low` |
| `context/domain-context-template.md` | Template for creating new domain files — not a project file |
| `prompts/setup/` | Setup agent's own files — excluded from find-and-replace |

---

## Re-Run Behavior

If the setup agent is run again on an already-customized project:
1. Detect that "HealthBridge" references are absent
2. Ask: "This project appears already customized for [detected name]. Do you want to reconfigure? This will overwrite current settings."
3. If yes, proceed with full flow
4. If no, offer to run only Phase 3 (verification) or Phase 4 (context customization) individually
