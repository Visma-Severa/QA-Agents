# Bug Severity Criteria

This document defines objective criteria for assessing bug severity in HealthBridge applications.

---

## Severity Levels

| Severity | Symbol | Priority | Description |
|----------|--------|----------|-------------|
| Critical | P1 | Immediate | System down, data loss, security breach, patient safety risk |
| High | P2 | Urgent | Core feature broken, significant user impact |
| Medium | P3 | Normal | Non-critical feature broken, limited impact |
| Low | P4 | Backlog | Minor issue, cosmetic, low impact |

---

## Critical Severity

### Definition
Issues that cause catastrophic failure, data loss, security vulnerabilities, or patient safety risks requiring immediate attention.

### Criteria (ANY ONE qualifies as Critical)

**System Availability:**
- [ ] Production system completely down
- [ ] Application crashes on startup for all users
- [ ] Login impossible for all users
- [ ] Critical service unavailable (e.g., prescription processing)

**Data Integrity:**
- [ ] Data loss or corruption occurring
- [ ] Database integrity compromised
- [ ] Patient medical records incorrect (diagnoses, medications, allergies)
- [ ] Irreversible data deletion without confirmation

**Security:**
- [ ] SQL injection vulnerability
- [ ] Authentication bypass
- [ ] Authorization bypass (access to unauthorized patient data)
- [ ] XSS allowing script execution
- [ ] Sensitive data exposure (patient records, medical history, personal info)
- [ ] HIPAA/regulatory compliance violation

**Patient Safety:**
- [ ] Prescription dosage calculations wrong
- [ ] Drug interaction check bypassed or showing incorrect results
- [ ] Allergy alerts not displaying
- [ ] Incorrect patient matched to records
- [ ] Lab results displayed for wrong patient

**User Impact:**
- [ ] >50% of active users affected
- [ ] All users in a critical user group affected (e.g., all physicians)
- [ ] Critical business process completely blocked (patient admission, emergency triage)

**Legal/Compliance:**
- [ ] Regulatory compliance violation
- [ ] Legal reporting incorrect
- [ ] Audit trail compromised

### Examples

```
CRITICAL Examples:
- "Database connection fails, all users cannot access system"
- "Prescription dosage calculation multiplies by 0, patients receive wrong medication instructions"
- "SQL injection allows unauthorized database access to patient records"
- "Lab results displayed for Patient A are actually Patient B's results"
- "Cannot save any patient records, emergency department workflow blocked"
- "Doctor A can see all patients in the system without department restriction"

NOT Critical (these are High):
- "Patient record creation fails but manual workaround exists"
- "Lab report shows wrong formatting for 10% of results"
- "Login slow (30 seconds) but eventually works"
```

### Response Time
- **Immediate:** Drop everything, all hands on deck
- **Fix Target:** Within hours
- **Release:** Hotfix to production ASAP

---

## High Severity

### Definition
Issues that prevent users from completing critical tasks but system remains operational and/or workarounds exist.

### Criteria (ANY ONE qualifies as High)

**Feature Availability:**
- [ ] Core clinical feature completely broken
- [ ] Critical workflow cannot be completed
- [ ] Major functionality unavailable
- [ ] Workaround exists but complex/time-consuming

**Data Integrity (Non-Critical):**
- [ ] Data integrity risk (but no actual loss yet)
- [ ] Clinical reports showing incorrect data
- [ ] Export/import functionality broken
- [ ] Data sync failing between systems

**User Impact:**
- [ ] 10-50% of users affected
- [ ] Critical user group partially impacted
- [ ] Multiple user complaints
- [ ] Clinical workflow significantly delayed

**Performance:**
- [ ] System unusable due to performance (>60s response times)
- [ ] Memory leaks causing frequent restarts
- [ ] Critical queries timing out

**Regression:**
- [ ] Previously working feature now broken
- [ ] Issue introduced in recent release
- [ ] Blocks rollout of new feature

### Examples

```
HIGH Examples:
- "Cannot create new patient records, workaround: use API endpoint directly"
- "Prescription approval page crashes, but prescriptions can be approved via mobile app"
- "Lab result report shows wrong reference ranges for 20% of test types"
- "Insurance claim submission fails, manual filing still works"
- "Appointment scheduling takes 10 minutes instead of 10 seconds"
- "Nurse role cannot access patient vitals dashboard"

NOT High (these are Medium):
- "Secondary diagnostic report fails but primary reports work"
- "UI button misaligned in one browser"
- "Export to PDF slow but completes eventually"
```

### Response Time
- **Urgent:** Address within 1 business day
- **Fix Target:** Within 1-3 days
- **Release:** Next scheduled release or urgent patch

---

## Medium Severity

### Definition
Issues that affect functionality but have workarounds, impact non-critical features, or affect limited users.

### Criteria (ANY ONE qualifies as Medium)

**Feature Availability:**
- [ ] Secondary feature broken
- [ ] Non-critical functionality unavailable
- [ ] Easy workaround available
- [ ] Affects convenience but not core clinical workflow

**UI/UX Issues:**
- [ ] UI workflow confusing or cumbersome
- [ ] Validation errors unclear
- [ ] Page layout broken in specific scenarios
- [ ] Navigation issues

**User Impact:**
- [ ] 1-10% of users affected
- [ ] Specific configuration/edge case
- [ ] Minor inconvenience
- [ ] Workaround is simple

**Performance:**
- [ ] Noticeable slowness but acceptable (<10s)
- [ ] Resource usage higher than expected
- [ ] UI responsiveness degraded

**Data Quality:**
- [ ] Minor data display issues
- [ ] Formatting incorrect
- [ ] Sorting/filtering not working
- [ ] Search results incomplete

### Examples

```
MEDIUM Examples:
- "Export to PDF button broken, but Export to Excel works"
- "Patient search slow with >1000 results, filtering helps"
- "Insurance code validation too strict, blocks edge cases"
- "Appointment calendar layout broken in Safari only"
- "Email notification delayed by 5 minutes"
- "Report footer shows wrong date format"

NOT Medium (these are Low):
- "Tooltip text has typo"
- "Button hover color slightly off"
- "Console warning with no user impact"
```

### Response Time
- **Normal:** Address in sprint planning
- **Fix Target:** Within 1-2 weeks
- **Release:** Next regular release

---

## Low Severity

### Definition
Minor issues, cosmetic problems, or enhancements that have minimal impact on functionality.

### Criteria (ANY ONE qualifies as Low)

**Cosmetic:**
- [ ] UI alignment/spacing issues
- [ ] Color/font inconsistencies
- [ ] Icon wrong or missing
- [ ] Minor visual glitches

**Text:**
- [ ] Typos in UI text
- [ ] Tooltip text missing or unclear
- [ ] Help text outdated
- [ ] Translation issues (non-critical)

**User Impact:**
- [ ] <1% of users affected
- [ ] Very specific edge case
- [ ] Enhancement rather than bug
- [ ] Minimal inconvenience

**Technical:**
- [ ] Console warnings (no functionality impact)
- [ ] Code quality issues (no behavior impact)
- [ ] Performance improvement opportunity
- [ ] Unused code/resources

**Nice to Have:**
- [ ] Feature request disguised as bug
- [ ] Enhancement suggestion
- [ ] Better way to do something

### Examples

```
LOW Examples:
- "Button text has typo: 'Savw' should be 'Save'"
- "Tooltip appears 1 pixel off-center"
- "Console shows deprecation warning"
- "Page title in browser tab could be more descriptive"
- "Field label alignment inconsistent"
- "Icon color doesn't match design system"

NOT a Bug (these are Enhancements):
- "Would be nice if button was bigger"
- "Should add shortcut key for this action"
- "Could improve performance by caching"
```

### Response Time
- **Backlog:** Address when time permits
- **Fix Target:** No specific deadline
- **Release:** Opportunistic (bundle with other changes)

---

## Assessment Decision Tree

Use this flowchart to determine severity:

```
START
  |
  +- Is system down or data lost? --YES-> CRITICAL
  |                                 NO|
  +- Security vulnerability? --YES-> CRITICAL
  |                           NO|
  +- Patient safety risk? --YES-> CRITICAL
  |                        NO|
  +- >50% users affected? --YES-> CRITICAL
  |                        NO|
  +- Core clinical feature completely broken? --YES-> HIGH
  |                                            NO|
  +- 10-50% users affected? --YES-> HIGH
  |                          NO|
  +- Critical workflow blocked? --YES-> HIGH
  |                              NO|
  +- Easy workaround exists? --NO-> HIGH
  |                           YES|
  +- Secondary feature broken? --YES-> MEDIUM
  |                             NO|
  +- UI/UX issue affecting workflow? --YES-> MEDIUM
  |                                   NO|
  +- Cosmetic or minor issue? --YES-> LOW
```

---

## Special Considerations

### Intermittent vs Stable

**Intermittent bugs** may warrant **+1 severity level** if:
- Difficult to diagnose
- Affects critical clinical operations
- Data loss risk when occurs
- Cannot be easily reproduced

**Example:**
- Stable bug: "Patient save always fails with insurance type X" -> High
- Intermittent bug: "Patient save randomly fails, data lost" -> Critical

### Workaround Quality

**Good workaround** (doesn't increase severity):
- Simple (1-2 steps)
- Doesn't lose data
- Documented
- Takes <1 minute

**Bad workaround** (increases severity):
- Complex (5+ steps)
- Requires technical knowledge
- Time-consuming (>5 minutes)
- Risk of errors

### User Type Impact

**Higher severity** if affects:
- Physicians during patient rounds
- Emergency department during triage
- Nurses during medication administration
- Lab technicians during result entry
- Multiple user roles

**Lower severity** if affects:
- Single user type
- Rarely used feature
- Optional functionality
- Test/demo environments only

### Business Context

**Higher severity during:**
- Peak patient hours
- Emergency situations
- Regulatory audit periods
- System migration windows
- Critical clinical processes

**Lower severity during:**
- Low-traffic periods
- Non-critical times
- Development/testing phases

---

## Edge Cases & Examples

### When to Escalate

**Medium -> High:**
- Customer escalation
- Multiple user complaints
- Regulatory deadline approaching
- Critical clinical period

**High -> Critical:**
- Actual data loss occurring (not just risk)
- Security actively being exploited
- System degradation affecting all users
- Patient safety impact discovered

### When to De-escalate

**Critical -> High:**
- Workaround discovered
- Only affects test environment
- Impact less than initially thought
- Risk mitigated

**High -> Medium:**
- Affects fewer users than estimated
- Simple workaround available
- Non-critical feature
- Can wait for normal release

---

## Severity vs Priority

**Severity** = Impact of the bug (objective)
**Priority** = Urgency of fixing it (subjective, business decision)

| Severity | Default Priority | Can be adjusted |
|----------|-----------------|-----------------|
| Critical | P1 (Immediate) | Rarely |
| High | P2 (Urgent) | Sometimes (business reasons) |
| Medium | P3 (Normal) | Often (based on sprint capacity) |
| Low | P4 (Low) | Often (may become P3 if many users request) |

### Example: Severity != Priority

```
Severity: High (core feature broken)
Priority: P3 (Normal)
Reason: Feature only used during annual health screening, occurrence is 10 months away

Severity: Medium (UI issue)
Priority: P2 (Urgent)
Reason: Hospital board demo tomorrow, UI needs to look good
```

---

## Documentation Requirements by Severity

### Critical
- **Detailed impact analysis** (estimated users, patient data scope)
- **Incident timeline**
- **Rollback plan**
- **Stakeholder communication plan**

### High
- **Impact assessment** (number of users)
- **Workaround documentation**
- **Regression test plan**

### Medium
- **Basic impact description**
- **Reproduction steps**

### Low
- **Brief description**
- **Screenshot** (if UI issue)

---

## Template Severity Justification

Use this template in bug reports:

```markdown
**Severity:** High

**Justification:**
- **Feature Impact:** Core prescription creation feature is broken
- **User Impact:** ~30% of users affected (those who create prescriptions without patient preselection)
- **Data Risk:** No data loss (crash prevents saving bad data)
- **Workaround:** Yes - Select patient before entering prescription details
- **Business Impact:** Slows down clinical workflow during peak hours

**Criteria Met:**
- [x] Core feature completely broken
- [x] 10-50% of users affected
- [ ] Critical workflow blocked
- [x] Workaround exists but complex
```

---

**File Location:** `prompts/bug-report/severity-criteria.md`

*Use this guide to ensure consistent, objective severity assessments.*
