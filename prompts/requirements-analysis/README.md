# Requirements Analysis Workflow

Automate the complete pipeline from requirements analysis through QA test planning and development estimation for the HealthBridge health management platform.

## Files

| File | Purpose |
|------|---------|
| `workflow-orchestrator.md` | Main workflow with 3-phase pipeline |
| `requirements-analysis.md` | Phase 1: Analysis instructions |
| `requirements-analysis-template.md` | Phase 1: Report structure |

## Purpose

Orchestrate the end-to-end flow from requirements gathering to delivery planning with intelligent quality gating:

1. **Phase 1:** Analyze requirements -> Calculate completeness score (0-10)
2. **Decision Point:** If score >= 7/10, proceed to Phases 2+3. If score < 7/10, STOP and clarify with PO
3. **Phase 2:** Generate QA test plan with automation analysis
4. **Phase 3:** Generate development estimates with task breakdown

**Key Innovation:** Prevents wasted effort on incomplete requirements by gating based on quality score.

## Quick Start

**VS Code Chat:**
```
Analyze this requirement using requirements-analysis workflow:

Ticket: HM-XXXXX
Title: [Feature title]
Requirement: [Paste requirement text]
```

## When to Use

| Scenario | Use This Workflow? |
|----------|-------------------|
| New feature needs analysis + planning | Yes |
| Check if requirement is complete | Yes (stops at Phase 1 if score <7) |
| Only need QA test plan | Use `../qa-test-plan/` directly |
| Only need dev estimation | Use `../dev-estimation/` directly |
| Code review (already developed) | Use `../code-review-qa/` |

## How It Works

```
+--------------------------------------------+
|     Requirements Analysis Pipeline         |
+--------------------------------------------+
|  PHASE 1: Requirements Analysis            |
|  - Analyze business gaps                   |
|  - Identify impacted repositories          |
|  - Map edge cases and errors               |
|  - Score completeness (0-10)               |
|  Output: requirements-analysis.md          |
|                v                           |
|    +-------------------+                   |
|    | Score >= 7/10?    |                   |
|    +---+--------+------+                   |
|  YES --+        +-- NO -> STOP            |
|   |                     Present critical   |
|   |                     questions to PO    |
|   v                                        |
|  PHASE 2: QA Test Plan                     |
|  - Manual test scenarios                   |
|  - Analyze Playwright/Mobile tests         |
|  - Estimate QA effort                      |
|  Output: qa-test-plan.md                   |
|                v                           |
|  PHASE 3: Development Estimation           |
|  - Break down tasks by repository          |
|  - Identify files to modify               |
|  - Calculate cross-repo coordination       |
|  - Apply risk buffers                      |
|  Output: dev-estimation.md                 |
|                v                           |
|  SUCCESS: 3 Documents Delivered            |
+--------------------------------------------+
```

## The 7/10 Threshold

Based on analysis of production hotfixes, incomplete requirements were a major defect contributor. The scoring system prevents planning when requirements are ambiguous.

### Scoring Dimensions (2 points each, 10 total)

1. **Business Rules** - All rules with examples?
2. **Edge Cases** - Comprehensive coverage?
3. **Integrations** - All points defined?
4. **Error Handling** - Scenarios detailed?
5. **Repository Scope** - All impacts identified?

### Interpretation

| Score | Action |
|-------|--------|
| 9-10 | Complete - Proceed with confidence |
| 7-8 | Good - Proceed, note assumptions |
| 5-6 | Incomplete - STOP, clarify with PO |
| 1-4 | Poor/Inadequate - STOP, rewrite requirements |

## Usage

**AI-Assisted:** Prompt AI to use workflow orchestrator. It executes Phase 1, checks threshold, then conditionally runs Phases 2+3.

**Manual:** Complete Phase 1 -> Check score -> If >=7, continue to Phases 2+3; else STOP.

## Output Locations

All reports saved to `reports/requirements-analysis/`:
- `[TICKET]-requirements-analysis.md` (Phase 1, always)
- `[TICKET]-qa-test-plan.md` (Phase 2, only if score >= 7)
- `[TICKET]-dev-estimation.md` (Phase 3, only if score >= 7)

## Examples

**High Completeness (9/10)**
- Input: Clear requirements with edge cases and integrations defined (e.g., patient discharge workflow with all external system touchpoints)
- Output: 3 documents delivered (analysis + QA + dev)

**Low Completeness (5/10)**
- Input: Vague requirements, no edge cases (e.g., "add medication tracking" with no detail on dosage validation or interaction checks)
- Output: 1 document with critical questions for PO, STOP

## Word Limits

- Requirements Analysis: 1,000 words max
- QA Test Plan: 1,000 words max
- Dev Estimation: 800 words max

## Quality Checklist

**Phase 1 (always):**
- [ ] All 12 sections complete
- [ ] Completeness score calculated
- [ ] If score < 7: Critical questions listed
- [ ] Impacted repositories identified

**Phases 2+3 (only if score >= 7):**
- [ ] QA: Manual scenarios + all test frameworks analyzed
- [ ] Dev: Task breakdown by repo + specific files listed
- [ ] Both: No placeholders like "[TODO]"

## Key Constraints

- **Decision Threshold:** 7/10 (not configurable)
- **Test Frameworks:** Must analyze all applicable (Playwright, Mobile/WebdriverIO)
- **Repository Scope:** Only impacted repos identified in Phase 1
- **Format:** Markdown files in `reports/requirements-analysis/`

## Related Templates

| Template | Path | Purpose |
|----------|------|---------|
| Requirements Analysis | `requirements-analysis-template.md` | Phase 1 report structure |
| QA Test Plan | `../qa-test-plan/qa-test-plan-template.md` | Phase 2 report structure |
| Dev Estimation | `../dev-estimation/dev-estimation-template.md` | Phase 3 report structure |

## FAQ

**Score is 6/10?** NO - Clarify with PO first. Threshold is 7/10 to avoid rework.

**Skip Phase 3?** Use `../qa-test-plan/` directly instead.

**Requirements changed?** Significant: Re-run all. Minor: Update Phase 2/3 only.

---

**Maintainer:** HealthBridge QA Team
