# Changelog

All notable changes to the HealthBridge QA Agents project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-27

### Added

#### QA Agents (7 agents)
- **Code Review Agent** (`@hb-code-review`): Analyze PR/branch for code quality, test gaps, and risks
  - Comprehensive report (1300 words max) and brief mode (450 words)
  - Predictive bug detection based on historical hotfix patterns
  - E2E test coverage gap analysis across all 3 frameworks
  - Client-server security consistency check
  - Interactive developer feedback mode with deep analysis
- **Acceptance Tests Agent** (`@hb-acceptance-tests`): Generate Given/When/Then test scenarios
  - Requirements validation (compare implementation vs original requirements)
  - Coverage summary reporting
- **Bug Report Agent** (`@hb-bug-report`): Analyze errors and generate ticket-ready bug reports
  - 7-phase analysis framework
  - Codebase pattern search (finds same bug in other files)
  - 3 fix options with complexity assessment
  - Data-driven severity assessment (Critical/High/Medium/Low)
- **Bugfix RCA Agent** (`@hb-bugfix-rca`): Root cause analysis for production hotfixes
  - Auto-detects Hotfix Mode (Release-X/YEAR) vs Investigation Mode
  - 7-section mandatory structure with Bugfix Pattern Match section
  - E2E test recommendation generation
- **Requirements Analysis Agent** (`@hb-requirements-analysis`): Pre-development requirements validation
  - 7/10 completeness scoring gate
  - Auto-generates QA Test Plan + DEV Estimation when score >= 7
  - 3-phase workflow pipeline with decision logic
- **Release Analysis Agent** (`@hb-release-analysis`): Release risk assessment
  - E2E regression coverage metric (area-based formula)
  - Release composition table
  - 3-tier risk: Low / Medium / Critical
  - Generates Risk Assessment, Release Notes, and Slack Message
- **Feedback Agent** (`@hb-feedback`): Interactive developer feedback collection
  - Rate findings as Valid / False Positive / Won't Fix / Provide More Information
  - Deep analysis workflow for detailed investigation
  - JSON output for accuracy tracking

#### Infrastructure
- VS Code chat extension (`.vscode-extension/`) with 7 chat participants
  - TypeScript extension with tool-calling loop (runTerminal, readFile, searchFiles)
  - Auto-repo-sync with 5-minute cooldown and safety gates
- Cross-platform setup scripts (macOS/Linux/Windows): `setup/setup.sh`, `setup.ps1`, `setup.bat`
- Cross-platform update scripts: `setup/update.sh`, `update.ps1`, `update.bat`
- Extension rebuild scripts: `setup/update-extension.sh`, `update-extension.ps1`
- Repository update script: `scripts/update-all-repos.sh`
- VS Code workspace file: `HealthBridge.code-workspace` (10 repos)
- GitHub Actions: PR analysis, bugfix RCA, release assessment
- CI/CD validation workflow: `.github/workflows/validate-prompts.yml`

#### Configuration
- `.claude/CLAUDE.md` - Global instructions for Claude Code
- `.github/copilot-instructions.md` - Global instructions for GitHub Copilot
- `.cursorrules` - Global instructions for Cursor IDE
- `.claude/settings.local.json` - Safe tool permissions
- `.gitignore` - Standard project ignores

#### Context Files
- E2E test coverage map (`context/e2e-test-coverage-map.md`)
- Domain: Prescriptions & Medications (`context/domain-prescriptions.md`)
- Domain: Patient Records (`context/domain-patient-records.md`)
- Domain: Staff Scheduling (`context/domain-staff-scheduling.md`)
- Code review false positive prevention rules (`context/code-review-false-positive-prevention.md`)
- Ticket field mappings (`context/jira-field-mappings.md`)
- Repository dependency map (`context/healthbridge-repository-dependencies.md`)
- Domain context template (`context/domain-context-template.md`)

#### Prompt Templates
- Code Review: comprehensive template, brief template, main prompt, findings-detailed, README
- Bug Report: template, 7-phase prompt, severity criteria, README
- Bugfix RCA: template
- Requirements Analysis: template, main prompt, workflow orchestrator, README
- Release Assessment: prompt, template, release notes, slack message
- Dev Estimation: template
- QA Test Plan: template
- Feedback: template

#### Documentation
- Comprehensive README with architecture, setup, usage, and troubleshooting
- Product Owner Getting Started guide (`docs/PO_GETTING_STARTED.md`)
- This changelog

### Multi-Repository Support
- 10 repositories across 4 categories:
  - 4 core applications (HealthBridge-Web, Portal, Api, Mobile)
  - 2 microservice APIs (Claims-Processing, Prescriptions-Api)
  - 3 test automation frameworks (Selenium, Playwright E2E, Mobile)
  - 1 QA agents (DEMO-QA-Agents)

### Historical Bugfix Patterns
- Web/API (HM-*): Edge Cases 28%, Authorization 22%, NULL 18%, Logic 16%, Validation 10%, Missing Impl 6%
- Mobile (HMM-*): Calculation 30%, State Mgmt 25%, Navigation 20%, Edge Cases 15%
- Microservices: NULL 22%, Config/DI 18%, Logic 16%, DB/EF Core 14%, Edge Cases 12%
- Claims-Processing: Concurrency 23%, CI/CD 19%, Data Validation 14%, Logic 12%
- Portal (HBP-*): Permission 25%, NULL 20%, Date Calculations 18%, UI Events 15%
