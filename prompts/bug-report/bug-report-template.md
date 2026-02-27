# Bug Report: {Error Summary Title}

**Ticket:** <TICKET-ID>
**Reporter:** {agent or person name}
**Date:** {YYYY-MM-DD}

## JIRA Fields

| Field | Value |
|-------|-------|
| **Summary** | {concise bug title, max 80 chars} |
| **Component** | {affected HealthBridge component, e.g., Patient Portal, Scheduling, Billing, Lab Results, Prescriptions} |
| **Severity** | {one of: 🔴 Critical / 🟠 Major / 🟡 Minor / 🟢 Trivial} |
| **Labels** | {relevant labels, e.g., regression, data-integrity, ui-defect, api-error} |
| **Affects Version** | {version or release, e.g., HealthBridge 2.4.1, WeekRelease-07/2026} |

---

## 1. Error Summary

> _30-50 words describing the bug concisely. State what is broken, where, and the immediate consequence._

{summary}

## 2. Steps to Reproduce

**Preconditions:**
- {precondition 1, e.g., user role, account state, feature flags}
- {precondition 2, e.g., specific data setup, browser/device}

**Steps:**
1. {step 1 — navigate to specific page or trigger specific action}
2. {step 2 — enter data or interact with UI element}
3. {step 3 — submit, save, or trigger the operation}
4. Observe: {what goes wrong — error message, incorrect result, crash}

**Frequency:** {Always / Intermittent (~X%) / Only under specific conditions}

## 3. Expected vs. Actual Behavior

| | Description |
|---|------------|
| **Expected** | {what should happen according to requirements or normal operation} |
| **Actual** | {what actually happens — include error messages, incorrect values, or UI state} |

## 4. Root Cause Analysis

> _100-150 words explaining why the bug occurs. Reference specific code locations._

{Analysis of the underlying cause. Explain the code path that leads to the defect,
why the logic fails, and under what conditions the bug manifests.}

```csharp
// File: {file-path}:{line-number}
// Code causing the issue:
{5-10 lines of the relevant code snippet showing the defect}
```

## 5. Impact Assessment

| Factor | Assessment |
|--------|-----------|
| **Severity Justification** | {explain why this severity level was chosen based on the criteria below} |
| **User Impact** | {who is affected — patients, clinicians, admins; how many; which workflows break} |
| **Data Risk** | {any risk of data corruption, data loss, or incorrect medical records} |
| **Workaround Available?** | {Yes / No} — {if yes, describe the workaround steps} |

### Severity Criteria Reference

| Severity | Criteria |
|----------|----------|
| 🔴 Critical | Data loss/corruption, security breach, system unusable, patient safety risk |
| 🟠 Major | Core feature broken, no workaround, affects many users or critical workflows |
| 🟡 Minor | Feature impaired but workaround exists, limited user impact |
| 🟢 Trivial | Cosmetic issue, no functional impact |

## 6. Pattern Scope Analysis

| Question | Answer |
|----------|--------|
| **Isolated or pattern?** | {Isolated incident / Part of a broader pattern} |
| **Similar code elsewhere?** | {file paths where the same anti-pattern or similar logic exists} |
| **Related bugs in JIRA?** | {related JIRA ticket IDs if found, or "None found"} |

> _If this is part of a pattern, list all affected locations so a comprehensive fix can be applied._

## 7. Fix Recommendation

{Specific, actionable fix suggestion. Explain what needs to change and why the proposed fix resolves the root cause.}

```csharp
// Recommended fix in {file-path}:{line-number}
{code snippet showing the corrected implementation}
```

**Validation:** {How to verify the fix works — specific checks or assertions}

## 8. Test Data Requirements

| Data Needed | Details |
|-------------|---------|
| {data type, e.g., patient record} | {specific values or conditions needed to reproduce} |
| {data type, e.g., appointment slot} | {specific values or conditions needed to reproduce} |

**SQL/Setup (if applicable):**
```sql
-- Query to create or identify test data:
{SQL query or manual setup steps to prepare the environment for reproduction}
```

## 9. Regression Test Recommendation

### Manual Tests

| # | Scenario | Steps | Expected Result |
|---|----------|-------|-----------------|
| 1 | {primary bug scenario} | {numbered steps} | {expected correct behavior} |
| 2 | {edge case or related scenario} | {numbered steps} | {expected correct behavior} |
| 3 | {boundary or negative test} | {numbered steps} | {expected correct behavior} |

### E2E Automation Gaps

| Framework | Coverage | Recommendation |
|-----------|----------|----------------|
| E2E Tests (Web/API) | {one of: ✅ Covered / ⚠️ Gap} | {action: existing test name, or new test to add} |
| Mobile Tests | {one of: ✅ Covered / ⚠️ Gap / N/A} | {action: existing test name, new test to add, or "Outside scope"} |

---

**Constraints:**
- **Max 600 words** total report length
- **Code snippets:** 5-10 lines only (focused on the defect)
- **file:line references** required for all code mentions
- **Severity must be justified** against the criteria table, not just assigned
- **Steps to reproduce** must be numbered, specific, and independently reproducible
- **Root cause** must reference actual code, not speculation
