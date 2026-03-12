# Project Setup Agent

**Agent:** `@hb-setup`
**Purpose:** Interactive wizard that adapts the QA Agents framework to a new project. Collects project configuration through guided questions, then updates all files automatically.
**Output:** Updated configuration files across the entire repository.

---

## Prompt & Template References

| File | Role | Path |
|------|------|------|
| Setup flow | Prompt | `prompts/setup/setup-prompt.md` |
| Domain skeleton | Template | `context/domain-context-template.md` |

**Before starting setup:**
```
Read: prompts/setup/setup-prompt.md
Read: context/domain-context-template.md
```

---

## Target Audience

Developers or QA Engineers adopting this framework for their own multi-repository project. Users may not be familiar with the internal file structure.

---

## Prerequisites

**Before running the setup agent, the user must have:**

1. Cloned the DEMO project
2. Run `setup/bootstrap.sh` (or `.ps1` / `.bat`) to create a new project folder from the DEMO template
3. Built and installed the VS Code extension from `.vscode-extension/`
4. Opened the new project folder in their IDE

The bootstrap script copies all framework files into a fresh directory without modifying the DEMO template. The setup agent then customizes files in this new project in-place.

---

## Execution Protocol

**This agent is INTERACTIVE — it asks questions and waits for answers.**

Unlike other agents that execute immediately, this agent guides the user through a multi-step configuration wizard.

If invoked without input, begin the interactive flow immediately per `prompts/setup/setup-prompt.md`.

If invoked with a configuration file path (e.g., `@hb-setup config.json`), read the file and skip to Phase 2 (Generate).

---

## 4-Phase Workflow

```
User invokes @hb-setup
        |
        v
Phase 1: Collect — Interactive questions
        |  - Project identity (name, agent prefix)
        |  - Repositories (clone URLs → CLONE IMMEDIATELY → auto-detect tech, branches, conventions)
        |  - JIRA configuration (ticket prefixes + repo mappings)
        |  - E2E test frameworks and repo assignments
        |  - Business domains for context files
        |  - Development context docs (optional)
        |
        v
Phase 2: Generate — Automated file updates
        |  - Present summary of all changes for user confirmation
        |  - Update IDE config files (CLAUDE.md, .cursorrules, copilot-instructions.md)
        |  - Update VS Code extension (package.json, extension.ts)
        |  - Update setup scripts (setup.sh, setup.ps1, workspace file)
        |  - Update agent definition files (prefix + examples)
        |  - Update prompt and template files (project refs + repo-specific sections)
        |  - Create skeleton context files
        |  - Create report directories
        |
        v
Phase 3: Verify — Scan for inconsistencies
        |  - Search for leftover "HealthBridge" references
        |  - Validate all agent prefixes are consistent
        |  - Check workspace file matches setup scripts
        |  - Report skeleton files that need manual content
        |
        v
Phase 4: Context Customization — Interactive guided setup
        |  - Generate repository dependencies (auto-scan repos)
        |  - Generate E2E coverage map (auto-scan test repos)
        |  - Generate bugfix patterns (if enough hotfix history)
        |  - Fill JIRA field mappings (guided from repo structure)
        |  - Domain context files (guided with key questions)
        |
        v
Setup Complete — All context files populated
```

---

## Phase 1 Details: Collect

Follow the question flow defined in `prompts/setup/setup-prompt.md`. Store all answers in a structured configuration object.

**Question groups:**
1. Project identity (2 questions: name, agent prefix)
2. Repositories — collect clone URLs, categorize, **clone immediately**, auto-detect technology, default branch, release/hotfix branch conventions
3. JIRA configuration (ticket prefixes + repo mappings)
4. E2E test frameworks (variable — framework name + repo assignment)
5. Business domains (variable — domain names for skeleton context files)
6. Development context docs (optional — path pattern for architectural docs)

**After all questions answered:** Present a configuration summary table and ask for confirmation before proceeding.

---

## Phase 2 Details: Generate

### Files to Update

| File | Changes |
|------|---------|
| `.claude/CLAUDE.md` | Project name, ticket prefixes, repo table, agent prefix, context file refs, example tickets |
| `.cursorrules` | Same as CLAUDE.md (mirrors instructions) |
| `.github/copilot-instructions.md` | Same as CLAUDE.md (mirrors instructions) |
| `HealthBridge.code-workspace` | Rename file, update folder list |
| `.vscode-extension/package.json` | Extension name/publisher/description, chat participant IDs |
| `.vscode-extension/src/extension.ts` | Agent IDs, prompt file names, repo detection path |
| `setup/setup.sh` | REPOS array (name=clone-url entries), workspace filename, brand text |
| `setup/setup.ps1` | Same as setup.sh (Windows equivalent) |
| `setup/update.sh` | Workspace filename, extension name |
| `setup/update.ps1` | Same as update.sh |
| `agents/vscode-chat-participants/*.md` | Agent prefix in headers, example ticket IDs, context file refs |
| `prompts/**/*.md` | Project name, repo names, E2E repo paths, example tickets, project descriptions. Rebuild repo-specific tables and per-repo sections (e.g., dev-estimation per-repo breakdown) |
| `README.md` | Project name, repo tables, examples, setup instructions |

### Skeleton Context Files to Create

For each business domain provided in Phase 1:
- Create `context/domain-<name>.md` using `context/domain-context-template.md` as base
- Pre-fill: domain name, trigger keywords, section headers
- Leave content placeholders for manual completion

Additionally create starter versions of:
- `context/<project>-repository-dependencies.md` — with repo names from Phase 1, empty dependency matrix
- `context/historical-bugfix-patterns.md` — starter template with repo types from Phase 1
- `context/e2e-test-coverage-map.md` — with functional areas (from domains) and frameworks from Phase 1
- `context/jira-field-mappings.md` — with repo names from Phase 1, empty path mappings

### Report Directories to Create

```
reports/
├── acceptance-tests/
├── bug-report/
├── bugfix-rca/
├── code-review/
├── feedback/
├── release-analysis/
└── requirements-analysis/
```

### Cleanup DEMO Artifacts

Delete leftover files from the DEMO template:
- `.vscode-extension/hb-qa-agents-*.vsix` — old extension package
- `.vscode-extension/node_modules/`, `dist/`, `package-lock.json` — build artifacts (regenerated during extension rebuild)
- Old workspace file if renamed (e.g., `HealthBridge.code-workspace`)

---

## Phase 3 Details: Verify

### Leftover Reference Check

Search all updated files for these patterns (should return zero matches):
- `HealthBridge` (case-sensitive)
- `healthbridge` (case-insensitive, excluding this setup agent)
- `@hb-` (old agent prefix)
- `HM-14200`, `HBP-5001`, `HMM-3200` (old example tickets)

Report any leftover references with file:line for manual review.

### Consistency Checks

| Check | How |
|-------|-----|
| Agent prefix consistency | All 8 agent files + package.json + extension.ts use same prefix |
| Workspace file matches setup script | Folder list in .code-workspace = REPOS array in setup.sh |
| Ticket prefix coverage | Every prefix has at least one mapped repository |
| Context files exist | All referenced context files in CLAUDE.md exist on disk |

---

## Phase 4 Details: Context Customization

**This phase runs interactively after verification passes.** The agent guides the user through populating context files with real project data — not just skeletons.

**Note:** Repositories were already cloned during Phase 1 (Q3.4). No additional cloning step is needed.

### 4.1 Repository Dependencies (Auto-Generated)

```
Let me scan your repositories and generate the dependency map.
This identifies API connections, shared databases, and NuGet/npm packages
across your repos.
```

Execute `prompts/setup/generate-repository-dependencies.md` automatically:
- Scan all cloned repos for HTTP client calls, database connection strings, shared packages
- Generate `context/<project>-repository-dependencies.md` with actual data
- Show the user a summary of what was found and ask for confirmation

### 4.2 E2E Coverage Map (Auto-Generated)

**Skip if user answered "none" for E2E frameworks in Phase 1.**

```
Now let me scan your test repositories and map which functional areas
have E2E coverage.
```

Execute `prompts/setup/generate-e2e-coverage-map.md` automatically:
- Scan test repos for test files, group by functional area
- Generate `context/e2e-test-coverage-map.md` with actual coverage data
- Show summary to user

### 4.3 Historical Bugfix Patterns (Conditional)

```
Do your repositories have hotfix history I can analyze?
This helps agents predict which code patterns are most likely to cause bugs.

I need roughly 10+ hotfixes for meaningful patterns.
Options:
  1. Yes, scan my repos now
  2. Skip for now — I'll run this later when we have more history
```

If user chooses 1: Execute `prompts/setup/generate-bugfix-patterns.md`
If user chooses 2: Leave skeleton, note in summary

### 4.4 JIRA Field Mappings (Guided)

```
Let me scan your repository structures to suggest JIRA component mappings.
These help agents auto-populate bug report fields from file paths.
```

- Scan repo directory structures (top-level folders, namespaces)
- Propose mappings: `<repo>/src/Payments/** → Payments component`
- Ask user to confirm or adjust each mapping
- Generate `context/jira-field-mappings.md`

### 4.5 Domain Context Files (Interactive)

For each domain context file created in Phase 2:

```
Let's fill in the domain knowledge for: [Domain Name]
This helps agents understand your business rules and validation logic.

I'll ask a few key questions:

1. What are the main business rules for [domain]?
   (e.g., "prescription refills require doctor approval", "invoices auto-close after 30 days")

2. Are there regulatory or compliance requirements?
   (e.g., HIPAA, GDPR, SOX, industry-specific rules)

3. What are the common edge cases or tricky scenarios?
   (e.g., "leap year date calculations", "currency rounding", "timezone handling")

4. What integrations does this domain have with external systems?
   (e.g., "bank API for payments", "tax authority reporting")
```

For each domain:
- Ask the 4 questions above
- Write answers into the corresponding `context/domain-<name>.md` file
- If user says "skip" for a domain, leave as skeleton

### 4.6 False Positive Prevention (Optional)

```
Do you have any known code patterns that look suspicious but are actually
safe? These prevent agents from flagging false issues during code review.

Examples:
  - "We use raw SQL in Reports/ — it's parameterized via our ORM wrapper"
  - "Empty catch blocks in BackgroundJobs/ are intentional — errors are logged upstream"

Type your patterns (one per line), or "skip" to fill in later.
```

If provided: Update `context/code-review-false-positive-prevention.md`
If skipped: Leave existing file as-is

---

## Completion Summary

```
Setup Complete!

Configuration:
- Project: [name]
- Agent prefix: @[prefix]-*
- Repositories: [count] ([core] core + [micro] microservice + [e2e] E2E)
- Ticket prefixes: [list]

Files Updated: [count]
Files Created: [count]
Leftover references: [count] (should be 0)

Context Files:
  ✓ context/[project]-repository-dependencies.md — generated from repo scan
  ✓ context/e2e-test-coverage-map.md — generated from test repo scan
  ✓/⚠ context/historical-bugfix-patterns.md — [generated / skipped — not enough history]
  ✓ context/jira-field-mappings.md — generated from repo structure
  ✓/⚠ context/domain-[name].md — [populated / skeleton — needs manual content]
  ✓/– context/code-review-false-positive-prevention.md — [updated / kept as default]

Next Steps:
1. Rebuild the VS Code extension:
   cd .vscode-extension && npm install && npm run compile
   npx vsce package --allow-missing-repository
   code --install-extension [prefix]-qa-agents-1.0.0.vsix --force
2. Open [workspace-file].code-workspace
3. Reload VS Code (F1 > 'Developer: Reload Window')
4. Test: @[prefix]-code-review [example-ticket]
```

---

## Failure Handling

| Failure | Action |
|---------|--------|
| User cancels during Phase 1 | Save partial answers, offer to resume later |
| File not found during Phase 2 | Skip file, report in summary with expected path |
| Leftover references found in Phase 3 | List all with file:line, recommend manual fix |
| Extension build fails after setup | Provide manual build commands in summary |
| Repo clone fails in Q3.4 | Report error, ask user to check access, continue with remaining repos |
| Context generation finds no data | Create skeleton with note, recommend re-running later |

---

## Constraints

- Never delete user's existing context files — only create new ones
- Never modify files outside the QA Agents repository
- Always confirm before executing Phase 2 (show summary first)
- Preserve all generic prompt/template logic — only change project-specific references
- If a file has already been customized (no "HealthBridge" references), skip it and report as "already customized"
