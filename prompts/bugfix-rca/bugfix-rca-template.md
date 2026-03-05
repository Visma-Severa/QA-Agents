# Root Cause Analysis: <TICKET-ID>

**Branch:** `<branch-name>`
**Repository:** `<repo-name>` _(selected because: [branch found in this repo / only repo with matching branch / etc.])_
**Mode:** Hotfix / Investigation
**Release:** `<release-branch>` _(Hotfix mode only)_
**Date:** {date}

---

## 1. Executive Summary

| Field | Details |
|-------|---------|
| **Repository** | {repo name — how it was selected} |
| **Bug Description** | {what went wrong} |
| **Causative PR/Commit** | {PR # or commit hash, or "Unknown — see Failure Handling"} |
| **Root Cause Category** | {Edge Case / NULL Handling / Logic Error / etc.} |
| **Preventability Verdict** | Preventable / Partially Preventable / Not Preventable |
| **Severity** | Critical / High / Medium / Low |
| **Environment** | Production / Staging / Testing |

## 2. Bugfix Pattern Match

> **MANDATORY SECTION — Do not skip.**
>
> Use the pattern table matching the **analyzed repository** (not just branch prefix).
> See `context/historical-bugfix-patterns.md` for all repository-specific pattern tables.

| Pattern | % of Historical Bugs | Match? | Evidence |
|---------|---------------------|--------|----------|
| [Pattern 1 from repo table] | XX% | EXACT/PARTIAL/No Match | {evidence} |
| [Pattern 2 from repo table] | XX% | EXACT/PARTIAL/No Match | {evidence} |
| [Pattern 3 from repo table] | XX% | EXACT/PARTIAL/No Match | {evidence} |
| [Pattern 4 from repo table] | XX% | EXACT/PARTIAL/No Match | {evidence} |
| [Pattern 5 from repo table] | XX% | EXACT/PARTIAL/No Match | {evidence} |
| [Pattern 6 from repo table] | XX% | EXACT/PARTIAL/No Match | {evidence} |
| _[Pattern 7+ if repo table has more]_ | XX% | EXACT/PARTIAL/No Match | {evidence} |

**Primary Pattern Match:** {pattern name} ({percentage}%)
**Secondary Pattern:** {pattern name, if any}
**Combined Score:** {primary %}% of historical hotfixes match this primary pattern. {Secondary pattern noted as secondary factor, if applicable.}

> **Combined Score = Primary pattern % only.** Do not sum primary + secondary percentages.

**Why This Matters:** {Brief explanation of how this pattern typically occurs and how to prevent it}

## 3. Timeline

| Event | Date | Details |
|-------|------|---------|
| Bug Introduced | YYYY-MM-DD | In PR #XXX / Release-XX (or "Unknown") |
| Bug Discovered | YYYY-MM-DD | {How discovered} |
| Bugfix Deployed | YYYY-MM-DD | In bugfix/<TICKET_ID> |

_(If approaching 1500-word limit, abbreviate to a single sentence.)_

## 4. Technical Root Cause

### Original Code (Buggy)

```
{code snippet showing the bug, 5-10 lines}
```

**File:** `{file}:{line}`

### Fixed Code

```
{code snippet showing the fix, 5-10 lines}
```

### Analysis

{Explain why the original code was incorrect. Reference file:line locations.}

## 5. 5 Whys Analysis

| # | Why? | Answer |
|---|------|--------|
| 1 | Why did {the bug} happen? | {direct cause} |
| 2 | Why did {direct cause} happen? | {deeper cause} |
| 3 | Why did {deeper cause} happen? | {underlying cause} |
| 4 | Why did {underlying cause} happen? | {systemic cause} |
| 5 | Why did {systemic cause} happen? | **{root cause}** |

**Root Cause:** {1-2 sentence summary of the true root cause}

## 6. Preventability Assessment

| Prevention Layer | Could it have caught this? | Gap |
|-----------------|---------------------------|-----|
| Requirements Analysis | Yes/No | {details} |
| Code Review | Yes/No | {details} |
| Unit Tests | Yes/No | {details} |
| Integration Tests | Yes/No | {details} |
| E2E Automated Tests | Yes/No | {details} |
| Manual Acceptance Testing | Yes/No | {details} |

**Most effective prevention:** {which layer would have been most effective}

## 7. Recommendations

1. **Immediate:** {action to prevent recurrence}
2. **Short-term:** {process or test improvement}
3. **Long-term:** {systemic fix or pattern prevention}

_(If approaching 1500-word limit, abbreviate to 2 items.)_

---

**Constraints reminder:**

- Max 1500 words
- Bugfix Pattern Match section (Section 2) is MANDATORY — never skip it
- Use the correct pattern table based on **repository** (not just branch prefix)
- Combined Score = primary pattern % only — do NOT sum percentages
- Repository selection must be stated in the header
- file:line references for all code analysis
- 5 Whys must reach a systemic root cause, not stop at the surface
- If causative commit is unknown, state "Unknown" — do not fabricate
- Sections 3 and 7 may be abbreviated if space is tight; Sections 1, 2, 4, 5, 6 must not be abbreviated
