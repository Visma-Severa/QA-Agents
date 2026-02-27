# Bug Report Analysis Prompt

You are analyzing an error or exception to generate a ticket-ready bug report. This document provides detailed analysis instructions.

---

## Analysis Framework

### Phase 1: Error Classification (2-3 minutes)

**Input Types:**
1. **Stack Trace** - Full exception with file:line references
2. **Error Message Only** - User-reported error text
3. **Symptom Description** - Behavior without technical details
4. **Code Issue** - Developer-reported code problem

**First Actions:**
```
1. Identify error type (NullRef, IndexOut, Logic, etc.)
2. Extract file path and line number (if available)
3. Determine repository (HealthBridge-Web, HealthBridge-Api, HealthBridge-Mobile)
4. Check branch/version context
```

---

### Phase 2: Code Location (3-5 minutes)

**If Stack Trace Available:**
```bash
# Parse stack trace for file:line
# Example: "at PrescriptionService.cs:line 234"

cd <repository-path>
# Read the file
Read: <file-path> lines <line-20> to <line+20>
```

**If Error Message Only:**
```
# Use semantic search
semantic_search: "<error message text>"

# Or grep for error message
grep -rn "<error message>" --include="*.cs" --include="*.ts" --include="*.dart"
```

**If Symptom Description Only:**
```
# Search for related code
semantic_search: "<feature name> <symptom keywords>"

# Example: "prescription creation validation"
```

---

### Phase 3: Root Cause Analysis (8-11 minutes)

#### Step 1: Read and Understand Code

**Context Window:**
- Read +/-20 lines around error line
- Understand function purpose
- Check input parameters
- Trace data flow

**Look For:**
- Missing null checks
- Incorrect conditions
- Boundary condition issues
- Unhandled edge cases
- Logic errors

#### Step 2: Match Hotfix Pattern

Use historical RCA patterns:

**NULL Handling (18%):**
```
Indicators:
- NullReferenceException
- "Object reference not set"
- Accessing properties without null check
- Optional parameters not validated

Detection:
if (obj.Property)  // No null check
if (obj != null && obj.Property)  // Correct
```

**Edge Cases (28%):**
```
Indicators:
- IndexOutOfRangeException
- Empty collection errors
- Date boundary issues
- Min/Max value problems

Detection:
array[i]  // No bounds check
foreach (var item in collection)  // Empty collection not handled
```

**Authorization Gaps (22%):**
```
Indicators:
- Unauthorized access to patient records
- Role-based permission bypass
- Department-level access violations
- Missing access control checks

Detection:
GetPatientRecord(patientId)  // No department check
if (user.Role == "Doctor")  // Missing nurse/admin roles
```

**Logic/Condition Errors (16%):**
```
Indicators:
- Logic errors
- Incorrect operators (&& vs ||)
- Wrong variable used
- Copy-paste errors

Detection:
if (x > 0 && y < 0)  // Should be ||?
if (patient.IsActive && patient.IsDeceased)  // Logic error
```

**Data Validation (10%):**
```
Indicators:
- Invalid medical data formats
- Missing format validation
- Type conversion failures

Detection:
int.Parse(dosageInput)  // No validation
DateTime.Parse(prescriptionDate)  // No format check
```

**Missing Implementation (6%):**
```
Indicators:
- NotImplementedException
- TODO comments
- Stub methods
- Incomplete features

Detection:
throw new NotImplementedException();  // Not implemented
// TODO: Implement this  // Incomplete
```

#### Step 3: Git History Check

```bash
# When was this code added?
git log --oneline -n 10 -- "<file-path>"

# Who last changed this line?
git blame "<file-path>" -L <line>,<line>

# Search for similar past errors/fixes
git log --all --grep="<error-type>" --oneline
```

**Questions to Answer:**
- Is this new code or legacy?
- Was it recently changed? (potential regression)
- Are there similar past issues?
- What PR introduced this code?

#### Step 4: Search Codebase for Similar Patterns

**CRITICAL:** Search for the same bug pattern elsewhere in the codebase.

```bash
# Search for similar code structure
grep -rn "problematic_pattern" --include="*.cs" --include="*.ts" --include="*.dart"

# Find similar function calls
grep -rn "SuspiciousMethod(" --include="*"

# Search for copy-paste candidates (similar file names)
find . -name "*Service*.cs" -o -name "*Service*.ts"
```

**Use semantic_search for conceptual similarity:**
```
Search for: code that does [same operation without safety check]
```

**Use list_code_usages to find all callers:**
```
Find usages of: [problematic method/class]
```

**Questions to Answer:**
1. **Same bug elsewhere?** - Does this pattern exist in other files?
2. **How many occurrences?** - Is this isolated or systemic?
3. **Copy-paste origin?** - Did someone copy this buggy code?
4. **Shared code?** - Is the buggy code in a base class/shared utility?

**Examples:**
- NULL error in `PrescriptionService.GetDosage()` -> Search all `*Service.cs` files for `.GetDosage()` without null check
- Index error in `items[0]` -> Search for `items[0]` without `items.Count > 0` check
- Missing auth check -> Search for other endpoints without `[Authorize]` attributes

**Expected Output:**
- Found in 5 other files: [list files]
- Isolated to this file only
- Used by 12 callers: [potential impact scope]

**Time Budget:** 2-4 minutes

---

### Phase 4: Severity Assessment (2-3 minutes)

Use the severity matrix from `severity-criteria.md`:

#### Critical
**Criteria (ANY of these):**
- Production completely down
- Data loss or corruption
- Security breach (SQL injection, XSS, auth bypass)
- >50% of users affected
- Patient safety risk (wrong medication, incorrect dosage)
- Regulatory/HIPAA compliance violation

**Examples:**
- Database delete without where clause
- Authentication bypass exposing patient records
- Prescription dosage calculation wrong
- Cannot log in (all users)

#### High
**Criteria (ANY of these):**
- Core feature completely broken
- 10-50% of users affected
- Data integrity risk (but no actual loss yet)
- Workaround exists but complex
- Medical records showing incorrect data

**Examples:**
- Patient record creation crashes
- Lab result display shows wrong values
- Appointment scheduling fails for certain date ranges
- Major clinical feature unusable

#### Medium
**Criteria (ANY of these):**
- Non-critical feature broken
- 1-10% of users affected
- Easy workaround available
- UI/UX issue affecting workflow
- Performance degradation (not critical)

**Examples:**
- Secondary report fails
- UI button not working (alternative exists)
- Slow page load (not timeout)
- Export format incorrect

#### Low
**Criteria (ANY of these):**
- Cosmetic issue
- <1% of users affected
- Minor UI inconsistency
- Typo or text issue
- Enhancement rather than bug

**Examples:**
- Button alignment off
- Tooltip text wrong
- Console warning (no user impact)
- Minor performance improvement needed

#### Assessment Questions

Ask yourself:
1. **Can users complete their task?** (No = Higher severity)
2. **Is patient data at risk?** (Yes = Higher severity)
3. **How many users affected?** (More = Higher severity)
4. **Is workaround available?** (No = Higher severity)
5. **What feature is broken?** (Clinical feature = Higher severity)

---

### Phase 5: Test Coverage Analysis (2-3 minutes)

#### Check Unit Tests

```bash
# Find test files for the affected class
find . -name "*Test.cs" -o -name "*Tests.cs" -o -name "*_test.dart"

# Search for test methods
grep -r "Test<FunctionName>" *Test*
```

**Assessment:**
- **Exist** - Tests cover this functionality
- **Partial** - Some tests exist but not for this case
- **Missing** - No tests for this function

#### Check E2E Coverage

Use `context/e2e-test-coverage-map.md`:

```
1. Identify functional area (e.g., "Prescription Creation")
2. Check coverage map - which framework covers it?
3. Search relevant E2E repo for tests
```

**Frameworks:**
- **Playwright** - Patient Records, Prescriptions, Scheduling, Billing
- **Mobile** - Appointments, Lab Results, Medication Tracking, Mobile UI

#### Automation Priority

Determine if this should be automated:

**High Priority:**
- Core clinical feature
- Patient safety calculation
- Data integrity
- High regression risk
- Affects many users

**Medium Priority:**
- Secondary feature
- UI validation
- Edge case
- Medium regression risk

**Low Priority:**
- Cosmetic issue
- Rare edge case
- Low user impact
- One-time issue

---

### Phase 6: Fix Recommendation (3-5 minutes)

#### Complexity Assessment

**Simple Fix (1-2 hours):**
- Add null check
- Fix typo
- Add validation
- Correct simple logic

**Medium Fix (0.5-1 day):**
- Refactor function
- Add comprehensive validation
- Fix multiple related issues
- Update multiple files

**Complex Fix (1-3 days):**
- Architectural change
- Database schema change
- Cross-component fix
- Major refactoring

**Very Complex (>3 days):**
- Major redesign
- Performance optimization
- Migration required
- Breaking API changes

#### Fix Approach

**Template:**
```
1. Identify exact change needed
2. List files to modify
3. Provide code example (3-5 lines)
4. List prevention measures
```

**Example for NULL Handling:**
```csharp
// Before (buggy)
var patientId = record.Patient.ID;

// After (fixed)
if (record.Patient == null)
{
    return Result.Failure("Patient record required");
}
var patientId = record.Patient.ID;
```

#### Prevention Measures

Always include 3 prevention measures:

1. **Testing:** Specific unit/E2E test to add
2. **Code Review:** Checklist item for reviews
3. **Validation:** Client/server validation to add

**Example:**
```
Prevention:
- [ ] Add unit test: TestSavePrescription_NullPatient_ReturnsError()
- [ ] Code review item: "Check for null before property access"
- [ ] Add client-side validation to prevent null submission
```

---

### Phase 7: Report Generation (5-10 minutes)

Use the template from `bug-report-template.md`.

#### Writing Guidelines

**Be Specific:**
- "Fix the error" -> "Add null check at PrescriptionService.cs:234"
- "Many users affected" -> "~20% of users (those who create prescriptions without patient selection)"
- "Should validate input" -> "Should display error: 'Patient selection is mandatory'"

**Be Concise:**
- Use bullet points
- Short sentences
- Clear structure
- No unnecessary words

**Be Actionable:**
- Provide exact file:line
- Show code fix
- List specific tests
- Give reproduction steps

#### Word Count Management

**Target: 600 words**

If over limit:
1. Shorten code snippets (5 lines max)
2. Remove redundant explanations
3. Use tables instead of prose
4. Combine related points

**Section Priorities:**
1. Steps to Reproduce (must be clear)
2. Root Cause (must be specific)
3. Fix Recommendation (must be actionable)
4. Impact Assessment (must be realistic)
5. Everything else (trim if needed)

---

## Error-Specific Analysis Patterns

### NullReferenceException

**Quick Checklist:**
- [ ] Where is null check missing?
- [ ] What object is null?
- [ ] Is it optional parameter?
- [ ] Is it user input?
- [ ] Should it ever be null?

**Pattern:** NULL Handling (18%)

**Typical Fix:**
```csharp
if (obj == null)
{
    // Handle null case
    return Result.Failure("Required data missing");
}
```

### IndexOutOfRangeException

**Quick Checklist:**
- [ ] Is collection empty?
- [ ] Is index calculation wrong?
- [ ] Is boundary check missing?
- [ ] Off-by-one error?

**Pattern:** Edge Cases (28%)

**Typical Fix:**
```csharp
if (collection.Count > 0 && index < collection.Count)
{
    // Access collection safely
}
```

### Logic Errors

**Quick Checklist:**
- [ ] Is condition correct (&& vs ||)?
- [ ] Is comparison right (> vs >=)?
- [ ] Wrong variable used?
- [ ] Copy-paste error?

**Pattern:** Logic/Condition Errors (16%)

**Typical Fix:**
```csharp
// Before
if (x > 0 && y < 0)  // Should be ||

// After
if (x > 0 || y < 0)  // Correct logic
```

### Authorization Errors

**Quick Checklist:**
- [ ] Is there an authorization attribute?
- [ ] Are all roles handled?
- [ ] Is department-level access enforced?
- [ ] Is data-level authorization checked?

**Pattern:** Authorization Gaps (22%)

**Typical Fix:**
```csharp
[Authorize(Roles = "Doctor,Nurse")]
public async Task<IActionResult> GetPatientRecord(int patientId)
{
    if (!await _authService.CanAccessPatient(User, patientId))
        return Forbid();
    // ...
}
```

---

## Ticket Field Auto-Detection

### Component Detection

Use file path to auto-detect component:

| Path Pattern | Component |
|--------------|-----------|
| `*/prescriptions/*` | Prescriptions |
| `*/patients/*` | Patient Records |
| `*/appointments/*` | Scheduling |
| `*/billing/*` | Billing |
| `*/insurance/*` | Insurance Claims |
| `*/lab/*` | Lab Results |
| `*/admin/*` | Administration |
| `*/auth/*` | Authentication |
| `*/api/*` | API |
| `*/mobile/*` | Mobile |

### Label Generation

Auto-generate labels based on:

**Hotfix Pattern:**
- `null-handling`
- `edge-case`
- `authorization-gap`
- `logic-error`
- `data-validation`
- `missing-implementation`

**Area:**
- `prescription`
- `patient-record`
- `appointment`
- `billing`
- `lab-results`
- etc.

**Severity:**
- `critical-severity`
- `high-severity`
- `medium-severity`
- `low-severity`

**Type:**
- `validation-error`
- `calculation-error`
- `ui-error`
- `performance-issue`

### Priority Mapping

| Severity | Priority |
|----------|----------|
| Critical | P1 |
| High | P2 |
| Medium | P3 |
| Low | P4 |

---

## Quality Assurance

### Before Submitting Report

**Technical Accuracy:**
- [ ] File paths are correct
- [ ] Line numbers are accurate
- [ ] Code snippets are valid syntax
- [ ] Root cause explanation makes sense

**Clarity:**
- [ ] Steps to reproduce are numbered and clear
- [ ] Expected vs Actual is unambiguous
- [ ] Fix recommendation is actionable
- [ ] Technical terms explained if needed

**Completeness:**
- [ ] All mandatory sections filled
- [ ] Severity justified
- [ ] Test data requirements specific
- [ ] Related issues searched

**Professional:**
- [ ] No typos
- [ ] Proper formatting
- [ ] Ticket-ready language
- [ ] Word count <= 600

---

## Time Budget

Total time: 18-24 minutes

- **Phase 1** (Classification): 2-3 min
- **Phase 2** (Location): 3-5 min
- **Phase 3** (Root Cause + Pattern Search): 8-11 min
- **Phase 4** (Severity): 2-3 min
- **Phase 5** (Test Coverage): 2-3 min
- **Phase 6** (Fix Recommendation): 3-5 min
- **Phase 7** (Report Writing): 5-10 min

If taking longer:
- Focus on essentials (Sections 1-6)
- Skip optional sections (screenshots, logs)
- Use template structure strictly
- Don't over-analyze

---

## Confidence Levels

Always indicate confidence in root cause analysis:

**High Confidence (90-100%):**
- Clear stack trace to exact line
- Obvious issue (missing null check)
- Easy to reproduce
- Similar past issues found

**Medium Confidence (60-90%):**
- Error located but logic complex
- Multiple potential causes
- Intermittent issue
- Needs more investigation

**Low Confidence (30-60%):**
- Error message only, no stack trace
- Complex system interaction
- Cannot reproduce reliably
- Insufficient information

**Example:**
```
Root Cause (Medium Confidence - 70%):
The error likely occurs due to missing null check at line 234,
but the intermittent nature suggests there may be a race condition
or timing issue that requires further investigation.
```

---

**File Location:** `prompts/bug-report/bug-report-prompt.md`

*Follow this analysis framework for consistent, high-quality bug reports.*
