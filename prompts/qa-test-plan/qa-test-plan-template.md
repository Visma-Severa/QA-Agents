# QA Test Plan Template

This template defines the structure and format for QA test planning documents based on requirements analysis for the HealthBridge health management platform.

## PATH NAMING CONVENTION

**CRITICAL:** Always use **hyphens** (`-`) not underscores (`_`) in output paths:
- Correct: `reports/requirements-analysis/[TICKET]-qa-test-plan.md` (when part of workflow)
- Wrong: `reports/qa_test_plan/` (old location, deprecated)

## CRITICAL CONSTRAINTS

| Constraint | Value | Enforcement |
|------------|-------|-------------|
| **Word Count** | **No hard cap — aim for conciseness** | Use tables over prose. See per-section budgets below. |
| **Prerequisites** | **Requirements completeness >= 7/10** | Only generate if requirements are sufficiently complete (scored per `requirements-analysis-template.md` rubric) |
| **Test Automation Analysis** | **ALL applicable frameworks** | Selenium (Python), Playwright (TypeScript), and Mobile (WebdriverIO) — analyze all existing tests |
| **Effort Estimates** | **Detailed task-level** | Specific hours per test scenario/automation change |
| **Format** | **Tables for data, Given/When/Then for test cases** | Test scenarios use Gherkin; everything else uses tables |

### Per-Section Word Budgets (Soft Targets)

| Section | Budget | Notes |
|---------|--------|-------|
| 1. Test Scope Summary | ~100 words | Prose-light, bullet points |
| 2. Manual Test Scenarios | No limit | Gherkin format, as many scenarios as needed |
| 3. Test Automation Analysis | No limit | Table-heavy, tables don't inflate word count meaningfully |
| 4. Test Data Requirements | ~150 words | Checklists and tables |
| 5. Test Environment | ~100 words | Checklists |
| 6. Test Execution Strategy | ~100 words | Tables |
| 7. QA Effort Estimates | No limit | Tables with line-item estimates |
| 8. Test Risks | ~100 words | Table |
| 9. Entry & Exit Criteria | ~100 words | Checklists |
| 10-11. Deliverables & Sign-off | ~50 words | Checklists, boilerplate |

### Prerequisites: Requirements Completeness Check

The 7/10 threshold is scored using the rubric in `requirements-analysis-template.md`. If the requirements analysis document does not exist or has not been generated:
- Set **Test Readiness** to `Blocked`
- List the missing document as a blocker in Section 8 (Risks)
- Do NOT generate the test plan until requirements are scored

---

## Report Structure

```markdown
# QA Test Plan: [TICKET-ID] - [Title]

**Ticket:** [TICKET-ID]
**Requirements Reference:** `[TICKET-ID]-requirements-analysis.md`
**Test Plan Created By:** [QA Analyst Name]
**Date Created:** YYYY-MM-DD
**Test Readiness:** Ready | Waiting for Clarification | Blocked
**RCA Reference:** `reports/bugfix-rca/[TICKET-ID]_Root_Cause_Analysis.md` _(if applicable — omit if no RCA exists)_

---

## 1. Test Scope Summary _(~100 words)_

**Features to Test:**
- [Feature/functionality 1]
- [Feature/functionality 2]
- [Feature/functionality 3]

**Out of Scope:**
- [What will NOT be tested in this iteration]
- [Deferred to future releases]

**Test Environments:**
- [ ] Development (healthbridge-dev.example.com)
- [ ] Staging (healthbridge-stg.example.com)
- [ ] Production smoke test (after deployment)

**Affected Modules:**
- [Module 1 - e.g., Prescriptions]
- [Module 2 - e.g., Patient Records]

---

## 2. Manual Test Scenarios

**Use Given/When/Then format for clarity**

### 2.1 Happy Path Tests

#### Test Case 1: [Main Success Scenario]
**Given** [precondition - system state, user role, test data]
**When** [action - what user does]
**Then** [expected result - what should happen]

**Test Steps:**
1. [Detailed step 1]
2. [Detailed step 2]
3. [Detailed step 3]

**Expected Result:** [Clear pass criteria]
**Test Data:** [Specific data needed]
**Priority:** Critical / High / Medium / Low

#### Test Case 2: [Secondary Success Scenario]
[Same format as above]

### 2.2 Edge Case Tests

**Based on historical bugfix analysis, edge cases are the #1 hotfix pattern (see `context/historical-bugfix-patterns.md` for repo-specific %)**

> _If an RCA report exists for this ticket, derive edge cases from the pattern match and 5 Whys findings._

#### Test Case 3: [Null/Empty State]
**Given** [empty patient list / null allergy record / no prescription history]
**When** [user action]
**Then** [expected handling - error message / empty state / default value]

**Test Steps:**
1. [Step]

**Expected Result:** [Clear pass criteria]
**Test Data:** [Setup needed for empty state]
**Priority:** Critical / High

#### Test Case 4: [Boundary Value]
**Given** [zero dosage / maximum appointment slots / date at period boundary]
**When** [user action]
**Then** [expected validation / handling]

**Test Steps:**
1. [Step]

**Expected Result:** [Clear pass criteria]
**Test Data:** [Specific boundary values]
**Priority:** High / Medium

#### Test Case 5: [Timing/Concurrency]
**Given** [concurrent clinicians / end of billing period / session timeout]
**When** [user action]
**Then** [expected conflict resolution / locking behavior]

**Test Steps:**
1. [Step]

**Expected Result:** [Clear pass criteria]
**Test Data:** [Setup needed]
**Priority:** High / Medium

### 2.3 Error Scenario Tests

#### Test Case 6: [Validation Error]
**Given** [invalid dosage / malformed diagnosis code / expired license]
**When** [user attempts to save/submit]
**Then** [validation error displayed, data not saved]

**Test Steps:**
1. [Step to trigger validation error]

**Expected Result:** [Error message text, field highlighting]
**Test Data:** [Invalid data examples]
**Priority:** Critical / High

#### Test Case 7: [System Error]
**Given** [external health registry unavailable / database error]
**When** [user action]
**Then** [graceful error handling, rollback, user notification]

**Test Steps:**
1. [Step - may need to simulate failure]

**Expected Result:** [Error handling behavior]
**Test Data:** [Setup needed]
**Priority:** High / Medium

### 2.4 Exploratory Test Areas

> _Derive exploratory areas from: (1) integration points identified in requirements, (2) historical bugfix patterns for this module (see CLAUDE.md pattern tables), (3) any TODO/FIXME found in code review._

**Areas requiring exploratory testing:**
- [ ] [Area 1 - e.g., Complex patient workflows across multiple screens]
- [ ] [Area 2 - e.g., Integration with external health registries]
- [ ] [Area 3 - e.g., Performance under concurrent clinician load]

**Focus:** [What to explore, what patterns to look for]

---

## 3. Test Automation Analysis

**CRITICAL: Analyze ALL applicable test automation frameworks**

Consult `context/e2e-test-coverage-map.md` to determine which frameworks are in scope for the affected functional area. The coverage map contains: Quick Reference Table (functional area -> framework), Detailed tables per framework (Module, Test Folder, Key Test Files, Search Keywords), and standardized Coverage Status Definitions (Full/Partial/Gap/N/A).

### 3.1 Selenium Tests (Python)

**Repository:** `HealthBridge-Selenium-Tests/`
**Covers:** Prescriptions, Patient Records, Insurance Claims, Billing (see coverage map for full list)

**Search Strategy:**
- Search for feature-related test files across ALL test directories
- Use keyword-first search (do NOT limit to a single subdirectory)

```
Grep pattern: "<feature-keyword>" path: "HealthBridge-Selenium-Tests" glob: "*.py"
```

#### Selenium Applicability Check

**Does the coverage map include this functional area for Selenium?**
- [ ] YES - Functional area is in Selenium scope, needs testing
- [ ] PARTIAL - Some aspects covered by Selenium, others not
- [ ] NO - Outside Selenium scope (skip to next framework)

**If YES or PARTIAL:**

#### Tests to UPDATE

| Test File | Test Name | Current Behavior | Required Change | Priority | Estimate |
|-----------|-----------|------------------|-----------------|----------|----------|
| [path/file.py] | [test name] | [What it currently tests] | [What needs to change] | Critical/High/Medium | [X.Xh] |

**Update Subtotal:** [X.X hours]

#### Tests to DELETE

| Test File | Test Name | Reason for Deletion | Priority | Estimate |
|-----------|-----------|---------------------|----------|----------|
| [path/file.py] | [test name] | [Why - e.g., obsolete feature, duplicate test] | High/Medium | [X.Xh] |

**Delete Subtotal:** [X.X hours]

#### Tests to ADD

| Test Scenario | Test File (new/existing) | Test Name | Description | Priority | Estimate |
|---------------|--------------------------|-----------|-------------|----------|----------|
| [What to test] | [Where to add] | [test name] | [What the test does] | Critical/High/Medium | [X.Xh] |

**Add Subtotal:** [X.X hours]

#### Selenium Test Coverage Assessment

**Existing Coverage:** [Percentage or description]

**Gaps Identified:**
- [ ] [Gap 1]
- [ ] [Gap 2]

**Selenium Total Estimate:** [Update + Delete + Add = X.X hours]

---

### 3.2 Playwright E2E Tests (TypeScript)

**Repository:** `HealthBridge-E2E-Tests/`
**Covers:** Appointments, Scheduling, Lab Results, Staff Scheduling (see coverage map for full list)

**Search Strategy:**
- Search for feature-related test files in `tests/` directory
- Check page objects in `pages/` directory
- Review test scenarios in spec files

```
Grep pattern: "<feature-keyword>" path: "HealthBridge-E2E-Tests" glob: "*.spec.ts"
Glob pattern: "**/<feature>*.spec.ts" path: "HealthBridge-E2E-Tests"
```

#### Playwright Applicability Check

**Does the coverage map include this functional area for Playwright?**
- [ ] YES - Functional area is in Playwright scope, needs testing
- [ ] PARTIAL - Some aspects covered by Playwright, others not
- [ ] NO - Outside Playwright scope (skip to next framework)

**If YES or PARTIAL:**

#### Tests to UPDATE

| Test File | Test Name | Current Behavior | Required Change | Priority | Estimate |
|-----------|-----------|------------------|-----------------|----------|----------|
| [path/file.spec.ts] | [test name] | [What it currently tests] | [What needs to change] | Critical/High/Medium | [X.Xh] |

**Update Subtotal:** [X.X hours]

#### Tests to DELETE

| Test File | Test Name | Reason for Deletion | Priority | Estimate |
|-----------|-----------|---------------------|----------|----------|
| [path/file.spec.ts] | [test name] | [Why - e.g., obsolete feature, duplicate test] | High/Medium | [X.Xh] |

**Delete Subtotal:** [X.X hours]

#### Tests to ADD

| Test Scenario | Test File (new/existing) | Test Name | Description | Priority | Estimate |
|---------------|--------------------------|-----------|-------------|----------|----------|
| [What to test] | [Where to add] | [test name] | [What the test does] | Critical/High/Medium | [X.Xh] |
| Example: Book appointment | `appointments.spec.ts` | `should book appointment with date validation` | Verify booking creates appointment, validates date conflicts | Critical | 1.5h |

**Add Subtotal:** [X.X hours]

#### Playwright Test Coverage Assessment

**Existing Coverage:** [Percentage or description - e.g., 60% of happy paths, no edge cases]

**Gaps Identified:**
- [ ] [Gap 1 - e.g., No tests for drug interaction validation errors]
- [ ] [Gap 2 - e.g., No tests for concurrent clinician scenarios]

**Playwright Total Estimate:** [Update + Delete + Add = X.X hours]

---

### 3.3 Mobile Tests (WebdriverIO)

**Repository:** `HealthBridge-Mobile-Tests/`
**Covers:** Prescriptions (approval), Appointments, Lab Results (viewing), Reimbursements (see coverage map for full list)

**Search Strategy:**
- Search for feature-related test files in `test/` directory
- Check if mobile app includes this feature
- Review existing mobile test coverage

```
Grep pattern: "<feature-keyword>" path: "HealthBridge-Mobile-Tests" glob: "*.js"
Glob pattern: "**/<feature>*.js" path: "HealthBridge-Mobile-Tests"
```

#### Mobile Applicability Check

**Does the coverage map include this functional area for Mobile?**
- [ ] YES - Feature exists in mobile, needs testing
- [ ] PARTIAL - Some aspects in mobile, some web-only
- [ ] NO - Web-only feature, mobile out of scope

**If YES or PARTIAL:**

#### Tests to UPDATE

| Test File | Test Name | Current Behavior | Required Change | Priority | Estimate |
|-----------|-----------|------------------|-----------------|----------|----------|
| [path/file.js] | [test name] | [What it currently tests] | [What needs to change] | Critical/High/Medium | [X.Xh] |

**Update Subtotal:** [X.X hours]

#### Tests to DELETE

| Test File | Test Name | Reason for Deletion | Priority | Estimate |
|-----------|-----------|---------------------|----------|----------|
| [path/file.js] | [test name] | [Why] | High/Medium | [X.Xh] |

**Delete Subtotal:** [X.X hours]

#### Tests to ADD

| Test Scenario | Test File (new/existing) | Test Name | Description | Priority | Estimate |
|---------------|--------------------------|-----------|-------------|----------|----------|
| [What to test] | [Where to add] | [test name] | [What the test does] | Critical/High/Medium | [X.Xh] |

**Add Subtotal:** [X.X hours]

#### Mobile Test Coverage Assessment

**Existing Coverage:** [Percentage or description]

**Gaps Identified:**
- [ ] [Gap 1]
- [ ] [Gap 2]

**Mobile Total Estimate:** [Update + Delete + Add = X.X hours]

---

### 3.4 Test Automation Summary

| Framework | Update | Delete | Add | Total |
|-----------|--------|--------|-----|-------|
| **Selenium (Python)** | [X.X]h | [X.X]h | [X.X]h | [X.X]h |
| **Playwright (TS)** | [X.X]h | [X.X]h | [X.X]h | [X.X]h |
| **Mobile (WDIO)** | [X.X]h | [X.X]h | [X.X]h | [X.X]h |
| **TOTAL** | [X.X]h | [X.X]h | [X.X]h | **[X.X]h** |

**Test Automation Priority Breakdown:**
- Critical (P1): [X.X] hours - Must complete before release
- High (P2): [X.X] hours - Should complete before release
- Medium (P3): [X.X] hours - Can defer if needed

---

## 4. Test Data Requirements _(~150 words)_

### 4.1 Test Environments

| Environment | Clinic/Organization | Purpose | Setup Requirements |
|-------------|---------------------|---------|-------------------|
| Dev | [Clinic name or ID] | [What it's used for] | [What data needs to exist] |
| Staging | [Clinic name or ID] | [What it's used for] | [What data needs to exist] |

### 4.2 Master Data Setup

**Required before testing:**
- [ ] [Data type 1 - e.g., Patients with specific conditions and allergies]
  - Count needed: [X]
  - Attributes: [List specific requirements]

- [ ] [Data type 2 - e.g., Prescriptions with specific medications and dosages]
  - Details: [Specific requirements]

- [ ] [Data type 3 - e.g., Clinician accounts with specific roles and department access]
  - Roles needed: [List]

### 4.3 Edge Case Test Data

**Specific data for edge case testing:**
- [ ] [Empty state - e.g., Patient with no allergy records]
- [ ] [Boundary value - e.g., Prescription at maximum dosage limit]
- [ ] [Special characters - e.g., Patient name with diacritics, hyphens]
- [ ] [Null values - e.g., Optional insurance fields left empty]

### 4.4 Data Cleanup

**Post-test cleanup required:**
- [ ] [What data to delete/reset after testing]
- [ ] [How to restore environment to clean state]

---

## 5. Test Environment & Configuration _(~100 words)_

### 5.1 Environment Setup

**Development Environment:**
- [ ] Feature flag: [Name] enabled for test clinics
- [ ] Database: [Any special configuration]
- [ ] Integrations: [Any external health systems to configure]

**Staging Environment:**
- [ ] Feature flag: [Name] enabled/disabled
- [ ] Database: [Any special configuration]
- [ ] Integrations: [Any external health systems to configure]

### 5.2 Test Tools & Access

**Required access:**
- [ ] QA user accounts with [specific clinical roles]
- [ ] Admin access for test data setup
- [ ] Database access (if needed for verification)
- [ ] Log access for debugging failures

**Test tools needed:**
- [ ] Playwright browsers installed
- [ ] Mobile emulators/devices
- [ ] API testing tools (Postman/Insomnia)

### 5.3 Browser/Device Coverage

**Web Testing:**
- [ ] Chrome (latest) — always required
- [ ] Firefox (latest) — always required
- [ ] Safari — check if any CSS/layout changes or macOS-specific features are in scope
- [ ] Edge — check if ticket affects admin portal used by enterprise clinic customers

**Mobile Testing:**
- [ ] iOS (version X.X+)
- [ ] Android (version X.X+)

---

## 6. Test Execution Strategy _(~100 words)_

### 6.1 Test Phases

**Phase 1: Smoke Testing (Post-deployment)**
- Duration: [X hours]
- Tests: [Critical path tests only]
- Blocker criteria: [What would block release]

**Phase 2: Functional Testing**
- Duration: [X hours/days]
- Tests: [All manual test cases]
- Pass criteria: [Percentage or specific tests]

**Phase 3: Regression Testing**
- Duration: [X hours/days]
- Tests: [Automated test suite]
- Pass criteria: [Percentage pass rate]

**Phase 4: Exploratory Testing**
- Duration: [X hours]
- Focus: [Areas identified in section 2.4]

### 6.2 Test Execution Schedule

> _Derive dates from: Section 7 effort estimates + deployment timeline. Phase 1 starts on staging deployment day. Each subsequent phase starts after the previous phase's duration._

| Phase | Start Date | End Date | Assigned To | Status |
|-------|-----------|----------|-------------|--------|
| Phase 1 | [Date] | [Date] | [QA Name] | Pending |
| Phase 2 | [Date] | [Date] | [QA Name] | Pending |
| Phase 3 | [Date] | [Date] | [Automation] | Pending |
| Phase 4 | [Date] | [Date] | [QA Name] | Pending |

---

## 7. QA Effort Estimates

### 7.1 Manual Testing Effort

> _Calibration: ~0.5h per happy path test, ~0.75h per edge case test, ~1h per error scenario (includes setup, execution, and documentation). Adjust based on feature complexity._

| Activity | Estimate | Notes |
|----------|----------|-------|
| **Test Case Execution** | | |
| - Happy path tests | [X.X]h | [Number of test cases] |
| - Edge case tests | [X.X]h | [Number of test cases] |
| - Error scenario tests | [X.X]h | [Number of test cases] |
| - Exploratory testing | [X.X]h | [Focus areas] |
| **Test Data Setup** | [X.X]h | [What needs to be created] |
| **Environment Configuration** | [X.X]h | [Feature flags, settings] |
| **Regression Testing (Manual)** | [X.X]h | [Related features to retest] |
| **Test Documentation** | [X.X]h | [Update test cases, report] |
| **MANUAL TESTING SUBTOTAL** | **[X.X]h** | **~[X.X] days** |

### 7.2 Test Automation Effort

| Activity | Estimate | Notes |
|----------|----------|-------|
| **Selenium Automation** | | |
| - Update existing tests | [X.X]h | [From section 3.1] |
| - Delete obsolete tests | [X.X]h | [From section 3.1] |
| - Add new tests | [X.X]h | [From section 3.1] |
| **Playwright Automation** | | |
| - Update existing tests | [X.X]h | [From section 3.2] |
| - Delete obsolete tests | [X.X]h | [From section 3.2] |
| - Add new tests | [X.X]h | [From section 3.2] |
| **Mobile Automation** | | |
| - Update existing tests | [X.X]h | [From section 3.3] |
| - Delete obsolete tests | [X.X]h | [From section 3.3] |
| - Add new tests | [X.X]h | [From section 3.3] |
| **Test Maintenance** | [X.X]h | [Code review, refactoring] |
| **CI/CD Pipeline Updates** | [X.X]h | [If pipeline changes needed] |
| **AUTOMATION SUBTOTAL** | **[X.X]h** | **~[X.X] days** |

### 7.3 Total QA Effort Summary

| Category | Estimate (Hours) | Estimate (Days) | Notes |
|----------|------------------|-----------------|-------|
| Manual Testing | [X.X]h | [X.X]d | [1 day = 8 hours] |
| Test Automation | [X.X]h | [X.X]d | [Can parallelize with dev] |
| **TOTAL QA EFFORT** | **[X.X]h** | **~[X.X]d** | [Calendar days vs. effort days] |

**Assumptions:**
- 1 QA day = 8 hours of focused testing
- Automation can start when dev completes feature flag
- Manual testing starts when feature deployed to staging

**Contingency:** Add 15% buffer for bug fixes and retesting on top of the total estimate. This is a risk-based contingency, not a calculated line item.

**Risk Factors:**
- [ ] Test data complexity: [Low/Medium/High]
- [ ] Environment stability: [Stable/Unstable]
- [ ] Feature complexity: [Low/Medium/High]
- [ ] Regression scope: [Small/Medium/Large]

---

## 8. Test Risks & Mitigation _(~100 words)_

| Risk | Impact | Probability | Mitigation Strategy | Owner |
|------|--------|-------------|---------------------|-------|
| [Risk 1 - e.g., Patient test data unavailable] | High/Medium/Low | High/Medium/Low | [How to prevent/handle] | [QA Lead] |
| [Risk 2 - e.g., Staging environment unstable] | High/Medium/Low | High/Medium/Low | [How to prevent/handle] | [DevOps] |
| [Risk 3 - e.g., Automated tests flaky] | High/Medium/Low | High/Medium/Low | [How to prevent/handle] | [QA Automation] |
| [Risk 4 - e.g., Requirements analysis missing] | High | [Probability] | Set Test Readiness to Blocked, escalate to PO | [QA Lead] |

---

## 9. Entry & Exit Criteria _(~100 words)_

### 9.1 Entry Criteria (Ready to Test)

**Manual Testing:**
- [ ] Feature deployed to staging environment
- [ ] Feature flag enabled for test clinics
- [ ] Test data prepared and verified
- [ ] Test cases reviewed and approved
- [ ] Smoke test passed (no critical blockers)

**Automation Testing:**
- [ ] Feature code merged to main branch
- [ ] API/backend endpoints stable
- [ ] Page objects/selectors updated (if UI changed)
- [ ] Test environment accessible from CI/CD

### 9.2 Exit Criteria (Done Testing)

**Manual Testing:**
- [ ] All P1/P2 test cases executed
- [ ] Pass rate >= 95% for P1/P2 tests, >= 85% overall (adjust per ticket risk level)
- [ ] All critical bugs fixed and verified
- [ ] Regression testing passed
- [ ] Test summary report completed

**Automation Testing:**
- [ ] All test updates completed and merged
- [ ] New tests added and passing
- [ ] Obsolete tests removed
- [ ] CI/CD pipeline green (>= 90% pass rate, adjust per ticket risk level)
- [ ] Code review approved

---

## 10. Test Deliverables

**Documents:**
- [ ] This test plan (approved by QA Lead + Dev Lead)
- [ ] Test execution report (after testing complete)
- [ ] Bug reports (in issue tracker)
- [ ] Test coverage report (from automation)

**Artifacts:**
- [ ] Updated automated test code (merged to repo)
- [ ] Test data scripts (for setup/teardown)
- [ ] Screenshots/videos (for bug reports)
- [ ] Performance metrics (if applicable)

---

## 11. Sign-off

| Role | Name | Approval Date | Signature/Comments |
|------|------|---------------|-------------------|
| **QA Lead** | [Name] | [Date] | [ ] Approved / [ ] Changes Requested |
| **Dev Lead** | [Name] | [Date] | [ ] Approved / [ ] Changes Requested |
| **Product Owner** | [Name] | [Date] | [ ] Approved / [ ] Changes Requested |

**Comments/Change Requests:**
- [Any feedback or requested changes]

---

**Date Completed:** YYYY-MM-DD
**QA Analyst:** [Name]
**Review Status:** [ ] Reviewed | [ ] Approved | [ ] In Testing | [ ] Complete
```

---

## Usage Guidelines

### When to Use This Template

1. **After Requirements Analysis** - When requirements completeness >= 7/10 (scored per `requirements-analysis-template.md`)
2. **Before Development Starts** - For test-first approach
3. **During Sprint Planning** - To estimate QA effort accurately

### How to Fill It Out

1. **Reference Requirements Analysis** - Link to the requirements document. If it doesn't exist, set Test Readiness to Blocked.
2. **Check Coverage Map** - Read `context/e2e-test-coverage-map.md` to determine which frameworks apply
3. **Search Test Repositories** - Use `Grep` and `Glob` tools to find existing tests
4. **Be Specific** - Exact file paths, method names, line numbers
5. **Realistic Estimates** - Based on similar past work
6. **Include Contingency** - 15% buffer for unknowns and bug fixing (in Section 7.3)

### Quality Checklist

- [ ] All applicable test automation frameworks analyzed (Selenium, Playwright, Mobile)
- [ ] Coverage map consulted to determine framework applicability
- [ ] Existing tests searched using Grep/Glob tools
- [ ] Specific file paths and method names provided
- [ ] Effort estimates are detailed (task-level, not feature-level)
- [ ] Test data requirements documented
- [ ] Entry/exit criteria defined
- [ ] Cross-referenced with requirements analysis document

---

## Test Automation Analysis Tips

### Effective Search Strategies

**Selenium (Python):**
```
Grep pattern: "prescription|medication" path: "HealthBridge-Selenium-Tests" glob: "*.py"
Glob pattern: "**/prescription*.py" path: "HealthBridge-Selenium-Tests"
```

**Playwright (TypeScript):**
```
Grep pattern: "prescription|medication" path: "HealthBridge-E2E-Tests" glob: "*.spec.ts"
Glob pattern: "**/prescription*.spec.ts" path: "HealthBridge-E2E-Tests"
```

**Mobile (WebdriverIO):**
```
Grep pattern: "prescription|medication" path: "HealthBridge-Mobile-Tests" glob: "*.js"
Glob pattern: "**/prescription*.js" path: "HealthBridge-Mobile-Tests"
```

### Reading Test Code

When you find relevant tests:
1. Use `Read` tool to understand current implementation
2. Check test assertions - what do they expect?
3. Identify page objects - what selectors are used?
4. Note test data setup - what dependencies exist?

### Estimating Test Effort

**Typical estimates:**
- Update simple assertion: 0.25h (15 min)
- Update complex test logic: 0.5-1h
- Add simple new test: 1-2h
- Add complex new test with setup: 2-4h
- Delete obsolete test: 0.25h (15 min)

Adjust based on:
- Test complexity
- Number of dependencies
- Page object changes needed
- Test data requirements

---

**Template Version:** 1.2
**Last Updated:** 2026-03-05
**Related Templates:**
- `requirements-analysis-template.md` (prerequisite — contains 7/10 scoring rubric)
- `dev-estimation-template.md` (companion)
