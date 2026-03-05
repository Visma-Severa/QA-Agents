# Bug Report: {Error Summary Title}

**Ticket:** <TICKET-ID>
**Reporter:** {agent: "@hb-bug-report" / person: enter your name}
**Date:** {YYYY-MM-DD}

## JIRA Fields

| Field | Value |
|-------|-------|
| **Summary** | {concise bug title, max 80 chars} |
| **Component** | {affected HealthBridge component, e.g., Patient Portal, Scheduling, Billing, Lab Results, Prescriptions} |
| **Severity** | {one of: 🔴 Critical / 🟠 High / 🟡 Medium / 🟢 Low} |
| **Labels** | {relevant labels, e.g., regression, data-integrity, ui-defect, api-error} |
| **Affects Version** | {derive from: release branch name pattern `Release-<WEEK>/<YEAR>`, or `version.txt`, or `package.json` -- format as `Release-<WEEK>/<YEAR>` e.g., `Release-07/2026`} |

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
— _Derive from: reproduction attempts during analysis, git blame recency (new code = likely always), confidence level (low confidence = likely intermittent)_

## 3. Expected vs. Actual Behavior

> _Expected: derive from acceptance criteria, requirements doc, or equivalent working behavior in a prior release. Actual: copy exact error message, incorrect value, or UI state observed — no paraphrasing._

| | Description |
|---|------------|
| **Expected** | {what should happen — cite requirement or prior behavior if available} |
| **Actual** | {exact error message, incorrect value, or UI state — quote verbatim where possible} |

## 4. Root Cause Analysis

> _100-150 words explaining why the bug occurs. Reference specific code locations._

**Confidence:** {🟢 High (90-100%) / 🟡 Medium (60-89%) / 🔴 Low (30-59%)} — {one sentence justification, e.g., "Clear stack trace to exact line, easily reproducible."}

{Analysis of the underlying cause. Explain the code path that leads to the defect,
why the logic fails, and under what conditions the bug manifests.}

```csharp
// File: {file-path}:{line-number}
// Code causing the issue (5-10 lines max):
{relevant code snippet showing the defect}
```

## 5. Impact Assessment

| Factor | Assessment |
|--------|-----------|
| **Severity Justification** | {explain why this severity level was chosen based on the criteria below} |
| **User Impact** | {who is affected — patients, clinicians, admins; how many; which workflows break} |
| **Data Risk** | {any risk of data corruption, data loss, or incorrect medical records} |
| **Workaround Available?** | {Yes / No} — {if yes, describe the workaround steps} |

### Severity Criteria Reference

| Severity | Priority | Criteria |
|----------|----------|----------|
| 🔴 Critical | P1 | Data loss/corruption, security breach, system unusable, patient safety risk, HIPAA violation |
| 🟠 High | P2 | Core feature broken, no workaround, affects many users or critical workflows |
| 🟡 Medium | P3 | Feature impaired but workaround exists, limited user impact |
| 🟢 Low | P4 | Cosmetic issue, no functional impact |

## 6. Pattern Scope Analysis

| Question | Answer |
|----------|--------|
| **Isolated or pattern?** | {Isolated incident / Part of a broader pattern} |
| **Similar code elsewhere?** | {file paths where the same anti-pattern or similar logic exists} |
| **Related PRs/Commits** | {commit hashes or PR numbers from git log that introduced or fixed similar patterns, or "None found"} |
| **Related JIRA tickets** | {manually link if known, or "Requires JIRA search — see related commit IDs above"} |

> _If this is part of a pattern, list all affected locations so a comprehensive fix can be applied._

## 7. Fix Recommendation

| Option | Scope | Effort | Risk |
|--------|-------|--------|------|
| **Quick Fix** | {minimal change, address immediate symptom} | {Low, e.g., 1-2h} | {Medium — may not address root cause} |
| **Proper Fix** | {address root cause in affected component} | {Medium, e.g., 4-8h} | {Low — targeted fix} |
| **Comprehensive Fix** | {fix root cause + all similar patterns in codebase} | {High, e.g., 8-16h} | {Very Low — prevents recurrence} |

**Recommended: {Quick Fix / Proper Fix / Comprehensive Fix}** — {one sentence justification}

```csharp
// Recommended fix in {file-path}:{line-number} (3-5 lines max):
{code snippet showing the recommended option's implementation}
```

**Validation:** {How to verify the fix works — specific checks or assertions}

## 8. Test Data Requirements

> _Identify the exact data state that triggers the bug. Derive from Steps to Reproduce preconditions and root cause analysis. Include user roles, record states, and any specific field values required._

| Data Needed | Details |
|-------------|---------|
| {data type, e.g., patient record} | {specific values or conditions, e.g., "Patient with no assigned GP, IsActive=true"} |
| {data type, e.g., user role} | {specific role and permissions required, e.g., "Nurse role, no admin rights"} |
| {data type, e.g., feature flag} | {flag name and required state, e.g., "PrescriptionV2=enabled"} |

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

| Framework | Repository | Coverage | Recommendation |
|-----------|------------|----------|----------------|
| Selenium UI (Python) | HealthBridge-Selenium-Tests | {Full / Partial / Gap / N/A} | {existing test name, or new test to add, or "Outside scope"} |
| Selenium Integration (Python) | HealthBridge-Selenium-Tests | {Full / Partial / Gap / N/A} | {existing test name, or new test to add, or "Outside scope"} |
| Playwright (TypeScript) | HealthBridge-E2E-Tests | {Full / Partial / Gap / N/A} | {existing test name, or new test to add, or "Outside scope"} |
| Mobile (WebdriverIO) | HealthBridge-Mobile-Tests | {Full / Partial / Gap / N/A} | {existing test name, or new test to add, or "Outside scope"} |

---

**Constraints:**
- **Max 900 words** total report length
- **Code snippets:** 5-10 lines (Section 4 defect snippet) / 3-5 lines (Section 7 fix snippet)
- **file:line references** required for all code mentions
- **Severity must be justified** against the criteria table, not just assigned
- **Steps to reproduce** must be numbered, specific, and independently reproducible
- **Root cause** must reference actual code, not speculation
- **Confidence level** must be stated in Section 4
