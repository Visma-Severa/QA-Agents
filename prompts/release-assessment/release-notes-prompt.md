# Release Notes Generation Prompt

Generate customer-facing release notes for HealthBridge releases.

## Purpose

Transform technical PR information into clear, non-technical release notes that help customers understand:
- What's new and improved
- How changes benefit them
- What UI changes they'll notice

## Output Location

`reports/week-release/Release-XX-YYYY-Release-Notes.md`

## Constraints

| Constraint | Value |
|------------|-------|
| **Target Length** | 400-600 words |
| **Maximum Length** | 800 words |
| **Highlights** | Max 5 items |
| **Changes by Area** | Max 2 sentences per PR |
| **Bug Fixes** | Max 5 items |
| **Trim Priority** | If over limit, cut: (1) low-impact bug fixes, (2) minor UI changes, (3) improvement PRs. Never trim Highlights or patient-safety items. |

**Edge Case — No Customer-Visible Changes:** If all PRs are excluded by filtering heuristics, generate only the Header and Footer with the note: *"This release contains internal improvements and infrastructure updates only. No customer-visible changes are included."*

---

## Document Structure

### 1. Header
```markdown
# HealthBridge Release Notes - Release XX/YYYY

**Release Date:** [Date]
**Version:** Release-XX/YYYY
```

### 2. Highlights (Top 3-5 Features)

**Selection criteria:** Prioritize by (1) highest customer visibility, (2) new features over improvements, (3) patient safety or compliance relevance. Exclude internal improvements even if large in scope.

```markdown
## Highlights

- **[Feature Name]** - One sentence benefit description
- **[Feature Name]** - One sentence benefit description
- **[Feature Name]** - One sentence benefit description
```

### 3. Changes by Area
Organize customer-visible changes by functional area. Only include sections for areas that have PRs in this release — the areas below are examples, not a fixed list. Use the full Area Categorization table (including Reporting & Analytics and User Interface) for mapping.

```markdown
## What's New and Improved

### Prescriptions & Medications
- **[PR Title]** (PR #XXX) - Customer benefit explanation

### Patient Records & Charts
- **[PR Title]** (PR #XXX) - Customer benefit explanation

### Appointments & Scheduling
- **[PR Title]** (PR #XXX) - Customer benefit explanation

### Insurance & Billing
- **[PR Title]** (PR #XXX) - Customer benefit explanation

### Lab Results & Diagnostics
- **[PR Title]** (PR #XXX) - Customer benefit explanation

### Integrations
- **[PR Title]** (PR #XXX) - Customer benefit explanation
```

### 4. User Interface Changes
```markdown
## User Interface Changes

### New UI Elements
- [Description of new buttons, screens, or features]

### Improved UI Elements
- [Description of enhanced existing elements]

### Visual Enhancements
- [Description of design improvements]
```

### 5. Bug Fixes (Customer-Impacting Only)
```markdown
## Bug Fixes

- **[Area]**: Fixed issue where [problem description] (PR #XXX)
```

### 6. Footer
```markdown
---

**Need Help?** Contact HealthBridge Support
**Documentation:** [Link to relevant docs]

*Release notes generated for Release-XX/YYYY*
```

---

## Content Rules

### INCLUDE
| Type | Examples |
|------|----------|
| New features | New buttons, screens, calculations, reports |
| Feature improvements | Enhanced workflows, better performance visible to users |
| UI changes | New layouts, redesigned screens, new icons |
| Customer-impacting bug fixes | Issues users could encounter |
| Integration changes | New or improved external connections |

### EXCLUDE
| Type | Examples |
|------|----------|
| Infrastructure | CI/CD, Docker, deployment scripts |
| Internal tooling | Developer tools, test utilities |
| Refactoring | Code cleanup with no visible impact |
| Test-only changes | Unit tests, test fixtures |
| Dependency updates | NuGet/npm updates (unless security-related) |
| Documentation | README updates, code comments |

### PR Filtering Heuristics
Skip PRs where:
- Title contains: `refactor`, `cleanup`, `ci:`, `chore:`, `test:`, `docs:`
- Only files changed are in: `Tests/`, `.github/`, `docs/`
- Title contains: `bump`, `upgrade`, `dependency`

**Note:** When used as part of a release analysis run, these heuristics supplement the agent's exclusion list — apply both. When used standalone, these heuristics are the primary filter.

---

## Writing Guidelines

### Tone
- **Professional but friendly** - "We've improved..." not "The system now..."
- **Benefit-focused** - "You can now..." not "Added feature X"
- **Action-oriented** - "Easily export..." not "Export functionality added"

### Language
| Avoid | Use Instead |
|-------|-------------|
| "Implemented new endpoint" | "You can now connect to..." |
| "Fixed null reference exception" | "Fixed an issue that could cause errors when..." |
| "Refactored calculation logic" | "Improved accuracy of calculations for..." |
| "Added validation" | "The system now checks that..." |
| "Updated database schema" | [Skip - internal change] |

### Formatting
- Use **bold** for feature names
- Use bullet points for lists
- Keep descriptions to 1-2 sentences
- Include PR numbers for traceability

---

## Area Categorization

Map PR content to customer-facing areas. Functional area categories should align with those in `context/e2e-test-coverage-map.md` — if a new area is added to the coverage map, add it here too.

If a PR cannot be mapped to any listed area, include it under `[Other Improvements]` rather than silently skipping it.

| Code Indicators | Area |
|-----------------|------|
| `Prescription`, `Medication`, `Dosage`, `Pharmacy`, `DrugInteraction` | Prescriptions & Medications |
| `Patient`, `Record`, `Chart`, `Admission`, `Discharge`, `Vitals` | Patient Records & Charts |
| `Appointment`, `Schedule`, `Calendar`, `Booking`, `Slot` | Appointments & Scheduling |
| `Insurance`, `Claim`, `Billing`, `Payment`, `Coverage` | Insurance & Billing |
| `Lab`, `Result`, `Diagnostic`, `TestOrder`, `Specimen` | Lab Results & Diagnostics |
| `Report`, `Analytics`, `Dashboard`, `Export`, `Print` | Reporting & Analytics |
| `Integration`, `API`, `Webhook`, `External`, `Import` | Integrations |
| `UI`, `Button`, `Dialog`, `Form`, `Layout`, `Style` | User Interface |

---

## Example Output

```markdown
# HealthBridge Release Notes - Release 02/2026

**Release Date:** January 10, 2026
**Version:** Release-02/2026

---

## Highlights

- **Enhanced Drug Interaction Alerts** - More accurate interaction checking with updated medication database
- **New Appointment Reminder System** - Automated patient notifications via SMS and email
- **Improved Lab Result Dashboard** - Faster loading with better filtering options

---

## What's New and Improved

### Prescriptions & Medications

- **Drug Interaction Database Update** (PR #1234) - Prescription safety checks now include the latest FDA interaction data, ensuring more accurate alerts when prescribing multiple medications.

- **Dosage Calculator Enhancement** (PR #1235) - You can now preview calculated dosages for weight-based medications before finalizing the prescription.

### Appointments & Scheduling

- **Automated Appointment Reminders** (PR #1236) - Patients now receive automatic SMS and email reminders 24 hours before their appointment, reducing no-show rates.

### Lab Results & Diagnostics

- **Lab Dashboard Performance** (PR #1237) - Lab result dashboard loads up to 50% faster, especially for patients with extensive test history.

---

## User Interface Changes

### New UI Elements
- New "Preview Dosage" button on the prescription creation page
- Added confirmation dialog before sending bulk appointment reminders

### Improved UI Elements
- Redesigned lab result filter dropdown for easier test selection
- Updated prescription preview with clearer dosage formatting

---

## Bug Fixes

- **Prescriptions**: Fixed an issue where certain drug interaction alerts could show incorrect severity for elderly patients (PR #1234)
- **Lab Results**: Fixed a display issue where long test names were cut off in the results table (PR #1238)

---

**Need Help?** Contact HealthBridge Support at support@healthbridge.example.com
**Documentation:** https://docs.healthbridge.example.com

*Release notes generated for Release-02/2026*
```

---

## Integration with Release Assessment Agent

This prompt is used by the **Release Analysis Agent** to generate release notes alongside the risk assessment report. Both documents are generated from the same PR analysis:

| Output | Location | Audience |
|--------|----------|----------|
| Risk Assessment | `reports/week-release/` | QA Team, Developers |
| Release Notes | `reports/week-release/` | Customers, Support |

The agent reuses PR categorization from the risk assessment to ensure consistency.
