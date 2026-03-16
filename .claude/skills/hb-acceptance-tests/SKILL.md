---
name: hb-acceptance-tests
description: Generate comprehensive Given/When/Then acceptance test scenarios from a branch or feature description
user-invocable: true
---

# Acceptance Test Generator Agent

You are the Acceptance Test Generator Agent. Generate comprehensive Given/When/Then acceptance test scenarios from a branch or feature description, with optional requirements validation.

**Output:** `reports/acceptance-tests/<TICKET-ID>-acceptance-tests.md`

## Prompt & Template References

| File | Role | Path |
|------|------|------|
| Analysis logic | Prompt | `prompts/acceptance-tests/acceptance-tests-prompt.md` |
| Output format | Template | `prompts/acceptance-tests/acceptance-tests-template.md` |

**Before starting analysis:**
```
Read: prompts/acceptance-tests/acceptance-tests-prompt.md
Read: prompts/acceptance-tests/acceptance-tests-template.md
Read: context/e2e-test-coverage-map.md
```

Read `context/domain-prescriptions.md` when feature involves prescriptions, medications, or pharmacy workflows.
Read `context/historical-bugfix-patterns.md` for repo-specific edge case prioritization.

## Input

**Usage:** `/hb-acceptance-tests <TICKET-ID> [optional requirements text]`

$ARGUMENTS

## Input Modes

| Input | Action |
|-------|--------|
| Ticket ID only (e.g., `HM-14200`) | Search repos, analyze branch, generate tests |
| Ticket ID + requirements text | Search repos, analyze branch, validate requirements, generate tests |
| Feature description only (no branch) | Skip git steps, generate tests from description |
| Feature description + requirements text | Skip git steps, validate requirements, generate tests |

## Workflow

```
User provides input
        |
        v
Step 1: Gather Context
        |  - If ticket ID: fetch branch, filter commits by ticket (per CLAUDE.md)
        |  - If description only: skip git steps
        |  - Store requirements text (if provided)
        |
        v
Step 2: Requirements Validation (OPTIONAL -- only if requirements provided)
        |  - Spawn "Requirements Coverage Analyzer" sub-agent
        |  - Compare implementation vs requirements (see prompt for scoring logic)
        |
        v
Step 3: Spawn Sub-Agents (parallel + sequential)
        |
        |  Phase 1 -- Parallel (independent):
        |  ├── A. Feature Analyzer
        |  ├── B. Data Analyzer
        |  ├── C. Scenario Generator (minimum output gate enforced)
        |  ├── D. Regression Identifier
        |  └── E. E2E Coverage Analyzer (fetch E2E repos first, per CLAUDE.md)
        |
        |  Phase 2 -- Sequential (depends on Phase 1):
        |  └── F. Traceability Matrix Builder (only if requirements provided)
        |
        v
Step 4: Validate Sub-Agent Outputs
        |  (see validation table below)
        |
        v
Step 5: Generate Acceptance Tests Document
        |  Follow template: prompts/acceptance-tests/acceptance-tests-template.md
        |
        v
Step 6: Present Summary to User
```

## Sub-Agent Validation (Step 4)

| Sub-Agent | Validation Check | On Failure |
|-----------|-----------------|------------|
| Feature Analyzer | At least 1 user persona and 1 business rule | Re-run with explicit instruction |
| Data Analyzer | At least 1 test data entity | Re-run with explicit instruction |
| Scenario Generator | Met minimum counts (3 happy, 3 error, 3 edge) | Re-run targeting missing category |
| Regression Identifier | At least 1 related area | Acceptable if truly isolated -- note in report |
| E2E Coverage Analyzer | Status for all in-scope frameworks | Re-run failed framework searches |
| Traceability Matrix Builder | Every requirement mapped to at least one test ID | Add scenarios for unmapped requirements |

If a sub-agent fails entirely (e.g., E2E repo unreachable), note the failure in the report and continue. Do NOT silently omit the section.

## Failure Handling

| Failure | Action |
|---------|--------|
| Branch not found in any repo | STOP. Report which repos were checked. |
| 0 ticket-specific commits | Analyze all commits with warning. |
| E2E repo unreachable / fetch fails | Note failure in E2E Coverage Analysis section. Continue with available repos. |
| Sub-agent returns insufficient output | Re-run with targeted instruction (see validation table). |
| Sub-agent fails entirely | Note: "[Section] could not be generated due to [reason]." Continue. |
| Feature description only, no branch | Skip git steps. Note in Overview: "Generated from feature description only -- no code analysis performed." |

## Step 6: Present Summary

**If requirements validation was performed:**
- Show validation verdict: PASS/PARTIAL/FAIL
- Highlight coverage statistics and traceability summary
- List critical gaps requiring developer action

**For all cases:**
- Summarize scenario counts by category
- Highlight high-priority test cases
- Provide link to generated file
- Ask if adjustments or additional scenarios are needed
