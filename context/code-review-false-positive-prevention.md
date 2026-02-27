# Code Review: False Positive Prevention

**Purpose:** Documented patterns that agents MUST understand before flagging issues. These reduce false positives by teaching agents about framework safety nets, data flow guarantees, and codebase conventions.

---

## Rule 1: Trust Framework-Level Safety Nets

**DO NOT flag null/empty handling as an issue when framework extensions already handle it.**

### Entity Extension Methods (HealthBridge-Web)

The `Entity` extension methods in HealthBridge-Web already check for null/default values and return safe defaults:
- `GetString()` → returns empty string for null or DBNull
- `GetInt()` → returns 0 for null or DBNull
- `GetDecimal()` → returns 0.0m for null or DBNull
- `GetDateTime()` → returns DateTime.MinValue for null or DBNull
- `GetNullable<T>()` → returns null for missing values (nullable-aware)

**Before flagging:** Check if the code uses Entity extension methods. If yes, null/DBNull handling is already covered.

**Source:** `HealthBridge-Web/docs/AGENTS-common-code-patterns.md` (Entity extension methods section)

### Clinical Validator Input Sanitization

The `ClinicalValidator` class sanitizes ALL user input before business logic receives it:
- `ValidatedField.FORMAT_STRING` → sanitizes strings, strips HTML
- `ValidatedField.FORMAT_INTEGER` → ensures valid integer
- `ValidatedField.FORMAT_DECIMAL` → ensures valid decimal with precision
- `ValidatedField.FORMAT_DATE` → ensures valid date in ISO 8601 format
- `ValidatedField.FORMAT_MEDICAL_CODE` → validates ICD-10/CPT code format
- `GetValidatedValue()` → returns sanitized, type-safe value

**Before flagging:** If input passes through `ClinicalValidator`, don't flag type conversion or injection risks on that input.

**Source:** `HealthBridge-Web/docs/AGENTS-validation.md`

---

## Rule 2: Analyze Data Flow End-to-End (Write + Read)

**DO NOT flag edge cases on the READ side without checking what the WRITE side guarantees.**

### Example: Diagnosis Code Parsing (Patient Records - Dev Feedback Feb 2026)

| Side | File | Behavior |
|------|------|----------|
| **Write (save)** | `SaveDiagnosisHandler.cs` | Always stores ICD-10 codes in normalized format `X##.##` — never stores bare category codes without subcategory |
| **Read (display)** | `DiagnosisDisplayService.cs` | Parses code with `code.Substring(0, 3)` for category and `code.Substring(4)` for subcategory |

The agent flagged `Substring()` crash if the code is shorter than expected, but the save handler **guarantees** this never happens. The edge case was based on analyzing the read side in isolation.

### Checklist Before Flagging Edge Cases

1. **Find the write path**: How does data get INTO the database/storage?
2. **Check write-side validation**: Does the save handler validate/format the data?
3. **Check if the edge case can actually occur**: Can the flagged input value actually exist given write-side guarantees?
4. **If write side prevents it**: Mark as "N/A - write-side guarantee" instead of flagging as issue

### How to Find Write/Read Pairs

| Read File Pattern | Write File Pattern |
|-------------------|--------------------|
| `<Entity>QueryHandler.cs` | `Save<Entity>CommandHandler.cs` or `Update<Entity>CommandHandler.cs` |
| `<Entity>Report.cs` (report class) | `<Entity>Repository.cs` (data access) |
| `Get<Entity>` (API read) | `Save<Entity>` / `Update<Entity>` (API write) |
| `<Entity>ViewController.cs` (display) | `<Entity>Controller.cs` (submit/save) |

---

## Rule 3: Standard Patterns Are Not Issues

**DO NOT flag standard codebase patterns as potential issues.**

### Health Record Data Layer Patterns Are Uniform

All Data Access Layer code in HealthBridge follows the same patterns:
- **Repository** classes for CRUD operations (IRepository<T>)
- **QueryHandler** classes for read-only queries (IQueryHandler<TQuery, TResult>)
- **CommandHandler** classes for write operations (ICommandHandler<TCommand>)
- These patterns are standardized across the entire codebase via the CQRS framework

**Before flagging DAL code:** Check if it follows the standard Repository/QueryHandler/CommandHandler pattern. If yes, it's consistent with the rest of the codebase — don't flag it.

**Source:** `HealthBridge-Web/docs/AGENTS-datalayer.md`

### Using/Dispose Statements for Database Connections

All database connections use `using` blocks or are managed by the DI container's scoped lifetime — this is a golden rule enforced across the codebase. Don't flag individual files for "missing Dispose" unless the connection is genuinely not wrapped in a `using` or scoped context.

**Source:** `HealthBridge-Web/docs/AGENTS-development-guidelines.md` (Golden Rules)

---

## Rule 4: Type Conversions for Medical Data

**Medical data type conversions in HealthBridge follow well-defined patterns** — they are not bug patterns.

C# `Enum.Parse<T>(stringValue)` is used for clinical code types, and is safe when:
- Input is sanitized by `ClinicalValidator` (guaranteed to be valid)
- Enum values are controlled (system-defined, not user-extensible)
- Lookup tables are pre-loaded from reference data

Then `Enum.Parse<T>(value)` or pattern matching on enums is safe and idiomatic C#. Only flag if:
- Input is NOT sanitized (raw user input from external API)
- Enum has been recently extended (new clinical codes not covered in switch expressions)
- External system provides codes outside the expected range (e.g., new ICD-10 revision codes)

---

## Rule 5: Verify Claims with Tools Before Flagging

**DO NOT flag ANY issue based solely on visual inspection. Every finding MUST be tool-verified.**

### Why Visual Inspection Fails

- Git diff renders tabs and spaces identically
- Line wrapping in terminal can make indentation look different
- SQL strings inside C# code have their own internal indentation (especially raw string literals)
- Truncated output can make complete code look incomplete
- JSON/XML clinical data payloads can be very long and appear truncated

### Mandatory Verification Steps

Use whatever tools your IDE provides (Claude Code tools, Cursor terminal, VS Code Copilot terminal, etc.). The goal is the same regardless of IDE — **verify before flagging**.

| Claim Type | What to Verify | How (cross-platform) |
|-----------|----------------|----------------------|
| Whitespace/indentation | Actual characters (tabs vs spaces) | Read the raw file content around the changed lines; on macOS/Linux `cat -vet` shows `^I` for tabs; on Windows use `git show origin/<branch>:<file>` and inspect in editor |
| Missing null check | Null checks exist in surrounding context | Search file for `is null`, `is not null`, `?.`, `??`, `!= null` patterns |
| Unused variable | Variable is referenced elsewhere | Search the file for all occurrences of the variable name |
| Missing implementation | Method is genuinely incomplete | Read the complete function/method, not just the diff hunk |
| SQL injection risk | Input is parameterized before use | Search for parameterized query usage (`@param`, `new SqlParameter`) in the same file |
| Missing authorization | Authorization attribute exists on controller/action | Search for `[Authorize]`, `[RequirePermission]`, or policy checks in the file |

### Protocol

1. **Before reporting ANY finding:** Run a tool to verify the claim
2. **If verification confirms the issue:** Include the evidence in your reasoning
3. **If verification is not feasible:** Label the finding as "UNVERIFIED" and downgrade to Suggestion
4. **If verification disproves the claim:** DROP the finding entirely

### Example: HM-14125 (Feb 2026)

**What happened:** Agent flagged "indentation inconsistency — new lines use spaces while original uses tabs" based on how the diff rendered in terminal.

**What tool verification showed:** Running `cat -vet` revealed:
- The OLD removed line used `^I^I^I` (3 tabs) inside the LINQ query string — inconsistent with neighboring lines
- The NEW added lines used spaces — matching all surrounding lines
- The fix actually IMPROVED consistency

**Correct verdict:** False positive — The change improved formatting, not worsened it.

---

## Rule 6: Compare Before vs After (Change Direction Analysis)

**DO NOT flag formatting, style, or pattern issues without comparing OLD vs NEW code.**

### Principle

A code change can only introduce a problem if the NEW code is WORSE than the OLD code. If the change improves an existing inconsistency, it is NOT an issue — it's a fix.

### Checklist Before Flagging Style/Pattern Issues

1. **Does the change INTRODUCE the problem, or INHERIT it?**
   - If the problem existed in the old code and persists → Not a finding for this PR
   - If the problem is NEW in this PR → Valid finding

2. **Does the change IMPROVE or WORSEN the pattern?**
   - If new code is MORE consistent with surrounding code → NOT an issue (improvement)
   - If new code introduces NEW inconsistency → Valid finding

3. **Is the surrounding code already inconsistent?**
   - If surrounding code mixes styles → The PR cannot be blamed for pre-existing inconsistency
   - Only flag if the PR makes things measurably worse

### Decision Matrix

| Old Code | New Code | Surrounding Code | Verdict |
|----------|----------|-------------------|---------|
| Tabs | Spaces | Spaces | Improvement — NOT an issue |
| Spaces | Tabs | Spaces | Regression — Valid finding |
| Tabs | Tabs | Spaces | No change — Not a finding for this PR |
| Mixed | Consistent | Either | Improvement — NOT an issue |

### Source: HM-14125 Code Review (Feb 2026)

Agent flagged indentation without comparing old vs new. The old line was the outlier; the fix aligned it with neighbors.

---

## Updating This Document

When developers provide feedback that a code review finding was a false positive:

1. **Identify the root cause** of the false positive (missing framework knowledge, incomplete data flow analysis, etc.)
2. **Add a new rule or example** to the appropriate section above
3. **Include the source** (developer feedback date, ticket ID if applicable)
4. **Reference the dev docs** that would have prevented the false positive
