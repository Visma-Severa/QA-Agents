# Findings Detailed Analysis Template

**Purpose:** When a developer selects "Provide More Information" during interactive code review feedback, the agent generates a deep analysis for the flagged finding following this exact structure.

**Output Location:** `reports/code-review/<TICKET>-findings-detailed.md`

**Multiple findings:** If the developer requests deep analysis for multiple findings, append each as a new `## Finding N` section in the same file.

---

## Template Structure

```markdown
# <TICKET> -- Code Review Findings Detailed Analysis

**Branch:** `<branch-name>`
**File(s):** `<affected files>`
**Date:** YYYY-MM-DD

---

## Finding N: <Pattern Category> (<Hotfix %>) -- <Specific Issue Title>

**Location:** `<file:line-range>`

### The code

[Actual code from the PR -- include 5-15 lines of context around the flagged location. Use syntax-highlighted code blocks with language tag.]

### The concern

[Clear explanation of what could go wrong. Walk through the execution path step-by-step. Show what happens with specific inputs that trigger the issue.]

### How realistic is this?

[Probability assessment -- NOT theoretical, but based on concrete scenarios:]

- **Scenario 1:** [Specific real-world situation when this would trigger -- e.g., "Patient with no allergy records is admitted through the emergency department"]
- **Scenario 2:** [Another plausible trigger -- e.g., "Insurance provider field is null for self-pay patients"]
- **Under normal operation:** [What happens in the happy path]

[If applicable: "This is/isn't a rare scenario because [data/evidence]"]

### Evidence from codebase

[Search for sibling/related code that handles the same pattern. Show how other files in the codebase deal with this:]

**[SiblingFile.cs:line-range]:**
```csharp
[Code from sibling showing the correct/different pattern]
```

[Explain what the sibling does differently and why. If 2-3 siblings all use the same pattern and this code doesn't, that's strong evidence.]

### Risk assessment

| Factor | Level | Justification |
|--------|-------|---------------|
| Probability | Low / Medium / High | [How likely to occur in production -- e.g., "5% of patients have no allergy records"] |
| Impact | Low / Medium / High | [What happens if it does occur -- data corruption? crash? wrong prescription? silent error?] |
| Detectability | Easy / Medium / Hard | [Would QA/users notice? Or silent failure?] |
| **Combined Risk** | **Low / Medium / High** | **[Overall assessment]** |

### Recommended fix

```csharp
[Corrected code -- show the minimal change needed. Include context lines for clarity.]
```

[One sentence explaining what the fix does and why it works.]

**Severity: Low/Medium/High.** [One-sentence justification linking probability, impact, and fix cost.]

---

## Summary

| # | Finding | Probability | Impact | Risk | Key Issue |
|---|---------|-------------|--------|------|-----------|
| N | [Title] | Low/Med/High | Low/Med/High | Low/Med/High | [One-line summary] |
```

---

## Guidelines

### What Makes a Good Deep Analysis

1. **Show, don't tell** -- Include actual code, not descriptions of code
2. **Concrete scenarios** -- "Patient has no allergy records on file" not "edge case might occur"
3. **Sibling evidence** -- If 3 similar files handle it differently, that's the strongest argument
4. **Honest probability** -- If something is unlikely under normal use, say so. Don't inflate risk
5. **Minimal fix** -- Show the smallest change that resolves the issue, not a refactor

### Severity Calibration

| Severity | Criteria |
|----------|----------|
| **Low** | Unlikely to occur AND low impact when it does. Defensive improvement. |
| **Medium** | Plausible scenario AND noticeable impact (wrong calculation, missing data, degraded UX). |
| **High** | Realistic scenario AND significant impact (patient safety risk, data corruption, security issue, incorrect clinical data). |

### When to Search for Siblings

- **Database queries** -- Search for same table name in other repositories/services
- **Null checks** -- Search for same method/property usage elsewhere
- **Switch/Select statements** -- Search for same enum usage
- **Error handling patterns** -- Search for same try/catch patterns
- **API responses** -- Search for same response format in other endpoints
