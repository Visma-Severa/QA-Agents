# E2E Test Coverage Map

**Version:** 1.0
**Last Updated:** 2026-03-05

**Single source of truth for which E2E test suites cover which functional areas of the HealthBridge system.**

This file is referenced by all QA agents when assessing existing test coverage and recommending new tests.

---

> **WARNING — Manual-Only Area:** Medical Licensing has no automated E2E coverage in any framework. Any ticket touching this area must be flagged for full manual testing.

---

## CRITICAL: Use Functional Area, NOT Branch Prefix

**Use FUNCTIONAL AREA to determine which E2E test suites to check -- NOT branch prefix.**

A code change in HealthBridge-Web (HM-*) can directly affect the Mobile app, and vice versa. The branch prefix only tells you WHERE the code was changed, not WHAT AREAS are impacted. For example:

- An HM-* branch modifying prescription API endpoints will affect Mobile prescription views
- An HMM-* branch changing appointment data models may require Web E2E test updates

Always identify the functional area first, then check all relevant test suites.

---

## How to Use

1. **Identify the functional area(s)** of the feature being analyzed (e.g., Prescriptions, Insurance Claims, Appointments)
   - If a change spans multiple functional areas, repeat steps 2–3 for each area independently. Report coverage per area.
2. **Check the Quick Reference Table** to see which test suites cover that area
3. **For each framework with coverage ("Yes"):**
   - Find the matching module in the framework's detailed section below
   - Use the **Search Keywords** column from that module to search for existing tests
   - If tests exist → assess coverage status; if no tests found → recommend ADD
4. **For each framework without coverage ("No"):**
   - Report "N/A — Outside scope" (do NOT recommend adding)

---

## Quick Reference Table

| Functional Area | Selenium (Python) | Playwright (TypeScript) | Mobile (WebdriverIO) |
|-----------------|-------------------|------------------------|----------------------|
| Prescriptions / Medications | Yes | No | Yes |
| Patient Records / Medical Charts | Yes | No | No |
| Insurance Claims / Billing | Yes | Yes | Yes (approval only) |
| Appointments / Scheduling | No | Yes | Yes |
| Pharmacy / Medical Inventory | Yes | No | No |
| Staff Scheduling / Shifts | No | Yes | No |
| Staff Reimbursements | No | Yes | Yes |
| Insurance Processing | Yes | No | No |
| National e-Prescription Registry | Yes | No | Yes (read-only) |
| Payment Gateways | Yes | No | No |
| National Health Board Reports | Yes | No | No |
| Medical Licensing | No | No | No |
| Patient Portal | No | No | Yes |
| Discharge / Transfer | Yes | No | No |

---

## Selenium Tests (HealthBridge-Selenium-Tests) - Detailed

Repository: `HealthBridge-Selenium-Tests` (Python / Selenium)

| Module | Test Folder | Key Test Files | Search Keywords |
|--------|-------------|----------------|-----------------|
| Prescriptions | HBPrescriptions/ | test_prescription_create.py, test_prescription_renewal.py, test_prescription_cancel.py | prescription, medication, dosage, refill |
| Patient Records | HBPatientRecords/ | test_patient_search.py, test_medical_history.py, test_chart_update.py | patient, record, chart, history, medical |
| Insurance Claims | HBInsuranceClaims/ | test_claim_submission.py, test_claim_approval.py, test_claim_denial.py | claim, insurance, billing, coverage |
| Pharmacy | HBPharmacy/ | test_inventory_check.py, test_drug_dispense.py, test_stock_alert.py | pharmacy, inventory, dispense, stock, drug |
| Insurance Processing | HBInsuranceProcessing/ | test_insurance_calc.py, test_insurance_form.py | insurance, processing, calculation |
| National e-Prescription | HBEPrescription/ | test_eprescription_api.py, test_prescription_registry.py | e-prescription, registry, national |
| National Health Board | HBReporting/ | test_health_board_report.py, test_compliance_check.py | report, compliance, health board |
| Payment Gateways | HBPayments/ | test_payment_process.py, test_refund_process.py | payment, gateway, refund, transaction |
| Discharge / Transfer | HBDischarge/ | test_discharge_process.py, test_transfer_request.py | discharge, transfer, release |
| **Integration Tests** | **HBIntegrationTests/** | **test_prescription_api.py, test_patient_api.py, test_insurance_api.py** | **api, integration, external** |

> **CRITICAL:** Selenium contains BOTH UI tests AND Integration/API tests in separate directories. Always search ALL directories — do not limit to UI folders.

### Search Strategy

```bash
# Search across ALL Selenium test directories (do NOT limit to a single folder)
cd HealthBridge-Selenium-Tests && git grep -n "<keyword>" origin/main -- "*.py"
```

Do NOT search only by folder structure. Keyword-first search prevents missed coverage.

---

## Playwright Tests (HealthBridge-E2E-Tests) - Detailed

Repository: `HealthBridge-E2E-Tests` (TypeScript / Playwright)

| Module | Test Folder | Key Test Files | Search Keywords |
|--------|-------------|----------------|-----------------|
| Insurance Claims | Tests/Insurance/ | ClaimSubmission.spec.ts, ClaimApproval.spec.ts, ClaimDenial.spec.ts | claim, insurance, billing, coverage |
| Appointments | Tests/Appointments/ | AppointmentBooking.spec.ts, AppointmentCancel.spec.ts, AppointmentReschedule.spec.ts | appointment, booking, schedule, calendar |
| Staff Scheduling | Tests/StaffScheduling/ | ShiftAssignment.spec.ts, ShiftSwap.spec.ts, OvertimeCalc.spec.ts | shift, schedule, roster, overtime |
| Staff Reimbursements | Tests/Reimbursements/ | ExpenseSubmit.spec.ts, ExpenseApproval.spec.ts | expense, reimbursement, receipt |

### Search Strategy

```bash
# Search across ALL Playwright test directories
cd HealthBridge-E2E-Tests && git grep -n "<keyword>" origin/main -- "*.spec.ts"
```

---

## Mobile Tests (HealthBridge-Mobile-Tests) - Detailed

Repository: `HealthBridge-Mobile-Tests` (JavaScript / WebdriverIO)

| Module | Test Folder | Key Test Files | Search Keywords |
|--------|-------------|----------------|-----------------|
| Prescriptions | tests/prescriptions/ | prescription_view.js, refill_request.js, medication_list.js | prescription, refill, medication, dosage |
| Insurance Claims | tests/insurance/ | claim_status.js, claim_approval.js, coverage_check.js | claim, approval, insurance, coverage |
| Appointments | tests/appointments/ | book_appointment.js, cancel_appointment.js, appointment_reminder.js | appointment, book, cancel, reminder |
| Reimbursements | tests/reimbursements/ | submit_expense.js, expense_history.js, receipt_upload.js | expense, reimbursement, receipt, submit |
| Patient Portal | tests/patient_portal/ | portal_login.js, health_summary.js, message_doctor.js | portal, summary, health, message |
| e-Prescription (read-only) | tests/e_prescription/ | prescription_lookup.js, prescription_history.js | e-prescription, lookup, registry |

### Search Strategy

```bash
# Search across ALL mobile test directories
cd HealthBridge-Mobile-Tests && git grep -n "<keyword>" origin/main -- "*.js"
```

---

## Coverage Table Format for Reports

When reporting E2E coverage in any agent output, use this format:

| Framework | In Scope | Related Tests Found | Coverage Status |
|-----------|----------|---------------------|-----------------|
| Selenium UI | Yes/No | [list test files] | Full / Partial / Gap / N/A |
| Selenium Integration | Yes/No | [list test files] | Full / Partial / Gap / N/A |
| Playwright | Yes/No | [list test files] | Full / Partial / Gap / N/A |
| Mobile | Yes/No | [list test files] | Full / Partial / Gap / N/A |

**Row assignment for Selenium:** Tests in `HBIntegrationTests/` folder → report as **Selenium Integration** row. All other Selenium test folders → report as **Selenium UI** row.

**When to use 4-row vs 3-row format:**
- **4-row format (Selenium UI + Selenium Integration + Playwright + Mobile):** Use in **code review** and **bug report** agents where distinguishing existing UI vs Integration test coverage matters.
- **3-row format (Selenium + Playwright + Mobile):** Acceptable in **acceptance tests**, **QA test plans**, and **RCA** agents where the focus is on recommending new tests rather than auditing existing coverage splits.

### Coverage Status Definitions (Standardized Across All Agents)

| Status | Definition |
|--------|-----------|
| **Full** | Tests exist covering the happy path AND at least one edge case or error scenario relevant to the feature |
| **Partial** | Tests exist but only cover the happy path, or don't cover the specific scenario being analyzed |
| **Gap** | Framework covers this functional area (per Quick Reference Table above) but no tests exist for this specific feature |
| **N/A** | Framework doesn't cover this functional area (per Quick Reference Table above) |

---

## Change Log

| Date | Change | Source |
|------|--------|--------|
| 2026-03-05 | Initial version with 14 functional areas, 3 frameworks, detailed sections, coverage format, status definitions | Codebase analysis |
