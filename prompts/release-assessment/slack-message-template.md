# Slack Release Assessment Message Template

## Purpose

Generate concise, actionable Slack notifications for release assessments.

## Target Audience

- Dev Team
- QA Team
- Tech Leads
- Release Managers

## Message Constraints

| Constraint | Value |
|------------|-------|
| **Target Length** | 250-350 words |
| **Maximum Length** | 500 words |
| **Format** | Slack markdown (bold, bullets, emojis) |
| **Tone** | Professional, direct, action-oriented |

---

## Message Structure

```
**[Release Name] Release Assessment**

**Repository:** [HealthBridge-Web | HealthBridge-Api | HealthBridge-Mobile]
**Planned Release:** [Date]
**PRs:** [X] | **Files:** [XXX] (+X,XXX/-X,XXX)
**Overall Risk:** Low | Medium | Critical

---

## HIGHLIGHTS

- **[HM-XXXXX]:** [Feature name] - [One line benefit/status]
- **[HM-XXXXX]:** [Feature name] - [One line benefit/status]
- **[HM-XXXXX]:** [Feature name] - [One line benefit/status]

---

## RISKS & GAPS

**Critical:** [X] PR(s) - [Brief description of blocking issues]
**Medium:** [X] PR(s) - [Brief description of concerns]
**Low:** [X] PR(s) - [Brief status]

**Key Issues:**
- **[HM-XXXXX]:** [Specific issue - e.g., "Patient safety fix without E2E tests"]
- **[HM-XXXXX]:** [Specific issue - e.g., "Large refactoring with no E2E coverage"]

---

## E2E REGRESSION COVERAGE

**Impacted Areas:** [X total areas affected by this release]
**E2E Coverage:** [X/Y areas covered] = [XX]%

**Covered Areas:**
- [Area 1] - [Framework: Playwright/Mobile]
- [Area 2] - [Framework: Playwright/Mobile]

**Gaps (Manual Testing Required):**
- [Area 3] - No E2E tests
- [Area 4] - No E2E tests

**Coverage Legend:**
- >= 70% - Good coverage
- 50-69% - Acceptable with caution
- < 50% - High risk, needs attention

---

## MANUAL TESTING REQUIRED

- **[HM-XXXXX]:** [Specific scenario] - [Priority: Critical/High/Medium]
- **[HM-XXXXX]:** [Specific scenario] - [Priority: Critical/High/Medium]
- **[HM-XXXXX]:** [Specific scenario] - [Priority: Critical/High/Medium]

---

## RECOMMENDATION

[Ready for Release | Conditional Release | Delay Recommended]

**Action Required:**
- [ ] [Specific action 1]
- [ ] [Specific action 2]
- [ ] [Specific action 3]

---

**Full Report:** `reports/week-release/Release-XX-YYYY-Risk-Assessment.md`

*Generated: [YYYY-MM-DD HH:MM]*
```

---

## Coverage Calculation Method

### E2E Regression Coverage for Impacted Areas

**Purpose:** Measure how many functional areas affected by this release are covered by existing E2E regression tests.

**Formula:**
```
E2E Regression Coverage = (Areas with E2E tests / Total impacted areas) x 100
```

**Steps:**

1. **Identify Impacted Areas** - Map each PR to functional area(s):
   - Prescriptions (medication processing, drug interactions, dosage calculations)
   - Patient Records (charts, admissions, discharges, vitals)
   - Appointments (scheduling, calendar, reminders)
   - Lab Results (diagnostics, test orders, result reporting)
   - Billing (insurance claims, payments, coverage)
   - Staff Management (scheduling, departments, roles)
   - Security (authentication, authorization)
   - Mobile (mobile-specific features)

2. **Check E2E Test Coverage** - For each impacted area, check if E2E tests exist:
   - **Covered:** E2E tests exist (Playwright/Mobile)
   - **Partially Covered:** Some tests exist but gaps identified
   - **No Coverage:** No E2E tests for this area

3. **Calculate Coverage:**
   ```
   Coverage = (Fully covered + 0.5 x Partially covered) / Total areas
   ```

**Example:**
```
Impacted Areas (7 total):
- Prescriptions - Drug Interactions (Playwright: prescriptions.spec.ts) -- Covered
- Patient Records - Discharge (No E2E) -- No Coverage
- Appointments - Reminders (Playwright: scheduling.spec.ts) -- Covered
- Lab Results - Reporting (No E2E) -- No Coverage
- Billing - Claims (No E2E) -- No Coverage
- Staff - Shift Scheduling (Partial: some shift tests exist) -- Partial
- Authentication - MFA (Playwright: auth.spec.ts) -- Covered

Coverage = (3 + 0.5 x 1) / 7 = 3.5 / 7 = 50% -- Acceptable
```

---

## Coverage Thresholds

### E2E Regression Coverage Thresholds

- **Good Coverage (>= 70%):** Most affected areas have E2E tests
- **Acceptable (50-69%):** Some gaps, manual testing needed
- **High Risk (< 50%):** Significant E2E gaps, heavy manual testing required

**Note:** This metric focuses on E2E regression testing because:
- E2E tests validate complete workflows (highest confidence for release)
- Unit/integration tests remain important but are per-PR concerns
- Release risk is about end-to-end functionality in affected areas
- Manual testing is acceptable for certain scenarios

---

## Writing Guidelines

### DO

- Start with positive highlights (3-5 items)
- Use specific ticket IDs (HM-XXXXX)
- Quantify risks (number of PRs affected)
- Provide actionable next steps
- Link to full detailed report
- Use formatting for quick visual scanning
- Keep total length under 500 words

### DON'T

- Lead with negative news
- Use vague language ("might need", "could be")
- Include technical implementation details
- List every single PR (focus on highlights + risks)
- Exceed 500 words
- Use jargon without context
- **Include time estimates** (e.g., "12-16h", "4-6h") - Focus on what needs to be done, not how long

---

## Example Messages

### Example 1: Good Release (Low Risk)

```
**Release-04/2026 Release Assessment**

**Repository:** HealthBridge-Web
**Planned Release:** Jan 21, 2026
**PRs:** 18 | **Files:** 85 (+4,200/-1,800)
**Overall Risk:** Low

---

## HIGHLIGHTS

- **HM-14200:** Prescription refill automation - Streamlined workflow for recurring medications
- **HM-14175:** Lab result trending - Enhanced diagnostic visualization
- **HM-14150:** Appointment reminder SMS - Reduced no-show rates

---

## RISKS & GAPS

**Critical:** 0 PR(s)
**Medium:** 2 PR(s) - Require manual testing
**Low:** 16 PR(s) - Ready to go

**Key Issues:**
- **HM-14280:** Performance optimization lacks load testing validation
- **HM-14220:** Complex insurance claim logic needs E2E coverage

---

## E2E REGRESSION COVERAGE

**Impacted Areas:** 5 total
**E2E Coverage:** 4/5 areas covered = 80%

**Covered Areas:**
- Prescriptions - Refill workflow - Playwright (prescriptions.spec.ts)
- Lab Results - Trending - Playwright (lab-results.spec.ts)
- Appointments - Reminders - Playwright (scheduling.spec.ts)
- Authentication - MFA - Playwright (auth.spec.ts)

**Gaps (Manual Testing Required):**
- Insurance Claims - Complex billing - No E2E tests

---

## MANUAL TESTING REQUIRED

- **HM-14280:** Load test with 500+ concurrent users - High
- **HM-14220:** Multi-provider insurance claim scenarios - Medium

---

## RECOMMENDATION

**Ready for Release**

**Action Required:**
- [ ] Complete manual load testing for HM-14280
- [ ] Validate insurance claim edge cases

---

**Full Report:** `reports/week-release/Release-04-2026-Risk-Assessment.md`

*Generated: 2026-01-20 14:30*
```

---

### Example 2: Risky Release (Critical Risk)

```
**Release-04/2026 Release Assessment**

**Repository:** HealthBridge-Web
**Planned Release:** Jan 21, 2026
**PRs:** 18 | **Files:** 85 (+4,200/-1,800)
**Overall Risk:** Critical

---

## HIGHLIGHTS

- **HM-14200:** Prescription refill automation - Good test coverage
- **HM-14150:** Appointment reminder - E2E validated
- **HM-14340:** Cache improvement - Ready

---

## RISKS & GAPS

**Critical:** 2 PR(s) - **BLOCKING ISSUES**
**Medium:** 5 PR(s) - Manual testing required
**Low:** 11 PR(s)

**Key Issues:**
- **HM-14399:** Patient data access fix WITHOUT security tests - **BLOCKING**
- **HM-14175:** 2K LOC clinical logic refactoring with NO E2E coverage - **BLOCKING**
- **HM-14280:** Performance optimization with no load testing
- **HM-14220:** Complex claim logic without E2E validation

---

## E2E REGRESSION COVERAGE

**Impacted Areas:** 7 total
**E2E Coverage:** 2/7 areas covered = 29%

**Covered Areas:**
- Prescriptions - Refill - Playwright (prescriptions.spec.ts)
- Authentication - MFA - Playwright (auth.spec.ts)

**Gaps (Manual Testing Required):**
- Patient Records - Discharge workflow - No E2E tests
- Lab Results - Alert notifications - No E2E tests
- Insurance Claims - Billing - No E2E tests
- Security - Patient data access - No security E2E tests
- Appointments - Complex scheduling - No E2E tests

---

## MANUAL TESTING REQUIRED (CRITICAL)

- **HM-14399:** Security validation - Unauthorized access scenarios - **CRITICAL**
- **HM-14175:** Clinical logic regression - 20 scenarios - **CRITICAL**
- **HM-14280:** Load testing with 500+ users - High
- **HM-14220:** Insurance claim edge cases - High

---

## RECOMMENDATION

**DELAY RECOMMENDED**

**Action Required (BEFORE RELEASE):**
- [ ] **HM-14399:** Add security E2E tests
- [ ] **HM-14175:** Add clinical workflow E2E tests
- [ ] **Review:** Consider splitting release - deploy low-risk PRs first

---

**Full Report:** `reports/week-release/Release-04-2026-Risk-Assessment.md`

*Generated: 2026-01-20 14:30*
```

---

## File Naming Convention

**Location:** `reports/week-release/`

**Naming Pattern:** `Release-[XX]-[YYYY]-Slack-Message.md`

**Examples:**
- `Release-04-2026-Slack-Message.md`
- `Release-39-2025-Slack-Message.md`

---

## Integration with Release Assessment Agent

The Slack message generator is spawned as a sub-agent after the main risk assessment is complete.

**Workflow:**
1. Main agent analyzes all PRs -> generates full risk assessment report
2. Main agent spawns Slack Message Generator sub-agent
3. Sub-agent reads full report -> extracts key metrics -> generates Slack message
4. Both files saved to `reports/week-release/`

**Input to sub-agent:**
- Full risk assessment markdown report
- PR summary data
- Test coverage analysis results

**Output:**
- Concise Slack message (250-500 words)
- Saved as separate `.md` file
- Can be copy-pasted directly to Slack

---

*Template Version: 1.0*
