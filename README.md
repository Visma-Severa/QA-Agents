# HealthBridge QA AI Agents

**Created by:** [Kira Komshilova](https://www.linkedin.com/in/kira-komshilova/)

> **This is a demo project** based on a production system used for QA automation across a large multi-repository enterprise platform. All domain-specific references have been replaced with a fictional "HealthBridge" health management theme. The project structure, agents, prompts, templates, and example reports can be used as a reference for building your own AI-powered QA agents.
>
> **Want to use this for your own project?** See [How to Install](#how-to-install) for the setup workflow.

A centralized repository for AI prompts and agents used across HealthBridge projects. These tools enhance developer productivity, code quality, and release management through AI-assisted analysis in a multi-repository health management platform.

---

## Table of Contents

1. [Purpose](#purpose)
2. [How to Install](#how-to-install)
   - [Prerequisites](#prerequisites)
   - [Automatic Installation](#automatic-installation)
   - [Manual Installation](#manual-installation)
   - [Verify Installation](#verify-installation)
3. [How to Use](#how-to-use)
   - [Available Agents](#available-agents)
   - [Agent Usage Examples](#agent-usage-examples)
   - [Common Workflows](#common-workflows)
4. [Architecture Overview](#architecture-overview)
   - [Multi-Repository Workspace](#multi-repository-workspace)
   - [Repositories](#repositories)
   - [How Agents Work](#how-agents-work)
   - [Key Design Principles](#key-design-principles)
   - [Folder Structure](#folder-structure)
   - [Shared Context Files](#shared-context-files)
   - [Prompt Templates](#prompt-templates)
   - [Output Locations](#output-locations)
5. [Troubleshooting](#troubleshooting)

---

## Purpose

These agents automate QA tasks across a multi-repository health management platform. They analyze code, generate test scenarios, assess release risk, and produce ticket-ready reports -- all driven by AI and guided by shared context files.

### How It Works

These agents rely on three foundational assumptions about the development workflow:

### JIRA for Project Management and Bug Tracking

All development tasks, bug fixes, and feature requests are tracked as JIRA tickets with unique IDs. Each ticket prefix maps to a set of repositories:

| Ticket Prefix | Example | Scope |
|---------------|---------|-------|
| `HM-*` | `HM-14200` | HealthBridge-Web, HealthBridge-Api, Claims-Processing, Prescriptions-Api |
| `HBP-*` | `HBP-5001` | HealthBridge-Portal |
| `HMM-*` | `HMM-3200` | HealthBridge-Mobile |

### Branch Naming Convention

**Git branch names must contain the JIRA ticket ID.** This is the mechanism that allows agents to automatically locate the correct branch in any repository when given only a ticket ID.

Valid branch names: `HM-14200`, `HM-14200-prescription-renewal`, `feature/HM-14200`

When a user provides a ticket ID (e.g., `HM-14200`), agents:
1. Search all repositories for branches matching `*HM-14200*`
2. Fetch latest from remote (`git fetch origin` -- safe, non-destructive)
3. Analyze using remote tracking branches (`origin/HM-14200-...`) without disrupting the developer's working directory

This means **the user only needs to provide a ticket ID** -- the agents handle repository discovery, branch detection, and analysis automatically.

### Release Branch Convention

Releases are managed through **release branches** (e.g., `release/Release-04/2026`). Each release branch aggregates merged feature branches scheduled for that deployment.

The **Release Analysis agent** uses this convention to:
1. Identify the release branch by name (e.g., `Release-09/2026`)
2. Compare it against the base branch (`main`) to find all included changes
3. Analyze each merged PR for risk, test coverage, and deployment concerns
4. Generate a Risk Assessment, Release Notes, and Slack Message

This means **the user only needs to provide a release identifier** (e.g., `Release-09/2026`) -- the agent finds the branch, fetches the latest, and performs a complete release analysis automatically.

---

## How to Install

### Prerequisites

| Tool | Required For | Download |
|------|-------------|----------|
| **Git** | Cloning repositories, version control | [git-scm.com/downloads](https://git-scm.com/downloads) |
| **Claude Code** | AI-powered CLI for running agents | [claude.ai/download](https://claude.ai/download) |

> **Note:** Claude Code is the primary supported IDE. The agents also work with VS Code + GitHub Copilot (via `.github/copilot-instructions.md`) and Cursor (via `.cursorrules`).

### Automatic Installation

The automatic installation clones the DEMO, copies the framework into a new project directory, and runs an interactive setup wizard that customizes all files for your project.

**Step 1: Clone the DEMO repository**

```bash
git clone https://github.com/visma-kira-komshilova/DEMO-QA-Agents
cd DEMO-QA-Agents
```

**Step 2: Run the bootstrap script**

The bootstrap script copies all framework files into a new directory (excluding `.git`, `node_modules`, build artifacts, and generated reports), then initializes a fresh git repo with an initial commit.

> Replace `<myproject-qa-agents>` with your actual project name.

**macOS / Linux:**
```bash
./setup/bootstrap.sh <myproject-qa-agents>
```

**Windows — PowerShell:**
```powershell
.\setup\bootstrap.ps1 -ProjectName "<myproject-qa-agents>"
```

**Windows — double-click:**
Run `setup/bootstrap.bat` and follow the prompts.

**Step 3: Open the new project and run the setup wizard**

```bash
cd ../<myproject-qa-agents>
claude
```

Then in Claude Code:
```
/hb-setup
```

The setup wizard is an interactive agent that customizes all files for your project through 4 phases:

| Phase | What Happens |
|-------|-------------|
| **1. Collect** | Asks questions about your project: name, repositories (clones them and auto-detects tech/branches), ticket prefixes, E2E frameworks, business domains |
| **2. Generate** | Updates all config files (CLAUDE.md, .cursorrules, copilot-instructions.md), agent definitions, prompts, templates, context files, setup scripts, and README |
| **3. Verify** | Runs `scripts/check-legacy-demo.sh` to scan for leftover DEMO references and auto-fixes them |
| **4. Context** | Populates context files with real project data — scans repos for dependencies, E2E coverage, JIRA mappings, and optionally analyzes hotfix history for bugfix patterns |

> **Tip:** If you don't know the answer to a question (e.g., technology stack, default branches, E2E frameworks), you can ask the setup agent to investigate your codebase. It will scan your repositories, read project files, and detect the answer automatically.

After setup completes, all `hb-` prefixes are replaced with your chosen prefix, all HealthBridge references are replaced with your project name, and context files contain real data from your repositories.

**Step 4: Set up the full workspace (optional)**

If you want the full multi-repository workspace with environment setup:

**macOS / Linux:**
```bash
./setup/setup.sh
```

**Windows — PowerShell:**
```powershell
.\setup\setup.ps1
```

This script clones all configured application and test repositories into the workspace, creates the VS Code workspace file, and sets up the environment.

### Manual Installation

If you prefer to set up the framework manually without running bootstrap or the setup wizard:

**Step 1: Clone the DEMO repository**

```bash
git clone https://github.com/visma-kira-komshilova/DEMO-QA-Agents
cd DEMO-QA-Agents
```

**Step 2: Copy framework files to your project**

Create a new directory and copy the framework structure (excluding DEMO-specific artifacts):

```bash
mkdir ../<myproject-qa-agents>
# Copy everything except .git, reports, and build artifacts
cp -r .claude agents prompts context scripts setup actions docs ../<myproject-qa-agents>/
cp .cursorrules .gitignore ../<myproject-qa-agents>/
cp -r .github ../<myproject-qa-agents>/
mkdir -p ../<myproject-qa-agents>/reports/{acceptance-tests,bug-report,bugfix-rca,code-review,feedback,release-analysis,requirements-analysis}
cd ../<myproject-qa-agents>
git init && git add -A && git commit -m "Initial commit from DEMO-QA-Agents framework"
```

**Step 3: Customize configuration files**

Replace DEMO references across all files. The key replacements:

| Find | Replace With | Files |
|------|-------------|-------|
| `HealthBridge` | Your project name | All files |
| `healthbridge` | Your project name (lowercase) | URLs, IDs |
| `hb-` | Your chosen prefix + `-` | Agent skills, CLAUDE.md, .cursorrules, copilot-instructions.md |
| `HM-14200` | Your example ticket ID | All files |
| `HealthBridge-Web`, `HealthBridge-Api`, etc. | Your repository names | CLAUDE.md, prompts, agents, context files |

**Step 4: Update the multi-repository table**

Edit `.claude/CLAUDE.md` (and `.cursorrules`, `.github/copilot-instructions.md`) to list your actual repositories with their technology, default branch, and ticket prefix.

**Step 5: Update context files**

| File | Action |
|------|--------|
| `context/e2e-test-coverage-map.md` | Rebuild with your E2E frameworks and functional areas |
| `context/jira-field-mappings.md` | Map your file paths to JIRA components |
| `context/code-review-false-positive-prevention.md` | Add your project's known safe patterns |
| `context/healthbridge-repository-dependencies.md` | Rename to `context/<yourproject>-repository-dependencies.md` and fill in actual dependencies |
| `context/historical-bugfix-patterns.md` | Update with your hotfix patterns (or leave as skeleton) |
| `context/domain-*.md` | Replace DEMO domain files with your business domains |

**Step 6: Update prompt templates**

Review files in `prompts/` and replace healthcare-specific examples (patient safety, prescriptions, HIPAA) with your domain-specific equivalents.

**Step 7: Verify**

Run the legacy reference scanner to check for missed replacements:

```bash
chmod +x scripts/check-legacy-demo.sh
./scripts/check-legacy-demo.sh
```

Fix any remaining references until the script reports 0 hits.

### Verify Installation

Verify Claude Code is installed and the skills are available:

```bash
claude --version   # Should print Claude Code version
```

Then start Claude Code and verify agent skills:

```bash
claude
```

Type `/hb-` (or your custom prefix) and you should see all available agent skills in the autocomplete:

```
/hb-code-review          # Code review agent
/hb-acceptance-tests     # Acceptance test generator
/hb-bug-report           # Bug report generator
/hb-bugfix-rca           # Root cause analysis
/hb-requirements-analysis # Requirements validation
/hb-release-analysis     # Release risk assessment
/hb-feedback             # Developer feedback processing
/hb-setup                # Project setup wizard
```

**Also verify Git access:**

```bash
git --version    # Should print: git version 2.x.x
```

---

## How to Use

### Available Agents

| Agent | Command | Purpose | Example |
|-------|---------|---------|---------|
| **Code Review** | `/hb-code-review` | Analyze PR/branch for code quality, test gaps, risks | `/hb-code-review HM-14200` |
| **Acceptance Tests** | `/hb-acceptance-tests` | Generate Given/When/Then test scenarios | `/hb-acceptance-tests HM-14200` |
| **Bug Report** | `/hb-bug-report` | Analyze errors and generate ticket-ready bug reports | `/hb-bug-report [error details]` |
| **Bugfix RCA** | `/hb-bugfix-rca` | Root cause analysis for hotfixes | `/hb-bugfix-rca HM-14200 Release-4/2026` |
| **Requirements Analysis** | `/hb-requirements-analysis` | Pre-development requirements validation (7/10 gate) | `/hb-requirements-analysis HM-14200` |
| **Release Analysis** | `/hb-release-analysis` | Analyze releases for risk, coverage, deployment readiness | `/hb-release-analysis release/Release-04/2026` |
| **Feedback** | `/hb-feedback` | Interactive developer feedback on code review findings | `/hb-feedback HM-14200` |
| **Setup** | `/hb-setup` | Interactive wizard to adapt this framework to your project | `/hb-setup` |

### Agent Usage Examples

#### Code Review for a Branch

**Scenario:** You have a branch `HM-14200` and want to analyze its code quality, test coverage, and identify risks.

```
/hb-code-review HM-14200
```

**What you get:**
- Risk assessment (Low / Medium / High)
- Code quality analysis with hotfix pattern detection
- **False Positive Prevention Protocol** -- 3-step verification (Verify, Compare, Counter-Argue) ensures high-confidence findings
- Security vulnerability scan (SQL injection, XSS, etc.)
- Test coverage gaps (Unit + E2E across 3 frameworks)
- **Interactive Developer Feedback** -- review each finding with Valid / False Positive / Won't Fix / Provide More Information
- Manual test checklist

**Available Formats:**

| Format | Flag | Word Limit | Output File | Use Case |
|--------|------|------------|-------------|----------|
| **Comprehensive** (default) | _(none)_ | 1300 words | `<TICKET>-code-review.md` | Internal QA audit, team review |
| **Brief** | `brief` | 300 words | `<TICKET>-code-review-brief.md` | GitHub PR comment, quick summary |
| **Both** | `both` | 1300 + 300 | Both files above | Full workflow: post brief to PR, keep comprehensive for records |

All outputs are saved to `reports/code-review/`.

**Examples:**

```
/hb-code-review HM-14200              # Comprehensive (default)
/hb-code-review HM-14200 brief        # Brief only (GitHub-ready)
/hb-code-review HM-14200 both         # Both formats simultaneously
```

---

#### Generate Acceptance Tests

**Scenario:** You need comprehensive test scenarios for a feature, bug fix, or requirement.

```
/hb-acceptance-tests HM-14200
```

**What you get:**
- Given/When/Then (BDD) acceptance test scenarios
- Happy path, alternative flow, error, and edge case coverage
- Regression test areas identification
- Automation candidates (Selenium, Playwright, Mobile)
- Requirements validation (if original requirements provided)
- Requirements Traceability Matrix (if requirements provided)

**Output:** `reports/acceptance-tests/<TICKET>-acceptance-tests.md`

---

#### Bug Report from Error Message

**Scenario:** Production error found in logs -- need a ticket-ready bug report.

```
/hb-bug-report
Error: System.NullReferenceException
File: PrescriptionService.cs, line 234
```

**What you get:**
- Root cause analysis with code snippet
- **Codebase pattern search** -- finds similar bugs across all files
- 3 fix options (Quick / Standard / Recommended) with effort estimates
- Severity assessment (Critical / High / Medium / Low)
- Ticket-ready fields (Summary, Description, Steps, Story Points)
- Output: `reports/bug-report/<descriptive-name>-bug-report.md`

---

#### Root Cause Analysis for Bugfixes

**Scenario:** A bug was found -- you need to understand why it happened.

**Two modes** (auto-detected from input):

| Mode | Trigger | What It Does |
|------|---------|-------------|
| **Hotfix** | Mention `Release-X/YEAR` | Compares bugfix branch vs release branch |
| **Investigation** | Only ticket ID provided | Searches git history to trace bug origin |

```
/hb-bugfix-rca HM-14200 Release-4/2026    # Hotfix Mode
/hb-bugfix-rca HM-14200                   # Investigation Mode
```

**Outputs** (both in `reports/bugfix-rca/`):
- `<TICKET>-rca.md` -- RCA report with timeline, 5 Whys, pattern match (1500 words)
- `<TICKET>-e2e-test-recommendations.md` -- Test code recommendations to prevent recurrence

---

#### Requirements Analysis Before Development

**Scenario:** Product Owner has written requirements -- validate completeness before dev starts.

```
/hb-requirements-analysis HM-15000
```

**What you get:**
- **Readiness score: X/10** (7+ = Ready for dev, <7 = More details needed)
- Business gap analysis
- Health domain compliance gaps
- Edge case identification (28% of hotfixes!)
- Multi-repository impact assessment

**If score >= 7/10:** Agent automatically generates:
- Acceptance Tests: `HM-15000-acceptance-tests.md`
- Dev Estimation: `HM-15000-dev-estimation.md`

**If score < 7/10:** Stops with critical questions -- no QA/Dev work until clarified.

---

#### Release Risk Assessment

**Scenario:** Preparing Release-04/2026 for production.

```
/hb-release-analysis release/Release-04/2026
```

**What you get:**
- Overall risk level (Low / Medium / Critical)
- PR-by-PR analysis with categories
- **E2E Regression Coverage** and **E2E Test Maintenance Plan**
- Manual testing checklist (prioritized)
- Go/No-Go recommendation
- Outputs (all in `reports/release-analysis/`):
  - `Release-04-2026-Risk-Assessment.md`
  - `Release-04-2026-Release-Notes.md`
  - `Release-04-2026-Slack-Message.md`

### Common Workflows

#### Workflow 1: New Feature Development
```
1. /hb-requirements-analysis [ticket]        -> Validate requirements
2. (If score >=7) -> Acceptance Tests + Dev Estimation auto-generated
3. [Developer implements]
4. /hb-code-review [branch]                  -> Pre-merge review
5. /hb-acceptance-tests [branch]             -> Final test scenarios
```

#### Workflow 2: Bug Investigation and Fix
```
1. /hb-bug-report                            -> Analyze error, get fix options
2. [Developer implements fix]
3. /hb-bugfix-rca [branch]                   -> Understand root cause
4. /hb-code-review [branch]                  -> Ensure fix quality
```

#### Workflow 3: Release Preparation
```
1. /hb-release-analysis release/Release-XX/YYYY
2. Review risk assessment report
3. Execute E2E test plan (Section 4.4)
4. Perform manual testing (Section 6)
5. Share Slack message with team
```

#### Workflow 4: PR Review Process
```
1. /hb-code-review [branch] both
2. Post brief report to GitHub PR
3. Use comprehensive report for team review
4. If critical issues -> Request changes
5. If ready -> Approve
```

---

## Architecture Overview

### Multi-Repository Workspace

This repository is designed to work within a **multi-repository workspace** that contains all HealthBridge repositories. The AI agents require access to multiple repositories to perform comprehensive analysis across the codebase.

**Why Multi-Repository Workspace?**

- **Cross-repository analysis** -- Agents can analyze code changes and find related E2E tests across different repositories
- **Unified context** -- AI assistants have visibility into the entire codebase for better suggestions
- **Consistent tooling** -- Shared prompts and agents work across all projects
- **E2E coverage detection** -- Release analysis can check Selenium, Playwright, and Mobile test coverage

### Repositories

The workspace contains **10 repositories** across four categories:

#### Core Application Repositories

| Repository | Technology | Default Branch | Branch Prefix | Description |
|------------|-----------|---------------|---------------|-------------|
| `HealthBridge-Web` | C# / ASP.NET Core | `main` | `HM-*` | Core patient management, scheduling, and clinical workflows |
| `HealthBridge-Portal` | C# / .NET Core, React | `main` | `HBP-*` | Provider portal backend and frontend |
| `HealthBridge-Api` | C# / .NET Core | `main` | `HM-*` | REST API for external partner integrations |
| `HealthBridge-Mobile` | Flutter / Dart | `main` | `HMM-*` | iOS/Android mobile application |

#### Microservice API Repositories

| Repository | Technology | Default Branch | Branch Prefix | Description |
|------------|-----------|---------------|---------------|-------------|
| `HealthBridge-Claims-Processing` | C# / .NET Core | `main` | `HM-*` | Insurance claims processing and payment reconciliation |
| `HealthBridge-Prescriptions-Api` | C# / .NET Core | `main` | `HM-*` | Prescription management |

#### Test Automation Repositories

| Repository | Technology | Default Branch | Description |
|------------|-----------|---------------|-------------|
| `HealthBridge-Selenium-Tests` | C# / Selenium | `master` | UI tests (Patient Records, Billing, Scheduling) + Integration/API tests |
| `HealthBridge-E2E-Tests` | TypeScript / Playwright | `master` | Modern E2E tests: prescriptions, referrals, staff scheduling |
| `HealthBridge-Mobile-Tests` | WebdriverIO / JavaScript | `main` | Mobile app automation tests |

#### QA Agents Repository

| Repository | Technology | Default Branch | Description |
|------------|-----------|---------------|-------------|
| `DEMO-QA-Agents` | Markdown | `main` | This repository -- AI prompts, agents, and Claude Code skills |

### How Agents Work

```
User Input (ticket ID, error, release name)
        |
        v
  Global Instructions (.claude/CLAUDE.md, .cursorrules, copilot-instructions.md)
        |
        v
  Agent Skill (.claude/skills/hb-<agent>/SKILL.md)
        |
        +---> Shared Context Files (context/*.md)
        |         - E2E coverage map
        |         - Domain knowledge (prescriptions, patient records)
        |         - False positive prevention rules
        |         - Repository dependency map
        |
        +---> Prompt Templates (prompts/<category>/*.md)
        |         - Report structure and formatting rules
        |         - Scoring criteria and thresholds
        |
        +---> IDE Tools (git, grep, file read)
        |         - Repository analysis via git fetch + remote tracking
        |         - Code search across all 10 repos
        |         - E2E test coverage detection
        |
        v
  Generated Report (reports/<category>/<TICKET>-<type>.md)
```

### Key Design Principles

- **Non-destructive analysis** -- Agents never use `git checkout`; they analyze via `git fetch` + remote tracking branches to protect developer working directories
- **Auto-detection** -- Branch prefixes (`HM-*`, `HBP-*`, `HMM-*`) automatically route to the correct repository
- **Predictive bug detection** -- Historical hotfix patterns (Edge Cases 28%, Authorization 22%, NULL 18%) are used to flag risks before merge
- **Cross-platform** -- All skills and tools work on macOS, Windows, and Linux
- **Template-driven output** -- Every report follows a standardized template for consistency and auditability

### Folder Structure

```
DEMO-QA-Agents/
├── README.md                                   # This file
├── CHANGELOG.md                                # Version history
├── HealthBridge.code-workspace                 # VS Code multi-repo workspace file
├── .cursorrules                                # Cursor AI instructions (copy to workspace root)
├── .github/
│   ├── copilot-instructions.md                 # GitHub Copilot instructions (copy to workspace root)
│   ├── workflows/
│   │   └── validate-prompts.yml                # CI/CD prompt validation
│   └── CODEOWNERS                              # Code ownership rules
│
├── .claude/
│   ├── CLAUDE.md                               # Claude Code global instructions (copy to workspace root)
│   ├── settings.local.json                     # Safe tool permissions
│   └── skills/                                 # Claude Code Agent Skills
│       ├── hb-code-review/SKILL.md             # /hb-code-review — PR code review
│       ├── hb-acceptance-tests/SKILL.md        # /hb-acceptance-tests — test scenario generation
│       ├── hb-bug-report/SKILL.md              # /hb-bug-report — bug report generation
│       ├── hb-bugfix-rca/SKILL.md              # /hb-bugfix-rca — root cause analysis
│       ├── hb-requirements-analysis/SKILL.md   # /hb-requirements-analysis — requirements validation
│       ├── hb-release-analysis/SKILL.md        # /hb-release-analysis — release risk assessment
│       ├── hb-feedback/SKILL.md                # /hb-feedback — developer feedback processing
│       └── hb-setup/SKILL.md                   # /hb-setup — project setup wizard
│
├── agents/                                     # Agent Definitions (IDE-agnostic)
│   └── vscode-chat-participants/
│       ├── code-review.md                      # Code review agent
│       ├── acceptance-tests.md                 # Acceptance test generation agent
│       ├── bug-report.md                       # Bug report agent
│       ├── feedback.md                         # Developer feedback agent
│       ├── bugfix-rca.md                       # Root cause analysis agent
│       ├── requirements-analysis.md            # Requirements validation agent
│       ├── release-analysis.md                 # Release risk assessment agent
│       └── setup.md                            # Interactive project customization wizard
│
├── prompts/                                    # Prompt Templates
│   ├── acceptance-tests/                       # Acceptance tests prompt + template
│   │   ├── acceptance-tests-prompt.md
│   │   └── acceptance-tests-template.md
│   ├── bug-report/                             # Bug report prompt + template + severity criteria
│   │   ├── bug-report-prompt.md
│   │   ├── bug-report-template.md
│   │   ├── severity-criteria.md
│   │   └── README.md
│   ├── bugfix-rca/                             # Root cause analysis prompt + templates
│   │   ├── bugfix-rca-prompt.md
│   │   ├── bugfix-rca-template.md
│   │   └── bugfix-rca-e2e-template.md
│   ├── code-review-qa/                         # Code review prompt + templates + findings-detailed
│   │   ├── code-review-qa.md
│   │   ├── code-review-template.md
│   │   ├── code-review-brief-template.md
│   │   ├── findings-detailed-template.md
│   │   └── README.md
│   ├── dev-estimation/                         # Dev estimation template
│   │   └── dev-estimation-template.md
│   ├── feedback/                               # Developer feedback prompt + template
│   │   ├── feedback-prompt.md
│   │   └── feedback-template.md
│   ├── release-assessment/                     # Release assessment prompt + templates
│   │   ├── release-assessment-prompt.md
│   │   ├── release-assessment-template.md
│   │   ├── release-notes-prompt.md
│   │   └── slack-message-template.md
│   ├── requirements-analysis/                  # Requirements analysis prompt + template (7/10 scoring)
│   │   ├── requirements-analysis.md
│   │   └── requirements-analysis-template.md
│   └── setup/                                  # Project setup wizard + context file generators
│       ├── setup-prompt.md                     # Interactive setup wizard prompt
│       ├── generate-repository-dependencies.md # Prompt: scan repos -> generate dependency map
│       ├── generate-e2e-coverage-map.md        # Prompt: scan test repos -> generate coverage matrix
│       └── generate-bugfix-patterns.md         # Prompt: analyze hotfix history -> generate pattern tables
│
├── context/                                    # Shared Context Files
│   ├── e2e-test-coverage-map.md                # Which E2E frameworks cover which functional areas
│   ├── jira-field-mappings.md                  # Auto-detect ticket components from file paths
│   ├── code-review-false-positive-prevention.md  # Known safe patterns to avoid flagging
│   ├── healthbridge-repository-dependencies.md # Consumer/Provider dependency map across all repos
│   ├── historical-bugfix-patterns.md           # RCA-derived bugfix patterns by repo type
│   ├── domain-prescriptions.md                 # Domain: Prescriptions & Medications
│   ├── domain-patient-records.md               # Domain: Patient Records & Charts
│   └── README.md
│
├── docs/                                       # Documentation
│   └── PO_GETTING_STARTED.md                   # Product Owner quick-start guide
│
├── actions/                                    # GitHub Actions (automation)
│   ├── ai-code-review-qa/
│   │   └── action.yml
│   ├── bugfix-rca/
│   │   └── action.yml
│   └── release-assessment/
│       └── action.yml
│
├── setup/                                      # Setup & Update Scripts
│   ├── bootstrap.bat                           # Windows double-click bootstrap
│   ├── bootstrap.sh                            # macOS/Linux bootstrap
│   ├── bootstrap.ps1                           # Windows PowerShell bootstrap
│   ├── setup.bat                               # Windows double-click setup
│   ├── setup.sh                                # macOS/Linux full environment setup
│   ├── setup.ps1                               # Windows PowerShell full environment setup
│   ├── update.bat                              # Windows double-click update
│   ├── update.sh                               # macOS/Linux update
│   └── update.ps1                              # Windows PowerShell update
│
├── scripts/                                    # Utility Scripts
│   ├── update-all-repos.sh                     # Fetch/pull all repos in one command
│   └── README.md
│
└── reports/                                    # Generated Outputs
    ├── acceptance-tests/                       # Standalone acceptance test scenarios
    ├── bug-report/                             # Bug reports with fix recommendations
    ├── bugfix-rca/                             # Root cause analysis + E2E test recommendations
    ├── code-review/                            # PR code review reports (brief & comprehensive) + findings-detailed
    ├── feedback/                               # Developer feedback JSON files
    ├── release-analysis/                       # Release risk assessments, release notes, Slack messages
    └── requirements-analysis/                  # Requirements analysis + acceptance tests + dev estimation
```

### Shared Context Files

Agents read shared context files from `context/` before analysis to improve accuracy and reduce false positives.

| Context File | Path | Used By | Purpose |
|--------------|------|---------|---------|
| **E2E Coverage Map** | `context/e2e-test-coverage-map.md` | All agents | Maps functional areas to E2E frameworks (Selenium/Playwright/Mobile) |
| **Ticket Field Mappings** | `context/jira-field-mappings.md` | Bug Report, Release | Auto-detects ticket components from file paths |
| **False Positive Prevention** | `context/code-review-false-positive-prevention.md` | Code Review | 6 rules: framework safety nets, data flow guarantees, standard patterns, tool verification |
| **Repository Dependencies** | `context/healthbridge-repository-dependencies.md` | All agents | Consumer/Provider dependency map, blast radius, shared databases |
| **Historical Bugfix Patterns** | `context/historical-bugfix-patterns.md` | Code Review, Bugfix RCA | RCA-derived bugfix patterns by repo type for predictive bug detection |

#### Domain Knowledge Context

Domain context files provide health management regulatory, business, and compliance knowledge for specific functional areas. Agents auto-detect the domain from ticket keywords and load the relevant file.

| Context File | Path | Domain | Trigger Keywords |
|--------------|------|--------|-----------------|
| **Prescriptions & Medications** | `context/domain-prescriptions.md` | Rx & Pharmacy | prescription, medication, refill, dosage, controlled substance, pharmacy, DEA |
| **Patient Records** | `context/domain-patient-records.md` | Medical Records | patient, chart, diagnosis, ICD, medical history, HIPAA, records |
| **Staff Scheduling** | `context/domain-staff-scheduling.md` | Workforce | scheduling, shift, roster, staff, availability, overtime |

### Prompt Templates

| Prompt | Location | Description |
|--------|----------|-------------|
| Acceptance Tests | `prompts/acceptance-tests/` | Given/When/Then scenario generation with BDD format |
| Bug Report | `prompts/bug-report/` | Error analysis + ticket-ready bug reports with severity criteria |
| Bugfix RCA | `prompts/bugfix-rca/` | Root cause analysis + E2E test recommendations |
| Code Review QA | `prompts/code-review-qa/` | PR analysis with hotfix pattern detection, findings-detailed, brief format |
| Dev Estimation | `prompts/dev-estimation/` | Task breakdown with file paths and risk buffers |
| Feedback | `prompts/feedback/` | Developer feedback collection and accuracy tracking |
| Release Assessment | `prompts/release-assessment/` | Release risk assessment, release notes, Slack message |
| Requirements Analysis | `prompts/requirements-analysis/` | Requirements validation with 7/10 scoring gate |
| Setup & Context Generators | `prompts/setup/` | Setup wizard + 3 context file generation prompts (dependencies, E2E coverage, bugfix patterns) |

### Output Locations

Reports are saved to `reports/` (from project root):

| Directory | Content | Word Limit |
|-----------|---------|------------|
| **`reports/code-review/`** | PR code review reports (brief and comprehensive) + findings-detailed analysis | 1300 / 450 words |
| **`reports/acceptance-tests/`** | Acceptance test scenarios with BDD format | No limit |
| **`reports/bug-report/`** | Ticket-ready bug reports with fix recommendations | 900 words |
| **`reports/bugfix-rca/`** | Root cause analysis and E2E test recommendations | 1500 words |
| **`reports/requirements-analysis/`** | Requirements analysis + acceptance tests + dev estimation | 1500 words |
| **`reports/release-analysis/`** | Release risk assessment + release notes + Slack message | 1500 words |
| **`reports/feedback/`** | Developer feedback JSON files for accuracy tracking | N/A (JSON) |

---

## Troubleshooting

### Common Issues

| Problem | Cause | Solution |
|---------|-------|----------|
| Agent does not recognize ticket prefix | Config files not at workspace root | Re-copy: `cp DEMO-QA-Agents/.claude/CLAUDE.md .claude/` |
| "No tests found" for a covered area | Stale E2E repo refs | Agent should `git fetch origin` before searching; verify with `git log origin/main -1` |
| Report has wrong section structure | Agent did not read template | Verify template exists in `prompts/<category>/` |
| Agent asks for confirmation instead of executing | Missing execution protocol in config | Re-copy `.claude/CLAUDE.md` to workspace root |
| `git checkout` used during analysis | Agent violated safety rule | Report as bug; agents must use `git fetch` + remote tracking branches only |
| Empty report generated | Branch not found in any repo | Verify branch exists: `git branch -r --list "*HM-14200*"` in each repo |
| `/hb-*` skills not showing | Skills directory missing | Verify `.claude/skills/hb-*/SKILL.md` files exist |
| Claude Code not finding repos | Working directory wrong | Start Claude Code from the workspace root that contains all repos |
| Bootstrap script fails | Missing permissions | Run `chmod +x setup/bootstrap.sh` (macOS/Linux) |
| Setup wizard not customizing files | Ran `/hb-setup` in DEMO directory | Run setup in the bootstrapped project directory, not the original DEMO |
| Legacy references after setup | Incomplete Phase 3 | Run `./scripts/check-legacy-demo.sh` and fix remaining hits |

### Verifying Agent Configuration

```bash
# Check that config files exist
ls -la .claude/CLAUDE.md .claude/skills/hb-*/SKILL.md

# Check that all repos are cloned
ls -d HealthBridge-*/

# Check branch exists in a specific repo
cd HealthBridge-Web && git branch -r --list "*HM-14200*"

# Verify no legacy DEMO references remain
./scripts/check-legacy-demo.sh
```

---

## Note

This is a **demo/reference implementation** showcasing how multi-agent AI systems can be structured for QA automation in a multi-repository software ecosystem. The domain (health management), repository names, and ticket prefixes are fictional examples designed to illustrate the architecture and agent coordination patterns.

---
