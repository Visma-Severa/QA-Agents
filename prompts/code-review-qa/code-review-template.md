# Code Review Report Template

**Related Documents:**
- `prompts/code-review-qa/code-review-qa.md` — PR analysis prompt (patterns, detection checklists, security checks)
- `prompts/code-review-qa/code-review-brief-template.md` — Brief report template
- `context/code-review-false-positive-prevention.md` — False positive prevention rules (Rules 1-6)

This template defines the structure and format for code review reports.

**USE THIS EXACT STRUCTURE - DO NOT MODIFY SECTION NUMBERS OR NAMES**

## CRITICAL CONSTRAINTS

| Constraint | Value | Enforcement |
|------------|-------|-------------|
| **Maximum Word Count** | **1300 words** | MANDATORY - Use tables, not paragraphs |
| **Focus** | **ISSUES & RISKS** | Don't describe obvious changes - identify PROBLEMS |
| **E2E Repositories** | **ALL FRAMEWORKS** | Selenium (Python), Playwright (TypeScript), Mobile (WebdriverIO) |
| **Specificity** | **FILE:LINE REFS** | Every issue with specific location |
| **Hotfix Patterns** | **MANDATORY** | Check all patterns from the repo-specific table in `context/historical-bugfix-patterns.md` |
| **Format** | **Tables > Prose** | Every finding in a table row |

---

## Report Structure

**COPY THIS STRUCTURE EXACTLY - DO NOT SKIP OR RENAME SECTIONS**

```markdown
# Code Review: [TICKET-ID] - [Title]

**Branch:** `[branch-name]`
**Repository:** [Auto-detected from branch prefix -- see Multi-Repository Workspace table for all repos]
**Review Date:** YYYY-MM-DD
**Risk Level:** Low | Medium | Critical

---

## 1. Summary (Max 50 words)

[2-3 sentences: What does this PR do? What's the business/clinical context?]

---

## 2. Risk Assessment

| Factor | Assessment |
|--------|------------|
| Files Changed | X files (+Y/-Z lines) |
| Core Areas Affected | [list affected modules -- e.g., Prescriptions, Patient Records, Billing] |
| Database Changes | Yes / No |
| API Changes | Yes / No |
| Breaking Changes | Yes / No |
| Patient Safety Impact | Yes / No |

**Risk Level: Low | Medium | Critical**

**Justification:** [One sentence explaining the risk rating]

---

## 3. Code Quality Review

### 3.1 Standard Checks

| Check | Status | Notes |
|-------|--------|-------|
| Follows conventions | pass/fail | [details if issue] |
| No logic errors | pass/fail | [details if issue] |
| Error handling | pass/fail | [details if issue] |
| Security (OWASP) | pass/fail | [details if issue] |
| Performance | pass/fail | [details if issue] |
| No hardcoded values | pass/fail | [details if issue] |

### 3.2 Hotfix Pattern Prevention

**Use the pattern table matching the auto-detected repository** from `context/historical-bugfix-patterns.md`.

| Pattern | Status | Finding | Location |
|---------|--------|---------|----------|
| [Pattern 1 (XX%)] | pass/warn/fail | [specific finding] | [file:line] |
| [Pattern 2 (XX%)] | pass/warn/fail | [specific finding] | [file:line] |
| [Pattern 3 (XX%)] | pass/warn/fail | [specific finding] | [file:line] |
| [Pattern 4 (XX%)] | pass/warn/fail | [specific finding] | [file:line] |
| [Pattern 5 (XX%)] | pass/warn/fail | [specific finding] | [file:line] |
| [Pattern 6 (XX%)] | pass/warn/fail | [specific finding] | [file:line] |

---

## 4. Test Coverage Analysis

### 4.1 Unit Test Coverage

| Source File | Test File | Status | Complexity | Est. Effort |
|-------------|-----------|--------|------------|-------------|
| [file.cs] | [test file or "None"] | pass/fail/warn | Low/Medium/High | [hours] |

**Unit Test Complexity:**
- **Low** (1-2h): Pure functions, DTOs, simple logic
- **Medium** (2-4h): Business logic, mockable dependencies
- **High** (4-8h): Complex clinical logic, tightly coupled services

### 4.2 E2E Automation Impact

**E2E Test Repositories:**
- **Selenium:** `HealthBridge-Selenium-Tests/` (Python/Selenium) — UI tests + Integration/API tests
- **Playwright:** `HealthBridge-E2E-Tests/` (TypeScript/Playwright)
- **Mobile:** `HealthBridge-Mobile-Tests/` (JavaScript/WebdriverIO)

| Framework | Test File | Test Name | Action | Reason | Effort |
|-----------|-----------|-----------|--------|--------|--------|
| Selenium UI | [path] | [name] | UPDATE/DELETE/ADD/NONE | [why] | [hrs] |
| Selenium Integration | [path] | [name] | UPDATE/DELETE/ADD/NONE | [why] | [hrs] |
| Playwright | [path] | [name] | UPDATE/DELETE/ADD/NONE | [why] | [hrs] |
| Mobile | [path] | [name] | UPDATE/DELETE/ADD/NONE | [why] | [hrs] |

**E2E Effort Summary:**

| Repository | Update | Add | Delete | Total Effort |
|------------|--------|-----|--------|--------------|
| Selenium | [#] | [#] | [#] | [hours] |
| Playwright | [#] | [#] | [#] | [hours] |
| Mobile | [#] | [#] | [#] | [hours] |
| **TOTAL** | | | | **[hours]** |

### 4.3 Test Data Requirements

| Test Type | Data Needed | Source | Setup Required |
|-----------|-------------|--------|----------------|
| Unit Tests | [data] | Mock/Fixture | [steps] |
| Selenium | [data] | Test DB/Fixture | [steps] |
| Playwright | [data] | Fixture/API | [steps] |
| Mobile | [data] | Test Account | [steps] |

---

## 5. Regression Testing Impact

| Impacted Area | Risk Level | Suggested Regression Tests |
|---------------|------------|---------------------------|
| [Feature -- e.g., Prescription Workflow] | Low/Medium/High | [specific scenarios] |

---

## 5.5 Security Consistency Check

**This section is MANDATORY for PRs modifying security-related code**

**Triggers:** PR contains changes to:
- TypeScript/JavaScript: authentication, token, session, cookie, authorization handling
- Files: `auth.ts`, `security.ts`, authentication modules
- Methods: token generation/validation, session management, permission checks

**If NOT triggered:** Report "N/A - No security code changes detected"

**If triggered, perform these checks:**

### 5.5.1 Client-Server Symmetry Analysis

| Check | Status | Finding |
|-------|--------|---------|
| Client-side security changes have server-side counterpart? | pass/fail | [Details] |
| Security feature disabled on client has server validation updated? | pass/fail | [Details] |
| Token generation changes match validation logic? | pass/fail | [Details] |

### 5.5.2 Dependency Impact (MANDATORY grep for usages)

| Dependent File | Dependency Type | Impact if Client-Side Change Deployed | Action Required |
|----------------|-----------------|---------------------------------------|-----------------|
| [file.cs] | Uses token from client | Will fail validation / Will break flow | Update in same PR / Safe |

### 5.5.3 Security Impact Documentation

| Aspect | Status | Notes |
|--------|--------|-------|
| WHY is security feature being modified? | pass/fail | [Explanation] |
| Security implications documented? | pass/fail | [What protection is changed?] |
| Alternative security measures in place? | pass/fail | [If disabling X, what replaces it?] |

### 5.5.4 Testing Evidence

| Test Type | Status | Evidence Location |
|-----------|--------|-------------------|
| Manual testing with security feature | pass/fail | [Screenshots / N/A] |
| Critical security flows tested | pass/fail | [Login / Patient access / Role verification] |
| Error scenarios tested | pass/fail | [Invalid token / Unauthorized access / Expired session] |

---

## 6. Issues Found

**Finding Quality Gate:** Only include findings with HIGH confidence (tool-verified). UNVERIFIED findings should be downgraded to Suggestion or moved to Section 7 (Questions).

### Critical (Must Fix)
1. [Issue with file:line reference] -- **Evidence:** [tool output or code reference that confirms this]

### Warning (Should Fix)
1. [Issue with file:line reference] -- **Evidence:** [tool output or code reference that confirms this]

### Suggestion (Nice to Have)
1. [Suggestion with file:line reference]

---

## 7. Questions for Author

1. [Specific question about the code]

---

## 8. Recommendation

- [ ] **Approve** - Ready to merge
- [ ] **Request Changes** - Issues must be addressed
- [ ] **Comment** - Questions need answers first

---

## 9. Critical Test Scenarios (Quick Checklist)

**Manual Verification Required Before Merge:**

Based on the code changes analyzed above, manually test these critical scenarios before merging. Add or remove items as appropriate for the PR — minimum 3, maximum 5.

- [ ] **[Primary Flow]:** [Brief description of main user-facing change]
- [ ] **[Edge Case]:** [Key boundary condition or edge case to verify]
- [ ] **[Backward Compatibility]:** [Existing functionality that must still work]
- [ ] **[Error Handling]:** [Error scenario or validation to test]

**For Comprehensive Test Planning:**

This is a minimal checklist for quick pre-merge validation. For detailed acceptance test scenarios with Given/When/Then format, run the Acceptance Tests Agent:
```
@hb-acceptance-tests <BRANCH-ID>
```

---

## 10. Developer Feedback

**Mode:** Interactive (default) / Static (`--no-feedback`)

Interactive feedback is managed by the agent per the feedback protocol in the agent prompt (Step 8). The agent auto-populates verdicts after collecting developer responses.

**Verdicts:**
- **Valid** — Finding is accurate and actionable
- **False Positive** — Finding is incorrect or not applicable
- **Won't Fix** — Finding is valid but won't be addressed

| # | Section | Finding | Verdict | Comment |
|---|---------|---------|---------|---------|
| 1 | [3.2/6] | [Pre-populated from report findings] | [from developer or empty in --no-feedback mode] | [deep analysis note if applicable] |

**Overall Accuracy:** ___/10

**Output:** Feedback is also saved as JSON to `reports/feedback/<TICKET>-feedback.json` for accuracy tracking.

---

*Generated: [date] | Branch: [branch] | Files: [count] | Risk: [level]*
```

---

## Section Constraints

These constraints add rules not visible in the template structure above. Sections not listed (2, 4, 5, 7) have no constraints beyond the template structure.

| Section | Constraint |
|---------|-----------|
| 1. Summary | Maximum 50 words. No code details. |
| 3.2 Hotfix Patterns | Use repo-specific pattern table. Apply False Positive Prevention rules before including any finding. |
| 4.3 Test Data | If no special test data is required, write "Standard test data sufficient — no special setup required" in a single row. |
| 6. Issues Found | Critical/Warning findings MUST include Evidence (tool output or code reference). |
| 8. Recommendation | One checkbox only — must match severity of issues found. |
| 9. Test Scenarios | Keep to 3-5 scenarios. One line per scenario. |
| 10. Developer Feedback | Pre-populate with ALL findings from Sections 3.2 (warn/fail) and 6 (all severities). **Excluded from 1300 word count limit.** |

---

## Output Requirements

**Generate ONLY the Code Review Report:**

**Location:** `reports/code-review/<TICKET>-code-review.md`

**For comprehensive acceptance test scenarios**, use the separate Acceptance Tests Agent:
```
@hb-acceptance-tests <BRANCH-ID>
```
