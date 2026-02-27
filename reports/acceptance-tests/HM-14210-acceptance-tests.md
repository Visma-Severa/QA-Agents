# Acceptance Tests - HM-14210

> **Feature:** Prescriptions with Allocated Insurance Claims Missing from Approval Views
> **Source:** Branch `HM-14210-Prescriptions-to-be-checked-does-not-show-which-are-allocated` in HealthBridge-Web
> **Generated:** 2026-02-25
> **Status:** Draft - Ready for QA Review

---

## Requirements Validation Results

### Coverage Summary

| Metric | Count | Percentage |
|--------|-------|------------|
| Fully Implemented | 3 | 100% |
| Partially Implemented | 0 | 0% |
| Not Implemented | 0 | 0% |
| Test Automation Added | 0 | - |
| Extra Features | 0 | - |

**Verdict:** PASS (100% fully implemented)

---

### Detailed Validation

#### Original Requirements (from user input)

1. **R1:** If insurance claim is allocated but not yet approved, it is missing from the front page "In process" screen and prescriptions to be checked list — it should still remain in this list
2. **R2:** Prescriptions that have not yet been approved (e.g. if insurance claim is allocated to them and it is thus marked as settled) should show up via the In process widget
3. **R3:** This ticket fixes an earlier version of the same task

#### Correctly Implemented Requirements

| # | Requirement | Implementation Evidence | File:Line |
|---|-------------|------------------------|-----------|
| R1 | Claim-allocated unapproved prescriptions missing from approval views | New `limitIncludeAllocatedInsuranceClaim` flag added to `GetLimitByPrescriptionSettlementStatusSql()`. When enabled, the SQL settlement status filter is expanded to include prescriptions where `AllSettlementsSum = PrescriptionSum` (fully settled by insurance claim allocation) but `OnRound <> @OnRoundAccepted` (not yet approved). This ensures claim-allocated but unapproved prescriptions remain visible. | `PrescriptionViewReport.cs:2408-2443` |
| R2 | Settled-by-claim prescriptions should show in "In process" widget | `UserTasks.cs:GetPrescriptionApproverTasks()` now passes `includeAllocatedInsuranceClaims: true` when creating `ApproverPrescriptionList`. The widget link also appends `&limitincludeallocatedinsuranceclaim=1` so clicking the widget navigates to the correct filtered view. | `UserTasks.cs:277,287` |
| R3 | Fixes earlier version of the same task | Multiple commits show iterative fixes: initial implementation, SQL fix, date limits fix, simplification, and review fixes — indicating the earlier version had issues that are now resolved | Commits `717473145f` through `7cd5fd1684` |

#### Partially Implemented Requirements

None.

#### Test Automation Added

No new automated tests were added in this branch for HM-14210.

#### Extra Features (Not in Requirements)

No extra features detected — all code changes relate to the requirements.

---

### Immediate Actions Required

**For QA:**
- [ ] Verify claim-allocated prescriptions appear in "In process" widget count
- [ ] Verify clicking the widget link navigates to filtered prescription view with claim-allocated prescriptions visible
- [ ] Verify that APPROVED prescriptions with insurance claim allocation do NOT appear (they should be filtered out)
- [ ] Test with prescription date range filtering (period start/end dates)

---

## Requirements Traceability Matrix

**Status Legend:**
- **Covered** — This test plan includes scenarios that fully verify the requirement
- **NOT COVERED** — No scenario in this plan verifies the requirement

| Req ID | Requirement | Test IDs | Unit | Integration | E2E | Manual | Status |
|--------|-------------|----------|------|-------------|-----|--------|--------|
| R1 | Claim-allocated unapproved prescriptions visible in approval list | T01, T02, T04, T06 | - | Yes | Selenium | - | Covered |
| R2 | Settled-by-claim prescriptions show in "In process" widget | T03, T05, T07 | - | - | Selenium | - | Covered |
| R3 | Fixes earlier version of same task | T01, T02, T03 | - | - | - | - | Covered |

### Testability Summary

| Test Level | Requirements | Count | % |
|------------|-------------|-------|---|
| Unit Testable | - | 0 | 0% |
| Integration/EndToEnd Testable | R1, R2, R3 | 3 | 100% |
| E2E Testable (Selenium) | R1, R2 | 2 | 67% |
| Manual Only | - | 0 | 0% |

### Automation Coverage

| Metric | Count | % |
|--------|-------|---|
| Total Requirements | 3 | 100% |
| Fully Covered by Test Plan | 3 | 100% |
| Automatable (Integration + Selenium) | 3 | 100% |
| Manual Only | 0 | 0% |

---

## Overview

Prescriptions that had insurance claims allocated to them were disappearing from the "In process" widget on the front page and from the prescription approval/checking list. This happened because the SQL settlement status filter (`GetLimitByPrescriptionSettlementStatusSql`) considered these prescriptions as "settled" (since `AllSettlementsSum >= PrescriptionSum` after insurance claim allocation) and filtered them out — even though the prescriptions had not yet been approved (`OnRound <> ACCEPTED`).

The fix introduces an `includeAllocatedInsuranceClaims` parameter that expands the filter logic to also include prescriptions where settlements equal the prescription sum but the prescription is not yet in "accepted" state. The `UserTasks` widget handler passes this flag when loading prescriptions for the "In process" count, and the prescription view page accepts a new `limitincludeallocatedinsuranceclaim` URL parameter for the list filter.

**Key code changes:**
- `PrescriptionViewReport.cs` — New `LimitIncludeAllocatedInsuranceClaim` property + expanded SQL in `GetLimitByPrescriptionSettlementStatusSql()`
- `ApproverPrescriptionList.cs` — New `includeAllocatedInsuranceClaims` constructor parameter, passed to `GetUnsettledPrescriptions()`
- `UserTasks.cs` — Passes `includeAllocatedInsuranceClaims: true` + adds `&limitincludeallocatedinsuranceclaim=1` to widget link + adds prescription date range filtering
- `prescriptionview.aspx` — Accepts new `limitincludeallocatedinsuranceclaim` URL parameter

## Prerequisites

### Environment
- [ ] Staging or test environment with prescription management enabled
- [ ] Clinic with circulation/approval flow configured (content supervisor + approver)

### Test Data Setup

1. Create or use an existing pharmacy/provider
2. Create a prescription from the provider (positive amount, e.g., 100 EUR)
3. Create an insurance claim from the same provider (negative amount, e.g., -100 EUR)
4. Set up approval circulation rules (content supervisor and/or approver assigned)
5. For widget tests: Ensure the "In process" widget is visible on the home page

### User Permissions
- User with Prescription management rights (`ProfileGroup.PrescriptionViewsAndLists`)
- User configured as content supervisor or approver in circulation rules
- User with access to the front page/dashboard

---

## Test Scenarios

### Happy Path Scenarios

#### T01: Claim-Allocated Unapproved Prescription Visible in Prescription List

**Priority:** High
**Automation Candidate:** Yes (Selenium)

**Given** a prescription exists with status "New" or "In approval" (not yet approved)
**And** an insurance claim has been allocated to this prescription (making it fully "settled")
**When** user opens the prescription view (`prescriptionview.aspx`) with approval filters (New + In approval statuses)
**Then** the claim-allocated but unapproved prescription is visible in the list

**Test Steps:**
1. Create a prescription (100 EUR) from provider A
2. Create an insurance claim (-100 EUR) from provider A
3. Allocate the insurance claim to the prescription
4. Navigate to Prescriptions > Prescription View with status filters: New + In approval
5. Verify the prescription appears in the list

**Expected Results:**
- [ ] Prescription appears despite being "settled" by insurance claim allocation
- [ ] Prescription shows correct status (not "Accepted")
- [ ] Prescription sum and settlement information are displayed correctly

---

#### T02: Claim-Allocated Prescription Visible When Using `limitincludeallocatedinsuranceclaim` Parameter

**Priority:** High
**Automation Candidate:** Yes (Selenium)

**Given** a prescription has been fully settled via insurance claim allocation
**And** the prescription has NOT been approved yet
**When** user navigates to `prescriptionview.aspx` with URL parameter `limitincludeallocatedinsuranceclaim=1`
**Then** the prescription appears in the results

**Test Steps:**
1. Create and allocate insurance claim to prescription (as in T01)
2. Navigate directly to prescription view with `limitincludeallocatedinsuranceclaim=1` parameter
3. Verify the prescription is listed

**Expected Results:**
- [ ] URL parameter correctly enables the extended filter
- [ ] Claim-allocated unapproved prescriptions are included in results
- [ ] The filter behaves as expected alongside other status filters

---

#### T03: "In Process" Widget Shows Claim-Allocated Unapproved Prescriptions in Count

**Priority:** High
**Automation Candidate:** Yes (Selenium)

**Given** there are N unapproved prescriptions
**And** one of them has an insurance claim allocated (marked as settled)
**When** user views the front page "In process" widget
**Then** the widget count includes the claim-allocated unapproved prescription

**Test Steps:**
1. Note current "In process" / "Prescriptions to be checked" count on front page
2. Create a prescription and assign to circulation (content supervisor/approver)
3. Verify widget count increases by 1
4. Allocate an insurance claim to this prescription
5. Verify widget count still includes this prescription (does NOT decrease)

**Expected Results:**
- [ ] Widget count includes claim-allocated unapproved prescriptions
- [ ] Count accurately reflects all prescriptions that need approval action
- [ ] Sum displayed in widget is correct

---

### Alternative Flow Scenarios

#### T04: Approved Prescription with Insurance Claim Allocation NOT Shown in Approval View

**Priority:** High
**Automation Candidate:** Yes (Selenium)

**Given** a prescription has been fully approved (OnRound = ACCEPTED)
**And** an insurance claim has been allocated to it
**When** user opens the prescription approval view
**Then** this prescription does NOT appear (it is correctly filtered out since it's already approved)

**Test Steps:**
1. Create a prescription and complete the full approval flow
2. Allocate an insurance claim to the approved prescription
3. Navigate to prescription view with approval filters
4. Verify the approved prescription does NOT appear

**Expected Results:**
- [ ] Approved prescriptions with insurance claim allocation are correctly excluded
- [ ] Only unapproved prescriptions with insurance claim allocation remain visible
- [ ] No false positives in the approval list

---

#### T05: Widget Link Navigates to Correct Filtered View

**Priority:** Medium
**Automation Candidate:** Yes (Selenium)

**Given** the "In process" widget shows prescriptions count
**When** user clicks the prescription task link in the widget
**Then** the URL contains `limitincludeallocatedinsuranceclaim=1` and `begindate` parameters
**And** the resulting list includes claim-allocated unapproved prescriptions

**Test Steps:**
1. Ensure at least one claim-allocated unapproved prescription exists
2. Navigate to front page
3. Click the "Prescriptions to be checked" link in the "In process" widget
4. Verify the URL contains the new parameter
5. Verify the claim-allocated prescription appears in the filtered list

**Expected Results:**
- [ ] URL includes `limitincludeallocatedinsuranceclaim=1`
- [ ] URL includes `begindate` parameter (oldest open period start date)
- [ ] Listed prescriptions match the widget count

---

### Error Handling Scenarios

#### T06: No Insurance Claims Allocated — Standard Behavior Unchanged

**Priority:** Medium
**Automation Candidate:** Yes (Selenium)

**Given** prescriptions exist with no insurance claim allocations
**When** user opens the prescription approval view
**Then** standard filtering behavior is preserved (open/overdue prescriptions shown, settled prescriptions hidden)

**Expected Results:**
- [ ] No regression in standard prescription list behavior
- [ ] Prescriptions without insurance claim allocations display as before
- [ ] Settled prescriptions (via direct payment, not insurance claim allocation) are still correctly hidden

---

#### T07: "In Process" Widget with "My Tasks" Filter

**Priority:** Medium
**Automation Candidate:** Yes (Selenium)

**Given** the "In process" widget is set to "My tasks" (targeted to current user)
**And** a claim-allocated unapproved prescription is assigned to the current user
**When** user views the "My tasks" widget
**Then** the claim-allocated prescription is included in the count

**Test Steps:**
1. Create a prescription with circulation targeting the current user
2. Allocate an insurance claim to it
3. Switch widget to "My tasks" mode
4. Verify the prescription is counted

**Expected Results:**
- [ ] "My tasks" filter correctly includes claim-allocated unapproved prescriptions assigned to user
- [ ] Count matches when switching between "All tasks" and "My tasks"

---

### Edge Case Scenarios

#### T08: Partial Insurance Claim Allocation — Prescription Still Shows as Open

**Priority:** Medium
**Automation Candidate:** Yes

**Given** a prescription (100 EUR) has a partial insurance claim allocation (50 EUR claim)
**And** the prescription is not yet approved
**When** user views the approval list
**Then** the prescription appears (it was already showing before the fix since AllSettlementsSum < PrescriptionSum)

**Expected Results:**
- [ ] Partially claim-allocated prescriptions still appear correctly
- [ ] Open sum reflects the partial settlement

---

#### T09: Prescription Date Range Filtering with Claim-Allocated Prescriptions

**Priority:** Medium
**Automation Candidate:** Yes

**Given** a claim-allocated unapproved prescription exists with a prescription date within the open reporting period
**When** user views the approval list (which uses period date range filtering)
**Then** the prescription appears within the date-filtered results

**Expected Results:**
- [ ] Prescription date range filter (from `PeriodReport.GetOldestOpenPeriodStartDate()`) correctly includes the prescription
- [ ] Prescriptions outside the period range are not shown

---

#### T10: Multiple Insurance Claim Allocations on Same Prescription

**Priority:** Low
**Automation Candidate:** Yes

**Given** a prescription (200 EUR) has multiple insurance claim allocations (e.g., -100 EUR + -100 EUR)
**And** the prescription is not yet approved
**When** user views the approval list
**Then** the prescription appears (total settlements equal prescription sum, but not approved)

**Expected Results:**
- [ ] Multiple insurance claim allocations are correctly summed
- [ ] Prescription still shows in approval view since not approved

---

## Regression Test Checklist

Based on the changes to `PrescriptionViewReport.cs`, `UserTasks.cs`, `ApproverPrescriptionList.cs`, and `prescriptionview.aspx`, verify these existing features still work:

| Area | Test Case | Priority | Last Passed |
|------|-----------|----------|-------------|
| Prescription List | Standard open/overdue prescription filtering | High | Not Run |
| Prescription Approval | Normal approval flow (no insurance claim allocation) | High | Not Run |
| Insurance Claim Allocation | Allocating insurance claim to prescription | High | Not Run |
| Insurance Claim Allocation | Editing/deleting insurance claim allocation | Medium | Not Run |
| "In Process" Widget | Widget displays correct counts for non-claim scenarios | High | Not Run |
| "In Process" Widget | "All tasks" vs "My tasks" toggle | Medium | Not Run |
| Prescription View | Status filters (New, In approval, Ready for processing) | High | Not Run |
| Prescription View | Pagination and sorting with new filter | Medium | Not Run |
| Direct Payment | Direct payment settlement status filtering | Medium | Not Run |

---

## E2E Test Coverage Analysis

### Existing Automated Test Coverage

| Repository | Technology | Related Tests Found | Coverage Status |
|------------|------------|---------------------|-----------------|
| Selenium UI | C#/Selenium | `HBPrescriptionTests/Tests/InsuranceClaimTests.cs` — 6 tests for insurance claim allocation, editing, deletion | Partial — insurance claim allocation tested but NO test for visibility of claim-allocated prescriptions in approval view |
| Selenium Integration | C#/NUnit | No related integration tests found for this specific scenario | Gap — no API-level test for claim-allocated prescription visibility |
| Playwright | TypeScript | N/A — Prescriptions not in Playwright scope | N/A — Outside scope |
| Mobile | JavaScript/WebdriverIO | `test/suites/12_prescriptions/` — 8 tests for prescription approval/reject flow | Partial — tests approval flow but does not test claim-allocated prescription scenario |

### E2E Test Recommendations

| Scenario | Automate? | Framework | Priority | Effort | Justification |
|----------|-----------|-----------|----------|--------|---------------|
| T01 (Claim-allocated unapproved in list) | Yes | Selenium UI | P0 | Medium | Core regression scenario — this was the bug |
| T03 (Widget count includes claim-allocated) | Yes | Selenium UI | P0 | Medium | Validates the "In process" widget fix |
| T04 (Approved with claim NOT shown) | Yes | Selenium UI | P1 | Low | Ensures no false positives |
| T05 (Widget link with correct parameters) | Yes | Selenium UI | P1 | Low | Validates navigation from widget |
| T06 (Standard behavior unchanged) | Yes | Selenium UI | P1 | Low | Regression safety |
| T07 (My tasks filter) | Yes | Selenium UI | P2 | Medium | Validates targeted tasks |

### Suggested Test Implementation

**For Selenium (C#):**
```csharp
[Test]
[Category("Prescription")]
[Category("InsuranceClaim")]
[Category("Regression")]
public void ClaimAllocatedUnapprovedPrescription_VisibleInApprovalView()
{
    // Arrange: Create prescription, create insurance claim, allocate claim
    // Act: Navigate to prescription view with approval filters + limitincludeallocatedinsuranceclaim=1
    // Assert: Claim-allocated unapproved prescription is visible in the list
}

[Test]
[Category("Prescription")]
[Category("Widget")]
public void InProcessWidget_IncludesClaimAllocatedUnapprovedPrescriptions()
{
    // Arrange: Create and allocate insurance claim to unapproved prescription
    // Act: Check front page "In process" widget count
    // Assert: Widget count includes the claim-allocated unapproved prescription
}
```

---

## Automation Notes

### Recommended for Automation
- T01, T03: Core regression scenarios — must be automated to prevent recurrence
- T04: Critical negative test — ensures approved prescriptions don't reappear
- T05: Widget link verification — validates end-to-end navigation flow

### Manual Testing Required
- Visual verification that widget link correctly opens filtered view
- Cross-browser verification of URL parameter handling

---

## Data Cleanup

After test execution:
1. Delete test prescriptions and insurance claims created during testing
2. Remove insurance claim allocations
3. Provider and circulation rules can be retained (reusable)

---

## Sign-off

| Role | Name | Date | Status |
|------|------|------|--------|
| QA Engineer | | | Pending |
| Developer | | | Pending |
| Product Owner | | | Pending |
