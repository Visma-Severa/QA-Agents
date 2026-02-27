# E2E Test Coverage Map

**Single source of truth for which E2E test suites cover which functional areas of the HealthBridge system.**

This file is referenced by all QA agents when assessing existing test coverage and recommending new tests.

---

## CRITICAL: Use Functional Area, NOT Branch Prefix

**Use FUNCTIONAL AREA to determine which E2E test suites to check -- NOT branch prefix.**

A code change in HealthBridge-Web (HM-*) can directly affect the Mobile app, and vice versa. The branch prefix only tells you WHERE the code was changed, not WHAT AREAS are impacted. For example:

- An HM-* branch modifying prescription API endpoints will affect Mobile prescription views
- An HMM-* branch changing appointment data models may require Web E2E test updates

Always identify the functional area first, then check all relevant test suites.

---

## How to Use

1. **Identify the functional area** of the feature being analyzed (e.g., Prescriptions, Insurance Claims, Appointments)
2. **Check this coverage map** to see which test suites cover that area
3. **For each framework:**
   - Coverage map shows check mark --> Search for existing tests, recommend ADD if missing
   - Coverage map shows N/A --> Report "N/A - Outside scope" (do NOT recommend adding)

---

## Quick Reference Table

| Functional Area | E2E Tests (Web/API) | Mobile Tests |
|-----------------|---------------------|--------------|
| Prescriptions / Medications | Yes | Yes |
| Patient Records / Medical Charts | Yes | No |
| Insurance Claims / Billing | Yes | Yes (approval only) |
| Appointments / Scheduling | Yes | Yes |
| Pharmacy / Medical Inventory | Yes | No |
| Staff Scheduling / Shifts | Yes | No |
| Staff Reimbursements | Yes | Yes |
| Insurance Processing | Yes | No |
| National e-Prescription Registry | Yes | Yes (read-only) |
| Payment Gateways | Yes | No |
| National Health Board Reports | Yes | No |
| Medical Licensing | No | No |
| Patient Portal | No | Yes |
| Discharge / Transfer | Yes | No |

---

## E2E Tests (HealthBridge-E2E-Tests) - Detailed

Repository: `HealthBridge-E2E-Tests` (C# / Playwright)

| Module | Test Folder | Key Test Files | Search Keywords |
|--------|-------------|----------------|-----------------|
| Prescriptions | Tests/Prescriptions/ | PrescriptionCreation.cs, PrescriptionRenewal.cs, PrescriptionCancel.cs | prescription, medication, dosage, refill |
| Patient Records | Tests/PatientRecords/ | PatientSearch.cs, MedicalHistory.cs, ChartUpdate.cs | patient, record, chart, history, medical |
| Insurance Claims | Tests/Insurance/ | ClaimSubmission.cs, ClaimApproval.cs, ClaimDenial.cs | claim, insurance, billing, coverage |
| Appointments | Tests/Appointments/ | AppointmentBooking.cs, AppointmentCancel.cs, AppointmentReschedule.cs | appointment, booking, schedule, calendar |
| Pharmacy | Tests/Pharmacy/ | InventoryCheck.cs, DrugDispense.cs, StockAlert.cs | pharmacy, inventory, dispense, stock, drug |
| Staff Scheduling | Tests/StaffScheduling/ | ShiftAssignment.cs, ShiftSwap.cs, OvertimeCalc.cs | shift, schedule, roster, overtime |
| Staff Reimbursements | Tests/Reimbursements/ | ExpenseSubmit.cs, ExpenseApproval.cs | expense, reimbursement, receipt |
| Discharge / Transfer | Tests/Discharge/ | DischargeProcess.cs, TransferRequest.cs | discharge, transfer, release |
| National Health Board | Tests/Reporting/ | HealthBoardReport.cs, ComplianceCheck.cs | report, compliance, health board |
| Payment Gateways | Tests/Payments/ | PaymentProcess.cs, RefundProcess.cs | payment, gateway, refund, transaction |
| Integration Tests | Tests/Integration/ | EPrescriptionApi.cs, PaymentGateway.cs, InsuranceApi.cs | api, integration, external, registry |

### Search Strategy

When searching for existing E2E tests, always search across ALL test directories first:

```bash
# Search across ALL test directories (do NOT limit to a single folder)
cd HealthBridge-E2E-Tests && git grep -n "<keyword>" origin/main -- "*.cs"
```

Do NOT search only by folder structure. Keyword-first search prevents missed coverage.

---

## Mobile Tests (HealthBridge-Mobile-Tests) - Detailed

Repository: `HealthBridge-Mobile-Tests` (Dart / Flutter integration tests)

| Module | Test Folder | Key Test Files | Search Keywords |
|--------|-------------|----------------|-----------------|
| Prescriptions | tests/prescriptions/ | prescription_view.dart, refill_request.dart, medication_list.dart | prescription, refill, medication, dosage |
| Insurance Claims | tests/insurance/ | claim_status.dart, claim_approval.dart, coverage_check.dart | claim, approval, insurance, coverage |
| Appointments | tests/appointments/ | book_appointment.dart, cancel_appointment.dart, appointment_reminder.dart | appointment, book, cancel, reminder |
| Reimbursements | tests/reimbursements/ | submit_expense.dart, expense_history.dart, receipt_upload.dart | expense, reimbursement, receipt, submit |
| Patient Portal | tests/patient_portal/ | portal_login.dart, health_summary.dart, message_doctor.dart | portal, summary, health, message |
| e-Prescription (read-only) | tests/e_prescription/ | prescription_lookup.dart, prescription_history.dart | e-prescription, lookup, registry |

### Search Strategy

```bash
# Search across ALL mobile test directories
cd HealthBridge-Mobile-Tests && git grep -n "<keyword>" origin/main -- "*.dart"
```

---

## Coverage Table Format for Reports

When reporting E2E coverage in any agent output, use this format:

| Framework | In Scope | Related Tests Found | Coverage Status |
|-----------|----------|---------------------|-----------------|
| E2E (Web) | Yes/No | [list test files] | Covered / Gap / N/A |
| E2E (Integration) | Yes/No | [list test files] | Covered / Gap / N/A |
| Mobile | Yes/No | [list test files] | Covered / Gap / N/A |

Always split Web and Integration test results into separate rows for clarity.
