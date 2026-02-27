# Requirements Analysis: HM-14200 - Get Prescriptions List of Company Prescriptions

**Ticket:** HM-14200
**Analyzed By:** QA Agent
**Analysis Date:** 2026-02-27
**Requirement Status:** Not Ready

---

## 1. Requirements Summary

**What:** New external API endpoint (`prescriptions`) to return a paginated list of company prescriptions with filtering by date ranges and statuses.

**Who:** External API consumers (integration partners), Mobile app (HBM-1882 consuming this endpoint)

**Why:** Enable external systems and the HealthBridge Mobile app to retrieve prescription data for the "Prescriptions" view (prescription folder).

**Where:** HealthBridge-Web WebServiceIntegration (external API), MedicalLedger infrastructure

**Complexity:** Medium

---

## 2. Business Gap Analysis

| Gap Type | Missing Information | Impact if Unaddressed | Priority |
|----------|---------------------|----------------------|----------|
| **API Spec Mismatch** | XML spec includes `<ApprovalStatus>` (Pending/Approved/Rejected) but implementation does NOT return it | Mobile app cannot display approval status shown in UI mockup | Critical |
| **DB Script Bug** | `HM-14200.txt` line 11: `ISNULL(MAX([ID], 0))` - `MAX()` takes 1 argument, parentheses misplaced. Should be `ISNULL(MAX([ID]), 0)` | **Deployment failure** - SQL syntax error will prevent migration from running | Critical |
| **Missing Detail Endpoint** | List returns URI `/prescriptiondetails.nv?id=X` but this endpoint does not exist on master or this branch | Mobile app clicking a prescription will get 404/error | Critical |
| **Pagination Metadata** | No total count returned - only data rows with offset/maxresults | Mobile app cannot determine total pages or show "X of Y" indicators | Important |
| **Status-to-Display Mapping** | Mobile shows "Sent - Waiting for Approval" but API Status enum has only: PrescriptionMissing, IncompleteData, Unmatched, Matched. The mobile display combines Status + ApprovalStatus | No documentation on how mobile maps API fields to display states | Important |
| **No ApprovalStatus Filter** | Search supports `statuses` filter (by StatusID) but not by ApprovalStatus | Cannot filter "only pending approval" prescriptions | Important |

### Domain / Regulatory Gaps

| Gap | Applicable Regulation | What's Missing | Impact if Unaddressed | Priority |
|-----|----------------------|----------------|----------------------|----------|
| Prescription retention | Healthcare Data Retention Act 2:10 | No documented retention period for prescription data | N/A for list endpoint (read-only) | Low |

**Domain context file used:** N/A - Prescriptions/medical ledger is cross-domain (clinical data + pharmacy)
**Regulations verified:** Healthcare Data Retention Act - no regulatory gaps for a read-only list endpoint

**Critical Questions for Product Owner:**
1. Should the API return `ApprovalStatus` as shown in the XML specification? The current implementation omits it.
2. Is the `prescriptiondetails.nv` detail endpoint being built in a separate ticket? Which ticket?
3. Does the mobile app need a total count for pagination (infinite scroll vs load-more)?

**Status:** 3 critical gaps identified - Must resolve

---

## 3. Requirements Completeness Score

| Dimension | Weight | Score (0-2) | Weighted | Assessment |
|-----------|--------|-------------|----------|------------|
| **Business Rules Defined** | 20% | 1/2 | 1.0 | XML spec provided but implementation deviates (missing ApprovalStatus) |
| **Edge Cases Addressed** | 15% | 1/2 | 0.75 | Good parameter validation exists; empty results, null handling covered |
| **Integration Impacts Clear** | 15% | 0/2 | 0.0 | Mobile app dependency unclear; detail endpoint missing; no API docs |
| **Error Handling Defined** | 15% | 2/2 | 1.5 | Comprehensive validation with translated error messages |
| **Multi-Repo Scope Clear** | 15% | 1/2 | 0.75 | HealthBridge-Web changes clear; Mobile + MyHealthBridge-Api impact undefined |
| **Domain/Regulatory Compliance** | 20% | 2/2 | 2.0 | Read-only endpoint, no regulatory concerns |
| **TOTAL** | 100% | - | **6.0/10** | **60%** |

### Readiness Decision

**Score: 6/10 (60%)**

- [x] Score < 7/10 - **STOP** - Clarify requirements with PO before planning

**Justification:** The implementation has good code quality with comprehensive unit/integration tests and solid parameter validation. However, the XML specification provided as the requirement includes `ApprovalStatus` which the implementation doesn't return, the DB migration script has a syntax error that will fail on deployment, and the list endpoint references a detail endpoint (`prescriptiondetails.nv`) that doesn't exist. These are blocking issues.

**Critical Questions to Resolve:**
1. **ApprovalStatus**: Should it be returned in the API response? The mobile UI mockup clearly shows approval states.
2. **DB Script**: Fix `ISNULL(MAX([ID], 0))` to `ISNULL(MAX([ID]), 0)` before merge.
3. **Detail endpoint**: Is `prescriptiondetails.nv` in scope for this ticket or a separate one?

---

## 4. Edge Cases & Exception Scenarios

### 4.1 Null/Empty States

| Scenario | Expected Behavior | Defined? |
|----------|-------------------|----------|
| No prescriptions for company | Returns empty `<Prescriptions/>` element | Handled in code |
| NULL ProviderName | Returns empty string | `If(IsDBNull(...), "")` |
| NULL PrescriptionTimestamp | Writes empty `<PrescriptionDate>` element | Checked |
| NULL Amount | Omits value in `<Amount>` element | Checked |
| NULL CurrencyCode | Defaults to "EUR" | Handled |

### 4.2 Boundary Values

| Scenario | Expected Behavior | Defined? |
|----------|-------------------|----------|
| maxresults = 0 or negative | InvalidDataException thrown | Validated |
| offset = 0 or negative | InvalidDataException thrown | Validated |
| Very large offset * maxresults overflow | Checked against `int.MaxValue` | Handled |
| Invalid status enum value | InvalidDataException thrown | Validated |
| Invalid date format | InvalidDataException thrown | Validated |
| importdateend same day | End time set to 23:59:59.9999999 | `AddDays(1).AddTicks(-1)` |

**Edge Case Status:** Well-covered for input validation. Acceptable

---

## 5. Multi-Repository Impact Analysis

### 5.1 HealthBridge-Web - Changes in branch

| Component | Change | Complexity | Risk |
|-----------|--------|------------|------|
| WebServiceIntegration API | New `prescriptions` endpoint + `PrescriptionListReply` | Low | Low |
| MedicalLedger.Infrastructure | New `MedicalPrescriptionReport.Search()` | Low | Low |
| Database | APIResources insert (syntax error) | Low | Critical |

### 5.2 Other Core Repositories

| Repository | Affected? | Notes |
|------------|-----------|-------|
| HealthBridge-Portal | No | No background processing needed |
| MyHealthBridge-Api | Unknown | Does the mobile app call this endpoint through MyHealthBridge-Api or directly? |
| HealthBridge-SystemManagement-Api | No | No user/company management changes |
| HealthBridge-Mobile | Likely consumer | HBM-1882 branch exists (`feature/HBM-1882-Create-prescriptions`). Mobile UI mockup provided. |

### 5.3 Microservice APIs

All N/A - Prescription list is served from HealthBridge-Web WebServiceIntegration, not microservices.

### 5.4 Cross-Repository Coordination

| Dependency | From to To | Deployment Order | Risk |
|------------|-----------|------------------|------|
| Mobile needs list API | HealthBridge-Web to HealthBridge-Mobile | API first | Medium |
| Mobile needs detail API | HealthBridge-Web to HealthBridge-Mobile | Detail endpoint missing | Critical |

---

## 6. Error Handling & Validation

| Error Scenario | User Message | Defined? |
|----------------|--------------|----------|
| Invalid maxresults | Translated "integrations.prescriptions.invalidparameter" | Yes |
| Invalid offset | Translated "integrations.prescriptions.invalidparameter" | Yes |
| Invalid date format | Translated "integrations.prescriptions.invaliddateformat" | Yes |
| Invalid status value | Translated "integrations.prescriptions.invalidparameter" | Yes |
| No permission | Standard API authentication (AuthenticationType=2) | Yes |

---

## 7. Risk Summary

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| DB migration fails in production | High | High | Fix `ISNULL(MAX([ID], 0))` syntax |
| Mobile app can't show approval status | High | Medium | Add ApprovalStatus to API response |
| Clicking prescription in mobile returns error | High | High | Build or clarify prescriptiondetails.nv scope |

---

## 8. Action Items

### Questions for Product Owner (Priority Order)

**Critical - Must Answer:**
1. The XML spec includes `<ApprovalStatus>Pending</ApprovalStatus>` but the code doesn't return it. Should ApprovalStatus be added to the response?
2. The list endpoint generates URIs pointing to `prescriptiondetails.nv` which doesn't exist. Is this being built in HM-14200 or a separate ticket?
3. Fix the SQL syntax error in `HM-14200.txt`: `ISNULL(MAX([ID], 0))` should be `ISNULL(MAX([ID]), 0)`.

**Important - Should Answer:**
4. Does the mobile app need a `totalCount` field in the response for pagination?
5. Should there be a filter parameter for `ApprovalStatus` (e.g., `approvalstatuses=1,2`)?
6. How does the mobile map API Status values to display labels? (e.g., Unmatched to "Sent - Waiting for Approval"?)

### Recommended Next Steps

1. [ ] **Dev team**: Fix DB script syntax error immediately
2. [ ] **PO**: Clarify ApprovalStatus inclusion in API response
3. [ ] **PO**: Confirm `prescriptiondetails.nv` scope and ticket
4. [ ] **Dev team**: Consider adding total count to support mobile pagination
5. [ ] Update API documentation with new endpoint specification

---

**Word Count:** ~870/1000
**Analysis Completed:** 2026-02-27
**Analyst:** QA Agent
**Review Status:** [ ] Reviewed by PO | [ ] Reviewed by Tech Lead | [ ] Ready for Planning
