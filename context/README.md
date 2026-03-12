# Context Files

This directory contains shared domain knowledge and test coverage data used by all QA AI agents in the HealthBridge ecosystem. Context files provide the foundational reference material that agents consult during code reviews, acceptance test generation, bug report analysis, and other QA workflows.

## Why Context Files Exist

QA agents need consistent, accurate domain knowledge to produce reliable analysis. Rather than embedding this knowledge in each agent definition, shared context files serve as a single source of truth that all agents reference. This ensures:

- Consistent domain terminology across all reports
- Accurate E2E test coverage assessments
- Up-to-date business rules and validation logic
- Correct regulatory compliance checks

## Available Context Files

| File | Purpose |
|------|---------|
| [e2e-test-coverage-map.md](e2e-test-coverage-map.md) | Maps functional areas to E2E test frameworks (Web/API and Mobile). Used by all agents to determine which test suites to search for existing coverage and where to recommend new tests. |
| [domain-prescriptions.md](domain-prescriptions.md) | Domain knowledge for Prescriptions/Medications features. Includes regulatory requirements, business rules, data validation, integration points, and common edge cases for testing. |
| [domain-patient-records.md](domain-patient-records.md) | Domain knowledge for Patient Records and Medical History. Covers HIPAA compliance, ICD-10/CPT coding, consent workflows, data sharing rules, chart management, and clinical documentation requirements. |
| [domain-staff-scheduling.md](domain-staff-scheduling.md) | Domain knowledge for Staff Scheduling and Workforce Management. Covers shift management, rotation patterns, credential verification, coverage requirements, overtime regulations, on-call rules, and ACGME duty hour limits. |
| [code-review-false-positive-prevention.md](code-review-false-positive-prevention.md) | Documented patterns that agents must understand before flagging code review issues. Covers framework-level safety nets, end-to-end data flow analysis, standard codebase patterns, medical data type conversions, tool verification requirements, and change direction analysis. Reduces false positives in code reviews. |
| [jira-field-mappings.md](jira-field-mappings.md) | Auto-detection rules for JIRA fields based on code analysis. Maps file paths to components (Patient Records, Prescriptions, Lab Results, Billing, Insurance Claims, Staff Scheduling, Appointments, Pharmacy, Compliance), generates labels, detects severity, and suggests priority, assignee, and fix versions. |
| [healthbridge-repository-dependencies.md](healthbridge-repository-dependencies.md) | Cross-repository dependency map for all 22 HealthBridge repositories. Documents HTTP API dependencies between health services, shared databases (patient DB, staff DB, claims DB), shared NuGet packages, architecture overview, and blast radius analysis for change impact assessment. |
| [historical-bugfix-patterns.md](historical-bugfix-patterns.md) | RCA-derived bugfix patterns by repository type for predictive bug detection. Tracks top hotfix causes (edge cases, NULL handling, logic errors, etc.) with percentages per technology stack. Used by Code Review and Bugfix RCA agents. |
| [domain-context-template.md](domain-context-template.md) | Template for creating new domain context files. Provides the standard structure including sections for regulatory requirements, business rules, edge cases, integration requirements, validation rules, compliance calendar, and terminology. Use this when adding a new health domain area. |

## How Agents Use Context Files

Agents automatically load relevant context files based on the feature area being analyzed:

- **Code Review Agent** reads the coverage map to assess E2E test gaps, the false positive prevention guide to avoid incorrect findings, the repository dependency map to assess blast radius, and the relevant domain file to validate business logic correctness.
- **Acceptance Tests Agent** reads domain files to generate comprehensive test scenarios covering edge cases and regulatory requirements.
- **Bug Report Agent** references domain rules to determine expected vs actual behavior, and uses JIRA field mappings to auto-populate bug report fields.
- **Bugfix RCA Agent** checks the coverage map to recommend E2E tests that would have caught the bug, and uses the repository dependency map to trace cross-service impact.
- **Requirements Analysis Agent** reads domain files to validate that requirements address all mandatory regulatory and business rules for the affected area.
- **Release Analysis Agent** uses the repository dependency map to assess cross-service risk and the coverage map to identify test gaps for changed areas.

## Adding New Context Files

To add a new domain context file, copy `domain-context-template.md` and fill in the sections for your domain area. Each domain context file should include:

1. A header explaining when to use the file
2. Regulatory or compliance requirements
3. Business rules with edge cases
4. Data validation rules
5. Integration points
6. Common edge cases for testing
7. An agent checklist

After creating the file, add an entry to the table above so other contributors can discover it.
