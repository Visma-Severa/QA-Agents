# Release Risk Assessment

**Release:** Release-9/2026
**Repository:** HealthBridge-Web
**Analysis Date:** 2026-02-23
**Total PRs:** 10 (11 tickets) | **Files:** 109 (+10,470/-2,226)
**Overall Risk:** Medium

---

## 1. Executive Summary (Max 200 words)

**Risk Level: Medium** - Large release dominated by a new feature (Open Prescriptions UI, HM-14211) comprising ~80% of changes. The feature is gated behind a special need flag, limiting blast radius. Healthcare-critical changes (HM-14227 MediCollect due date, HM-14233 rounding) lack unit tests. E2E regression coverage is 35% (low).

### Release Composition

| Category | Count | % of Release | Notable Items |
|----------|-------|--------------|---------------|
| **Bug Fixes** | 5 | 45% | HM-14267, HM-14249, HM-14210, HM-14233, HM-14283 |
| **New Features** | 1 | 9% | HM-14211 (Open Prescriptions UI - 78 files) |
| **Enhancements** | 3 | 27% | HM-14278, HM-14279, HM-14227 |
| **Infrastructure** | 1 | 9% | HM-14261 (SemanticKernel security upgrade) |
| **Bug Fix (Store)** | 1 | 9% | HM-14253 (Starter package fix) |
| **Total** | **11** | **100%** | 109 files (+10,470/-2,226 lines) |

**Key Changes:**
- **HM-14211:** New Open Prescriptions UI -- complete prescription CRUD, file upload, 2 new DB tables (78 files, Unit only)
- **HM-14278/14279:** Cross-company automation rule copying with mapping and category linking (14 files, Unit tests)
- **HM-14227:** MediCollect appointment due date change in collection (4 files, No tests)

**Critical Gaps:**
- HM-14227: No unit tests for appointment due date validation logic
- HM-14211: Zero E2E coverage for entirely new feature
- HM-14267: No unit tests for changed SQL referral filtering

---

## 2. PR Analysis Summary

| Ticket | Date | Files | Test Coverage | Risk | Rationale |
|--------|------|-------|---------------|------|-----------|
| HM-14267 | 02-23 | 4 | None | Medium | SQL filter changes for referral allocation display |
| HM-14249 | 02-23 | 3 | E2E Tests | Low | PO dimension fix + 3 regression tests |
| HM-14278 | 02-23 | 14 | Unit | Medium | Automation rule copy with mapping/category linking |
| HM-14279 | 02-23 | (via 14278) | Unit | Medium | Copy result reporting UI modal |
| HM-14227 | 02-23 | 4 | None | Medium | MediCollect due date change -- appointment validation |
| HM-14210 | 02-23 | 1 | None | Low | TRY_CONVERT fix for insurance form 6b (legacy ASP) |
| HM-14233 | 02-23 | 2 | None | Medium | Rounding fix + ad-hoc query update |
| HM-14253 | 02-23 | 1 | None | Medium | Starter package special need deactivation |
| HM-14211 | 02-23 | 78 | Unit | High | New Open Prescriptions UI -- 2 new tables, 261-line migration |
| HM-14261 | 02-23 | 11 | N/A | Low | SemanticKernel security upgrade |
| HM-14283 | 02-23 | 1 | None | Low | Empty batch INSERT edge case fix |

**Legend:** Full | Partial | None | N/A

---

## 3. Test Coverage Analysis (MEDIUM/HIGH-RISK PRs ONLY)

### 3.1 HM-14211: Create the open prescriptions UI (High Risk)

**Files:** 78 (+~8,200/-~2,750) | **Unit:** Good (7 new test files) | **E2E:** None

**Architecture:** Complete new prescription handling system -- list page, edit page, upload handler, 2 new DB tables, 261-line migration. Feature gated behind `CompanySpecialNeedType.NewPrescriptionHandling`.

**Strengths:**
- Unit tests for `MedicalPrescriptionRowRepository`, `MedicalPrescriptionRowService`, `MedicalPrescriptionStatusHelper`, `MedicalPrescriptionCopayRepository`, `LinkedCardRepository`, `LinkedCardService`
- CSRF protection enabled on handlers
- Parameterized SQL throughout
- `safeNavigate()` XSS protection in JavaScript

**Concerns:**
- File upload validates extension only (not content-type/magic bytes)
- Delete handler -- verify company-level ownership check exists in accessor
- `LinkedCard.UserID` column dropped -- verify no other repos reference it

**Recommendation:** Manual testing critical for prescription CRUD flow, file upload, and migration

### 3.2 HM-14227: MediCollect Appointment Due Date Change (Medium Risk)

**Files:** 4 (+83/-7) | **Unit:** None | **E2E:** Partial (Selenium has appointment tests)

**Concern:** Complex validation in `AppointmentEntityController` (53 lines) determines due date from scheduling terms when appointment is in collection. Multiple branching paths for `AppointmentValueDate`, `AppointmentSchedulingTermID`, `AppointmentDueDate` combinations.

**Edge Case:** Tolerance check `AppointmentDueDate.Date <= Date.Today.AddDays(1)` -- blocks editing if current due date is tomorrow or earlier. Verify intentional.

**Recommendation:** Add unit tests for validation logic before release

### 3.3 HM-14278/14279: Automation Rule Copying (Medium Risk)

**Files:** 14 (+~2,889/-~1,326) | **Unit:** Good | **E2E:** No copy tests

**Changes:** `Copy()` refactored from `Sub` to `Function` returning `List(Of AutomationRuleCopyCompanyResult)`. New mapping and category-name linking modes. New enums: `RuleCopyError`, `RuleCopyWarning`, `RuleCopyCompanyError`.

**Strengths:** Extensive unit test refactoring covers the controller logic.

**Recommendation:** Manual test of cross-company copy with mapping/category linking

### 3.4 Test Coverage Summary

| Ticket | Unit | Integration | E2E | Status | Critical Gap |
|--------|------|-------------|-----|--------|--------------|
| HM-14267 | No | No | Partial | Partial | No tests for SQL filter change |
| HM-14249 | Yes | Yes | Partial | Yes | None -- good regression tests |
| HM-14278/79 | Yes | No | No | Partial | No E2E for copy workflow |
| HM-14227 | No | No | Partial | No | No tests for validation logic |
| HM-14210 | No | No | Partial | Partial | Legacy ASP, hard to test |
| HM-14233 | No | No | Yes | Partial | No unit test for rounding |
| HM-14253 | No | No | No | No | No tests for package logic |
| HM-14211 | Partial | No | No | Partial | Zero E2E for new feature |
| HM-14261 | N/A | N/A | N/A | N/A | Dependency upgrade |
| HM-14283 | No | No | Yes | Partial | CategoryListTests covers area |

---

## 4. Automated Regression Test Coverage

### 4.1 E2E Coverage Summary

| Ticket | Feature Area | Selenium Coverage | Playwright Coverage | Mobile Coverage | Overall Status |
|--------|--------------|-------------------|---------------------|-----------------|----------------|
| HM-14267 | Referrals | Partial (CreditReferralTests - allocation, not "to be checked") | N/A | Partial (Approval only) | Partial |
| HM-14249 | Orders | Partial (CreateOrderTests - no dimension persistence) | N/A | N/A | Partial |
| HM-14278/79 | Referral Automation | Partial (ReferralAutomationTests - no copy test) | N/A | N/A | Gap |
| HM-14227 | Appointments / MediCollect | Partial (CreateAppointmentTest - no MediCollect integration) | N/A | N/A | Partial |
| HM-14210 | Insurance Forms | Partial (InsuranceCalculationTests - no insurance form 6b) | N/A | N/A | Gap |
| HM-14233 | Clinical Statements | Full (ClinicalStatementTests + HealthReportsTest) | N/A | N/A | Full |
| HM-14253 | Store/Packages | Partial (HBStorePage - Basic/Professional only) | N/A | N/A | Gap |
| HM-14211 | Prescription Handling | None | None | None | None |
| HM-14261 | Infrastructure | N/A | N/A | N/A | N/A |
| HM-14283 | Category List | Full (CategoryListTests - 6 tests) | N/A | N/A | Full |

**Coverage Statistics:**
- Full Coverage: 2 tickets (20%)
- Partial Coverage: 3 tickets (30%)
- No Coverage: 5 tickets (50%)
- N/A: 1 ticket

**E2E Coverage = (2 + 0.5 x 3) / 10 = 35% (low)**

### 4.2 Existing E2E Tests for This Release

#### Selenium Tests

| Ticket | Related Test File(s) | Test Coverage | Sufficient? |
|--------|---------------------|---------------|-------------|
| HM-14267 | `HBReferralTests/Tests/CreditReferralTests.cs` | 6 tests: allocate, edit, delete allocation | No "to be checked" view |
| HM-14249 | `HBOrderTests/Tests/OrderLineTest.cs` | 1 dimension ref: CopyDimensionsFromFirstLine | No persistence validation |
| HM-14278 | `HBReferralTests/Tests/ReferralAutomationTests.cs` | 5 tests: add/verify/accept/post/process rules | No copy test |
| HM-14227 | `HBAppointments/Tests/CreateAppointmentTest.cs` | Appointment creation with due dates | No MediCollect integration |
| HM-14210 | `HBClinicalData/Tests/InsuranceCalculationTests.cs` | Insurance calculation | No insurance form 6b |
| HM-14233 | `HBClinicalData/Tests/ClinicalStatementTests.cs` | Preview, create/archive, balance sheet | Yes |
| HM-14253 | `HBCreateCompany/Pages/HBStorePage.cs` | Basic/Professional switching | No starter package |
| HM-14211 | None | - | No coverage |
| HM-14283 | `HBClinicalData/Tests/CategoryListTests.cs` | 6 tests: add/edit/delete/hide categories | Yes |

#### Playwright Tests
No PRs in this release impact Playwright-covered areas (Scheduling, Shifts, Travel).

#### Mobile Tests

| Ticket | Related Test File(s) | Test Coverage | Sufficient? |
|--------|---------------------|---------------|-------------|
| HM-14267 | `test/suites/12_referrals/` | 9 tests: approve/reject/search | No credit note display |

### 4.3 Automation Coverage Gaps

| Ticket | Change Description | Gap | Manual Testing Required? |
|--------|-------------------|-----|-------------------------|
| HM-14211 | Open Prescriptions UI -- entire new feature | Zero E2E coverage | Critical |
| HM-14278/79 | Automation rule cross-company copy | No copy workflow test | Medium |
| HM-14210 | Insurance form 6b opening error fix | No insurance form rendering test | Medium |
| HM-14253 | Starter package special need | No starter package test | Medium |
| HM-14267 | Credit notes in "to be checked" view | No "to be checked" view test | Medium |

### 4.4 Recommended E2E Test Execution Plan

**Pre-Release Must Run:**
- [ ] `HealthBridge-Selenium-Tests/HBReferralTests/` -- HM-14267, HM-14278
- [ ] `HealthBridge-Selenium-Tests/HBOrderTests/` -- HM-14249
- [ ] `HealthBridge-Selenium-Tests/HBClinicalData/Tests/ClinicalStatementTests.cs` -- HM-14233
- [ ] `HealthBridge-Selenium-Tests/HBClinicalData/Tests/CategoryListTests.cs` -- HM-14283
- [ ] `HealthBridge-Selenium-Tests/HBClinicalData/Tests/InsuranceCalculationTests.cs` -- HM-14210
- [ ] `HealthBridge-Selenium-Tests/HBAppointments/` -- HM-14227
- [ ] `HealthBridge-Mobile-Tests/test/suites/12_referrals/` -- HM-14267

**Smoke Tests:**
- [ ] Login/Authentication
- [ ] `HealthBridge-Selenium-Tests/HBCreateCompany/`
- [ ] `HealthBridge-E2E-Tests/tests/01_create_company_tests.spec.ts`

**Manual Testing Required (Not covered by automation):**
- [ ] HM-14211: Open Prescriptions -- create, edit, delete prescription + file upload + row CRUD
- [ ] HM-14278/79: Copy automation rules to another company with mapping/category linking
- [ ] HM-14210: Open insurance form 6b -- verify no error
- [ ] HM-14253: Starter package re-activation -- verify special needs preserved
- [ ] HM-14227: Change due date on MediCollect appointment in collection

### 4.5 E2E Test Maintenance Action Plan

| Action | Test Case Description | Repo | JIRA Ticket | Priority | Effort |
|--------|----------------------|------|-------------|----------|--------|
| CREATE | Open Prescriptions UI: list, create, edit, delete prescription, file upload | Selenium | HM-14211 | P0 | L (8-12h) |
| CREATE | Automation rule copy to another company (with mapping/category linking) | Selenium | HM-14278 | P1 | M (4-6h) |
| CREATE | Copy result notification modal -- verify error/warning display | Selenium | HM-14279 | P1 | S (2-3h) |
| CREATE | Insurance form 6b opening/rendering test | Selenium | HM-14210 | P1 | M (3-4h) |
| UPDATE | CreditReferralTests: add "referrals to be checked" view with allocated credit notes | Selenium | HM-14267 | P1 | S (2h) |
| CREATE | Starter package special need activation/deactivation in store | Selenium | HM-14253 | P2 | M (3-4h) |
| UPDATE | OrderLineTest: add dimension persistence validation | Selenium | HM-14249 | P2 | S (1-2h) |

**P0 Test Description:**

#### HM-14211: Open Prescriptions UI (CREATE - Selenium)
**Test Case:** `OpenPrescriptions_CreateEditDeletePrescription_WithFileUpload`
**Preconditions:** Company with `NewPrescriptionHandling` special need enabled
**Steps:**
1. Navigate to Prescription Handling > Open Prescriptions
2. Verify list page loads (empty or with existing prescriptions)
3. Upload a prescription image (JPG) via drag-and-drop or file picker
4. Verify new prescription appears in list with "Incomplete Data" status
5. Click prescription > Edit page opens with attachment image displayed
6. Fill in: provider name, prescription type, amount, copay percent, category
7. Add a prescription row with description, amount, copay
8. Save > Verify status updates, data persists on reload
9. Delete the prescription > Verify removed from list
**Expected:** Full CRUD lifecycle works, file upload creates prescription, data persists correctly
**Estimated Effort:** L (8-12h) -- New page objects + multi-step workflow

---

## 5. Hotfix Pattern Analysis

| Pattern | Status | PRs Affected | Findings |
|---------|--------|--------------|----------|
| Edge Cases (26%) | Warning | HM-14283, HM-14211 | HM-14283 IS an edge case fix (empty batch). HM-14211 upload validates extension only. |
| Enum/Switch Incomplete (20%) | Warning | HM-14278, HM-14253 | HM-14278 adds new enums with `<Flags>` attribute. HM-14253 replaces hardcoded packet list with DB lookup. |
| NULL Handling (18%) | OK | HM-14267, HM-14211 | HM-14267 uses `Maybe` pattern for nullable dates. HM-14211 handles DBNull correctly. |
| Logic/Condition Errors (16%) | Warning | HM-14227, HM-14233, HM-14253 | HM-14227 complex branching for due date validation. HM-14253 reordered logic for package deactivation. |
| Type Casting Errors (12%) | OK | HM-14210 | HM-14210 IS a type casting fix -- TRY_CONVERT for insurance form 6b. |
| Missing Implementation (8%) | Warning | HM-14211 | `ApprovalStatusID` column added but described as "future use". |

---

## 6. Risk Mitigation

### 6.1 Critical Priority (Must Address)

| Risk | PR | Mitigation |
|------|----|------------|
| No tests for MediCollect due date validation | HM-14227 | Manual test: change due date on appointment in MediCollect collection |
| New Prescriptions feature has zero E2E | HM-14211 | Manual test: full CRUD lifecycle + file upload |
| 261-line DB migration with column drops | HM-14211 | Verify migration on staging; check LinkedCard.UserID is not referenced elsewhere |

### 6.2 High Priority (Must Test Before Release)

| Risk | PR | Mitigation Test |
|------|----|-----------------|
| SQL filter changes for referral allocation | HM-14267 | Verify "to be checked" view shows allocated credit notes correctly |
| Cross-company automation copy | HM-14278/79 | Copy rules to company with different category structure |
| Starter package re-activation | HM-14253 | Re-select Starter package, verify special needs preserved |

### 6.3 Testing Checklist

- [ ] **HM-14211:** Open Prescriptions -- create prescription with image, edit fields, add rows, save, delete
- [ ] **HM-14211:** Verify migration runs cleanly on staging (2 new tables, column drops)
- [ ] **HM-14227:** Change due date on appointment in MediCollect collection, verify tolerance check works
- [ ] **HM-14267:** Open "referrals to be checked" widget, verify allocated credit notes appear
- [ ] **HM-14278:** Copy automation rules to another company with mapping/category linking
- [ ] **HM-14279:** Verify copy result modal shows errors and warnings correctly
- [ ] **HM-14210:** Open insurance form 6b -- verify no conversion error
- [ ] **HM-14233:** Import clinical data with multi-decimal amounts, verify rounding
- [ ] **HM-14253:** Re-select Starter package in store, verify special needs not expired
- [ ] **HM-14283:** Open category list view in fresh/new company, verify editing works

---

## 7. Go/No-Go Recommendation

**Decision: GO WITH CAUTION**

**Conditions:**
1. Run manual testing checklist above (Section 6.3) before release
2. Verify HM-14211 migration runs cleanly on staging environment
3. Confirm `LinkedCard.UserID` column is not referenced by MyHealthBridge-Api or HealthBridge-Portal

**Reasoning:** The release is large but well-structured. The highest-risk item (HM-14211 Open Prescriptions) is gated behind a special need flag, limiting blast radius. Bug fixes are targeted and low-risk. The MediCollect due date change (HM-14227) needs manual validation of the tolerance logic. E2E coverage is low (35%), but the impacted areas are well-defined for focused manual testing.

---

## 8. Post-Release Monitoring (24h)

**Critical Metrics:**

| Metric | Threshold | Alert |
|--------|-----------|-------|
| SystemError count for prescription handling pages | > 5 in 1h | High |
| Referral approval errors | > 3 in 1h | High |
| Insurance form 6b rendering errors | Any | Medium |
| Store/package change errors | Any | Medium |

**Actions:**
- 0-4h: Monitor SystemError for new pages (openprescriptions, prescription, prescriptionhandler, prescriptionuploadhandler). Check MediCollect due date changes work in production.
- Week 1: Track prescription handling adoption and any data inconsistencies in MedicalPrescriptionCopay/MedicalPrescriptionRow tables.

---

*Generated: 2026-02-23 | Release: 09-2026 | PRs Analyzed: 10 (11 tickets) | Risk: Medium*
