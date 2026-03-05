# Historical Bugfix Patterns

**This is the canonical source of truth for all bugfix pattern tables.** All agents, templates, and prompts reference this file — update patterns and percentages here only.

---

## Repository-to-Pattern Routing

| Repository | Pattern Table | Branch Prefix |
|------------|--------------|---------------|
| HealthBridge-Web | Web / API Patterns | `HM-*` |
| HealthBridge-Portal | Portal Patterns | `HBP-*` |
| HealthBridge-Mobile | Mobile / Flutter Patterns | `HMM-*` |
| HealthBridge-Api | Microservice API Patterns | `HM-*` |
| HealthBridge-Prescriptions-Api | Microservice API Patterns | `HM-*` |
| HealthBridge-Claims-Processing | Claims-Processing Patterns | `HM-*` |

**IMPORTANT:** Use the correct pattern table based on **repository**, not just branch prefix. Multiple repositories share the `HM-*` prefix.

---

## Web / API Patterns (HealthBridge-Web)

Based on RCA of 50+ production bugfixes:

| Pattern | % | Detection Focus |
|---------|---|-----------------|
| **Edge Cases** | 28% | Empty patient lists, boundary dates for prescription validity, zero-dose quantities |
| **Authorization Gaps** | 22% | Doctor accessing patient outside department, role-based permission mismatches |
| **NULL Handling** | 18% | Missing allergy records, null insurance provider, absent emergency contacts |
| **Logic/Condition Errors** | 16% | Drug interaction checks skipped, overlapping appointment slots, discharge without all sign-offs |
| **Data Validation** | 10% | Invalid dosage formats, expired license numbers, malformed diagnosis codes |
| **Missing Implementation** | 6% | TODOs in discharge workflows, stubs in referral processing, incomplete audit logging |

---

## Portal Patterns (HealthBridge-Portal)

Based on RCA of 30+ bugfixes:

| Pattern | % | Detection Focus |
|---------|---|-----------------|
| **Permission/Authorization** | 25% | API fetches without permission guards, missing `enabled` flags in React Query |
| **NULL/Undefined Handling** | 20% | Missing optional chaining, nullable DB fields mapped to non-nullable |
| **Cross-Year/Date Calculations** | 18% | `.Year` arithmetic without month handling, period copying across years |
| **UI Event Handling & Refs** | 15% | Ref scope issues, blur/mousedown containment checks, `props.children` unreliability |
| **Logic/Condition Errors** | 12% | `return` vs `continue` in loops, missing condition cases |
| **Error Propagation** | 10% | Errors breaking pages instead of graceful degradation |

**Key differences from HealthBridge-Web:** Portal has significantly more permission bugs (25% vs 5%) and UI lifecycle issues (15% vs 2%) due to React frontend.

---

## Mobile / Flutter Patterns (HealthBridge-Mobile)

Based on RCA of 20+ mobile app bugfixes:

| Pattern | % | Detection Focus |
|---------|---|-----------------|
| **Calculation/Logic Errors** | 30% | Date math, week boundaries, dosage calculations, appointment duration |
| **State Management Issues** | 25% | Riverpod lifecycle, async races, disposed widget access |
| **Navigation/UI Lifecycle** | 20% | Modal handling, missing pop() calls, back button behavior |
| **Edge Cases** | 15% | Empty patient lists, optional data fields, offline mode boundaries |
| **NULL/Optional Handling** | 5% | Async nulls, state access timing |
| **Missing Implementation** | 5% | Incomplete features, partial offline support |

---

## Microservice API Patterns (HealthBridge-Api, HealthBridge-Prescriptions-Api)

Based on RCA of bugfixes across microservice repositories:

| Pattern | % | Detection Focus |
|---------|---|-----------------|
| **NULL Handling** | 22% | `FirstOrDefault()` without null check, nullable DB fields, empty collection `.First()` |
| **Configuration/DI Errors** | 18% | Missing DI registrations, wrong service lifetimes (scoped vs transient), auth setup |
| **Logic/Condition Errors** | 16% | Swapped constructor parameters, incorrect condition ordering, wrong method overloads |
| **Database/EF Core Issues** | 14% | Wrong column types (`int` vs `tinyint`), missing `.Include()`, double joins, FK misconfig |
| **Edge Cases** | 12% | Boundary values, empty collections, optional parameter defaults, pagination missing |
| **Type Casting Errors** | 8% | Value Object vs primitive confusion in LINQ, wrong DB column type declarations |
| **Permission/Authorization** | 5% | Missing permission guards, incorrect access level checks |
| **Concurrency/Race Conditions** | 5% | `DbUpdateConcurrencyException`, operation ordering, message queue sequencing |

**Key differences from HealthBridge-Web:** Microservices have significantly more Configuration/DI bugs (18% vs 3%) and Database/EF Core issues (14% vs 5%) due to distributed architecture and EF Core configuration complexity.

---

## Claims-Processing Patterns (HealthBridge-Claims-Processing)

Based on RCA of 43 bugfixes:

| Pattern | % | Detection Focus |
|---------|---|-----------------|
| **Concurrency/Race Conditions** | 23% | `DbUpdateConcurrencyException`, EF Core change tracking races, operation ordering |
| **CI/CD & Deployment** | 19% | Workflow bugs, Docker path errors, deploy script logic, tag formatting |
| **Data Validation/Uniqueness** | 14% | Missing composite keys, incorrect uniqueness checks, ClaimId scoping |
| **Logic/Condition Errors** | 12% | Wrong terminal status values, incorrect polling conditions |
| **Configuration/DI Errors** | 12% | Missing options, wrong service lifetime, name shadowing |
| **Edge Cases** | 9% | Pagination missing, negative backoff, infinite loops, empty entity handling |
| **NULL Handling** | 7% | Nullable fields, `FirstOrDefault` returning null |
| **Error Handling/Retry** | 5% | Missing retry on transient failures |

**Key difference:** Claims-Processing uniquely has concurrency as its #1 pattern (23%) due to multiple services accessing shared state.

---

## How Agents Use This File

### Code Review / Bug Report / Bugfix RCA
1. Identify the repository from the branch
2. Select the matching pattern table from this file
3. Check each pattern against the code changes
4. Report status (pass/fail/warn or EXACT/PARTIAL/No Match) per pattern

### Release Analysis
1. For each PR in the release, identify its repository
2. Apply the matching pattern table per-PR
3. Group findings by repository in the report

### Requirements Analysis
1. Use patterns to identify likely edge cases and risk areas
2. Prioritize requirements gaps that match high-frequency patterns

### Output Templates (Generic Format)
Templates use placeholder rows — the agent fills in actual pattern names and percentages from this file:

```markdown
| Pattern | Status | Finding | Location |
|---------|--------|---------|----------|
| [Pattern 1 (XX%)] | pass/fail/warn | [Description or N/A] | `[file:line]` or N/A |
```
