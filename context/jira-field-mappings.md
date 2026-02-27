# JIRA Field Mappings

This document defines auto-detection rules for JIRA fields based on code analysis.

---

## Component Auto-Detection

Map file paths to JIRA components:

| Path Pattern | Component | Description |
|--------------|-----------|-------------|
| `*/patient-records/*` | Patient Records | Patient demographics, medical history, charts |
| `*/prescriptions/*` | Prescriptions | Medication orders, refills, e-prescribing |
| `*/lab-results/*` | Lab Results | Laboratory tests, diagnostic reports |
| `*/billing/*` | Billing | Patient billing, payment processing |
| `*/insurance/*` | Insurance Claims | Insurance claim submission and tracking |
| `*/scheduling/*` | Staff Scheduling | Staff shifts, rotations, on-call assignments |
| `*/appointments/*` | Appointments | Patient appointment booking and management |
| `*/pharmacy/*` | Pharmacy | Medication dispensing, inventory |
| `*/compliance/*` | Compliance | Regulatory compliance, audit logs |
| `*/admin/*` | Administration | System administration and configuration |
| `*/auth/*` | Authentication | Login, SSO, role-based access control |
| `*/api/*` | API | REST/GraphQL API endpoints |
| `*/import/*` | Data Import | File imports, HL7/FHIR integrations |
| `*/reports/*` | Reporting | Clinical and operational report generation |
| `*/mobile/*` | Mobile | Mobile application features |
| `*/portal/*` | Patient Portal | Patient-facing web portal |

### Detection Logic

```python
def detect_component(file_path):
    path_lower = file_path.lower()

    # Check most specific patterns first
    if 'prescription' in path_lower or 'medication' in path_lower:
        return 'Prescriptions'
    elif 'patient-record' in path_lower or 'patient_record' in path_lower or 'chart' in path_lower:
        return 'Patient Records'
    elif 'lab-result' in path_lower or 'lab_result' in path_lower or 'diagnostic' in path_lower:
        return 'Lab Results'
    elif 'insurance' in path_lower or 'claim' in path_lower:
        return 'Insurance Claims'
    elif 'billing' in path_lower or 'payment' in path_lower:
        return 'Billing'
    elif 'scheduling' in path_lower or 'shift' in path_lower or 'rotation' in path_lower:
        return 'Staff Scheduling'
    elif 'appointment' in path_lower or 'booking' in path_lower:
        return 'Appointments'
    elif 'pharmacy' in path_lower or 'dispensing' in path_lower:
        return 'Pharmacy'
    elif 'compliance' in path_lower or 'audit' in path_lower or 'hipaa' in path_lower:
        return 'Compliance'
    elif 'auth' in path_lower or 'login' in path_lower or 'sso' in path_lower:
        return 'Authentication'
    elif 'api' in path_lower:
        return 'API'
    elif 'import' in path_lower or 'hl7' in path_lower or 'fhir' in path_lower:
        return 'Data Import'
    elif 'report' in path_lower:
        return 'Reporting'
    elif 'admin' in path_lower:
        return 'Administration'
    elif 'mobile' in path_lower or file_path.startswith('HealthBridge-Mobile'):
        return 'Mobile'
    elif file_path.startswith('HealthBridge-Portal'):
        return 'Patient Portal'
    else:
        return 'General'
```

---

## Label Auto-Generation

### Hotfix Pattern Labels

Based on root cause analysis of production hotfixes:

| Pattern | Label | When to Use |
|---------|-------|-------------|
| NULL Handling (18%) | `null-handling` | NullReferenceException, missing null checks |
| Edge Cases (28%) | `edge-case` | Boundary conditions, empty collections, date ranges |
| Authorization Gaps (22%) | `authorization-gap` | Missing permission checks, role mismatches |
| Logic/Condition Errors (16%) | `logic-error` | Logic errors, incorrect conditions |
| Data Validation (10%) | `data-validation` | Invalid format, missing required fields |
| Missing Implementation (6%) | `missing-implementation` | NotImplementedException, TODOs |

### Area/Feature Labels

Based on affected functionality:

**Patient Records:**
- `patient-record`
- `medical-history`
- `demographics`
- `consent`
- `chart-notes`
- `allergies`

**Prescriptions:**
- `prescription`
- `medication`
- `drug-interaction`
- `refill`
- `e-prescribing`
- `dosage`

**Lab Results:**
- `lab-order`
- `lab-result`
- `diagnostic-report`
- `reference-range`

**Billing & Insurance:**
- `billing`
- `insurance-claim`
- `claim-denial`
- `copay`
- `deductible`
- `prior-authorization`

**Staff & Scheduling:**
- `staff-scheduling`
- `shift-management`
- `on-call`
- `appointment-booking`
- `provider-availability`

**General:**
- `validation-error`
- `calculation-error`
- `ui-error`
- `performance-issue`
- `data-integrity`
- `security`
- `accessibility`
- `hipaa-compliance`

### Severity Labels

| Severity | Label |
|----------|-------|
| Critical | `critical-severity` |
| High | `high-severity` |
| Medium | `medium-severity` |
| Low | `low-severity` |

### Error Type Labels

Based on exception type:

| Exception | Label |
|-----------|-------|
| NullReferenceException | `nullreference` |
| IndexOutOfRangeException | `indexoutofrange` |
| ArgumentException | `argument-error` |
| InvalidOperationException | `invalid-operation` |
| NotImplementedException | `not-implemented` |
| DbUpdateException | `database-error` |
| TimeoutException | `timeout` |
| UnauthorizedAccessException | `authorization` |
| ValidationException | `validation-failure` |

### Repository Labels

| Repository | Label |
|------------|-------|
| HealthBridge-Web | `healthbridge-web` |
| HealthBridge-Portal | `healthbridge-portal` |
| HealthBridge-Mobile | `mobile` |
| HealthBridge-Api | `api` |
| HealthBridge-Claims-Processing | `claims-processing` |
| HealthBridge-Prescriptions-Api | `prescriptions-api` |

### Label Generation Logic

```python
def generate_labels(bug_analysis):
    labels = []

    # Add hotfix pattern
    if bug_analysis.pattern:
        pattern_map = {
            'NULL Handling': 'null-handling',
            'Edge Cases': 'edge-case',
            'Authorization Gaps': 'authorization-gap',
            'Logic/Condition Errors': 'logic-error',
            'Data Validation': 'data-validation',
            'Missing Implementation': 'missing-implementation'
        }
        labels.append(pattern_map.get(bug_analysis.pattern))

    # Add severity
    severity_map = {
        'Critical': 'critical-severity',
        'High': 'high-severity',
        'Medium': 'medium-severity',
        'Low': 'low-severity'
    }
    labels.append(severity_map.get(bug_analysis.severity))

    # Add functional area (from file path or error context)
    if 'prescription' in bug_analysis.affected_files.lower():
        labels.append('prescription')
    if 'patient' in bug_analysis.affected_files.lower():
        labels.append('patient-record')
    if 'billing' in bug_analysis.affected_files.lower():
        labels.append('billing')
    if 'lab' in bug_analysis.affected_files.lower():
        labels.append('lab-result')
    if 'scheduling' in bug_analysis.affected_files.lower():
        labels.append('staff-scheduling')

    # Add error type (from exception)
    if 'NullReferenceException' in bug_analysis.error_message:
        labels.append('nullreference')
    elif 'IndexOutOfRange' in bug_analysis.error_message:
        labels.append('indexoutofrange')
    elif 'UnauthorizedAccess' in bug_analysis.error_message:
        labels.append('authorization')

    # Add repository
    if 'HealthBridge-Web' in bug_analysis.repository:
        labels.append('healthbridge-web')
    elif 'HealthBridge-Portal' in bug_analysis.repository:
        labels.append('healthbridge-portal')
    elif 'Mobile' in bug_analysis.repository:
        labels.append('mobile')

    # Limit to 5 most relevant labels
    return labels[:5]
```

---

## Priority Mapping

Map severity to default priority:

| Severity | Default Priority | Can Override |
|----------|-----------------|--------------|
| Critical | P1 | Rarely (only if mitigated) |
| High | P2 | Sometimes (business reasons) |
| Medium | P3 | Often (sprint capacity) |
| Low | P4 | Often (batching) |

### Priority Override Reasons

**P1 (Critical) to P2 (High):**
- Workaround discovered
- Affects only test/staging environment
- Risk successfully mitigated
- Can wait for next release

**P2 (High) to P1 (Critical):**
- Patient safety concern escalated
- Regulatory compliance deadline imminent
- Multiple facilities affected
- Data breach or loss discovered

**P3 (Medium) to P2 (High):**
- Facility accreditation audit scheduled
- Feature launch blocked
- Sprint commitment
- Clinical workflow disruption

---

## Affected Version Detection

### Release Detection

```bash
# Check which release branch contains current commit
git branch -r --contains HEAD | grep "Release"
```

**Format:** `Release-XX/YYYY`

**Examples:**
- `Release-01/2026`
- `Release-52/2025`
- `Release-3/2026` (note: sometimes without leading zero)

### Version Number Detection

For tagged releases:
```bash
git describe --tags --abbrev=0
```

**Format:** `vX.Y.Z`

**Examples:**
- `v3.12.0`
- `v1.0.45`

### Branch Detection Logic

```python
def detect_affected_version(repository_path):
    # Try to get Release branch
    result = run_command(f"cd {repository_path} && git branch -r --contains HEAD | grep Release")

    if result:
        # Extract Release-XX/YYYY
        match = re.search(r'Release-(\d+)/(\d{4})', result)
        if match:
            week = match.group(1)
            year = match.group(2)
            return f"Release-{week}/{year}"

    # Try to get version tag
    result = run_command(f"cd {repository_path} && git describe --tags --abbrev=0")
    if result:
        return result.strip()

    # Fallback to branch name
    result = run_command(f"cd {repository_path} && git branch --show-current")
    return result.strip() or "Unknown"
```

---

## Fix Version Suggestion

Suggest next appropriate fix version:

### For Critical/High Bugs

```python
def suggest_fix_version(current_version, severity):
    if severity in ['Critical', 'High']:
        # Suggest next Release
        match = re.match(r'Release-(\d+)/(\d{4})', current_version)
        if match:
            week = int(match.group(1))
            year = int(match.group(2))

            # Next week
            next_week = week + 1
            next_year = year

            # Handle year rollover
            if next_week > 52:
                next_week = 1
                next_year = year + 1

            return f"Release-{next_week:02d}/{next_year}"

    # For Medium/Low, suggest version TBD
    return "TBD"
```

**Examples:**
- Current: `Release-01/2026`, Severity: High → Fix: `Release-02/2026`
- Current: `Release-52/2025`, Severity: Critical → Fix: `Release-01/2026`
- Current: `Release-03/2026`, Severity: Medium → Fix: `TBD`

---

## Assignee Suggestion

Suggest assignee based on component:

| Component | Default Team/Assignee |
|-----------|----------------------|
| Patient Records | Patient Records Team |
| Prescriptions | Pharmacy Team |
| Lab Results | Diagnostics Team |
| Billing | Revenue Cycle Team |
| Insurance Claims | Claims Team |
| Staff Scheduling | Workforce Team |
| Appointments | Scheduling Team |
| Pharmacy | Pharmacy Team |
| Compliance | Compliance Team |
| Mobile | Mobile Team |
| API | Platform Team |
| Authentication | Security Team |
| Patient Portal | Portal Team |

### Assignee Detection Logic

```python
def suggest_assignee(component, git_blame_author=None):
    # Component-based assignment
    component_map = {
        'Patient Records': 'Patient Records Team',
        'Prescriptions': 'Pharmacy Team',
        'Lab Results': 'Diagnostics Team',
        'Billing': 'Revenue Cycle Team',
        'Insurance Claims': 'Claims Team',
        'Staff Scheduling': 'Workforce Team',
        'Appointments': 'Scheduling Team',
        'Pharmacy': 'Pharmacy Team',
        'Compliance': 'Compliance Team',
        'Mobile': 'Mobile Team',
        'API': 'Platform Team',
        'Authentication': 'Security Team',
        'Patient Portal': 'Portal Team'
    }

    team = component_map.get(component, 'Unassigned')

    # If git blame shows recent author, suggest them
    if git_blame_author:
        return f"{git_blame_author} ({team})"

    return team
```

---

## Epic Link Detection

Link to epic if error relates to recent feature work:

### Detection Strategy

1. **Search commit messages** for epic/feature references (HM-XXXXX pattern)
2. **Check branch name** for ticket IDs

**Note:** Manual JIRA search required - no API integration available.

```python
def detect_epic_link(file_path, component):
    # Check recent commits on this file for ticket references
    commits = run_command(f"git log -10 --oneline -- {file_path}")

    # Look for epic/ticket references (HM-XXXXX, HBP-XXXXX, HMM-XXXX patterns)
    epic_pattern = r'(HM-\d{5}|HBP-\d{4}|HMM-\d{4})'
    matches = re.findall(epic_pattern, commits)

    if matches:
        # Return most recent ticket reference
        return matches[0]

    # No epic found - suggest manual search
    return f"N/A (Suggest searching JIRA for {component} epics manually)"
```

---

## JIRA Field Template

Complete JIRA fields section for bug report:

```markdown
## 9. JIRA Fields (Auto-populated)

**Component:** [Component from path detection]
**Affected Version:** [Release-XX/YYYY from branch]
**Fix Version:** [Suggested next Release for Critical/High]
**Labels:** `[pattern]`, `[area]`, `[severity]`, `[error-type]`, `[repository]`
**Priority:** [P1/P2/P3/P4 from severity mapping]
**Assignee:** [Team/Person from component mapping]
**Epic Link:** [Epic-ID if detected, otherwise N/A]
**Story Points:** [Estimate from complexity: 1-2-3-5-8]
**Environment:** [Production/Staging/Test]
```

### Story Points Mapping

| Complexity | Story Points | Typical Duration |
|------------|-------------|------------------|
| Simple Fix | 1 | 1-2 hours |
| Medium Fix | 2-3 | 0.5-1 day |
| Complex Fix | 5 | 2-3 days |
| Very Complex | 8+ | 3+ days |

---

## Example: Complete JIRA Fields

**Component:** Prescriptions
**Affected Version:** Release-01/2026
**Fix Version:** Release-02/2026
**Labels:** `null-handling`, `prescription`, `high-severity`, `nullreference`, `prescriptions-api`
**Priority:** P2 (High)
**Assignee:** Pharmacy Team
**Epic Link:** N/A
**Story Points:** 1
**Environment:** Production

**Auto-Detection Summary:**
- Component: Detected from file path `src/Prescriptions/Services/RefillService.cs`
- Labels: Pattern (null-handling), Area (prescription), Severity (high), Type (nullreference), Repo (prescriptions-api)
- Priority: P2 mapped from High severity
- Fix Version: Next Release suggested due to High severity
- Story Points: 1 (Simple fix - add null check)

---

## Integration Example

Show how fields are populated in bug report agent:

```python
# In Bug Report Agent workflow

# Step 1: Analyze error
error_analysis = analyze_error(error_message, stack_trace)

# Step 2: Detect repository and file
repository = detect_repository(error_analysis.file_path)
component = detect_component(error_analysis.file_path)

# Step 3: Assess severity
severity = assess_severity(error_analysis)

# Step 4: Detect version
affected_version = detect_affected_version(repository)
fix_version = suggest_fix_version(affected_version, severity)

# Step 5: Generate labels
labels = generate_labels(error_analysis)

# Step 6: Map priority
priority = map_priority(severity)

# Step 7: Suggest assignee
assignee = suggest_assignee(component)

# Step 8: Populate JIRA fields section
jira_fields = {
    'component': component,
    'affected_version': affected_version,
    'fix_version': fix_version,
    'labels': labels,
    'priority': priority,
    'assignee': assignee,
    'story_points': estimate_story_points(error_analysis.complexity)
}
```

---

## Manual Override

All auto-detected fields can be manually overridden:

**When to Override:**
- Component misdetected (cross-cutting concern)
- Severity needs adjustment (clinical safety reasons)
- Priority different from severity (accreditation timing)
- Assignee change (expertise needed)
- Labels addition (missing context)

**How to Override:**
Simply edit the JIRA fields section in the generated bug report before copying to JIRA.

---

**File Location:** `context/jira-field-mappings.md`

*Reference this document for consistent JIRA field auto-population in bug reports.*
