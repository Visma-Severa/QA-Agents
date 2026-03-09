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

## 3-Phase Workflow

```
User invokes @hb-setup
        |
        v
Phase 1: Collect — Interactive questions
        |  - Project identity (name, GitHub org, agent prefix)
        |  - JIRA configuration (ticket prefixes + repo mappings)
        |  - Repository inventory (name, category, tech, default branch)
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
Setup Complete — Next steps summary
```

---

## Phase 1 Details: Collect

Follow the question flow defined in `prompts/setup/setup-prompt.md`. Store all answers in a structured configuration object.

**Question groups:**
1. Project identity (3 questions)
2. JIRA configuration (variable — depends on number of prefixes)
3. Repository inventory (variable — per repo: name, category, technology, default branch)
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
| `setup/setup.sh` | GITHUB_ORG, REPOS array, workspace filename, brand text |
| `setup/setup.ps1` | Same as setup.sh (Windows equivalent) |
| `setup/update.sh` | Workspace filename, extension name |
| `setup/update.ps1` | Same as update.sh |
| `agents/vscode-chat-participants/*.md` | Agent prefix in headers, example ticket IDs, context file refs |
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

## Completion Summary

```
Project Setup Complete!

Configuration Applied:
- Project: [name]
- Agent prefix: @[prefix]-*
- Repositories: [count] ([core] core + [micro] microservice + [e2e] E2E)
- Ticket prefixes: [list]
- Domain context files: [count] created

Files Updated: [count]
Files Created: [count]
Leftover references: [count] (should be 0)

Skeleton files that need your data:
  ⚠ context/domain-[name].md — add business rules and regulations (manual)
  ⚠ context/[project]-repository-dependencies.md — run generation prompt
  ⚠ context/e2e-test-coverage-map.md — run generation prompt
  ⚠ context/historical-bugfix-patterns.md — run generation prompt (after 10+ hotfixes)

Next Steps:
1. Generate context files using the prompts in prompts/setup/:
   - prompts/setup/generate-repository-dependencies.md → scans repos, generates dependency map
   - prompts/setup/generate-e2e-coverage-map.md → scans test repos, generates coverage matrix
   - prompts/setup/generate-bugfix-patterns.md → analyzes hotfix history (run after 10+ hotfixes)
   Paste prompt content into AI chat or reference the file to run.
2. Fill in domain context files manually (context/domain-[name].md)
3. Rebuild the VS Code extension with your new agent prefix:
   cd .vscode-extension && npm install && npm run compile
   npx vsce package --allow-missing-repository
   code --install-extension [prefix]-qa-agents-1.0.0.vsix --force
3. Clone your repositories and set up the workspace:
   ./setup/setup.sh          (macOS/Linux)
   .\setup\setup.ps1         (Windows)
4. Open [workspace-file].code-workspace
5. Reload VS Code (F1 > 'Developer: Reload Window')
6. Test: @[prefix]-code-review [example-ticket]
```

---

## Failure Handling

| Failure | Action |
|---------|--------|
| User cancels during Phase 1 | Save partial answers, offer to resume later |
| File not found during Phase 2 | Skip file, report in summary with expected path |
| Leftover references found in Phase 3 | List all with file:line, recommend manual fix |
| Extension build fails after setup | Provide manual build commands in summary |

---

## Constraints

- Never delete user's existing context files — only create new ones
- Never modify files outside the QA Agents repository
- Always confirm before executing Phase 2 (show summary first)
- Preserve all generic prompt/template logic — only change project-specific references
- If a file has already been customized (no "HealthBridge" references), skip it and report as "already customized"
