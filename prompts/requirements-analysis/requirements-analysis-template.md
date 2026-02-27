# Requirements Analysis: <TICKET-ID>

**Ticket:** <TICKET-ID>
**Title:** {ticket title}
**Date:** {date}

---

## 1. Requirements Summary

| Aspect | Details |
|--------|---------|
| **What** | {what is being built/changed} |
| **Who** | {target users/roles} |
| **Why** | {business justification} |
| **Where** | {affected areas/modules} |

### JIRA Context (if available)

- Reporter: {reporter}
- Priority: {priority}
- Labels: {labels}
- Sprint: {sprint}

## 2. Business Gap Analysis

| Gap Type | Description | Severity |
|----------|-------------|----------|
| Missing Requirement | {what's missing} | Red/Yellow/Green |
| Ambiguous Requirement | {what's unclear} | Red/Yellow/Green |
| Conflicting Requirement | {what conflicts} | Red/Yellow/Green |

### Critical Questions

1. {specific question about a gap}
2. {specific question about ambiguity}

## 3. Requirements Completeness Score

| # | Dimension | Score (0-2) | Evidence |
|---|-----------|-------------|----------|
| 1 | Functional Requirements | 0/1/2 | {why this score} |
| 2 | Edge Cases | 0/1/2 | {why this score} |
| 3 | Error Handling | 0/1/2 | {why this score} |
| 4 | Integration Impact | 0/1/2 | {why this score} |
| 5 | Data Requirements | 0/1/2 | {why this score} |
| 6 | Security & Authorization | 0/1/2 | {why this score} |
| | **TOTAL** | **X/12 -> normalized to Y/10** | |

### Scoring Guide

- **0 (Missing):** Not mentioned at all in requirements
- **1 (Partial):** Mentioned but incomplete or vague
- **2 (Complete):** Fully specified with clear acceptance criteria

### Readiness Decision

| Score | Verdict |
|-------|---------|
| **>= 7/10** | READY FOR DEVELOPMENT -- proceed to QA Test Plan + DEV Estimation |
| **< 7/10** | NOT READY -- return to Product Owner with gap list |

**Verdict: {READY / NOT READY} ({score}/10)**

## 4. Edge Cases & Exception Scenarios

### Null/Empty Data

| Scenario | Expected Behavior |
|----------|-------------------|
| {null scenario} | {expected handling} |

### Boundary Values

| Scenario | Expected Behavior |
|----------|-------------------|
| {boundary scenario} | {expected handling} |

### Timing/Concurrency

| Scenario | Expected Behavior |
|----------|-------------------|
| {timing scenario} | {expected handling} |

### External System Failures

| Scenario | Expected Behavior |
|----------|-------------------|
| {failure scenario} | {expected handling} |

## 5. Integration Impact

| Repository | Affected? | Changes Needed |
|------------|-----------|----------------|
| HealthBridge-Web | yes/no | {description} |
| HealthBridge-Api | yes/no | {description} |
| HealthBridge-Mobile | yes/no | {description} |

### Cross-Repository Coordination

{Any coordination needed between repos}

## 6. External Integrations

| System | Integration Type | Impact |
|--------|------------------|--------|
| {e.g., National e-Prescription Registry} | API call / webhook / batch | {changes needed} |

_(Use "N/A -- No external integrations affected" if not applicable)_

## 7. Error Handling

| Scenario | Error Message | Recovery |
|----------|---------------|----------|
| {error scenario} | {user-facing message} | {how to recover} |

## 8. Data Requirements

| Field | Type | Validation | Required? |
|-------|------|------------|-----------|
| {field} | {type} | {rules} | yes/no |

## 9. Missing Requirements Checklist

- [ ] {missing item 1}
- [ ] {missing item 2}
- [ ] {missing item 3}

## 10. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| {risk} | Red/Yellow/Green | {mitigation strategy} |

## 11. Recommendations

1. {recommendation 1}
2. {recommendation 2}
3. {recommendation 3}

## 12. Questions for Product Owner

1. {specific, actionable question}
2. {specific, actionable question}

---

**Constraints reminder:**

- Max 1000 words
- Tables over prose
- Questions must be specific (not generic "please clarify")
- All 6 scoring dimensions must be evaluated
- Score >= 7 triggers automatic QA Test Plan + DEV Estimation generation
