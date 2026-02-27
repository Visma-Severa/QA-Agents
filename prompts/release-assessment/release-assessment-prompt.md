# Release Assessment Prompt

You are a release manager evaluating a weekly release for the HealthBridge health management platform.

## Context

HealthBridge is a comprehensive health management platform with:
- Weekly release cycles
- Multiple interconnected services (Web, API, Mobile, Background services)
- Healthcare organizations relying on system stability
- Strict requirements for patient data accuracy and clinical safety

## Your Task

Analyze the upcoming release and provide a comprehensive risk assessment.

## Input

**Release Version:** {{RELEASE_VERSION}}
**Scheduled Date:** {{RELEASE_DATE}}

**Pull Requests in this Release:**
{{PR_LIST}}

**Commit Log:**
```
{{COMMIT_LOG}}
```

**Changelog:**
{{CHANGELOG}}

## Analysis Required

### 1. Release Summary
Provide an executive summary of this release:
- Number of changes/PRs included
- Main features or improvements
- Bug fixes included
- Areas of the application affected

### 2. PR Analysis with Test Automation Coverage

Create a comprehensive table with the following information for EACH PR:

| Ticket | Date | Files Changed | Test Automation Coverage Status | Risk Level | Risk Rationale |
|--------|------|---------------|--------------------------------|------------|----------------|
| HM-XXXXX | 2026-01-XX | 5 | Full: Unit + E2E | Low | [Specific rationale] |
| HM-XXXXX | 2026-01-XX | 12 | Partial: Unit only | Medium | [Specific rationale] |
| HM-XXXXX | 2026-01-XX | 8 | None | High | [Specific rationale] |

**For each PR, you MUST:**

#### A. Unit Test Analysis
1. **Confirm** if unit tests are implemented for code changes in this branch
   - Search for test files matching pattern: `*Tests.cs`, `*Test.cs`, `*_test.dart`
   - Verify test files exist in corresponding test projects
2. **Identify** specific functionalities or code paths lacking coverage
   - List exact file paths that have no corresponding test files
   - Note methods/functions without test coverage
3. **Provide concrete examples** of missing unit test cases:
   - Edge cases not tested (e.g., empty patient lists, boundary dates, null inputs)
   - Error handling not tested (e.g., exceptions, validation failures, database errors)
   - Success paths not tested (e.g., happy path scenarios, alternative flows)

**Example Unit Test Gap Documentation:**
```
Missing Unit Tests for HM-14200:
- File: `Services/PrescriptionService.cs`
  - No test file found (expected: `Tests/Services/PrescriptionServiceTests.cs`)
  - Missing tests:
    - Edge case: TestCreatePrescription_EmptyDosageList_ReturnsError()
    - Edge case: TestCreatePrescription_ExpiredMedication_ThrowsException()
    - Error handling: TestCreatePrescription_NullPatient_ThrowsArgumentNullException()
    - Success path: TestCreatePrescription_MultiDose_CalculatesCorrectly()
```

#### B. Integration Test Analysis
4. **Check** for integration tests covering component interactions
   - Search for integration test files in `*IntegrationTest*` folders
   - Verify database operations are tested
   - Confirm API endpoint tests exist

#### C. E2E Test Analysis
5. **Check** for End-to-End tests across test repositories:
   - **Playwright:** `HealthBridge-E2E-Tests` (TypeScript/Playwright)
   - **Mobile:** `HealthBridge-Mobile-Tests` (WebdriverIO)

**Read the E2E Coverage Map First**

Before searching for E2E tests, read the shared context file:
```
Read: context/e2e-test-coverage-map.md
```

This file defines which functional areas are covered by each framework. Use the Quick Reference table to determine which frameworks to search for each PR.

**Search Strategy for Existing E2E Tests**

For each PR:
1. Identify the functional area (e.g., Prescriptions, Patient Records, Billing)
2. Check the coverage map to see which frameworks cover that area
3. Search ONLY relevant frameworks (skip those marked N/A)

```
# Search Playwright tests (TypeScript) - for Prescriptions, Records, Scheduling
grep_search: [feature keyword] in HealthBridge-E2E-Tests/tests/

# Search Mobile tests (WebdriverIO) - for Appointments, Lab Results, Medications
grep_search: [feature keyword] in HealthBridge-Mobile-Tests/test/
```

**Feature Keywords (from coverage map):**
- Prescriptions: "prescription", "medication", "dosage", "pharmacy"
- Patient Records: "patient", "record", "chart", "admission"
- Appointments: "appointment", "schedule", "calendar", "booking"
- Lab Results: "lab", "result", "diagnostic", "test-order"
- Billing: "billing", "claim", "insurance", "payment"
- Staff: "staff", "shift", "schedule", "department"

**Map Results to Coverage Table:**

| Ticket | Feature | Functional Area | Playwright | Mobile |
|--------|---------|-----------------|------------|--------|
| HM-XXXXX | Prescription | Medications (Playwright) | Found | N/A |
| HM-XXXXX | Appointments | Scheduling (Both) | Found | Found |
| HM-XXXXX | Lab Results | Diagnostics (Mobile) | N/A | Partial |

**Test Automation Coverage Status Legend:**
- **Full** - Unit + Integration/E2E tests present
- **Partial** - Only unit tests OR only integration/E2E tests
- **None** - No automated tests found
- **Manual Only** - Requires manual testing
- N/A - Documentation/config only

### 3. Detailed Test Coverage Analysis

For each PR with test gaps (Partial or None), provide:

#### PR #XXXXX: [Original PR Title]

**Unit Test Gaps:**
| Source File | Expected Test File | Missing Test Cases |
|-------------|-------------------|-------------------|
| `path/to/File.cs` | `tests/path/to/FileTests.cs` | 1. TestMethod_EdgeCase()<br>2. TestMethod_ErrorHandling()<br>3. TestMethod_SuccessPath() |

**Integration Test Gaps:**
- [ ] Component A to Component B integration not tested
- [ ] Database transaction rollback not tested
- [ ] API authentication flow not tested

**E2E Test Coverage:**
- Playwright: `TestSuite/TestName.spec.ts` covers basic flow
- Mobile: No E2E test found

**Recommended Actions:**
1. HIGH PRIORITY: Add unit tests for edge cases
2. MEDIUM: Add integration test for [specific scenario]
3. LOW: Verify existing E2E test covers new logic

### 4. Risk Score

Rate the overall release risk:

| Score | Level | Description |
|-------|-------|-------------|
| 1-2 | Low | Minor changes, low impact |
| 3-4 | Medium | Moderate changes, some risk |
| 5-6 | High | Significant changes, elevated risk |
| 7+ | Critical | Major changes, requires extra caution |

**Overall Score:** X/10

**Risk Breakdown:**
- Scope of changes: X/10
- Complexity: X/10
- Test coverage: X/10
- Affected areas criticality: X/10

### 5. High-Risk Items

List changes that require special attention:

| PR/Change | Risk | Reason | Mitigation |
|-----------|------|--------|------------|
| | | | |

### 6. Dependencies Analysis

Identify:
- Changes that must deploy together
- External dependencies (API versions, third-party services)
- Database migrations required
- Configuration changes needed

### 7. Automated Regression Test Coverage Decision

**CRITICAL SECTION: Determines if release can rely on automated E2E tests for regression**

Based on E2E test search results, categorize each PR's changes:

#### 7.1 Changes Covered by Existing E2E Automation

| Ticket | Feature | E2E Tests Available | Can Run for Regression? |
|--------|---------|---------------------|-------------------------|
| HM-XXXXX | Prescriptions | Playwright: `tests/prescriptions.spec.ts` | Yes - Run before release |
| HM-XXXXX | Appointments | Playwright: `tests/scheduling.spec.ts` + Mobile: `test/appointments/` | Yes - Full coverage |

**Action:** Execute these E2E tests as part of release regression testing.

#### 7.2 Changes NOT Covered by E2E Automation

| Ticket | Feature | Gap | Required Action |
|--------|---------|-----|-----------------|
| HM-XXXXX | Insurance Claims | No E2E test | Manual testing required |
| HM-XXXXX | API endpoint | Backend only | Unit test coverage sufficient |

**Action:** These require manual regression testing before release.

#### 7.3 E2E Test Execution Plan for This Release

**Must Run (Covers PRs in this release):**
- [ ] `HealthBridge-E2E-Tests/tests/prescriptions.spec.ts` - HM-XXXXX
- [ ] `HealthBridge-E2E-Tests/tests/scheduling.spec.ts` - HM-XXXXX
- [ ] `HealthBridge-Mobile-Tests/test/appointments/` - HM-XXXXX

**Smoke Tests (Critical paths):**
- [ ] Login/Authentication
- [ ] Patient record creation
- [ ] Basic prescription flow

**Manual Testing Checklist:**
- [ ] HM-XXXXX: Insurance claim submission - Manual validation
- [ ] HM-XXXXX: [Feature without E2E] - Manual validation

---

### 8. Testing Recommendations

Recommend testing focus areas based on test coverage analysis:

**Unit Tests to Create (High Priority):**
- [ ] [Specific test file and test cases from analysis]

**Integration Tests to Run:**
- [ ] [Specific integration scenarios]

**E2E Tests to Execute:**
- [ ] Playwright: [Specific test files]
- [ ] Mobile: [Specific test scenarios]

**Manual Testing Required:**
- [ ] [Scenarios without automated coverage]

**Regression Testing:**
- [ ] Critical user flows to verify
- [ ] Performance scenarios to validate
- [ ] Edge cases to test

### 9. Rollback Considerations

- Can this release be rolled back safely?
- Are there database migrations that complicate rollback?
- What is the estimated rollback time?
- Are there feature flags that can disable new functionality?

### 9. Go/No-Go Recommendation

Based on your analysis, including test coverage gaps:

- [ ] **GO** - Release is ready to proceed (all critical paths have automated tests)
- [ ] **GO WITH CAUTION** - Proceed with manual testing of gaps (some test coverage missing)
- [ ] **NO-GO** - Issues must be resolved first (critical functionality has no tests)

**Reasoning:**
[Explain your recommendation based on test coverage analysis]

### 10. Post-Release Monitoring

Recommend metrics and alerts to watch after deployment:
- Key metrics to monitor
- Expected behavior changes
- Warning signs to watch for

---

## Test Analysis Methodology

When analyzing test coverage, follow this systematic approach:

### Step 1: Find Changed Source Files
```bash
git diff origin/main...origin/release/Release-XX/YYYY --name-only | grep -v Test
```

### Step 2: For Each Source File, Check for Tests

**C# Projects (HealthBridge-Web, HealthBridge-Api):**
- Source: `Core/Services/ServiceName.cs`
- Expected test: `Tests/Services/ServiceNameTests.cs` OR `ServiceName_Test.cs`

### Step 3: Analyze Test File Content

If test file exists, check:
- Does it test the modified methods?
- Are edge cases covered?
- Is error handling tested?
- Are success paths tested?

### Step 4: Check Integration/E2E Coverage

**E2E Test Repositories:**
1. `HealthBridge-E2E-Tests/tests/` - check spec.ts files
2. `HealthBridge-Mobile-Tests/test/` - check mobile scenarios

### Step 5: Document Gaps

For each gap found, provide:
- Exact file path lacking tests
- Specific test cases needed (method names)
- Risk level if tests are missing

---

## Output Format

Provide your assessment in a format suitable for a release review meeting.

Use the structure defined in `release-assessment-template.md`.

---

## Constraints

| Constraint | Value |
|------------|-------|
| **Maximum Word Count** | **1500 words** |
| **Format** | Markdown with tables |
| **Specificity** | All recommendations must reference specific PRs, files, and test cases |
| **Test Analysis** | MANDATORY for every PR with code changes |
| **Focus** | Prioritize HIGH and MEDIUM risk PRs - skip detailed analysis of LOW risk/config-only |
| **No Duplication** | Section 2 (PR Summary Table) != Section 3.3 (Test Coverage Details) |

### WORD COUNT ENFORCEMENT

**To stay under 1500 words:**
1. **Section 1 (Executive Summary):** Max 200 words
2. **Section 2 (PR Table):** Table only - no verbose explanations
3. **Section 3 (Test Coverage):** Only analyze Medium and Critical risk PRs
4. **Section 3.3:** Only include if critical gaps exist - no duplication with Section 2
5. **Sections 4-6:** Use concise bullet points, not paragraphs
6. **Section 7-10:** Combined max 400 words

**Remove:**
- Verbose explanations and background
- Repetitive content between sections
- Detailed analysis of Low-risk or N/A PRs
- Long example code snippets
- Duplicate tables

**Keep:**
- Specific file paths and test case names
- Actionable recommendations
- Risk-critical information only
- Concise bullet points

### AVOID
- Generic statements not tied to specific changes
- Vague risk descriptions without concrete examples
- Recommendations without actionable mitigation steps
- Statements like "add more tests" without specific file paths and test case names
- Skipping test analysis for any PR

### REQUIRE
- Every risk item linked to a specific PR or commit
- Concrete testing scenarios with clear acceptance criteria
- Quantified risk scores with justification
- **Detailed test coverage analysis for EVERY PR**
- Specific file paths for missing test files
- Concrete test case names (e.g., `TestMethodName_Scenario_ExpectedResult()`)
- E2E test repository search results for each functional area
- Integration test verification for database/API changes
