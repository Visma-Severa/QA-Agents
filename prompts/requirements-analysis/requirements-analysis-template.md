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

| Gap Type | Description / Question | Impact if Unaddressed | Severity |
|----------|----------------------|----------------------|----------|
| Missing Requirement | {what's missing} | {what could go wrong} | Low/Medium/High |
| Ambiguous Requirement | {what's unclear} | {user confusion/errors} | Low/Medium/High |
| Conflicting Requirement | {what conflicts} | {integration failures} | Low/Medium/High |

### Domain / Regulatory Gaps

| Gap | Regulation / Source | Impact | Priority |
|-----|---------------------|--------|----------|
| {what's missing} | {law/regulation} | {consequence} | Critical/Medium/Low |

_(Use "N/A — no regulatory gaps identified" if not applicable)_

### Critical Questions

1. {specific question about a gap}
2. {specific question about ambiguity}

## 3. Requirements Readiness Score

**This is the canonical scoring definition.** All other documents (prompt, orchestrator) reference this table — update weights and dimensions here only.

| Criteria | Weight | Score | Weighted |
|----------|--------|-------|----------|
| **Completeness** | 20% | X/10 | X.XX |
| **Clarity** | 15% | X/10 | X.XX |
| **Testability** | 15% | X/10 | X.XX |
| **Feasibility** | 15% | X/10 | X.XX |
| **Edge Cases Defined** | 10% | X/10 | X.XX |
| **Integration Impact Defined** | 10% | X/10 | X.XX |
| **Domain Compliance** | 15% | X/10 | X.XX |
| **Total** | 100% | - | **X.X/10** |

### Score Breakdown

| Criteria | Score | Justification |
|----------|-------|---------------|
| **Completeness** | X/10 | {Are all business rules defined?} |
| **Clarity** | X/10 | {Is the user story unambiguous?} |
| **Testability** | X/10 | {Can acceptance criteria be tested?} |
| **Feasibility** | X/10 | {Is it technically achievable?} |
| **Edge Cases Defined** | X/10 | {What % of edge cases have defined behavior?} |
| **Integration Impact** | X/10 | {Are cross-system impacts understood?} |
| **Domain Compliance** | X/10 | {Do requirements align with healthcare regulations?} |

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
| HealthBridge-Portal | yes/no | {description} |
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

## 8.5. Existing Code Impact

| File/Component | Purpose | Change Required | Complexity |
|----------------|---------|-----------------|------------|
| {path} | {what it does} | {what to change} | Low/Med/High |

## 9. Missing Requirements Checklist

| Requirement Area | Status | Notes |
|------------------|--------|-------|
| Happy path defined | Yes/No | |
| Error scenarios defined | Yes/No | |
| Edge cases defined | Yes/No | |
| Permissions defined | Yes/No | |
| Validation rules defined | Yes/No | |
| UI/UX defined | Yes/No | |
| Mobile impact considered | Yes/No | |
| API changes defined | Yes/No | |
| Database changes defined | Yes/No | |
| Migration plan defined | Yes/No | |
| Rollback plan defined | Yes/No | |
| Performance requirements defined | Yes/No | |
| Audit/logging requirements defined | Yes/No | |

## 10. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| {risk} | Low/Med/High | Low/Med/High | {mitigation strategy} |

## 11. Recommendations

1. {recommendation 1}
2. {recommendation 2}
3. {recommendation 3}

## 12. Questions for Product Owner

1. {specific, actionable question}
2. {specific, actionable question}

## 13. Questions for Developers

1. {question about existing implementation}
2. {question about technical constraints}
3. {question about integration points}

---

**Constraints:** Max 1500 words · Tables over prose · Specific questions only
