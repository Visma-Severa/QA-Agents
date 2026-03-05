# Bug Report Analysis Agent

Analyzes errors, exceptions, and code issues to generate ticket-ready bug reports with root cause analysis and fix recommendations.

## Files in This Folder

| File | Purpose |
|------|---------|
| `bug-report-prompt.md` | Detailed analysis framework with 7 phases, hotfix patterns, and investigation instructions |
| `bug-report-template.md` | **Report template (MUST FOLLOW EXACTLY)** - Defines 9 mandatory sections |
| `severity-criteria.md` | Objective criteria for assessing bug severity (Critical/High/Medium/Low) |
| `README.md` | This documentation |

## Purpose

This agent helps QA and developers by automatically analyzing errors and exceptions to:
- Classify error types (NullRef, IndexOut, Logic, Authorization, etc.)
- Locate problematic code with file:line references
- Perform root cause analysis with code context
- Match against historical hotfix patterns (repo-specific — see `context/historical-bugfix-patterns.md`)
- Search codebase for same bug pattern elsewhere (critical for preventing copy-paste bugs)
- Assess severity objectively using defined criteria
- Provide actionable fix recommendations with code examples
- Suggest test coverage improvements (Unit, E2E, Mobile)
- Generate ticket-ready bug reports (max 900 words)

## Outputs

**Bug Report Document** - Comprehensive bug report (max 900 words) following 9-section template:
1. Error Summary
2. Steps to Reproduce
3. Expected vs Actual Behavior
4. Root Cause Analysis (with code snippets)
5. Impact Assessment (with severity justification)
6. Pattern Scope Analysis (codebase search for similar bugs)
7. Fix Recommendation (with code example and effort estimate)
8. Test Data Requirements
9. Regression Test Recommendation

**Location:** `reports/bug-reports/<TICKET-ID>-bug-report.md`

## Usage

### VS Code/Cursor

1. Open the multi-repository workspace
2. Use the agent from `agents/vscode-chat-participants/bug-report.md`
3. Provide error message, stack trace, or symptom description

**Important:** Always read all three files before generating reports:
```
Read: prompts/bug-report/bug-report-prompt.md
Read: prompts/bug-report/bug-report-template.md
Read: prompts/bug-report/severity-criteria.md
```

### Manual Use

Copy the prompt from [bug-report-prompt.md](bug-report-prompt.md) and provide it to your AI assistant along with:
- Stack trace or error message
- Steps to reproduce (if known)
- Affected repository and branch
- Any relevant context

## Analysis Framework (7 Phases)

### Phase 1: Error Classification (2-3 min)
- Identify error type
- Extract file:line references
- Determine repository context

### Phase 2: Code Location (3-5 min)
- Parse stack trace for exact location
- Use semantic search if needed
- Read code context (+/-20 lines)

### Phase 3: Root Cause Analysis (8-11 min)
- Understand code logic and data flow
- Match against hotfix patterns
- Check git history for recent changes
- **CRITICAL:** Search codebase for same bug pattern elsewhere

### Phase 4: Severity Assessment (2-3 min)
- Apply severity criteria objectively
- Consider user impact, patient safety, data risk, workaround availability
- Justify severity level

### Phase 5: Test Coverage Analysis (2-3 min)
- Check unit test existence
- Check E2E coverage (Selenium UI, Selenium Integration, Playwright, Mobile)
- Determine automation priority

### Phase 6: Fix Recommendation (3-5 min)
- Assess complexity (Simple 1-2h / Medium 0.5-1d / Complex 1-3d / Very Complex >3d)
- Provide specific code fix example
- List prevention measures

### Phase 7: Report Generation (5-10 min)
- Follow template exactly
- Keep within 900-word limit
- Ensure all 9 sections are complete

**Total Time Budget:** 25-35 minutes

## Hotfix Patterns (Historical Data)

**Canonical source:** `context/historical-bugfix-patterns.md` — contains 5 repository-specific pattern tables. Use the correct table for the analyzed repository.

## Severity Levels

| Severity | Symbol | Priority | Response Time | Criteria Example |
|----------|--------|----------|---------------|------------------|
| **Critical** | P1 | Hours | System down, data loss, security breach, patient safety risk, >50% users affected |
| **High** | P2 | 1-3 days | Core feature broken, 10-50% users, complex workaround |
| **Medium** | P3 | 1-2 weeks | Secondary feature broken, 1-10% users, easy workaround |
| **Low** | P4 | Backlog | Cosmetic issue, <1% users, minor UI inconsistency |

## Codebase Pattern Search (Critical Step)

**Why:** Prevents copy-paste bugs from spreading. If one file has a null handling bug, similar files often have the same issue.

**Methods:**
- `git grep -n "problematic_pattern" origin/main` for similar code structures
- IDE search tools for conceptual similarity
- `git grep` to find all callers and usages
- Search similar file names (e.g., `*Service.cs` if bug in `PrescriptionService.cs`)

**Time Budget:** 2-4 minutes (part of Phase 3)

## Quality Checklist

Before submitting report:
- [ ] All 9 mandatory sections present
- [ ] Word count <= 900 words
- [ ] Severity correctly assessed and justified
- [ ] Steps to reproduce are clear and numbered
- [ ] Root cause includes file:line references
- [ ] Fix recommendation is actionable (not vague)
- [ ] Codebase pattern search performed
- [ ] Test data requirements are specific
- [ ] Hotfix pattern identified
- [ ] Ticket fields populated
- [ ] Professional tone (ticket-ready)

## Related Documentation

- [severity-criteria.md](severity-criteria.md) - Detailed severity assessment guide
- [bug-report-template.md](bug-report-template.md) - Complete template with examples
- [bug-report-prompt.md](bug-report-prompt.md) - Full analysis framework

## Integration with Other Agents

**After Bug Fix:**
- Use `@hb-code-review` to review the fix implementation
- Use `@hb-acceptance-tests` to create regression test scenarios

**During Development:**
- Use `@hb-requirements-analysis` to prevent bugs during planning phase
- Reference bug patterns in code review checklists
