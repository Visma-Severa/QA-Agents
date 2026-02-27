# Domain: Staff Scheduling & Workforce Management — Agent Context

> **Purpose:** Staff scheduling, shift management, credential tracking, and workforce compliance regulatory/business rules for HealthBridge. Enables agents to flag domain-specific gaps that code-level analysis would miss.
> **Used by:** Requirements Analysis, Code Review, Acceptance Tests, Bugfix RCA agents — when analyzing staff scheduling, shift management, on-call, overtime, or credential features.
> **Maintainer:** QA Team + Workforce Management Domain Expert
> **Last Updated:** 2026-02-27
> **Review Status:** [ ] Verified by Domain Expert | [ ] Verified by PO

---

## How Agents Use This File

1. **Load when:** Ticket involves staff scheduling, shift management, rotation patterns, on-call assignments, coverage requirements, overtime, credential tracking, department staffing, or workforce compliance
2. **Cross-reference:** Check if requirements address the regulatory rules below
3. **Flag gaps:** If a scheduling feature doesn't mention rest period requirements, credential verification, or coverage minimums — flag it
4. **Edge cases:** Add scheduling-specific edge cases (cross-midnight shifts, holiday scheduling, credential expiry during shift, multi-department float staff) to analysis
5. **Integration checks:** Verify time-and-attendance system, payroll, and credential verification integration requirements are addressed

**Trigger keywords:** schedule, shift, rotation, on-call, staffing, coverage, overtime, credential, department, provider availability, shift swap, shift bid, call schedule, rest period, float pool, agency staff, time off, PTO, leave request, break, fatigue management

---

## Quick Reference: Regulatory Requirements

| Rule ID | Requirement | Regulation/Source | Compliance | Impact if Missed |
|---------|-------------|-------------------|------------|------------------|
| SS-REG-001 | Nurses must have uninterrupted rest periods of at least 10 consecutive hours between shifts | State Nurse Staffing Laws / Joint Commission | Mandatory | Staff fatigue, patient safety risk, regulatory citation |
| SS-REG-002 | Physicians (residents) limited to 80 hours/week averaged over 4 weeks, with maximum 24+4 hour continuous duty | ACGME Duty Hour Requirements | Mandatory | Accreditation violation, physician well-being |
| SS-REG-003 | Staff must hold valid, non-expired credentials (license, certifications) to work clinical shifts | State Licensing Boards / CMS CoP | Mandatory | Practicing without valid license, facility liability |
| SS-REG-004 | Minimum nurse-to-patient ratios must be maintained per department type | State Staffing Ratio Laws (varies by state) | Mandatory (where enacted) | Regulatory citation, patient safety compromise |
| SS-REG-005 | Overtime hours must comply with Fair Labor Standards Act (FLSA) for non-exempt employees | FLSA (29 USC 207) | Mandatory | Wage and hour violations, back pay liability |
| SS-REG-006 | On-call staff must be able to respond within facility-defined response time (typically 30 minutes) | Facility Policy / CMS CoP | Mandatory | Delayed patient care, policy violation |
| SS-REG-007 | Mandatory overtime restrictions: some states prohibit mandatory overtime for nurses except in emergencies | State Labor Laws (varies) | Mandatory (where enacted) | Labor law violation |
| SS-REG-008 | Staff immunization and health screening records must be current per CDC/OSHA requirements | OSHA Bloodborne Pathogens Standard / CDC guidelines | Mandatory | Occupational health risk, regulatory citation |

---

## Business Rules

| Rule ID | Rule | Description | Edge Cases | Source |
|---------|------|-------------|------------|--------|
| SS-BIZ-001 | Shift types and duration | Standard shifts: Day (7a-7p), Night (7p-7a), Mid (11a-11p), Short (4h/8h); custom shift definitions per department | Cross-midnight shifts span two calendar days; DST transitions add/remove an hour | `ShiftTypeDefinition.cs` |
| SS-BIZ-002 | Coverage requirements by department | Each department has minimum staffing levels by role: e.g., ICU requires 1 RN per 2 patients, ED requires 1 RN per 4 patients | Census fluctuation during shift; patient transfers between departments mid-shift | `DepartmentCoverageRules.cs` |
| SS-BIZ-003 | Rotation pattern management | Rotation cycles (e.g., 4-on-2-off, 7-on-7-off) auto-generate schedules; deviations tracked as exceptions | Rotation start date changes; staff joining mid-rotation; rotation pattern change mid-cycle | `RotationPatternService.cs` |
| SS-BIZ-004 | On-call assignment rules | On-call requires primary + backup; escalation chain must be defined; response time logged | Primary unavailable — auto-escalate to backup; both unavailable — notify department head | `OnCallAssignmentService.cs` |
| SS-BIZ-005 | Shift swap workflow | Staff can request shift swaps; both parties and manager must approve; credential/qualification check required | Swap creates overtime for one party; swap violates rest period; swap crosses pay period boundary | `ShiftSwapService.cs` |
| SS-BIZ-006 | Credential-based scheduling | System must verify staff member holds required credentials for the assigned department/role; expired credentials block scheduling | Credential expiring between schedule publication and shift date; temporary credential/waiver | `CredentialValidationService.cs` |
| SS-BIZ-007 | Float pool and agency staff | Float pool staff can be assigned to any department matching their credentials; agency staff have facility-specific onboarding requirements | Float staff unfamiliar with department-specific protocols; agency staff credential verification delay | `FloatPoolAssignmentService.cs` |
| SS-BIZ-008 | Overtime calculation | Regular hours: 40/week (non-exempt); hours beyond 40 = overtime at 1.5x; double-time may apply per facility/state rules | Cross-week-boundary shifts; on-call callback hours; training hours counted or excluded | `OvertimeCalculationService.cs` |

---

## Schedule Generation Rules

### Shift Types

| Shift Type | Code | Hours | Start-End | Notes |
|-----------|------|-------|-----------|-------|
| Day | D | 12 | 07:00-19:00 | Standard day shift |
| Night | N | 12 | 19:00-07:00 | Night differential applies |
| Early | E | 8 | 06:00-14:00 | Used in outpatient departments |
| Late | L | 8 | 14:00-22:00 | Used in outpatient departments |
| Mid | M | 8 | 11:00-19:00 | Peak coverage shift |
| Short | S | 4 | Variable | Part-time, per diem |
| On-Call | OC | Variable | As needed | Response within 30 min |

### Rotation Patterns

| Pattern | Cycle | Example | Common Usage |
|---------|-------|---------|-------------|
| 4-on-2-off | 6 days | DDDD--DDDD-- | Nursing, 12-hour shifts |
| 7-on-7-off | 14 days | DDDDDDD------- | Travel nurses, locum tenens |
| 5-on-2-off | 7 days | EEEEE--EEEEE-- | Outpatient clinics, 8-hour |
| Alternating weekends | 14 days | DDDDD--DD---DD | Staff requesting weekend rotation |
| Custom | Variable | Per department rules | Specialty departments |

### Coverage Requirements by Department

| Department | Min RN:Patient Ratio | Min Staff Per Shift | On-Call Required | Special Requirements |
|-----------|---------------------|--------------------|-----------------|--------------------|
| ICU | 1:2 | 3 RN + 1 Charge | Yes (Intensivist) | Continuous monitoring trained |
| ED | 1:4 | 4 RN + 1 Charge + 1 MD | Yes (Trauma Surgeon) | ACLS/BLS certified |
| Med-Surg | 1:5 | 3 RN + 1 CNA | No | BLS certified |
| Labor & Delivery | 1:2 (active labor) | 2 RN + 1 Charge | Yes (OB/GYN) | NRP certified |
| OR | 1:1 (during procedure) | Per surgical schedule | Yes (Anesthesia) | Specialty-trained per case |
| Outpatient | 1:8 | 2 RN + 1 MA | No | Ambulatory care trained |

---

## Common Edge Cases (Domain-Specific)

| Scenario | Required Behavior | Regulatory Basis | Severity |
|----------|-------------------|------------------|----------|
| **Cross-midnight shift** | Shift spanning midnight (e.g., 19:00-07:00) must correctly allocate hours to the correct calendar day for payroll; overtime calculated per FLSA work week | FLSA | High |
| **DST spring forward (lose 1 hour)** | Night shift on DST spring forward is 11 hours, not 12; system must auto-adjust and not count phantom hour | FLSA | High |
| **DST fall back (gain 1 hour)** | Night shift on DST fall back is 13 hours; extra hour must be paid and counted toward overtime threshold | FLSA | High |
| **Credential expires between schedule publish and shift date** | System must re-validate credentials at shift start; if expired, flag shift for reassignment and alert manager | CMS CoP / State Licensing | Critical |
| **Shift swap creates overtime** | Before approving swap, system must calculate resulting overtime for both parties and flag for manager review | FLSA / Facility policy | High |
| **Minimum staffing not met after PTO approval** | PTO request that would drop department below minimum must be blocked or flagged for coverage | State staffing laws | Critical |
| **On-call primary and backup both unavailable** | Auto-escalate to department head; log escalation; ensure response within maximum allowed time | Facility policy | Critical |
| **Staff member assigned to two overlapping shifts** | System must prevent double-booking; if manual override attempted, require manager approval with reason | Schedule integrity | High |
| **Float staff assigned to department without matching credentials** | Block assignment; show credential mismatch error; suggest qualified alternatives | CMS CoP / State Licensing | Critical |
| **Rest period violation (less than 10 hours between shifts)** | Block scheduling that violates rest period; if emergency override, require documented justification | State nurse staffing laws | High |
| **Holiday scheduling fairness** | Holiday assignments must rotate fairly year-over-year; system tracks historical holiday assignments per staff member | Facility policy / Union agreement | Medium |
| **Agency staff without completed onboarding** | Block shift assignment until all onboarding requirements are met (orientation, credential verification, system access) | Facility policy | High |

---

## Integration Requirements

| External System | Data Exchange | Direction | Format | Deadlines | Error Handling |
|-----------------|---------------|-----------|--------|-----------|----------------|
| **Time-and-Attendance System** | Clock-in/out events, actual hours worked | Receive | REST API / flat file | Real-time or daily batch | Queue + retry; manual entry fallback |
| **Payroll System** | Approved hours, overtime, differentials | Send | REST API | Before payroll processing deadline | Queue + retry; hold payroll if unresolved |
| **Credential Verification (NPDB/State Boards)** | License status, expiration dates, disciplinary actions | Receive | REST API / batch file | Monthly or on-demand | Cache + flag expired; manual verification fallback |
| **PTO/Leave Management** | Approved time off, leave balances | Both | REST API | Real-time | Sync conflicts resolved by leave system as source of truth |
| **Bed Census System** | Current patient census by department | Receive | HL7 ADT / REST API | Real-time | Use last known census if feed interrupted |
| **Notification Service** | Shift reminders, on-call alerts, swap approvals | Send | REST API | Event-driven | Retry with escalation to SMS if push fails |

---

## Overtime and Compensation Rules

### Standard Overtime (FLSA)

| Condition | Rate | Calculation |
|-----------|------|-------------|
| Hours > 40 in work week (non-exempt) | 1.5x base rate | (Actual hours - 40) * hourly rate * 1.5 |
| Double time (if facility/state policy) | 2.0x base rate | Hours > 12 in a day (varies) |
| On-call callback (non-exempt) | Regular or OT rate | Callback hours added to weekly total |
| Holiday premium | Varies (1.5x or 2.0x) | Per facility policy or union agreement |

### Shift Differentials

| Differential Type | Typical Rate | Applied When |
|------------------|-------------|-------------|
| Night shift (7p-7a) | +10-15% | Any hours worked between 19:00-07:00 |
| Weekend (Sat-Sun) | +5-10% | Any hours worked on Saturday or Sunday |
| Holiday | +50-100% | Any hours worked on designated holidays |
| Charge nurse | +$2-5/hour | When assigned charge role for shift |
| Float differential | +$3-8/hour | When floating to a non-home department |

---

## Validation Rules

| Field / Calculation | Rule | Error Handling | Regulatory Basis |
|---------------------|------|----------------|------------------|
| Rest period | Minimum 10 consecutive hours between shifts | Block schedule; allow emergency override with justification | State staffing laws |
| Weekly hours (residents) | Max 80 hours averaged over 4 weeks | Warning at 75 hours; hard stop at 80 (4-week average) | ACGME |
| Continuous duty (residents) | Max 24+4 hours | Warning at 24 hours; hard stop at 28 hours | ACGME |
| Credential status | Must be Active and not expired at time of shift | Block scheduling if expired; warn if expiring within 30 days | CMS CoP |
| Coverage minimum | Department must meet minimum staffing per coverage rules | Block PTO/swap that violates minimum; flag uncovered shifts | State staffing ratios |
| Overtime threshold | 40 hours/week for non-exempt staff | Auto-calculate and flag shifts that would create overtime | FLSA |
| Shift overlap | No staff member may be scheduled for overlapping shifts | Block creation; require manager override for split shifts | Schedule integrity |
| On-call response time | Must be within facility-defined maximum (default 30 min) | Log response times; flag violations for review | Facility policy |
| Shift swap qualification | Both parties must hold required credentials for swapped departments | Block swap if credential mismatch | CMS CoP |

---

## Compliance Calendar

| What | When | Who Reports | Penalty for Late | System Impact |
|------|------|-------------|------------------|---------------|
| Credential verification | Monthly (rolling) | HR / Credentialing Office | Regulatory citation if expired staff works | Block scheduling for expired credentials |
| ACGME duty hour report | Quarterly | Residency Program | Accreditation warning/probation | Auto-generate from scheduling data |
| Nurse staffing ratio report | Daily / Per shift | Nursing Administration | State regulatory citation | Auto-calculate from schedule + census |
| Overtime compliance report | Bi-weekly (per pay period) | Finance / HR | FLSA wage violations | Auto-generate from time-and-attendance data |
| OSHA immunization compliance | Annual (with ongoing tracking) | Occupational Health | OSHA citation | Flag non-compliant staff |
| Holiday fairness audit | Annual (December) | HR / Scheduling Manager | Grievance/union complaint | Auto-generate holiday distribution report |

---

## Terminology

| English Term | Abbreviation | Definition |
|-------------|-------------|------------|
| Registered Nurse | RN | Licensed nurse with state board certification |
| Certified Nursing Assistant | CNA | Support staff with CNA certification |
| Medical Assistant | MA | Clinical support staff in ambulatory settings |
| Charge Nurse | - | Shift leader nurse responsible for unit operations |
| Float Pool | - | Staff available to work in multiple departments |
| Agency/Travel Staff | - | Temporary contract staff from external agencies |
| On-Call | OC | Staff available to respond within defined time |
| Shift Differential | - | Additional pay for non-standard shift hours |
| Per Diem | - | Staff working on an as-needed, day-by-day basis |
| Full-Time Equivalent | FTE | Standard measure of staff capacity (1.0 = 40h/wk) |
| Paid Time Off | PTO | Accrued leave hours available to staff |
| Work Week | - | FLSA-defined 168-hour period for overtime calculation |
| Census | - | Current patient count in a department |
| Coverage Gap | - | Period where minimum staffing is not met |
| Escalation Chain | - | Ordered list of contacts for on-call/emergency situations |
| Credential | - | Professional license, certification, or competency record |
| National Practitioner Data Bank | NPDB | Federal repository of practitioner credentials and actions |
| Accreditation Council for Graduate Medical Education | ACGME | Body governing physician residency training standards |

---

## Lessons from Production Bugs

| Bug | Root Cause | Domain Lesson | Pattern |
|-----|-----------|---------------|---------|
| HM-13780 | DST spring forward caused night shift to calculate as 12 hours instead of 11 — overtime triggered incorrectly | Cross-midnight shifts during DST transitions must use actual elapsed time, not assumed duration | Calculation/Logic (30%) |
| HM-14022 | Credential expiry check ran at schedule generation time but not at shift start — expired nurse worked a shift | Credential validation must occur at TWO points: schedule generation AND shift check-in | Edge Cases (28%) |
| HM-14088 | Shift swap approved despite creating 72-hour continuous duty for resident — system checked nurse rules (10h rest) not resident rules (24+4h max) | Role-based validation rules: nurses, residents, attending physicians each have different scheduling constraints | Authorization Gaps (22%) |
| HM-13910 | Float staff assigned to ICU via manual override but lacked ICU-specific certifications | Override workflows must still enforce credential requirements, not bypass them | Logic/Condition (16%) |

---

## Agent Checklist: Staff Scheduling Requirements

When analyzing staff scheduling-related requirements, verify these are addressed:

- [ ] **Rest period compliance:** Does the feature create or modify shift assignments? If yes, are minimum rest periods between shifts enforced?
- [ ] **Credential verification:** Does the feature assign staff to clinical shifts? If yes, are credential status and department-specific qualifications checked?
- [ ] **Coverage minimums:** Does the feature affect department staffing (PTO, swaps, transfers)? If yes, are minimum staffing levels enforced?
- [ ] **Overtime calculation:** Does the feature impact hours worked? If yes, is overtime correctly calculated per FLSA (40h/week for non-exempt)?
- [ ] **Cross-midnight shifts:** Does the feature involve shift time calculations? If yes, are cross-midnight shifts handled correctly for both scheduling and payroll?
- [ ] **DST handling:** Does the feature calculate shift duration? If yes, are DST spring-forward and fall-back transitions handled?
- [ ] **On-call escalation:** Does the feature involve on-call scheduling? If yes, is the escalation chain defined with backup coverage?
- [ ] **Shift swap validation:** Does the feature allow shift swaps? If yes, are credential checks, rest period checks, and overtime impact included?
- [ ] **Role-based rules:** Does the feature apply scheduling constraints? If yes, are different rules applied per role (nurse vs resident vs attending)?
- [ ] **Holiday fairness:** Does the feature affect holiday scheduling? If yes, is historical fairness data considered?
- [ ] **Float/agency staff:** Does the feature schedule non-regular staff? If yes, are onboarding and credential requirements enforced?

---

**File Version:** 1.0
**Created:** 2026-02-27
**Next Review:** 2026-Q2 (or after regulatory/policy changes)
