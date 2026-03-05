# Requirements Analysis Workflow Orchestrator

This prompt orchestrates the complete requirements analysis to delivery planning workflow.

## PATH NAMING CONVENTION

**CRITICAL:** Always use **hyphens** (`-`) not underscores (`_`) in folder and file paths:

| Correct | Wrong |
|---------|-------|
| `reports/requirements-analysis/` | `reports/requirements_analysis/` |
| `reports/requirements-analysis/[TICKET]-qa-test-plan.md` | `reports/qa_test_plan/` |
| `reports/requirements-analysis/[TICKET]-dev-estimation.md` | `reports/dev_estimation/` |

## Purpose

Automate the end-to-end analysis from requirements gathering through QA test planning and development estimation, with intelligent decision-making based on requirements completeness.

## Workflow Overview

```
+------------------------------------------------------------------+
|                 REQUIREMENTS-TO-DELIVERY PIPELINE                 |
+------------------------------------------------------------------+
|                                                                   |
|  PHASE 1: Requirements Analysis                                  |
|  - Analyze requirements document                                 |
|  - Identify gaps, edge cases, integration impacts                |
|  - Score completeness (0-10 scale)                               |
|  - OUTPUT: [TICKET-ID]-requirements-analysis.md                  |
|         |                                                         |
|         v                                                         |
|  DECISION POINT: Completeness Score >= 7/10?                     |
|         |                                                         |
|    +----+----+                                                    |
|    |         |                                                    |
|   YES        NO                                                   |
|    |         |                                                    |
|    |         +-> STOP: Present critical questions to PO           |
|    |             Wait for clarification before continuing         |
|    |                                                              |
|    v                                                              |
|  PHASE 2: QA Test Plan Generation                                |
|  - Generate manual test scenarios                                |
|  - Analyze existing test automation                              |
|  |  - Playwright tests (TypeScript)                              |
|  |  - Mobile tests (WebdriverIO)                                 |
|  - Identify tests to UPDATE/DELETE/ADD                           |
|  - Estimate QA effort (detailed)                                 |
|  - OUTPUT: [TICKET-ID]-qa-test-plan.md                           |
|         |                                                         |
|         v                                                         |
|  PHASE 3: Dev Estimation Generation                              |
|  - Analyze impacted repositories                                 |
|  - Break down implementation tasks                               |
|  - Identify unit test requirements                               |
|  - Estimate development effort (detailed)                        |
|  - Calculate risk buffers                                        |
|  - OUTPUT: [TICKET-ID]-dev-estimation.md                         |
|         |                                                         |
|         v                                                         |
|  COMPLETE: All 3 documents generated                             |
|  Ready for sprint planning!                                      |
|                                                                   |
+------------------------------------------------------------------+
```

---

## Input

**Ticket/Feature:** `{{TICKET_ID}}`

**Title:** `{{TITLE}}`

**Requirements:**
```
{{REQUIREMENTS}}
```

**Acceptance Criteria:**
```
{{ACCEPTANCE_CRITERIA}}
```

---

## Execution Instructions

### Step 1: Requirements Analysis

**Use prompt:** `requirements-analysis.md` (this folder)
**Use template:** `requirements-analysis-template.md` (this folder)

**Actions:**
1. Analyze requirements for business gaps
2. Identify edge cases based on historical RCA patterns
3. Analyze integration impacts across all repositories
4. Identify error handling requirements
5. Assess multi-repository scope clarity

**Critical: Score Requirements Completeness**

Use the **7-dimension weighted scoring model**. Canonical definition: `requirements-analysis-template.md`, Section 3.
- Completeness (20%), Clarity (15%), Testability (15%), Feasibility (15%), Edge Cases (10%), Integration Impact (10%), Domain Compliance (15%)
- Each dimension scored 0-10, weighted total = **Score/10**

**Output File:** `reports/requirements-analysis/[TICKET-ID]-requirements-analysis.md`

---

### Step 2: Decision Point - Can We Proceed?

**Check completeness score from Step 1:**

```
IF completeness_score >= 7:
    OUTPUT to user: "Score: [X]/10 — threshold met. Generating QA Test Plan and DEV Estimation."
    PROCEED to Step 3 (QA Test Plan)
    PROCEED to Step 4 (Dev Estimation)

ELSE:
    OUTPUT to user:
       - "Requirements completeness: [X]/10 ([XX]%)"
       - "Cannot generate test plan and dev estimation yet"
       - "Critical questions that must be answered:"
         1. [Question 1]
         2. [Question 2]
         3. [Question 3]
       - "Please clarify with Product Owner, then re-run analysis"
    DO NOT generate QA Test Plan
    DO NOT generate Dev Estimation
    EXIT workflow
```

**Rationale:**
- Score 7-10 = Good enough to plan with acceptable risk
- Score < 7 = Too many unknowns, high risk of rework

---

### Step 3: QA Test Plan Generation

**Prerequisites:**
- Requirements completeness score >= 7/10
- Requirements analysis document exists

**Use template:** `../qa-test-plan/qa-test-plan-template.md`
If template file cannot be read, stop and notify user: "Template not found at [path]. Verify path and re-run."

**Actions:**

#### 3.1 Generate Manual Test Scenarios
- Happy path tests (Given/When/Then format)
- Edge case tests (based on requirements analysis gaps)
- Error scenario tests
- Exploratory test areas

#### 3.2 Analyze Test Automation Impact

**IMPORTANT:** Before analyzing E2E test coverage, read the shared context file:
```
Read: context/e2e-test-coverage-map.md
```

This file defines which functional areas are covered by each E2E framework. Use the Quick Reference table to determine which frameworks to search based on the feature's functional area.

**Playwright Tests (TypeScript):**
*Use for: Prescriptions, Patient Records, Scheduling, Billing, Lab Results, Staff*
```bash
# Search strategy
cd HealthBridge-E2E-Tests && git fetch origin
git grep -n "[feature keywords]" origin/main -- "*.spec.ts"

# Identify:
- Tests to UPDATE (assertions, selectors, logic)
- Tests to DELETE (obsolete features)
- Tests to ADD (new functionality coverage)
```

**Mobile Tests (WebdriverIO):**
*Use for: Mobile app features - Appointments, Lab Results, Medications, Dashboard*
```bash
# Check the coverage map to see if feature is in Mobile scope
# If feature in mobile scope per coverage map:
cd HealthBridge-Mobile-Tests && git fetch origin
git grep -n "[feature keywords]" origin/main -- "*.js"

# Identify:
- Tests to UPDATE
- Tests to DELETE
- Tests to ADD

# If feature NOT in mobile scope:
Document: "Feature not in mobile app scope (per coverage map) - no mobile testing needed"
```

**Report Format:**
Use the coverage status legend from the coverage map:
- Full - Tests exist and cover this feature
- Partial - Some tests exist but gaps identified
- Gap - Framework covers this area but no tests for this feature
- N/A - Framework doesn't cover this functional area

#### 3.3 Estimate QA Effort

**Detailed estimates for:**
- Manual test case execution (per scenario)
- Test data setup
- Automation updates (per test file/method)
- New automation development (per test scenario)
- Test maintenance and cleanup

**Include:**
- Task-level breakdown
- Priority (P1/P2/P3)
- Dependencies
- Risk factors

**Output File:** `reports/requirements-analysis/[TICKET-ID]-qa-test-plan.md`

---

### Step 4: Dev Estimation Generation

**Prerequisites:**
- Requirements completeness score >= 7/10
- Requirements analysis document exists
- QA test plan document exists (or generated in parallel)

**Use template:** `../dev-estimation/dev-estimation-template.md`
If template file cannot be read, stop and notify user: "Template not found at [path]. Verify path and re-run."

**Actions:**

#### 4.1 Identify Impacted Repositories

**From requirements analysis, extract:**
- Which repositories have "Impact Level: High/Medium/Low"
- Skip repositories with "Impact Level: None"

**Analyze ONLY impacted repositories:**

**HealthBridge-Web (C#/ASP.NET Core):**
```bash
# Search for relevant files
cd HealthBridge-Web && git fetch origin
git grep -n "[feature keywords]" origin/main -- "*.cs" "*.cshtml" "*.razor"

# Identify:
- Backend files to modify (.cs services, controllers)
- Frontend files to modify (.cshtml, .razor, .js)
- Database changes needed (EF Core migrations)
- Unit test files to add/modify
- Integration test files
```

**HealthBridge-Api (C#):**
```bash
cd HealthBridge-Api && git fetch origin
git grep -n "[feature keywords]" origin/main -- "*.cs"
# Identify:
- API controllers to modify
- DTOs to add/modify
- Breaking changes?
- API documentation to update
- Unit tests
```

**HealthBridge-Portal (C# / .NET Core + React):**
```bash
cd HealthBridge-Portal && git fetch origin
git grep -n "[feature keywords]" origin/main -- "*.cs" "*.tsx" "*.ts"
# Identify:
- React components to add/modify
- Backend controllers/services to modify
- Permission guards to add/update
- Unit tests (backend + frontend)
```

**HealthBridge-Mobile (Flutter):**
```bash
cd HealthBridge-Mobile && git fetch origin
git grep -n "[feature keywords]" origin/main -- "*.dart"
# Identify:
- Widgets/screens to modify
- State management changes
- API client updates
- Localization (.arb files)
- Unit/integration tests
```

#### 4.2 Break Down Implementation Tasks

**For each repository, create detailed task list:**

| Task | File(s) | Complexity | Estimate | Notes |
|------|---------|------------|----------|-------|
| [Specific task] | [Exact file path] | Low/Med/High | [X.X]h | [Implementation details] |

#### 4.3 Identify Unit Test Requirements

**Use existing test framework in each repo:**
- Check existing test files to identify framework (xUnit/NUnit/MSTest/Flutter test)
- Estimate unit test effort per component
- Include integration test effort

#### 4.4 Estimate Additional Tasks

- **Database migrations:** Migration scripts, rollback plans
- **DevOps:** Feature flags, CI/CD updates, monitoring
- **Documentation:** Technical docs, user docs, API docs
- **Code review:** Review time, feedback iterations
- **Smoke testing:** Dev team's own testing before QA

#### 4.5 Calculate Risk Buffers

**Known risks:** Specific contingency hours per risk
**Complexity buffer:**
- Low: +10%
- Medium: +20%
- High: +30%
- Very High: +50%

**Output File:** `reports/requirements-analysis/[TICKET-ID]-dev-estimation.md`

---

## Final Output Summary

### If Completeness Score >= 7/10:

**Generated Documents:**
```
reports/requirements-analysis/[TICKET-ID]-requirements-analysis.md
reports/requirements-analysis/[TICKET-ID]-qa-test-plan.md
reports/requirements-analysis/[TICKET-ID]-dev-estimation.md
```

**Present to User:**
```markdown
**Requirements Analysis Complete!**

**Completeness Score:** [X]/10 ([XX]%) - Ready for planning

**Generated Documents:**
1. **Requirements Analysis** - [X] words
   - [Y] gaps identified ([Z] critical)
   - Score breakdown: 7-dimension weighted model (see report for details)

2. **QA Test Plan** - [X] words
   - [Y] manual test scenarios
   - [Z] tests to update (Playwright: A, Mobile: B)
   - [W] tests to add
   - **QA Effort:** [X.X] hours (~[Y.Y] days)

3. **Dev Estimation** - [X] words
   - [Y] impacted repositories
   - [Z] implementation tasks
   - [W] unit tests required
   - **Dev Effort:** [X.X] hours (~[Y.Y] days)

**Total Effort Estimate:**
- Development: [X.X] hours (~[Y] days)
- QA Testing: [X.X] hours (~[Y] days)
- **Combined:** [X.X] hours (~[Y] days)

**Ready for sprint planning!**

**Next Steps:**
1. Review all 3 documents with team
2. Refine estimates if needed
3. Create ticket stories/tasks
4. Schedule sprint planning meeting
```

### If Completeness Score < 7/10:

**Generated Documents:**
```
reports/requirements-analysis/[TICKET-ID]-requirements-analysis.md
```

**Present to User:**
```markdown
**Requirements Analysis Complete - Clarification Needed**

**Completeness Score:** [X]/10 ([XX]%) - Not ready for planning

**Score Breakdown (7-dimension weighted model):**
- Completeness (20%): [X]/10 - [Assessment]
- Clarity (15%): [X]/10 - [Assessment]
- Testability (15%): [X]/10 - [Assessment]
- Feasibility (15%): [X]/10 - [Assessment]
- Edge Cases (10%): [X]/10 - [Assessment]
- Integration Impact (10%): [X]/10 - [Assessment]
- Domain Compliance (15%): [X]/10 - [Assessment]

**Why score is too low:**
[Explanation of what's missing]

**Critical Questions for Product Owner:**
1. [Most critical question]
2. [Second critical question]
3. [Third critical question]

**Cannot generate QA Test Plan and Dev Estimation yet**
- Too many unknowns to create reliable test scenarios
- Development effort cannot be estimated accurately
- High risk of rework if we proceed

**Next Steps:**
1. Schedule meeting with Product Owner
2. Get answers to critical questions
3. Update requirements document
4. Re-run requirements analysis with updated requirements as new input (previous files are not overwritten)
5. Once score >= 7/10, we'll auto-generate test plan and dev estimation

**Generated Document:**
- Requirements Analysis: reports/requirements-analysis/[TICKET-ID]-requirements-analysis.md
```

---

## Constraints & Rules

### Mandatory Rules

1. **Always score requirements** - No exceptions
2. **Respect 7/10 threshold** - Don't generate test plan/estimation below threshold
3. **Analyze all test frameworks** - Playwright, Mobile (if applicable)
4. **Only impacted repos** - Don't analyze repos with "None" impact
5. **Use existing unit test frameworks** - Don't invent new frameworks
6. **Detailed estimates** - Task-level, not feature-level
7. **Include risk buffers** - Always add contingency

### Word Limits (STRICTLY ENFORCED)

**MANDATORY - These limits are non-negotiable:**

- Requirements Analysis: **1500 words max**
- QA Test Plan: **1000 words max**
- Dev Estimation: **800 words max**

**Enforcement Strategy:**
- Use tables and bullet points instead of paragraphs
- Focus on actionable insights, not explanations
- Omit obvious information
- Code examples only when essential (max 10 lines)
- Reference existing docs instead of repeating content

### Search Strategy

**Always use your IDE's tools (or git commands) to:**
- Search file contents: `git grep -n "<pattern>" origin/main -- "*.cs"`
- Locate files: `git ls-tree -r --name-only origin/main | grep "<pattern>"`
- Read files from remote: `git show origin/main:<file-path>`

**Don't make assumptions** - Search first, then estimate

---

## Quality Checklist

Before delivering final output, verify:

**Requirements Analysis:**
- [ ] Completeness score calculated with justification
- [ ] All 7 dimensions scored per weighted model (Completeness, Clarity, Testability, Feasibility, Edge Cases, Integration, Domain Compliance)
- [ ] Decision documented: Proceed (>=7) or Stop (<7)
- [ ] If <7: Specific critical questions listed

**QA Test Plan (if generated):**
- [ ] All E2E test frameworks analyzed (Playwright, Mobile)
- [ ] Existing tests searched using grep/file search
- [ ] Specific file paths and method names provided
- [ ] Detailed estimates (task-level, not feature-level)
- [ ] Test data requirements documented

**Dev Estimation (if generated):**
- [ ] Only impacted repositories included
- [ ] Specific file paths identified via code search
- [ ] Unit test framework identified per repo
- [ ] Detailed task breakdown with estimates
- [ ] Risk buffers included (20-50%)
- [ ] Cross-repo dependencies documented

**All Documents:**
- [ ] Word count within limits
- [ ] Cross-referenced correctly
- [ ] Actionable recommendations
- [ ] Ready for sprint planning (if completeness >=7)

---

## Template Files Reference

**Requirements Analysis (Phase 1):**
- Prompt: `requirements-analysis.md` (this folder)
- Template: `requirements-analysis-template.md` (this folder)

**QA Test Plan (Phase 2):**
- Template: `../qa-test-plan/qa-test-plan-template.md`

**Dev Estimation (Phase 3):**
- Template: `../dev-estimation/dev-estimation-template.md`

---

**Orchestrator Version:** 1.2

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.2 | 2026-03-05 | Standardized to 7-dimension weighted scoring model, fixed output file naming, raised word limit to 1500, added re-run protocol |
| 1.1 | ~2026-02 | Previous version |
| 1.0 | ~2026-01 | Initial release |
