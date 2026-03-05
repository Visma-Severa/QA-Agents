# Release Risk Assessment Template

This template defines the structure and format for release risk assessment reports.

## CRITICAL CONSTRAINTS

| Constraint | Value | Enforcement |
|------------|-------|-------------|
| **Maximum Word Count** | **1500-2000 words** | HARD FAIL if exceeded. After displaying word count breakdown, wait for user instruction. Do not auto-regenerate. |
| **Section 2 vs 3.3** | NO DUPLICATION | Section 2 = summary table only, Section 3.3 = detailed findings |
| **Focus** | HIGH-RISK ITEMS ONLY | Skip low-risk/config-only PRs in detailed analysis |

---

## Report Structure

```markdown
# Release Risk Assessment

**Release:** Release-XX/YYYY
**Repository:** [Auto-detected from release branch -- see Multi-Repository Workspace table for all repos]
**Analysis Date:** YYYY-MM-DD
**Total PRs:** X | **Files:** XXX (+XX,XXX/-XX,XXX)
**Overall Risk:** Low | Medium | Critical

---

## 1. Executive Summary (Max 200 words)

**Risk Level: [Level]** - [One sentence summary]

### Release Composition

| Category | Count | % of Release | Notable Items |
|----------|-------|--------------|---------------|
| **Bug Fixes** | X | XX% | [Key tickets] |
| **New Features** | X | XX% | [Key tickets] |
| **Enhancements** | X | XX% | [Key tickets] |
| **Infrastructure** | X | XX% | [Key tickets] |
| **Configuration** | X | XX% | [Key tickets] |
| **Total** | **XX** | **100%** | XX files (+X,XXX/-X,XXX lines) |

**Categorization Guide:**
- **Bug Fixes** - Fixes for reported issues, errors, or incorrect behavior
- **New Features** - Completely new functionality or capabilities
- **Enhancements** - Improvements to existing features (performance, UX, etc.)
- **Infrastructure** - Database scripts, data fixes, system maintenance
- **Configuration** - Settings changes, integration config, timing adjustments

**Key Changes:**
- **HM-XXXXX:** [One line] ([X files], [test status])
- **HM-XXXXX:** [One line] ([X files], [test status])
- **HM-XXXXX:** [One line] ([X files], [test status])

**Critical Gaps:**
- [Specific gap 1]
- [Specific gap 2]
- [Specific gap 3]

---

## 2. PR Analysis Summary (HIGH-LEVEL ONLY)

| Ticket | Date | Files | Test Coverage | Risk | Rationale |
|--------|------|-------|---------------|------|-----------|
| HM-XXXXX | MM-DD | 5 | Full: Unit + E2E | Low | [10 words max] |
| HM-XXXXX | MM-DD | 12 | Partial: Unit only | Medium | [10 words max] |

**Legend:** Full | Partial | None | N/A

---

## 3. Test Coverage Analysis (MEDIUM/HIGH-RISK PRs ONLY)

**IMPORTANT:** Only analyze PRs with Medium or Critical risk. Skip Low risk and N/A.

### 3.1 HM-XXXXX: [Title] (Medium Risk)

**Files:** X (+XX/-XX) | **Unit:** status | **Integration:** status | **E2E:** status

**Missing Unit Tests:**
- `File.cs` -> `FileTests.cs` - TestMethod_EdgeCase(), TestMethod_Error()

**Missing E2E:**
- Playwright: [specific test needed]

**Recommendation:** Add unit tests before release

---

### 3.2 HM-XXXXX: [Title] (Medium Risk)

[Same concise format]

---

### 3.3 Test Coverage Summary (ONLY IF >5 PRs)

| Ticket | Unit | Integration | E2E | Status | Critical Gap |
|--------|------|-------------|-----|--------|--------------|
| HM-X | status | status | status | status | No unit tests |
| HM-Y | status | status | status | status | None |

---

## 4. Automated Regression Test Coverage

**CRITICAL: This section identifies which changes CAN be regression-tested by existing E2E automation**

**MANDATORY: Include ALL functional tickets from Section 2. Do NOT filter by risk level.**

### 4.1 E2E Coverage Summary

**Include EVERY ticket from Section 2.** Group by coverage status for readability.

| Ticket | Feature Area | Selenium Coverage | Playwright Coverage | Mobile Coverage | Overall Status |
|--------|--------------|-------------------|---------------------|-----------------|----------------|
| HM-XXXXX | [e.g., Prescriptions] | Covered | None | N/A | Partial |
| HM-XXXXX | [e.g., Appointments] | None | Covered | Covered | Full |
| HM-XXXXX | [e.g., Lab Results] | N/A | None | Covered | Partial |
| HM-XXXXX | [e.g., Admin Tool] | N/A | N/A | N/A | N/A |

**Coverage Statistics:**
- Full Coverage: X tickets (X%)
- Partial Coverage: X tickets (X%)
- No Coverage: X tickets (X%)
- N/A (Admin/Config/Docs): X tickets (X%)

**Status Legend:**
- **Full** - Covered in 2+ test repositories, can rely on automation
- **Partial** - Covered in 1 repository only, supplement with manual testing
- **None** - No E2E tests exist, manual regression testing required
- N/A - Not applicable (backend-only, admin tools, config, or docs)

---

### 4.2 Existing E2E Tests for This Release

**Search each E2E repository for tests related to changed functionality:**

#### Selenium Tests (HealthBridge-Selenium-Tests)

| Ticket | Related Test File(s) | Test Coverage | Sufficient? |
|--------|---------------------|---------------|-------------|
| HM-XXXXX | `HBPrescriptions/Tests/PrescriptionWorkflowTests.cs` | Prescription creation and validation | Yes |
| HM-XXXXX | `HBIntegrationTests/Tests/ClaimsApiTests.cs` | Claims API integration | Partial - missing edge case |
| HM-XXXXX | None found | - | No coverage |

#### Playwright Tests (HealthBridge-E2E-Tests)

| Ticket | Related Test File(s) | Test Coverage | Sufficient? |
|--------|---------------------|---------------|-------------|
| HM-XXXXX | `tests/scheduling.spec.ts` | Appointment scheduling flow | Yes |
| HM-XXXXX | None found | - | No coverage |

#### Mobile Tests (HealthBridge-Mobile-Tests)

| Ticket | Related Test File(s) | Test Coverage | Sufficient? |
|--------|---------------------|---------------|-------------|
| HM-XXXXX | `test/appointments/add_appointment.ts` | Mobile appointment booking | Yes |
| HM-XXXXX | N/A - feature not in mobile | - | N/A |

---

### 4.3 Automation Coverage Gaps

| Ticket | Change Description | Gap | Manual Testing Required? |
|--------|-------------------|-----|-------------------------|
| HM-XXXXX | Insurance claim processing | No E2E test for claim submission | Critical |
| HM-XXXXX | Lab result notification | Existing test only covers viewing | Medium |
| HM-XXXXX | Backend API change | No UI impact, unit tests cover it | No |

---

### 4.4 Recommended E2E Test Execution Plan

**Pre-Release Must Run (Changes covered by existing automation):**
- [ ] `HealthBridge-Selenium-Tests/HBPrescriptions/Tests/PrescriptionWorkflowTests.cs` - Covers HM-XXXXX
- [ ] `HealthBridge-E2E-Tests/tests/scheduling.spec.ts` - Covers HM-XXXXX
- [ ] `HealthBridge-Mobile-Tests/test/appointments/` - Covers HM-XXXXX

**Smoke Tests (Critical paths):**
- [ ] Login/logout flow
- [ ] Patient record creation
- [ ] Prescription workflow

---

### 4.5 E2E Test Maintenance Action Plan

**CRITICAL: Provide actionable plan for E2E test suite maintenance - ADD/DELETE/UPDATE tests**

**For EVERY PR with functional changes (exclude config/docs), evaluate:**

| Action | Test Case Description | Repo | Ticket | Priority | Effort |
|--------|----------------------|------|--------|----------|--------|
| CREATE | New test: Insurance claim with multi-provider billing | Playwright | HM-XXXXX | P0 | M (4-6h) |
| UPDATE | Modify existing: `prescriptions.spec.ts` to include new dosage validation | Playwright | HM-XXXXX | P1 | S (1-2h) |
| DELETE | Remove obsolete: `legacy_admission.spec.ts` (feature removed in this PR) | Playwright | HM-XXXXX | P2 | S (1h) |
| CREATE | New test: Lab result notification workflow | Mobile | HM-XXXXX | P0 | L (8-12h) |

**Priority Legend:**
- **P0 (Critical):** Patient safety, security fixes, clinical calculations, data corruption risks -> Must create/update tests before release
- **P1 (High):** New patient-facing features, breaking changes, core workflow modifications -> Create tests in same sprint
- **P2 (Medium):** Bug fixes, enhancements, non-critical flows -> Create tests when capacity allows

**Effort Legend:**
- **S (Small):** 1-2 hours - Simple test modification or deletion
- **M (Medium):** 3-6 hours - New test with moderate complexity or significant update
- **L (Large):** 7-12 hours - Complex end-to-end workflow with multiple pages/steps

**Action Decision Logic:**
- **CREATE**: New feature added, or existing feature has no E2E coverage
- **UPDATE**: Existing test needs modification (new validation, changed UI, new edge case)
- **DELETE**: Feature removed, or test made obsolete by refactoring

**Framework Selection:** Use the Quick Reference Table in `context/e2e-test-coverage-map.md` to determine which frameworks apply to each functional area. Do not hardcode framework-to-area mappings.

---

## 5. Hotfix Pattern Analysis (Historical RCA)

Apply patterns per-PR based on each PR's ticket prefix, not the release branch prefix. Group findings by repository. Use the repo-specific pattern table from `context/historical-bugfix-patterns.md`.

**For releases spanning multiple repositories**, use a sub-heading per repository (e.g., `### HealthBridge-Web`, `### HealthBridge-Api`) with a separate pattern table under each.

| Pattern (XX%) | Status | PRs Affected | Findings |
|----------------|--------|--------------|----------|
| [Pattern 1 from repo-specific table] | pass/warn/fail | [tickets] | [Specific findings or "No issues detected"] |
| [Pattern 2 from repo-specific table] | pass/warn/fail | [tickets] | [Specific findings or "No issues detected"] |
| [Pattern 3 from repo-specific table] | pass/warn/fail | [tickets] | [Specific findings or "No issues detected"] |
| [Pattern 4 from repo-specific table] | pass/warn/fail | [tickets] | [Specific findings or "No issues detected"] |
| [Pattern 5 from repo-specific table] | pass/warn/fail | [tickets] | [Specific findings or "No issues detected"] |
| [Pattern 6 from repo-specific table] | pass/warn/fail | [tickets] | [Specific findings or "No issues detected"] |

---

## 6. Risk Mitigation

### 6.1 Critical Priority (Blocking Issues - Must Fix Before Release)

| Risk | Related PR | Mitigation Action |
|------|-----------|------------------|
| Security vulnerability without tests | #123 | Add security E2E test for unauthorized access |
| Patient data loss potential | #125 | Add unit tests for rollback scenarios |

### 6.2 High Priority (Must Test Before Release)

| Risk | Related PR | Mitigation Test |
|------|-----------|-----------------|
| Prescription calculation changes without tests | #123 | Create prescription with complex dosage, verify calculation |
| New API endpoint with no auth tests | #125 | Test unauthorized access returns 401 |

### 6.3 Medium Priority (Should Test)

| Risk | Related PR | Mitigation Test |
|------|-----------|-----------------|
| Edge case handling in appointment date picker | #124 | Test month-end dates, leap year |

---

## 7. Release Recommendation

- [ ] **GO** — All critical areas covered, automated tests pass
- [ ] **CONDITIONAL GO** — Proceed with noted manual testing of gaps
- [ ] **NO-GO** — Critical gaps must be resolved first

**Justification:** [1-2 sentences explaining the recommendation]

---

## 8. Post-Release Monitoring

| Metric | Baseline | Alert Threshold | Action |
|--------|----------|-----------------|--------|
| [metric] | [value] | [threshold] | [action] |

**Actions Timeline:**
- **0-4h post-release:** [specific checks]
- **Week 1:** [specific monitoring]

**Warning Signs:**
- [sign 1]
- [sign 2]

---

*Generated: YYYY-MM-DD | Release: XX-YYYY | PRs Analyzed: X*
```

---

## Constraints

| Constraint | Value |
|------------|-------|
| Word Count | 1500-2000 words |
| File Name | `Release-XX-YYYY-Risk-Assessment.md` |
| Location | `reports/week-release/` |
| Branch Pattern | `release/Release-XX/YYYY` |

---

## Critical Rules

### AVOID
- Generic statements not tied to specific PR findings
- Vague terms like "improve testing" without concrete file paths and test cases
- High-level statements like "ensure quality" without specific testing strategies
- Duplicate content across sections - each section provides unique value
- AI-generated PR names - use original PR titles only

### REQUIRE
- Every recommendation linked to a specific PR number
- Exact file paths for missing tests
- Specific test scenarios with clear acceptance criteria
- Risk rationale based on actual code analysis
- Original PR titles from GitHub

---

## Example Entries

### Good PR Analysis Entry
| HM-4521 | 2026-01-03 | 4 | Partial | Medium | Modifies core calculation, tests only cover single dose |

### Bad PR Analysis Entry (AVOID)
| HM-4521 | 2026-01-03 | 4 | Partial | Medium | Needs more testing |

### Good Testing Recommendation
- `Services/PrescriptionService.cs` -> Create `Tests/Services/PrescriptionServiceTests.cs`
- Test case: `TestCalculateDosage_MultiDose_RoundsCorrectly`

### Bad Testing Recommendation (AVOID)
- Add more tests for the prescription module

---

## Risk Level Definitions

| Level | Criteria |
|-------|----------|
| **Low** | Minor changes, well-tested, low regression risk, no core areas affected |
| **Medium** | Moderate complexity, some test gaps, medium regression risk, or affects important features |
| **Critical** | High complexity, major test gaps, security issues, release-blocking, or affects core clinical logic |

**Combined Release Risk Assessment:**
- Takes into account: max individual PR risk, PR clustering, integration complexity, test coverage %, pattern concentration, functional area overlap
- NOT just an average of individual PR risks
