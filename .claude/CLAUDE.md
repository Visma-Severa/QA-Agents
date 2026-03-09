# HealthBridge QA Agents — Global Instructions

This workspace contains multiple QA AI agents for the HealthBridge multi-repository health management platform.

---

## CRITICAL: Agent Execution Protocol

**When user provides a ticket ID or clear request, IMMEDIATELY execute — DO NOT stop to ask confirmations.**

### Execution Rules

1. **Auto-detect repositories**: When user provides "HM-14200", search ALL repos automatically. User may not know which repo contains the branch.
2. **No confirmation needed**: Start analysis immediately without "I'm ready to..." messages.
3. **Complete task delivery**: Agent is responsible for delivering final reports, not stopping mid-execution.
4. **Infer missing parameters**: Format, repo, base branch can be auto-detected or use defaults.

### Examples

| User Input | DON'T | DO |
|------------|-------|-----|
| `HM-14200` | "Which repo?" | Search all repos, find branch, analyze |
| `analyze HM-14200` | "I'm ready. Shall I proceed?" | Immediately fetch, analyze, report |
| `Release-7/2026` | "Which format?" | Use default (comprehensive), execute |

**Agent Responsibility = Complete Delivery** from input -> analysis -> final report(s)

### WARNING: Tool Execution Required

**You MUST use your IDE's tools to execute commands. Writing code blocks with fake output is NOT execution.**

This applies to ALL IDEs: Claude Code, Cursor, VS Code Copilot Chat, and any other AI-assisted IDE.

| FORBIDDEN | REQUIRED |
|-----------|----------|
| Writing ```bash blocks with made-up output | Executing real commands via your IDE's terminal/tools |
| Generating plausible-looking git hashes | Reading real commit hashes from actual command output |
| Fabricating file contents | Reading actual files via your IDE's file tools |

**If you write a code block that looks like terminal output without invoking a tool, you are hallucinating.**

---

## JIRA Ticket ID and Git Branch Naming Convention

**JIRA is used for task management and defect tracking.** Every development task, bug fix, and feature request is tracked as a JIRA ticket with a unique ID.

**The JIRA ticket ID MUST be used when creating Git branches.** This is the key mechanism that allows QA agents to automatically find the corresponding branch in any repository by searching for the ticket ID substring.

| Ticket Prefix | Example | Repository Scope |
|---------------|---------|-----------------|
| `HM-*` | `HM-14200-prescription-renewal` | HealthBridge-Web, HealthBridge-Api, Claims-Processing, Prescriptions-Api |
| `HBP-*` | `HBP-5001-portal-dashboard-fix` | HealthBridge-Portal |
| `HMM-*` | `HMM-3200-mobile-appointment-view` | HealthBridge-Mobile |

**Rules:**
- Branch name **must start with or contain** the JIRA ticket ID (e.g., `HM-14200`, `HM-14200-feature-name`, `feature/HM-14200`)
- Agents search for branches using `git branch -r --list "*<TICKET_ID>*"` — the ticket ID substring is sufficient
- One JIRA ticket = one branch per repository (a ticket may span multiple repos)
- Commit messages should also include the ticket ID for commit filtering

**How agents use this:**
```bash
# Agent receives ticket ID "HM-14200" from user
# Step 1: Search ALL repos for the branch
cd HealthBridge-Web && git fetch origin && git branch -r --list "*HM-14200*"
cd HealthBridge-Api && git fetch origin && git branch -r --list "*HM-14200*"
# ... repeat for all repos until branch is found
```

---

## Language & Communication Defaults

- **Default output language: ENGLISH** — Always generate reports, analyses, and documentation in English unless explicitly requested otherwise.
- If the user's input is in another language, still respond and generate documents in English.
- Only use another language when the user explicitly requests it.

---

## Cross-Platform & Cross-IDE Compatibility

**IMPORTANT:** These agents are used across multiple IDEs and operating systems:

- **IDEs:** Claude Code, Cursor, VS Code Copilot Chat
- **OS:** Windows, macOS, Linux

### IDE Tool Mapping

Each IDE provides equivalent capabilities. Use whatever your IDE offers:

| Task | Claude Code | Cursor / VS Code Copilot | Fallback |
|------|-------------|--------------------------|----------|
| Search file contents | `Grep` tool | Terminal: `git grep` | `git grep -n "pattern"` |
| Find files by pattern | `Glob` tool | Terminal: `git ls-files` | `git ls-files "*.cs"` |
| Read file contents | `Read` tool | Open file / Terminal: `git show` | `git show origin/branch:path` |
| Execute commands | `Bash` tool | Terminal panel | Terminal / Git Bash |

### Use Git Built-in Flags (Cross-Platform)

Prefer git's built-in flags over shell pipes — they work identically on all platforms:

| Instead of Unix Pipe | Use Git Flag |
|----------------------|--------------|
| `git log \| grep -i "TICKET"` | `git log --grep="TICKET"` |
| `git branch -r \| grep "pattern"` | `git branch -r --list "*pattern*"` |

### Shell Commands That Work Cross-Platform

These commands work on Windows (with Git Bash), macOS, and Linux:
- `git log`, `git diff`, `git show`, `git branch` (all git commands)
- `cd`, `ls` (basic navigation — Windows CMD uses `dir` instead of `ls`)

### Windows-Specific Notes

- Windows users should use **Git Bash** (installed with Git for Windows) for shell commands
- Claude Code's `Grep`, `Glob`, and `Read` tools work on ALL platforms without shell dependencies
- Cursor and VS Code Copilot terminal commands work via the IDE's integrated terminal

---

## CRITICAL: Never Disrupt Developer's Working Directory

**Agents must NEVER use `git checkout` or `git switch` for analysis purposes.**

This applies to ALL repositories in the workspace (application repos, microservice APIs, test automation repos).

Developers may be working on any branch in any repository with uncommitted changes. Analysis operations must be non-destructive.

### For Analysis: Use `git fetch` + Remote Tracking Branches

`git fetch` downloads latest commits from remote but does NOT change your working directory, current branch, or uncommitted changes.

```bash
# SAFE: Fetch latest and analyze using remote tracking branches
git fetch origin
git diff origin/main..origin/<feature-branch>       # Compare branches
git log origin/main..origin/<feature-branch>         # View commits
git show origin/<branch>:<file-path>                 # Read file from any branch
git grep "<pattern>" origin/main -- "*.cs"           # Search in remote main
```

```bash
# UNSAFE: Never do this for analysis
git checkout <branch-name>      # Disrupts developer
git switch <branch-name>        # Disrupts developer
git pull                        # May fail with uncommitted changes
```

### When Checkout IS Allowed

Only use `git checkout` when the user **explicitly requests** to switch branches for their own development work. In that case:

1. Check for uncommitted changes: `git status --short`
2. If changes exist, stash: `git stash push -u -m "Auto-stash before switching to <target-branch>"`
3. Then checkout: `git checkout <target-branch>`
4. Inform user about stash entry and how to restore: `git stash pop`

---

## Available QA Agents

These agents can be invoked by describing the task or using the Task tool with specialized prompts:

| Agent | Purpose | How to Invoke | Definition |
|-------|---------|---------------|------------|
| **Code Review** | Analyze PR/branch for code quality, test gaps, risks | "Review branch HM-xxxxx" | `agents/vscode-chat-participants/code-review.md` |
| **Acceptance Tests** | Generate Given/When/Then test scenarios | "Generate acceptance tests for HM-xxxxx" | `agents/vscode-chat-participants/acceptance-tests.md` |
| **Bug Report** | Analyze errors and generate ticket-ready bug reports | "Create bug report for [error]" | `agents/vscode-chat-participants/bug-report.md` |
| **Bugfix RCA** | Root cause analysis for hotfixes | "RCA for hotfix HM-xxxxx" | `agents/vscode-chat-participants/bugfix-rca.md` |
| **Requirements Analysis** | Pre-development requirements validation | "Analyze requirements for HM-xxxxx" | `agents/vscode-chat-participants/requirements-analysis.md` |
| **Release Analysis** | Analyze releases for risk and coverage | "Analyze Release-XX/YYYY" | `agents/vscode-chat-participants/release-analysis.md` |
| **Feedback** | Interactive developer feedback on code review findings | "Feedback on HM-xxxxx review" | `agents/vscode-chat-participants/feedback.md` |
| **Setup** | Interactive wizard to adapt framework to your project | "Setup QA agents for my project" | `agents/vscode-chat-participants/setup.md` |

### Predictive Code Analysis

The **Code Review Agent** includes **Predictive Bug Detection** — proactive analysis that scans code for patterns that historically cause production hotfixes. Pattern tables with percentages and detection focus are defined per-repository in `context/historical-bugfix-patterns.md`.

**Result:** Issues are flagged BEFORE merge, reducing hotfix rate.

### Interactive Developer Feedback (Default)

The **Code Review Agent** includes **interactive developer feedback** as part of the standard flow. After generating the report, the agent presents each finding to the developer with 4 options:
- **Valid** / **False Positive** / **Won't Fix** / **Provide More Information**

**"Provide More Information"** triggers deep analysis: the agent reads actual code, searches for sibling patterns, assesses probability and risk, and generates a detailed findings file (`<TICKET>-findings-detailed.md`) following `prompts/code-review-qa/findings-detailed-template.md`.

**This is always on.** To skip, use `--no-feedback`.

**Output:**
- Section 10 auto-populated with developer verdicts
- `reports/code-review/<TICKET>-findings-detailed.md` (if deep analysis requested)
- `reports/feedback/<TICKET>-feedback.json` (for accuracy tracking)

---

## Document Type Detection

Use these keywords to infer document type (ask if ambiguous):

| Keywords in Request | Likely Document Type | Action |
|---------------------|---------------------|--------|
| "bug", "issue", "error", "not working", "broken" | Bug Report | Generate bug report |
| "requirement", "task", "implement", "feature", "user story" | Requirements Analysis | Analyze requirements |
| "review", "PR", "branch", "code quality" | Code Review | Review code changes |
| "test", "acceptance", "scenario", "QA" | Acceptance Test Plan | Generate test scenarios |
| "hotfix", "RCA", "root cause", "why did this break" | Bugfix RCA | Root cause analysis |
| "release", "Release-", "deployment" | Release Analysis | Release risk assessment |

**When document type is ambiguous, ask:** "What type of document would you like? (Requirements Analysis / Bug Report / Code Review / Other)"

---

## Multi-Repository Workspace

Use the branch prefix to identify the correct repository:

| Branch Prefix | Repository | Technology | Base Branch |
|---------------|------------|------------|-------------|
| `HM-*` | `HealthBridge-Web` | C# / ASP.NET Core | `main` |
| `HM-*` | `HealthBridge-Api` | C# / .NET Core | `main` |
| `HM-*` | `HealthBridge-Claims-Processing` | C# / .NET Core | `main` |
| `HM-*` | `HealthBridge-Prescriptions-Api` | C# / .NET Core | `main` |
| `HBP-*` | `HealthBridge-Portal` | C# / .NET Core | `main` |
| `HMM-*` | `HealthBridge-Mobile` | Flutter / Dart | `main` |
| `-` | `HealthBridge-E2E-Tests` | TypeScript / Playwright | `main` |
| `-` | `HealthBridge-Selenium-Tests` | Python / Selenium | `main` |
| `-` | `HealthBridge-Mobile-Tests` | JavaScript / WebdriverIO | `main` |

---

## Shared Context Files

Before running any analysis, read these shared context files:

| Context File | Path | Purpose |
|--------------|------|---------|
| E2E Coverage Map | `context/e2e-test-coverage-map.md` | Which E2E frameworks cover which functional areas |
| JIRA Field Mappings | `context/jira-field-mappings.md` | Auto-detect JIRA components from file paths |
| False Positive Prevention | `context/code-review-false-positive-prevention.md` | Known safe patterns to avoid flagging as issues |
| Repository Dependencies | `context/healthbridge-repository-dependencies.md` | Consumer/Provider dependency map across all repos — blast radius, shared databases, API connections |
| Historical Bugfix Patterns | `context/historical-bugfix-patterns.md` | Canonical source for all 5 repo-specific bugfix pattern tables with percentages and detection focus |

---

## HealthBridge-Web Development Context for QA Agents

**When analyzing HM-* branches (HealthBridge-Web repository), agents MUST read the relevant development context docs before analysis.**

These documents are maintained by development agents in `HealthBridge-Web/docs/` and provide deep architectural knowledge that improves QA analysis accuracy.

### Agent-to-Document Mapping

| QA Agent | Required Context Docs (in `HealthBridge-Web/docs/`) | Purpose |
|----------|------------------------------------------------------|---------|
| **Code Review** | `AGENTS-development-guidelines.md`, `AGENTS-security.md`, `AGENTS-errorhandling.md`, `AGENTS-datalayer.md`, `AGENTS-common-code-patterns.md`, `AGENTS-validation.md`, `AGENTS-performance.md`, `AGENTS-frontend.md`, `AGENTS-translations.md`, `AGENTS-api.md`, `AGENTS-logging.md`, `AGENTS-database.md`, `AGENTS-backgroundservices.md` | Verify code follows golden rules, security patterns, Result pattern, DAL conventions, frontend patterns, translations, API conventions, logging, DB conventions, background service patterns |
| **Acceptance Tests** | `AGENTS-validation.md`, `AGENTS-frontend.md`, `AGENTS-translations.md`, `AGENTS-api.md`, `AGENTS-testing-e2e.md`, `AGENTS-errorhandling.md`, `AGENTS-security.md`, `AGENTS-database.md` | Understand validation framework, UI patterns, i18n, error handling, permissions, and database architecture for test scenarios |
| **Bug Report** | `AGENTS-errorhandling.md`, `AGENTS-logging.md`, `AGENTS-security.md`, `AGENTS-database.md`, `AGENTS-datalayer.md`, `AGENTS-common-code-patterns.md`, `AGENTS-validation.md`, `AGENTS-development-guidelines.md`, `AGENTS-frontend.md` | Trace error sources, logging infrastructure, security context, DAL patterns, common code patterns, validation, golden rules, frontend patterns |
| **Bugfix RCA** | `AGENTS-errorhandling.md`, `AGENTS-logging.md`, `AGENTS-database.md`, `AGENTS-datalayer.md`, `AGENTS-backgroundservices.md`, `AGENTS-security.md`, `AGENTS-development-guidelines.md`, `AGENTS-common-code-patterns.md`, `AGENTS-validation.md`, `AGENTS-frontend.md`, `AGENTS-api.md` | Deep root cause tracing through error handling, data layer, background services, security patterns, golden rules, common code patterns, validation, frontend, and API conventions |
| **Requirements Analysis** | `AGENTS-development-guidelines.md`, `AGENTS-database.md`, `AGENTS-api.md`, `AGENTS-security.md`, `AGENTS-errorhandling.md`, `AGENTS-validation.md`, `AGENTS-frontend.md` | Assess technical feasibility, data model impact, API patterns, security requirements, error handling completeness, validation feasibility, UI feasibility |
| **Release Analysis** | Inherits from Code Review Agent (per-PR delegation) | Same context as Code Review for individual PR analysis |

### How to Read

```
Read: HealthBridge-Web/docs/AGENTS-<name>.md
```

**When to read:** Before starting analysis for HM-* branches (HealthBridge-Web only). Skip for HBP-* (Portal) and HMM-* (Mobile) branches.

### Key Knowledge per Document

| Document | Key QA-Relevant Knowledge |
|----------|--------------------------|
| `AGENTS-development-guidelines.md` | Golden rules (Using statements, parameterized queries, TenantID filtering), code organization |
| `AGENTS-security.md` | UserSession singleton, access levels, permission validation, CSRF prevention |
| `AGENTS-errorhandling.md` | Result pattern (not exceptions for business logic), HBException hierarchy |
| `AGENTS-datalayer.md` | Accessor (CRUD) vs Report (read-only) patterns, parameterized queries |
| `AGENTS-common-code-patterns.md` | Result pattern, Entity base class, extension methods |
| `AGENTS-validation.md` | Validator class, ValidatorField types, form/AJAX validation patterns |
| `AGENTS-database.md` | Tenant vs Management databases, SQL naming conventions |
| `AGENTS-performance.md` | Data structure selection, N+1 prevention, caching patterns |
| `AGENTS-frontend.md` | HealthBridge JS library, HBForm/HBModal, CSRF token handling |
| `AGENTS-logging.md` | IEventLogger interfaces, structured logging, SystemError table |
| `AGENTS-api.md` | API integration patterns, data node interfaces |
| `AGENTS-translations.md` | Database-driven translations, language fallback, key requirements |
| `AGENTS-testing-e2e.md` | TestingEnvironment types, in-memory DB, test data management |
| `AGENTS-backgroundservices.md` | BackgroundServiceInitializer, thread-safe context, parallel processing |

---

## CRITICAL: E2E Framework Selection by Functional Area

**Use FUNCTIONAL AREA to determine which E2E frameworks to check — NOT branch prefix.**

A change in HealthBridge-Web (HM-*) can affect the Mobile app, and vice versa. The branch prefix only tells you WHERE the code changed, not WHAT AREAS are impacted.

**Decision Logic:**
1. Identify the **functional area** of the feature (e.g., Prescriptions, Patient Records, Billing).
2. Read the coverage map: `context/e2e-test-coverage-map.md`
3. For EACH framework:
   - Coverage map shows check mark -> Search for tests, recommend ADD if missing
   - Coverage map shows N/A -> Report "N/A — Outside scope" (do NOT recommend adding)

**Quick Reference:**

| Functional Area | Selenium | Playwright | Mobile |
|-----------------|----------|------------|--------|
| Prescriptions / Medications | Yes | No | Yes (approval) |
| Patient Records / Charts | Yes | No | No |
| Insurance Claims / Billing | Yes | Yes | Yes (approval) |
| Appointments / Scheduling | No | Yes | Yes |
| Staff Scheduling / Shifts | No | Yes | No |
| Lab Results / Diagnostics | No | Yes | Yes (viewing) |

**Always read the full coverage map for accurate functional area mapping.**

---

## CRITICAL: Branch Commit Filtering

**ALL agents analyzing branches MUST filter commits by ticket ID before analysis.**

When a branch contains merged commits from other tickets (common after merging main/development):

```bash
# First: Fetch latest to ensure remote tracking branches are up to date
git fetch origin

# Step 1: Count ALL commits on branch
git rev-list --count origin/main..origin/<branch-name>

# Step 2: Get ticket-specific commits using git's built-in --grep flag
git log origin/main..origin/<branch-name> --oneline --grep="<TICKET_ID>"

# Step 3: Count ticket-specific commits
git rev-list --count origin/main..origin/<branch-name> --grep="<TICKET_ID>"
```

**Decision Logic:**
- If ALL commits contain the ticket ID -> Use standard `git diff`
- If branch contains OTHER ticket IDs -> **ONLY analyze ticket-specific commits**

**Validation:** Always report: "Branch contains X total commits, analyzing Y commits specific to <TICKET_ID>"

---

## CRITICAL: E2E Repository — Fetch Latest Before Coverage Analysis

**ALL agents analyzing E2E test coverage MUST fetch latest before searching.**

Use `git fetch` to get latest code without disrupting developer's working directory:

```bash
# Fetch latest from all E2E test repositories (safe, non-destructive)
cd HealthBridge-Selenium-Tests && git fetch origin && cd ..
cd HealthBridge-E2E-Tests && git fetch origin && cd ..
cd HealthBridge-Mobile-Tests && git fetch origin && cd ..
```

**Then search on remote tracking branch** (not local branch):

```bash
# Search in latest main without checking it out (use correct extension per repo)
cd HealthBridge-Selenium-Tests && git grep -n "<keyword>" origin/main -- "*.py"
cd HealthBridge-E2E-Tests && git grep -n "<keyword>" origin/main -- "*.spec.ts"
cd HealthBridge-Mobile-Tests && git grep -n "<keyword>" origin/main -- "*.js"

# Read a specific file from remote main
git show origin/main:path/to/TestFile.py
```

**Report to user:** "Fetched latest from E2E test repositories"

**Why this matters:**
- E2E tests are frequently updated; stale remote refs lead to incorrect coverage analysis
- New tests may have been added that cover the feature being analyzed
- Prevents false "No coverage" reports when tests actually exist
- Developer's current branch and uncommitted changes remain untouched

**When to run:**
- Before analyzing E2E test coverage in code review
- Before generating E2E test recommendations in acceptance tests
- Before checking coverage gaps in bugfix RCA
- Before E2E coverage analysis in release reports

---

## CRITICAL: E2E Test Search Strategy

**DO NOT search only by folder structure. ALWAYS search by functionality keyword first.**

### The Problem

Agent incorrectly reported "No API tests" for prescription invalidation because:
- Searched only `HBPatientRecords/Tests/` (UI tests)
- Missed `HBIntegrationTests/Tests/` (API/Integration tests)
- Pattern-matched "prescription" to UI tests only

### The Solution: Keyword-First Search

After fetching latest, search on remote tracking branch:

```bash
# Search across ALL test directories in latest main
cd HealthBridge-Selenium-Tests && git grep -n "<keyword>" origin/main -- "*.py"
```

Or use your IDE's search tools on local files:

```
Search pattern: "<keyword>" path: "HealthBridge-Selenium-Tests" glob: "*.py"
```

**Do NOT limit search to specific subdirectories initially.**

### Selenium Test Directories (MUST search ALL)

| Directory | Test Type | Coverage Areas |
|-----------|-----------|----------------|
| **HBIntegrationTests/** | **API/Integration** | **Prescription API, Patient Records API, external integrations** |
| HBPatientRecords/ | UI E2E | Patient records tests |
| HBPrescriptions/ | UI E2E | Prescription workflow tests |
| HBInsuranceClaims/ | UI E2E | Insurance claims tests |
| HBBilling/ | UI E2E | Billing UI tests |

### Updated Coverage Table Format

When reporting E2E coverage, split Selenium into UI and Integration:

| Framework | Scope | Related Tests | Status |
|-----------|-------|---------------|--------|
| Selenium UI | Yes/No | [UI tests found] | Coverage status |
| Selenium Integration | Yes/No | [API tests found] | Coverage status |
| Playwright | Yes/No | [tests found] | Coverage status |
| Mobile | Yes/No | [tests found] | Coverage status |

---

## Historical Bugfix Patterns

**ALL agents must check for these patterns based on repository type.**

**Canonical source:** `context/historical-bugfix-patterns.md` — contains all 5 repository-specific pattern tables with percentages and detection focus. All agents read this file at runtime to get the correct patterns for the analyzed repository.

| Repository | Pattern Table |
|------------|--------------|
| HealthBridge-Web | Web / API Patterns |
| HealthBridge-Portal | Portal Patterns |
| HealthBridge-Mobile | Mobile / Flutter Patterns |
| HealthBridge-Api, HealthBridge-Prescriptions-Api | Microservice API Patterns |
| HealthBridge-Claims-Processing | Claims-Processing Patterns |

---

## Prompt Templates

All agents use prompt templates from `prompts/`:

| Category | Path | Contents |
|----------|------|----------|
| Acceptance Tests | `prompts/acceptance-tests/` | `acceptance-tests-prompt.md`, `acceptance-tests-template.md` |
| Code Review | `prompts/code-review-qa/` | `code-review-qa.md`, `code-review-template.md`, `code-review-brief-template.md`, `findings-detailed-template.md` |
| Bug Report | `prompts/bug-report/` | `bug-report-prompt.md`, `bug-report-template.md`, `severity-criteria.md` |
| Bugfix RCA | `prompts/bugfix-rca/` | `bugfix-rca-prompt.md`, `bugfix-rca-template.md`, `bugfix-rca-e2e-template.md` |
| Release Assessment | `prompts/release-assessment/` | `release-assessment-prompt.md`, `release-assessment-template.md`, `release-notes-prompt.md`, `slack-message-template.md` |
| Requirements Analysis | `prompts/requirements-analysis/` | `requirements-analysis-template.md`, `requirements-analysis.md` |
| Dev Estimation | `prompts/dev-estimation/` | `dev-estimation-template.md` |
| Feedback | `prompts/feedback/` | `feedback-prompt.md`, `feedback-template.md` |
| Setup | `prompts/setup/` | `setup-prompt.md`, `generate-repository-dependencies.md`, `generate-e2e-coverage-map.md`, `generate-bugfix-patterns.md` |

**Always read the relevant template before generating any document.**

### Requirements Analysis — Scoring Gate

The Requirements Analysis agent uses a **7/10 scoring threshold**:

| Score | Verdict | Next Steps |
|-------|---------|------------|
| **>= 7/10** | **READY** | **AUTO-GENERATE:** Acceptance Tests + DEV Estimation |
| **< 7/10** | **NOT READY** | No QA/DEV work until PO resolves gaps |

**AUTOMATIC WORKFLOW (Score >= 7/10):**
```
Requirements Analysis (Score >= 7)
        |
        v AUTO-GENERATE
Acceptance Tests -> reports/requirements-analysis/<TICKET-ID>-acceptance-tests.md
        |
        v AUTO-GENERATE
DEV Estimation -> reports/requirements-analysis/<TICKET-ID>-dev-estimation.md
```

**Template location:** `prompts/requirements-analysis/requirements-analysis-template.md`

---

## Output Constraints

| Document Type | Word Limit | Output Location |
|---------------|------------|-----------------|
| Code Review Report | 1300 words | `reports/code-review/<TICKET-ID>-code-review.md` |
| Code Review Brief | 450 words | `reports/code-review/<TICKET-ID>-code-review-brief.md` |
| Code Review Deep Analysis | No limit | `reports/code-review/<TICKET-ID>-findings-detailed.md` |
| Code Review Feedback | N/A (JSON) | `reports/feedback/<TICKET-ID>-feedback.json` |
| Acceptance Tests (standalone) | No limit | `reports/acceptance-tests/<TICKET-ID>-acceptance-tests.md` |
| Acceptance Tests (from workflow) | No limit | `reports/requirements-analysis/<TICKET-ID>-acceptance-tests.md` |
| Bug Report | 900 words | `reports/bug-report/<TICKET-ID>-bug-report.md` |
| Bugfix RCA | 1500 words | `reports/bugfix-rca/<TICKET-ID>-rca.md` |
| Requirements Analysis | 1500 words | `reports/requirements-analysis/<TICKET-ID>-requirements-analysis.md` |
| Dev Estimation (from workflow) | 1500 words | `reports/requirements-analysis/<TICKET-ID>-dev-estimation.md` |
| Release Risk Assessment | 1500 words | `reports/release-analysis/Release-XX-YYYY-Risk-Assessment.md` |
| Release Notes | No limit | `reports/release-analysis/Release-XX-YYYY-Release-Notes.md` |
| Slack Message | 300 words | `reports/release-analysis/Release-XX-YYYY-Slack-Message.md` |

---

## Important Notes

- Always run fresh analysis — do not rely on cached data.
- Use relative paths (not hardcoded absolute paths).
- Follow exact section structure from templates — do not skip or rename sections.
- Use "N/A — [reason]" if a section is not applicable.
- Include file:line references where possible.
- Never write documents with placeholder values.
- When document type is ambiguous, ask: "What type of document would you like? (Requirements Analysis / Bug Report / Code Review / Other)"
