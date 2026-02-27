**Release-09/2026 Release Assessment**
10 PRs (11 tickets) | 109 files | +10,470/-2,226 lines
**Overall Risk: MEDIUM**

---

## HIGHLIGHTS

- **HM-14211** -- New Open Prescriptions UI: prescription list, edit page, file upload with drag-and-drop, line item management. Gated behind `NewPrescriptionHandling` special need.
- **HM-14278/14279** -- Automation rule copying now matches categories by mapping code and dimensions by name cross-company. Result modal shows per-company/per-rule status.
- **HM-14249** -- Order dimension display fix with 3 excellent regression tests added.
- **HM-14261** -- Critical security dependency update (Microsoft.SemanticKernel.Core).
- **HM-14227** -- MediCollect Appointment: due date now editable while in collection.

---

## RISKS & GAPS

- **HM-14211 (HIGH)** -- 78 files, 261-line DB migration (2 new tables, column drops). Good unit tests but zero E2E coverage. Migration needs staging verification. Blast radius limited by feature flag.
- **HM-14227 (MEDIUM)** -- Appointment due date validation for collected appointments has no unit tests. Complex branching logic needs manual verification.
- **HM-14267 (MEDIUM)** -- SQL filter changes for referral allocation display. No unit tests for the new SQL logic.
- **HM-14253 (MEDIUM)** -- Starter package logic rewrite with no tests. Replaced hardcoded packet list with DB lookup.

---

## E2E REGRESSION COVERAGE

**Combined: 35% (low)**

- HM-14267 Referrals: Partial (CreditReferralTests exists, but no "to be checked" view test)
- HM-14249 Orders: Partial (Order tests exist, no dimension persistence test)
- HM-14278/79 Referral Automation: No copy workflow test
- HM-14227 Appointments/MediCollect: Partial (appointment tests, no MediCollect integration)
- HM-14210 Insurance Form 6b: No insurance form rendering test
- HM-14233 Clinical Statements: Full (ClinicalStatementTests)
- HM-14253 Store/Packages: No starter package test
- HM-14211 Prescription Handling: Zero coverage (new feature)
- HM-14261 Infrastructure: N/A
- HM-14283 Category List: Full (CategoryListTests)

---

## MANUAL TESTING REQUIRED

**P0 (Critical):**
- [ ] HM-14211: Full prescription CRUD -- create with image upload, edit, add rows, save, delete
- [ ] HM-14211: Verify DB migration runs cleanly on staging
- [ ] HM-14227: Change due date on MediCollect appointment in collection, verify tolerance check

**P1 (High):**
- [ ] HM-14267: "Referrals to be checked" shows allocated credit notes
- [ ] HM-14278: Copy automation rules cross-company with mapping/category linking
- [ ] HM-14210: Open insurance form 6b -- no error
- [ ] HM-14253: Re-select Starter package -- special needs preserved

**P2 (Medium):**
- [ ] HM-14233: Import clinical data with multi-decimal values, verify rounding
- [ ] HM-14283: Edit category list in new company

---

## RECOMMENDATION

**GO WITH CAUTION**

Conditions:
1. Complete P0 manual testing (prescriptions CRUD + migration + MediCollect)
2. Verify `LinkedCard.UserID` column drop doesn't break other repos
3. Run Selenium regression suite for Referrals, Clinical Statements, and Category List

[Full Risk Assessment Report](reports/week-release/Release-09-2026-Risk-Assessment.md)
