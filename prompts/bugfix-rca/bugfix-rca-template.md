# Root Cause Analysis: <TICKET-ID>

**Branch:** `<branch-name>`
**Repository:** `<repo-name>`
**Mode:** Hotfix / Investigation
**Release:** `<release-branch>` _(Hotfix mode only)_
**Date:** {date}

---

## 1. Bug Summary

| Field | Details |
|-------|---------|
| **What happened** | {brief description of the bug} |
| **Who reported** | {reporter or detection method} |
| **When discovered** | {date/time} |
| **Environment** | Production / Staging / Testing |
| **Severity** | Critical / Major / Minor |

## 2. Bugfix Pattern Match

> **MANDATORY SECTION -- Do not skip.**

### Web/API Patterns (HM-* branches)

| Pattern | % of Historical Bugs | Match? | Evidence |
|---------|---------------------|--------|----------|
| Edge Cases | 28% | {yes/no} | {evidence} |
| Authorization Gaps | 22% | {yes/no} | {evidence} |
| NULL Handling | 18% | {yes/no} | {evidence} |
| Logic/Condition Errors | 16% | {yes/no} | {evidence} |
| Data Validation | 10% | {yes/no} | {evidence} |
| Missing Implementation | 6% | {yes/no} | {evidence} |

### Mobile Patterns (HMM-* branches)

| Pattern | % of Historical Bugs | Match? | Evidence |
|---------|---------------------|--------|----------|
| Calculation/Logic Errors | 30% | {yes/no} | {evidence} |
| State Management Issues | 25% | {yes/no} | {evidence} |
| Navigation/UI Lifecycle | 20% | {yes/no} | {evidence} |
| Edge Cases | 15% | {yes/no} | {evidence} |
| NULL/Optional Handling | 5% | {yes/no} | {evidence} |
| Missing Implementation | 5% | {yes/no} | {evidence} |

_(Use the table matching the repository type. Mark the primary match and any secondary matches.)_

**Primary Pattern Match:** {pattern name} ({percentage}%)

## 3. Root Cause -- 5 Whys Analysis

| # | Why? | Answer |
|---|------|--------|
| 1 | Why did {the bug} happen? | {direct cause} |
| 2 | Why did {direct cause} happen? | {deeper cause} |
| 3 | Why did {deeper cause} happen? | {underlying cause} |
| 4 | Why did {underlying cause} happen? | {systemic cause} |
| 5 | Why did {systemic cause} happen? | {root cause} |

**Root Cause:** {1-2 sentence summary of the true root cause}

## 4. Code Changes Analysis

**Files changed:**

| File | Lines Changed | What Was Fixed |
|------|--------------|----------------|
| `{file}:{line}` | +X / -Y | {description} |

**Key code snippet** (before / after):

```
// Before (buggy)
{code snippet showing the bug, 5-10 lines}

// After (fixed)
{code snippet showing the fix, 5-10 lines}
```

## 5. Preventability Assessment

| Prevention Layer | Could it have caught this? | Rating (1-5) | Notes |
|-----------------|---------------------------|--------------|-------|
| Requirements Analysis | {yes/no} | {1-5} | {why} |
| Code Review | {yes/no} | {1-5} | {why} |
| Unit Tests | {yes/no} | {1-5} | {why} |
| E2E Tests | {yes/no} | {1-5} | {why} |
| QA Manual Testing | {yes/no} | {1-5} | {why} |
| Monitoring/Alerts | {yes/no} | {1-5} | {why} |

**Most effective prevention:** {which layer would have been most effective}

## 6. Recommendations

1. **Immediate:** {action to prevent recurrence}
2. **Short-term:** {process or test improvement}
3. **Long-term:** {systemic fix or pattern prevention}

## 7. Lessons Learned

| Lesson | Action Item | Owner |
|--------|-------------|-------|
| {lesson 1} | {specific action} | {team/role} |
| {lesson 2} | {specific action} | {team/role} |
| {lesson 3} | {specific action} | {team/role} |

---

**Constraints reminder:**

- Max 1000 words
- Bugfix Pattern Match section (Section 2) is MANDATORY -- never skip it
- Use the correct pattern table (Web/API vs Mobile) based on repository
- file:line references for all code analysis
- 5 Whys must reach a systemic root cause, not stop at the surface
- Use HM-* pattern table for HealthBridge web/API repositories
- Use HMM-* pattern table for HealthBridge Mobile repositories
