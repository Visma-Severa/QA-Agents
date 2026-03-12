# HealthBridge QA AI Agents

**Created by:** [Kira Komshilova](https://www.linkedin.com/in/kira-komshilova/)

> **This is a demo project** based on a production system used for QA automation across a large multi-repository enterprise platform. All domain-specific references have been replaced with a fictional "HealthBridge" health management theme. The project structure, agents, prompts, templates, and example reports can be used as a reference for building your own AI-powered QA agents.
>
> **Want to use this for your own project?** See [Adapt to Your Project](#adapt-to-your-project) for the 5-step setup workflow.

A centralized repository for AI prompts and agents used across HealthBridge projects. These tools enhance developer productivity, code quality, and release management through AI-assisted analysis in a multi-repository health management platform.

---

## Table of Contents

- [How It Works](#how-it-works)
  - [JIRA for Project Management and Bug Tracking](#jira-for-project-management-and-bug-tracking)
  - [Branch Naming Convention](#branch-naming-convention)
  - [Release Branch Convention](#release-branch-convention)
- [Multi-Repository Workspace](#multi-repository-workspace)
  - [Why Multi-Repository Workspace?](#why-multi-repository-workspace)
  - [Repositories](#repositories)
- [Prerequisites](#prerequisites)
  - [IDE Options](#ide-options)
  - [Verify Installation](#verify-installation)
- [Architecture Overview](#architecture-overview)
  - [Key Design Principles](#key-design-principles)
- [Available Agents](#available-agents)
- [Quick Start](#quick-start)
  - [Explore the Demo](#explore-the-demo)
  - [Use It for Your Project](#use-it-for-your-project)
- [Agent Usage Examples](#agent-usage-examples)
  - [Example 1: Code Review for a Branch](#example-1-code-review-for-a-branch)
  - [Example 2: Generate Acceptance Tests](#example-2-generate-acceptance-tests)
  - [Example 3: Bug Report from Error Message](#example-3-bug-report-from-error-message)
  - [Example 4: Root Cause Analysis for Bugfixes](#example-4-root-cause-analysis-for-bugfixes)
  - [Example 5: Requirements Analysis Before Development](#example-5-requirements-analysis-before-development)
  - [Example 6: Release Risk Assessment](#example-6-release-risk-assessment)
  - [Common Workflows](#common-workflows)
- [Folder Structure](#folder-structure)
- [Shared Context Files](#shared-context-files)
  - [Domain Knowledge Context](#domain-knowledge-context)
- [Output Locations](#output-locations)
- [Prompt Templates](#prompt-templates)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Verifying Agent Configuration](#verifying-agent-configuration)
- [Adapt to Your Project](#adapt-to-your-project)
  - [Setup Workflow (7 Steps)](#setup-workflow-7-steps)
  - [What Gets Customized](#what-gets-customized)
  - [What Stays Generic (Do NOT Change)](#what-stays-generic-do-not-change)
  - [Context Files — Your Project Knowledge](#context-files--your-project-knowledge)
  - [Building Your Historical Bugfix Patterns](#building-your-historical-bugfix-patterns)
- [Note](#note)

---

## How It Works

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
2. Fetch latest from remote (`git fetch origin` — safe, non-destructive)
3. Analyze using remote tracking branches (`origin/HM-14200-...`) without disrupting the developer's working directory

This means **the user only needs to provide a ticket ID** — the agents handle repository discovery, branch detection, and analysis automatically.

### Release Branch Convention

Releases are managed through **release branches** (e.g., `release/Release-04/2026`). Each release branch aggregates merged feature branches scheduled for that deployment.

The **Release Analysis agent** uses this convention to:
1. Identify the release branch by name (e.g., `Release-09/2026`)
2. Compare it against the base branch (`main`) to find all included changes
3. Analyze each merged PR for risk, test coverage, and deployment concerns
4. Generate a Risk Assessment, Release Notes, and Slack Message

This means **the user only needs to provide a release identifier** (e.g., `Release-09/2026`) — the agent finds the branch, fetches the latest, and performs a complete release analysis automatically.

---

## Multi-Repository Workspace

This repository is designed to work within a **multi-repository VS Code/Cursor workspace** that contains all HealthBridge repositories. The AI agents require access to multiple repositories to perform comprehensive analysis across the codebase.

### Why Multi-Repository Workspace?

- **Cross-repository analysis** -- Agents can analyze code changes and find related E2E tests across different repositories
- **Unified context** -- AI assistants have visibility into the entire codebase for better suggestions
- **Consistent tooling** -- Shared prompts and agents work across all projects
- **E2E coverage detection** -- Release analysis can check Selenium, Playwright, and Mobile test coverage
- **Automatic repository sync** -- The VS Code extension safely syncs all repos before each agent run (never forces, never overwrites your work)

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
| `DEMO-QA-Agents` | Markdown / TypeScript | `main` | This repository -- AI prompts, agents, and VS Code extension |

---

## Prerequisites

Before starting, ensure the following tools are installed on your machine:

| Tool | Required For | Download |
|------|-------------|----------|
| **Git** | Cloning repositories, version control | [git-scm.com/downloads](https://git-scm.com/downloads) |
| **Node.js** (v18+) | Building the VS Code extension | [nodejs.org](https://nodejs.org/) |
| **VS Code** or **Cursor** | IDE with GitHub Copilot Chat support | [code.visualstudio.com](https://code.visualstudio.com/) |
| **GitHub Copilot** | AI chat participants (`@hb-*` agents) | [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) |

### IDE Options

| IDE | How Agents Work | Configuration File |
|-----|----------------|--------------------|
| **VS Code + GitHub Copilot** | `@hb-*` chat participants via extension | `.github/copilot-instructions.md` |
| **Cursor** | Agent mode with `.cursorrules` | `.cursorrules` |
| **Claude Code** | CLI agent with CLAUDE.md | `.claude/CLAUDE.md` |

### Verify Installation

**macOS/Linux:**
```bash
git --version    # Should print: git version 2.x.x
node --version   # Should print: v18.x.x or higher
npm --version    # Should print: 9.x.x or higher
```

**Windows (PowerShell):**
```powershell
git --version    # Should print: git version 2.x.x
node --version   # Should print: v18.x.x or higher
npm --version    # Should print: 9.x.x or higher
```

> **Windows: "git is not recognized" error?** This means Git is not installed or not added to your system PATH. Follow the steps below to fix it.

#### Fixing "git is not recognized" on Windows

**Option A: Restart your terminal (try this first)**

If you just installed Git, close and reopen PowerShell (or VS Code terminal). New PATH entries only take effect in new terminal sessions.

**Option B: Re-run the Git installer with PATH option**

1. Run the Git installer again from [git-scm.com/downloads](https://git-scm.com/downloads)
2. On the **"Adjusting your PATH environment"** screen, select: **"Git from the command line and also from 3rd-party software"** (the recommended/middle option)
3. Complete the installation
4. Open a **new** PowerShell window and verify: `git --version`

**Option C: Manually add Git to PATH**

If Git is already installed but not in PATH:

1. Find your Git installation path. Common locations:
   - `C:\Program Files\Git\cmd`
   - `C:\Users\<username>\AppData\Local\Programs\Git\cmd`
2. Open **Start** > search **"Environment Variables"** > click **"Edit the system environment variables"**
3. Click **"Environment Variables..."** button
4. Under **"User variables"** (or **"System variables"**), select **Path** > click **Edit**
5. Click **New** and add the path to Git's `cmd` folder (e.g., `C:\Program Files\Git\cmd`)
6. Click **OK** on all dialogs
7. Open a **new** PowerShell window and verify: `git --version`

**Option D: Use Git Bash instead of PowerShell**

Git for Windows includes **Git Bash**, a Unix-like terminal where `git` always works. All commands in this guide work in Git Bash without modification:
- Open from Start menu: search **"Git Bash"**
- Or right-click in File Explorer > **"Open Git Bash here"**

---

## Architecture Overview

The system is built around **8 specialized agents**, each governed by shared global instructions and backed by:

```
User Input (ticket ID, error, release name)
        |
        v
  Global Instructions (.claude/CLAUDE.md, .cursorrules, copilot-instructions.md)
        |
        v
  Agent Definition (agents/vscode-chat-participants/<agent>.md)
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
- **Cross-platform** -- All commands and tools work on macOS, Windows, and Linux
- **Template-driven output** -- Every report follows a standardized template for consistency and auditability

---

## Available Agents

| Agent | Chat Participant | Purpose | Example |
|-------|-----------------|---------|---------|
| **Code Review** | `@hb-code-review` | Analyze PR/branch for code quality, test gaps, risks | `@hb-code-review HM-14200` |
| **Acceptance Tests** | `@hb-acceptance-tests` | Generate Given/When/Then test scenarios | `@hb-acceptance-tests HM-14200` |
| **Bug Report** | `@hb-bug-report` | Analyze errors and generate ticket-ready bug reports | `@hb-bug-report [error details]` |
| **Bugfix RCA** | `@hb-bugfix-rca` | Root cause analysis for hotfixes | `@hb-bugfix-rca HM-14200 Release-4/2026` |
| **Requirements Analysis** | `@hb-requirements-analysis` | Pre-development requirements validation (7/10 gate) | `@hb-requirements-analysis HM-14200` |
| **Release Analysis** | `@hb-release-analysis` | Analyze releases for risk, coverage, deployment readiness | `@hb-release-analysis release/Release-04/2026` |
| **Feedback** | `@hb-feedback` | Interactive developer feedback on code review findings | Invoked after `@hb-code-review` with `interactive` |
| **Setup** | `@hb-setup` | Interactive wizard to adapt this framework to your project | `@hb-setup` |

---

## Quick Start

This is a **reference project** — you don't need to install or run it. Browse the repository to understand the structure, then adapt it to your own project.

### Explore the Demo

```bash
git clone https://github.com/visma-kira-komshilova/DEMO-QA-Agents
```

Key things to look at:

| What | Where | Why |
|------|-------|-----|
| Agent definitions | `agents/vscode-chat-participants/` | How each QA agent is configured |
| Prompt templates | `prompts/` | Analysis logic, scoring models, report structures |
| Context files | `context/` | Project knowledge that makes agents smart about your domain |
| Example reports | `reports/` | Sample output from each agent |
| IDE config files | `.claude/CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md` | How agents receive instructions in each IDE |
| VS Code extension | `.vscode-extension/` | Chat participant integration for GitHub Copilot |
| Setup scripts | `setup/` | Automated bootstrap, setup, and update scripts |

> **The HealthBridge application repositories** (HealthBridge-Web, HealthBridge-Api, etc.) referenced throughout the documentation are **fictional**. They illustrate the kind of multi-repository workspace these agents are designed for.

### Use It for Your Project

Ready to adapt this framework to your own repositories? See [Adapt to Your Project](#adapt-to-your-project) for the step-by-step workflow — clone the demo, run the bootstrap script, and the setup agent rewrites all configuration for your project automatically.

---

## Agent Usage Examples

### Example 1: Code Review for a Branch

**Scenario:** You have a branch `HM-14200` and want to analyze its code quality, test coverage, and identify risks.

```
@hb-code-review HM-14200
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

| Format | Shorthand | Flag | Word Limit | Output File | Use Case |
|--------|-----------|------|------------|-------------|----------|
| **Comprehensive** (default) | _(none)_ | `--format comprehensive` | 1300 words | `<TICKET>-code-review.md` | Internal QA audit, team review |
| **Brief** | `brief` | `--format brief` | 300 words | `<TICKET>-code-review-brief.md` | GitHub PR comment, quick summary |
| **Both** | `both` | `--format both` | 1300 + 300 | Both files above | Full workflow: post brief to PR, keep comprehensive for records |

All outputs are saved to `DEMO-QA-Agents/reports/code-review/`.

**Examples:**

```
@hb-code-review HM-14200              # Comprehensive (default)
@hb-code-review HM-14200 brief        # Brief only (GitHub-ready)
@hb-code-review HM-14200 both         # Both formats simultaneously
```

---

### Example 2: Generate Acceptance Tests

**Scenario:** You need comprehensive test scenarios for a feature, bug fix, or requirement -- either from an existing branch or before development starts.

**When to use:**
- After code review, to plan detailed manual/automated testing
- Before development, to define expected behavior from requirements
- For bug fixes, to generate regression test scenarios
- When validating implementation against original requirements

**What you get:**
- Given/When/Then (BDD) acceptance test scenarios
- Happy path, alternative flow, error, and edge case coverage
- Regression test areas identification
- Automation candidates (Selenium, Playwright, Mobile)
- Requirements validation (if original requirements provided) -- shows Implemented / Missing / Modified / Extra
- Requirements Traceability Matrix (if requirements provided)

**Output:** `DEMO-QA-Agents/reports/acceptance-tests/<TICKET>-acceptance-tests.md` (no word limit)

**Input options:**

| Input Type | What Happens |
|------------|-------------|
| Branch ID only | Analyzes code changes, generates test scenarios from implementation |
| Branch ID + requirements | Analyzes code + validates implementation against requirements |
| Requirements only (no branch) | Generates test scenarios from requirements before development |

**Examples:**

```
@hb-acceptance-tests HM-14200
```

```
@hb-acceptance-tests HM-14200

Original Requirements:
- Doctor can prescribe controlled substances with dual authorization
- Prescription requires valid DEA number
- Patient allergy check must pass before prescribing
```

---

### Example 3: Bug Report from Error Message

**Scenario:** Production error found in logs -- need a ticket-ready bug report with root cause and fix options.

```
@hb-bug-report

Error: System.NullReferenceException
File: PrescriptionService.cs, line 234
Message: Object reference not set to an instance of an object

Stack trace:
at HealthBridge.Services.PrescriptionService.ValidatePrescription()
at HealthBridge.Controllers.PrescriptionController.Create()
```

**What you get:**
- Root cause analysis with code snippet
- **Codebase pattern search** -- finds similar bugs across all files
- 3 fix options (Quick / Standard / Recommended) with effort estimates
- Severity assessment (Critical / High / Medium / Low)
- Ticket-ready fields (Summary, Description, Steps, Story Points)
- Test recommendations
- Output: `DEMO-QA-Agents/reports/bug-report/<descriptive-name>-bug-report.md`

---

### Example 4: Root Cause Analysis for Bugfixes

**Scenario:** A bug was found -- either as a hotfix in a release or during general development. You need to understand why it happened and how to prevent similar issues.

**What you get:**
- Timeline: When bug was introduced, discovered, fixed
- Before/After code comparison
- 5 Whys analysis + Bugfix pattern match (Edge Case / NULL / Missing Implementation / etc.)
- Preventability assessment (Unit / Integration / E2E / Code Review / Requirements)
- E2E test recommendations with actual implementation code (C#/TypeScript)

**Outputs** (both in `DEMO-QA-Agents/reports/bugfix-rca/`):

| Document | Word Limit | Content |
|----------|-----------|---------|
| `<TICKET>-rca.md` | 1500 words | RCA report with timeline, 5 Whys, pattern match |
| `<TICKET>-e2e-test-recommendations.md` | No limit | Test code recommendations to prevent recurrence |

**Two modes** (auto-detected from input):

| Mode | Trigger | What It Does |
|------|---------|-------------|
| **Hotfix** | Mention `Release-X/YEAR` | Compares bugfix branch vs release branch |
| **Investigation** | Only ticket ID provided | Searches git history to trace bug origin |

**Examples:**
```
@hb-bugfix-rca HM-14200 Release-4/2026    # Auto-detects Hotfix Mode
@hb-bugfix-rca HM-14200                   # Auto-detects Investigation Mode
```

---

### Example 5: Requirements Analysis Before Development

**Scenario:** Product Owner has written requirements -- validate completeness before dev starts.

```
@hb-requirements-analysis HM-15000

Ticket: HM-15000
Title: Add electronic prescription refill workflow

Requirements:
- Patients can request prescription refills through the portal
- Doctor reviews and approves or denies refill requests
- Controlled substances require additional verification
- Refill history is logged in patient medical record
```

**What you get:**
- **Readiness score: X/10** (7+ = Ready for dev, <7 = More details needed)
- Business gap analysis
- Health domain compliance gaps (auto-detects domain from ticket keywords)
- Edge case identification (28% of hotfixes!)
- Multi-repository impact assessment
- Missing requirements checklist
- Questions for Product Owner
- Output: `DEMO-QA-Agents/reports/requirements-analysis/HM-15000-requirements-analysis.md`

**If score >= 7/10:** Agent automatically generates:
- Acceptance Tests: `HM-15000-acceptance-tests.md`
- Dev Estimation: `HM-15000-dev-estimation.md`

**If score < 7/10:** Stops with critical questions -- no QA/Dev work until clarified.

---

### Example 6: Release Risk Assessment

**Scenario:** Preparing Release-04/2026 for production -- need risk analysis and testing plan.

```
@hb-release-analysis release/Release-04/2026
```

**What you get:**
- Overall risk level (Low / Medium / Critical)
- PR-by-PR analysis with categories (Bug Fix / Feature / Enhancement / etc.)
- **E2E Regression Coverage** -- Shows which functional areas lack automated tests
- **E2E Test Maintenance Plan** -- CREATE/UPDATE/DELETE recommendations
- Manual testing checklist (prioritized)
- Go/No-Go recommendation
- Outputs (all in `DEMO-QA-Agents/reports/release-analysis/`):
  - `Release-04-2026-Risk-Assessment.md` (Full analysis)
  - `Release-04-2026-Release-Notes.md` (Customer-facing)
  - `Release-04-2026-Slack-Message.md` (Team notification)

---

### Common Workflows

#### Workflow 1: New Feature Development
```
1. @hb-requirements-analysis [ticket]          -> Validate requirements
2. (If score >=7) -> Acceptance Tests + Dev Estimation auto-generated
3. [Developer implements]
4. @hb-code-review [branch]                 -> Pre-merge review
5. @hb-acceptance-tests [branch]            -> Final test scenarios
```

#### Workflow 2: Bug Investigation and Fix
```
1. @hb-bug-report                           -> Analyze error, get fix options
2. [Developer implements fix]
3. @hb-bugfix-rca [branch]                     -> Understand root cause
4. @hb-code-review [branch]                 -> Ensure fix quality
```

#### Workflow 3: Release Preparation
```
1. @hb-release-analysis release/Release-XX/YYYY
2. Review risk assessment report
3. Execute E2E test plan (Section 4.4)
4. Perform manual testing (Section 6)
5. Share Slack message with team
```

#### Workflow 4: PR Review Process
```
1. @hb-code-review [branch] both
2. Post brief report to GitHub PR
3. Use comprehensive report for team review
4. If critical issues -> Request changes
5. If ready -> Approve
```

> **Note:** Repository sync happens automatically before each agent run. No need to sync manually unless you want to verify repo status via **F1** > "HealthBridge QA: Sync Repositories".

---

## Folder Structure

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
│   └── settings.local.json                     # Safe tool permissions
│
├── .vscode-extension/                          # VS Code Chat Extension
│   ├── src/
│   │   ├── extension.ts                        # Extension activation + agent registration + sync integration
│   │   └── repo-sync.ts                        # Safe repository sync engine (3 safety gates)
│   ├── package.json                            # Extension manifest + sync command registration
│   └── tsconfig.json
│
├── agents/                                     # Agent Definitions
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
│       ├── generate-repository-dependencies.md # Prompt: scan repos → generate dependency map
│       ├── generate-e2e-coverage-map.md        # Prompt: scan test repos → generate coverage matrix
│       └── generate-bugfix-patterns.md         # Prompt: analyze hotfix history → generate pattern tables
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
│   ├── bootstrap.bat                           # Windows double-click bootstrap (creates new project from DEMO)
│   ├── bootstrap.sh                            # macOS/Linux bootstrap (creates new project from DEMO)
│   ├── bootstrap.ps1                           # Windows PowerShell bootstrap
│   ├── setup.bat                               # Windows double-click setup (runs setup.ps1)
│   ├── setup.sh                                # macOS/Linux full environment setup
│   ├── setup.ps1                               # Windows PowerShell full environment setup
│   ├── update.bat                              # Windows double-click update (runs update.ps1)
│   ├── update.sh                               # macOS/Linux update (pull + config + extension)
│   ├── update.ps1                              # Windows PowerShell update (pull + config + extension)
│   ├── update-extension.sh                     # macOS/Linux extension-only rebuild + install
│   └── update-extension.ps1                    # Windows extension-only rebuild + install
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

---

## Shared Context Files

Agents read shared context files from `context/` before analysis to improve accuracy and reduce false positives.

| Context File | Path | Used By | Purpose |
|--------------|------|---------|---------|
| **E2E Coverage Map** | `context/e2e-test-coverage-map.md` | All agents | Maps functional areas to E2E frameworks (Selenium/Playwright/Mobile) |
| **Ticket Field Mappings** | `context/jira-field-mappings.md` | Bug Report, Release | Auto-detects ticket components from file paths |
| **False Positive Prevention** | `context/code-review-false-positive-prevention.md` | Code Review | 6 rules: framework safety nets, data flow guarantees, standard patterns, tool verification |
| **Repository Dependencies** | `context/healthbridge-repository-dependencies.md` | All agents | Consumer/Provider dependency map, blast radius, shared databases |
| **Historical Bugfix Patterns** | `context/historical-bugfix-patterns.md` | Code Review, Bugfix RCA | RCA-derived bugfix patterns by repo type for predictive bug detection |

### Domain Knowledge Context

Domain context files provide health management regulatory, business, and compliance knowledge for specific functional areas. Agents auto-detect the domain from ticket keywords and load the relevant file.

| Context File | Path | Domain | Trigger Keywords |
|--------------|------|--------|-----------------|
| **Prescriptions & Medications** | `context/domain-prescriptions.md` | Rx & Pharmacy | prescription, medication, refill, dosage, controlled substance, pharmacy, DEA |
| **Patient Records** | `context/domain-patient-records.md` | Medical Records | patient, chart, diagnosis, ICD, medical history, HIPAA, records |
| **Staff Scheduling** | `context/domain-staff-scheduling.md` | Workforce | scheduling, shift, roster, staff, availability, overtime |

---

## Output Locations

Reports are saved to `DEMO-QA-Agents/reports/` (from workspace root):

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

## Prompt Templates

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

---

## Troubleshooting

### Common Issues

| Problem | Cause | Solution |
|---------|-------|----------|
| Agent does not recognize ticket prefix | Config files not at workspace root | Re-copy: `cp DEMO-QA-Agents/.github/copilot-instructions.md .github/` |
| "No tests found" for a covered area | Stale E2E repo refs | Agent should `git fetch origin` before searching; verify with `git log origin/main -1` |
| Report has wrong section structure | Agent did not read template | Verify template exists in `prompts/<category>/` |
| Agent asks for confirmation instead of executing | Missing execution protocol in config | Re-copy `.claude/CLAUDE.md` or `.cursorrules` to workspace root |
| `git checkout` used during analysis | Agent violated safety rule | Report as bug; agents must use `git fetch` + remote tracking branches only |
| Empty report generated | Branch not found in any repo | Verify branch exists: `git branch -r --list "*HM-14200*"` in each repo |
| Windows: scripts fail silently | Execution policy | Run with: `powershell -ExecutionPolicy Bypass -File <script>` |
| Extension not loading after install | VS Code needs reload | **F1** > "Developer: Reload Window" |

### Verifying Agent Configuration

```bash
# Check that config files exist at workspace root
ls -la .github/copilot-instructions.md .cursorrules .claude/CLAUDE.md

# Check that all repos are cloned
ls -d HealthBridge-*/

# Check that extension is installed
code --list-extensions | grep hb-qa

# Check branch exists in a specific repo
cd HealthBridge-Web && git branch -r --list "*HM-14200*"
```

---

## Adapt to Your Project

This framework is designed to be reused. The agents, prompts, templates, and scoring models are **~70% generic** — only the project-specific configuration (names, repositories, ticket prefixes, domain knowledge) needs to change.

### Setup Workflow (7 Steps)

```
1. Open VS Code or Cursor
2. Create a workspace folder for your projects
3. Clone the DEMO project
4. Run bootstrap script → creates your project folder from DEMO (DEMO stays clean)
5. Build & install the VS Code extension
6. Open your project folder in VS Code
7. Run @setup agent → answer questions → all files updated → done
```

**Why this order?** The bootstrap script copies the DEMO into a fresh folder first, so the setup agent modifies your copy — never the original template. You can bootstrap multiple projects from the same DEMO.

### Step 1: Open VS Code or Cursor

Open VS Code (or Cursor) before proceeding — all following steps run from within the IDE terminal.

### Step 2: Create a Workspace Folder

Create a dedicated folder on your machine where all project repositories will live:

```bash
mkdir my-workspace
cd my-workspace
```

### Step 3: Clone the DEMO

```bash
git clone https://github.com/visma-kira-komshilova/DEMO-QA-Agents
cd DEMO-QA-Agents
```

### Step 4: Bootstrap Your Project

The bootstrap script copies all framework files into a new directory, excluding `.git`, `node_modules`, build artifacts, and generated reports. It then initializes a fresh git repo with an initial commit.

> Replace `<myproject-qa-agents>` with your actual project name — this becomes the name of the folder created for your adapted framework (e.g., `./setup/bootstrap.sh MyProject` creates `myproject-qa-agents/`).

**Windows — PowerShell:**
```powershell
.\setup\bootstrap.ps1 -ProjectName "<myproject-qa-agents>"

# Or specify a target directory:
.\setup\bootstrap.ps1 -ProjectName "<myproject-qa-agents>" -TargetDir "C:\Projects"
```

**macOS/Linux:**
```bash
./setup/bootstrap.sh <myproject-qa-agents>

# Or specify a target directory:
./setup/bootstrap.sh <myproject-qa-agents> ~/Projects
```

This creates a new folder `<myproject-qa-agents>/` with all framework files and a fresh git history.

### Step 5: Build & Install the VS Code Extension

```bash
cd ../<myproject-qa-agents>/.vscode-extension
npm install
npm run compile
npx vsce package --allow-missing-repository
code --install-extension *.vsix --force
cd ..
```

> **macOS:** If `code` is not found, open VS Code > Command Palette > "Shell Command: Install 'code' command in PATH"

### Step 6: Open the Project in VS Code

Open the bootstrapped project folder in VS Code:

```bash
cd ../<myproject-qa-agents>
code .
```

### Step 7: Run the Setup Agent

The **Setup Agent** is an interactive wizard that customizes the entire framework for your project. It runs in 4 phases:

```
@hb-setup
```

> **Important:** After the setup agent asks its first question, **clear `@hb-setup` from the input field** before typing your answer. If `@hb-setup` remains in the input, each reply will restart the setup from the beginning instead of continuing the conversation.

#### Phase 1: Collect (Interactive Questions)

The agent asks questions in 6 groups, one at a time:

| Group | Questions | What You Provide |
|-------|-----------|-----------------|
| **1. Project Identity** | Project name, agent chat prefix | e.g., "Acme Platform", prefix "acme" → creates `@acme-code-review`, `@acme-bug-report`, etc. |
| **2. Repositories** | Clone URLs + category (Core / Microservice / E2E) | Agent **clones each repo immediately**, then auto-detects technology, default branch, and release/hotfix branch conventions from git history |
| **3. JIRA Configuration** | Ticket prefixes + which repos each prefix maps to | e.g., `ACME-*` → acme-backend, acme-frontend |
| **4. E2E Frameworks** | Framework names + which repo contains the tests | e.g., Playwright → acme-e2e-tests. Type "none" if no E2E tests yet |
| **5. Business Domains** | Functional domain names for context files | e.g., Payments & Billing, User Management, Inventory |
| **6. Dev Context Docs** | Path to architectural docs (optional) | e.g., "acme-backend/docs/AGENTS-*.md" or "none" |

After all questions, the agent shows a **configuration summary** and asks for confirmation before proceeding.

#### Phase 2: Generate (Automated File Updates)

The agent updates **all** project-specific files automatically:

| What | Files |
|------|-------|
| IDE config files | `.claude/CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md` |
| VS Code extension | `.vscode-extension/package.json`, `extension.ts` |
| Setup scripts | `setup/setup.sh`, `setup.ps1`, `.code-workspace` |
| Agent definitions | `agents/vscode-chat-participants/*.md` (8 files) |
| Prompts & templates | `prompts/**/*.md` — project name, repo names, ticket IDs, E2E repo paths |
| Skeleton context files | `context/*.md` — repository dependencies, E2E coverage map, bugfix patterns, JIRA mappings, domain files |
| Report directories | `reports/` with all subdirectories + `.gitkeep` files |
| README | Updated last — removes DEMO-only sections, replaces all examples |
| Cleanup | Deletes old DEMO artifacts (`.vsix`, `node_modules`, old workspace file) |

#### Phase 3: Verify (Automated Legacy Scan)

The agent runs `scripts/check-legacy-demo.sh --fix-plan` to scan all files for leftover DEMO references across 6 categories:

| Category | What It Catches |
|----------|----------------|
| Project names | "HealthBridge", "Health Bridge" |
| Ticket prefixes | `HM-*`, `HBP-*`, `HMM-*` |
| Repository names | HealthBridge-Web, HealthBridge-Api, etc. |
| Domain terms | prescription, patient, appointment, pharmacy, HIPAA |
| DEMO references | "Clone the DEMO", "DEMO template", bootstrap instructions |
| E2E/Mobile frameworks | Playwright, Selenium, WebdriverIO, Flutter, Dart (if not applicable) |

If hits are found, the agent **auto-fixes** them and re-runs the script until clean. It also validates consistency (agent prefix across all files, workspace file matches setup scripts, all referenced context files exist).

#### Phase 4: Context Customization (Interactive + Auto-Generated)

The agent populates context files with real project data:

| Step | Mode | What Happens |
|------|------|-------------|
| **4.1 Repository Dependencies** | Auto-generated | Scans all cloned repos for API connections, shared databases, NuGet/npm packages → generates dependency map |
| **4.2 E2E Coverage Map** | Auto-generated | Scans test repos, maps test files to functional areas → generates coverage matrix. Skipped if no E2E frameworks |
| **4.3 Historical Bugfix Patterns** | Conditional | Asks: "Scan repos now or skip?" Needs 10+ hotfixes for meaningful patterns. Runs `prompts/setup/generate-bugfix-patterns.md` if chosen |
| **4.4 JIRA Field Mappings** | Guided | Scans repo directory structures, proposes file path → JIRA component mappings, asks you to confirm or adjust |
| **4.5 Domain Context Files** | Interactive | For each domain: asks about business rules, regulatory requirements, edge cases, and external integrations |
| **4.6 False Positive Prevention** | Optional | Asks for known safe code patterns that agents should not flag (e.g., "raw SQL in Reports/ is parameterized via ORM") |
| **4.7 Final Validation** | Auto-generated | Re-runs `scripts/check-legacy-demo.sh` to catch any leftovers introduced during context generation |

After setup completes, rebuild the VS Code extension and test:

```bash
cd .vscode-extension && npm install && npm run compile
npx vsce package --allow-missing-repository
code --install-extension *.vsix --force
```

Then reload VS Code (**F1** > "Developer: Reload Window") and verify: type `@<your-prefix>` in Copilot Chat.

### What Gets Customized

| Category | Files | Effort |
|----------|-------|--------|
| **Core Configuration** | `.claude/CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md` | Automated by setup agent |
| **VS Code Extension** | `.vscode-extension/package.json`, `extension.ts` | Automated by setup agent |
| **Setup Scripts** | `setup/setup.sh`, `setup.ps1`, `.code-workspace` | Automated by setup agent |
| **Agent Definitions** | `agents/vscode-chat-participants/*.md` (8 files) | Automated by setup agent |
| **Prompts & Templates** | `prompts/**/*.md` | Automated by setup agent |
| **Context Files** | `context/*.md` (domain knowledge, dependencies, patterns) | Auto-generated + interactive guided setup |

### What Stays Generic (Do NOT Change)

| Category | Why |
|----------|-----|
| Prompt files (`prompts/*/`) | Analysis logic, scoring models, report structures are project-agnostic |
| 7/10 scoring gate | Generic quality threshold for requirements validation |
| Report templates | Consistent output format across all projects |
| Non-destructive git strategy | `git fetch` + remote refs — universal safety pattern |
| Branch commit filtering | Works with any ticket prefix automatically |

### Context Files — Your Project Knowledge

After setup, the most impactful step is filling in your context files. These are what make agents smart about **your** project.

**Three context files have dedicated generation prompts** that analyze your codebase and generate the file automatically. Run these prompts in your IDE (paste the prompt file content into the AI chat, or reference the file):

| Priority | Context File | Generation Prompt | How It Works |
|----------|-------------|-------------------|--------------|
| **Start here** | `<project>-repository-dependencies.md` | `prompts/setup/generate-repository-dependencies.md` | Scans all repos for HTTP clients, DB connections, shared packages → generates dependency map |
| **Start here** | `e2e-test-coverage-map.md` | `prompts/setup/generate-e2e-coverage-map.md` | Scans test repos for test files, maps to functional areas → generates coverage matrix |
| After 10+ hotfixes | `historical-bugfix-patterns.md` | `prompts/setup/generate-bugfix-patterns.md` | Analyzes hotfix branches/commits, categorizes root causes → generates pattern tables per repo type |

**These context files must be filled in manually** (no generation prompt — they require domain expert knowledge):

| Priority | Context File | What to Add |
|----------|-------------|-------------|
| Add over time | `domain-*.md` | Business rules, regulatory requirements per functional area |
| Add over time | `jira-field-mappings.md` | File path → JIRA component auto-detection rules |
| Add over time | `code-review-false-positive-prevention.md` | Patterns that agents incorrectly flag as issues |

#### How to Run a Generation Prompt

**Claude Code:**
```bash
# Paste the prompt content or reference the file
cat prompts/setup/generate-repository-dependencies.md
# Then ask: "Run this prompt to generate my repository dependencies"
```

**VS Code / Cursor:**
1. Open the prompt file (e.g., `prompts/setup/generate-repository-dependencies.md`)
2. Copy its content into the AI chat
3. The AI will analyze your repos and generate the context file

**Re-run anytime:** These prompts are safe to re-run. They overwrite the previous output with fresh analysis.

### Building Your Historical Bugfix Patterns

The `historical-bugfix-patterns.md` file powers **predictive bug detection** — the Code Review agent checks new code against patterns that historically caused production hotfixes. The more accurate your patterns, the more real bugs get caught before merge.

**Start after your first 10-15 hotfixes.** You need enough data to see patterns. Before that, use the starter template (created by the bootstrap/setup agent) with placeholder percentages.

#### Generate with the AI Agent (Recommended)

A dedicated generation prompt automates the entire process — it scans your git history, finds hotfix branches/commits, analyzes code diffs, categorizes root causes, calculates percentages, and writes the output file:

```
prompts/setup/generate-bugfix-patterns.md
```

**How to run:**

| IDE | How |
|-----|-----|
| **VS Code / Cursor** | Open the prompt file, copy its content into the AI chat |
| **Claude Code** | `cat prompts/setup/generate-bugfix-patterns.md` then ask the AI to run it |

The agent performs these steps automatically:
1. Searches all repos for hotfix/bugfix branches and commits
2. Analyzes each hotfix's code diff to determine root cause category
3. Groups repositories by technology/architecture type
4. Calculates percentages per category per repo type
5. Writes `context/historical-bugfix-patterns.md` with project-specific detection focus

**Re-run anytime** — safe to re-run quarterly or after major incidents. Overwrites previous output with fresh analysis.

#### How It Works (Under the Hood)

For reference, this is the methodology the agent follows. You can also use these steps manually if you prefer:

<details>
<summary>Manual methodology (click to expand)</summary>

**Step 1: Collect hotfix data.** For each production hotfix in the last 6-12 months, record:

| Field | How to Find It |
|-------|---------------|
| Repository | Which repo was the fix in? |
| Root cause category | What type of mistake caused the bug? (see category list below) |
| File/area affected | Which module or functional area? |
| How it could have been caught | Code review? Unit test? E2E test? Better requirements? |

Use git history to find hotfix branches/commits:
```bash
# Find hotfix branches (adjust pattern to match your naming convention)
git branch -r --list "*hotfix*"
git branch -r --list "*bugfix*"

# Or search commit messages for hotfix indicators
git log --oneline --grep="hotfix" --since="2025-01-01"
git log --oneline --grep="fix" --grep="prod" --all-match --since="2025-01-01"
```

**Step 2: Categorize each hotfix.** Assign each hotfix to one of these common root cause categories:

| Category | What It Means | Example |
|----------|--------------|---------|
| Edge Cases | Code doesn't handle boundary/empty/unusual inputs | Empty list, zero quantity, date at year boundary |
| NULL Handling | Missing null/undefined checks | `FirstOrDefault()` without null check, optional field assumed present |
| Logic/Condition Errors | Incorrect business logic or control flow | Wrong operator, missing condition branch, off-by-one |
| Permission/Authorization | Access control gaps | Missing role check, wrong permission level |
| Data Validation | Invalid input accepted | Malformed format, out-of-range value, duplicate allowed |
| Configuration/DI Errors | Dependency injection or config mistakes | Missing DI registration, wrong service lifetime |
| Database/ORM Issues | Data layer bugs | Wrong column type, missing include, FK misconfiguration |
| Concurrency/Race Conditions | Thread safety or ordering issues | Concurrent writes, change tracking conflicts |
| Type Casting Errors | Wrong type conversions | Integer overflow, wrong data type in query |
| Missing Implementation | Incomplete features shipped | TODO left in code, stub not replaced |
| State Management | UI/app state lifecycle bugs | Stale state, disposed widget access, async races |
| Error Handling | Missing or wrong error handling | Swallowed exceptions, missing retry on transient failure |

**Step 3: Calculate percentages per repository type.** Group repositories by technology (e.g., all C# microservices together, frontend separately, mobile separately). Count how many hotfixes fall into each category:

```
Example: 40 hotfixes across 3 C# microservice repos
  NULL Handling:      9 hotfixes → 22%
  Configuration/DI:   7 hotfixes → 18%
  Logic/Condition:    6 hotfixes → 15%
  Database/EF Core:   6 hotfixes → 14%
  Edge Cases:         5 hotfixes → 12%
  ...
```

**Step 4: Write your pattern table.** Update `context/historical-bugfix-patterns.md` with one table per repository type. Follow the format in the demo file — each row needs: Pattern name, percentage, and Detection Focus (specific examples from your codebase).

</details>

#### Separate Tables per Repository Type

Different repository types produce different bug patterns. **Always create separate tables** for:

| Repository Type | Why Different Patterns |
|-----------------|----------------------|
| **Monolith / Web backend** | Business logic complexity, authorization layers, legacy code |
| **Microservice APIs** | DI configuration, database/ORM issues, inter-service contracts |
| **Frontend (React, Angular)** | State management, UI lifecycle, permission guards |
| **Mobile (Flutter, React Native)** | Navigation lifecycle, async state, calculation errors |
| **Background services / Workers** | Concurrency, retry logic, deployment configuration |

#### Keeping Patterns Current

- **Review quarterly** — Re-run the generation prompt to update percentages with new hotfix data
- **After major incidents** — Re-run to capture new pattern categories
- **When onboarding new repos** — Start with the closest existing pattern table, then re-run after 10+ hotfixes

---

## Note

This is a **demo/reference implementation** showcasing how multi-agent AI systems can be structured for QA automation in a multi-repository software ecosystem. The domain (health management), repository names, and ticket prefixes are fictional examples designed to illustrate the architecture and agent coordination patterns.

---

*Maintained by: HealthBridge QA Team*
