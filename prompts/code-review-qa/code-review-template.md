# Code Review Report Template

This template defines the structure and format for code review reports.

**USE THIS EXACT STRUCTURE - DO NOT MODIFY SECTION NUMBERS OR NAMES**

## CRITICAL CONSTRAINTS

| Constraint | Value | Enforcement |
|------------|-------|-------------|
| **Maximum Word Count** | **1300 words** | MANDATORY - Use tables, not paragraphs |
| **Focus** | **ISSUES & RISKS** | Don't describe obvious changes - identify PROBLEMS |
| **E2E Repositories** | **ALL FRAMEWORKS** | Playwright, Mobile |
| **Specificity** | **FILE:LINE REFS** | Every issue with specific location |
| **Hotfix Patterns** | **MANDATORY** | Check all 6 patterns from Hotfix RCA |
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

| Pattern | Status | Finding | Location |
|---------|--------|---------|----------|
| Edge Cases (28%) | pass/warn/fail | [specific finding] | [file:line] |
| Authorization Gaps (22%) | pass/warn/fail | [specific finding] | [file:line] |
| NULL Handling (18%) | pass/warn/fail | [specific finding] | [file:line] |
| Logic/Condition Errors (16%) | pass/warn/fail | [specific finding] | [file:line] |
| Data Validation (10%) | pass/warn/fail | [specific finding] | [file:line] |
| Missing Implementation (6%) | pass/warn/fail | [specific finding] | [file:line] |

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
- **Playwright:** `HealthBridge-E2E-Tests/` (TypeScript/Playwright)
- **Mobile:** `HealthBridge-Mobile-Tests/` (WebdriverIO)

| Framework | Test File | Test Name | Action | Reason | Effort |
|-----------|-----------|-----------|--------|--------|--------|
| Playwright | [path] | [name] | UPDATE/DELETE/ADD/NONE | [why] | [hrs] |
| Mobile | [path] | [name] | UPDATE/DELETE/ADD/NONE | [why] | [hrs] |

**E2E Effort Summary:**

| Repository | Update | Add | Delete | Total Effort |
|------------|--------|-----|--------|--------------|
| Playwright | [#] | [#] | [#] | [hours] |
| Mobile | [#] | [#] | [#] | [hours] |
| **TOTAL** | | | | **[hours]** |

### 4.3 Test Data Requirements

| Test Type | Data Needed | Source | Setup Required |
|-----------|-------------|--------|----------------|
| Unit Tests | [data] | Mock/Fixture | [steps] |
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

Based on the code changes analyzed above, manually test these critical scenarios before merging:

- [ ] **[Primary Flow]:** [Brief description of main user-facing change]
- [ ] **[Edge Case]:** [Key boundary condition or edge case to verify]
- [ ] **[Backward Compatibility]:** [Existing functionality that must still work]
- [ ] **[Error Handling]:** [Error scenario or validation to test]

**For Comprehensive Test Planning:**

This is a minimal checklist for quick pre-merge validation. For detailed acceptance test scenarios with Given/When/Then format, run the Acceptance Tests Agent:
```
@hb-qa-acceptance-tests <BRANCH-ID>
```

---

## 10. Developer Feedback

**Mode:** Interactive (default) / Static (`--no-feedback`)

### Interactive Mode (default)

After generating the report, the agent presents each finding to the developer. The developer selects a verdict for each finding from 4 options:

- **Valid** - Finding is accurate and actionable
- **False Positive** - Finding is incorrect or not applicable
- **Won't Fix** - Finding is valid but won't be addressed
- **Provide More Information** - Request deep analysis with probability, risk assessment, and code evidence

**"Provide More Information" triggers:**
1. Agent reads actual code at flagged location
2. Searches for sibling/related code patterns in codebase
3. Generates detailed analysis with risk assessment table (Probability x Impact x Detectability)
4. Saves to `reports/code-review/<TICKET>-findings-detailed.md`
5. Presents summary and asks for final verdict (Valid / False Positive / Won't Fix)

**The agent auto-populates this table** with developer responses. Findings that received deep analysis are noted in the Comment column.

| # | Section | Finding | Verdict | Comment |
|---|---------|---------|---------|---------|
| 1 | [3.2/6] | [Pre-populated from report findings] | [from developer] | [deep analysis note if applicable] |

**Output:** Feedback is also saved as JSON to `reports/feedback/<TICKET>-feedback.json` for accuracy tracking.

### Static Mode (`--no-feedback`)

When `--no-feedback` is specified, Section 10 is a static table. Developers fill in verdicts manually.

| # | Section | Finding | Verdict | Comment |
|---|---------|---------|---------|---------|
| 1 | [3.2/6] | [Pre-populated from report findings] | | |

**Overall Accuracy:** ___/10

---

*Generated: [date] | Branch: [branch] | Files: [count] | Risk: [level]*
```

---

## Section Guidelines

### Section 1: Summary
- Maximum 50 words
- What changed and why (business/clinical context)
- No code details

### Section 2: Risk Assessment
- All factors in table format
- Clear risk justification
- Consider patient safety and downstream impacts

### Section 3: Code Quality Review
- Two subsections required: Standard Checks + Hotfix Patterns
- Every check with status icon
- File:line references for any issues

### Section 4: Test Coverage Analysis
- Three subsections required: Unit Tests + E2E Impact + Test Data
- Cover ALL E2E repositories (Playwright, Mobile)
- Include effort estimates for each

### Section 5: Regression Testing
- Focus on areas outside the direct change
- Consider integration points

### Section 9: Critical Test Scenarios
- Keep to 3-5 scenarios maximum
- High-level only (one line per scenario)
- Focus on must-test items before merge
- Include reference to Acceptance Tests Agent for comprehensive planning

### Section 6: Issues Found
- Categorize by severity (Critical/Warning/Suggestion)
- Include file:line references
- Be actionable
- Critical/Warning findings MUST include Evidence
- Apply the False Positive Prevention Protocol before including any finding

### Section 7: Questions
- Specific, not generic
- Only if genuinely unclear

### Section 8: Recommendation
- One checkbox only
- Match to issues found

### Section 10: Developer Feedback
- Pre-populate the feedback table with ALL findings from Sections 3.2 (Hotfix Patterns) and 6 (Issues Found)
- Each finding that has warn or fail status in Section 3.2, or any issue listed in Section 6, gets its own row
- Leave Verdict and Comment columns empty for developers to fill in
- Include "Overall Accuracy" score field (___/10)
- This section is **excluded from the 1300 word count limit**

---

## Output Requirements

**Generate ONLY the Code Review Report:**

**Location:** `reports/code-review/<TICKET>-code-review.md`

**For comprehensive acceptance test scenarios**, use the separate Acceptance Tests Agent:
```
@hb-qa-acceptance-tests <BRANCH-ID>
```
