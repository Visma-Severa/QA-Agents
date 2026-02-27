# Development Estimation Template

This template defines the structure and format for development effort estimation documents based on requirements analysis for the HealthBridge health management platform.

## PATH NAMING CONVENTION

**CRITICAL:** Always use **hyphens** (`-`) not underscores (`_`) in output paths:
- Correct: `reports/requirements-analysis/[TICKET]-dev-estimation.md` (when part of workflow)
- Wrong: `reports/dev_estimation/` (old location, deprecated)

## CRITICAL CONSTRAINTS

| Constraint | Value | Enforcement |
|------------|-------|-------------|
| **Maximum Word Count** | **800 words** | MANDATORY - Tables only. No prose explanations. |
| **Prerequisites** | **Requirements completeness >= 7/10** | Only generate if requirements are sufficiently complete |
| **Repository Scope** | **Only impacted repos** | Skip repos with no impact |
| **Estimation Level** | **Detailed (task-level)** | Specific hours per file/component modification |
| **Code Examples** | **NONE** | Reference file paths, don't show code |
| **Format** | **Tables > Prose** | Every estimate in a table row |

---

## Report Structure

```markdown
# Development Estimation: [TICKET-ID] - [Title]

**Ticket:** [TICKET-ID]
**Requirements Reference:** `[TICKET-ID]-requirements-analysis.md`
**Estimation Created By:** [Tech Lead Name]
**Date:** YYYY-MM-DD
**Estimation Confidence:** High (+/-10%) | Medium (+/-20%) | Low (+/-30-50%)

---

## 1. Estimation Summary (Max 100 words)

**Impacted Repositories:**
- [Repository 1 - e.g., HealthBridge-Web]
- [Repository 2 - e.g., HealthBridge-Api]
- [Repository 3 - e.g., HealthBridge-Mobile]

**Development Complexity:** Low | Medium | High | Very High

**Total Effort Estimate:** [X.X] hours (~[X.X] days)

**Key Risk Factors:**
- [Risk 1 - e.g., Database migration with zero-downtime requirement]
- [Risk 2 - e.g., Multi-repository coordination needed]
- [Risk 3 - e.g., Unclear integration with external health registry]

---

## 2. Repository-by-Repository Breakdown

**ONLY include repositories that are IMPACTED (identified in requirements analysis)**

### 2.1 HealthBridge-Web (C# / ASP.NET Core)

**Impact Level:** High / Medium / Low / None

**If None - Skip this repository**

#### 2.1.1 Backend Changes

| Task | File(s) to Modify | Complexity | Estimate | Notes |
|------|-------------------|------------|----------|-------|
| [Task description] | [Full file path] | Low/Med/High | [X.X]h | [Implementation details, gotchas] |
| Example: Add prescription validation | `Services/PrescriptionService.cs` | Medium | 3h | Add dosage range validation logic |
| Example: Update patient record handler | `Controllers/PatientController.cs` | Low | 2h | Add new endpoint for record merge |

**Backend Subtotal:** [X.X] hours

#### 2.1.2 Frontend Changes

| Task | File(s) to Modify | Complexity | Estimate | Notes |
|------|-------------------|------------|----------|-------|
| [Task description] | [Full file path] | Low/Med/High | [X.X]h | [Implementation details] |
| Example: Add prescription preview | `Views/Prescriptions/Create.cshtml` | Low | 1h | Preview modal with dosage summary |
| Example: Update JavaScript handler | `wwwroot/js/prescriptions.js` | Medium | 1.5h | Handle preview button, async dosage calc |

**Frontend Subtotal:** [X.X] hours

#### 2.1.3 Database Changes

| Task | Tables Affected | Migration Required? | Estimate | Notes |
|------|----------------|---------------------|----------|-------|
| [Task description] | [Table names] | Yes/No | [X.X]h | [Migration script details, rollback plan] |
| Example: Add RenewalDate column | PrescriptionHistory | Yes | 2h | Nullable column, no data backfill needed |

**Database Subtotal:** [X.X] hours

#### 2.1.4 Localization/Resources

| Task | Resource Files | Estimate | Notes |
|------|---------------|----------|-------|
| [Task description] | [.resx or .json files] | [X.X]h | [Languages: EN, ES, FR, etc.] |
| Example: Add renewal labels | `Resources.en.resx`, `Resources.es.resx` | 0.5h | 3 new strings x 2 languages |

**Localization Subtotal:** [X.X] hours

#### 2.1.5 Unit Tests (HealthBridge-Web)

**Existing Test Framework:** [xUnit / NUnit / MSTest]

| Task | Test File | Complexity | Estimate | Notes |
|------|-----------|------------|----------|-------|
| [What to test] | [Full test file path] | Low/Med/High | [X.X]h | [What test cases to add] |
| Example: Test dosage validation | `Tests/Services/PrescriptionServiceTests.cs` | Medium | 2h | Edge cases: zero, negative, max dosage |

**Unit Test Subtotal:** [X.X] hours

#### 2.1.6 Integration Tests (HealthBridge-Web)

| Task | Test File | Complexity | Estimate | Notes |
|------|-----------|------------|----------|-------|
| [What to test] | [Full test file path] | Low/Med/High | [X.X]h | [Integration points to test] |
| Example: Test full prescription workflow | `IntegrationTests/PrescriptionWorkflowTests.cs` | Medium | 2h | End-to-end with database |

**Integration Test Subtotal:** [X.X] hours

**HealthBridge-Web Total:** [Backend + Frontend + Database + Localization + Unit Tests + Integration Tests = X.X hours]

---

### 2.2 HealthBridge-Api (C# / .NET Core)

**Impact Level:** High / Medium / Low / None

**If None - Skip this repository**

#### 2.2.1 API Endpoint Changes

| Task | File(s) to Modify | Breaking Change? | Estimate | Notes |
|------|-------------------|------------------|----------|-------|
| [Task description] | [Full file path] | Yes/No | [X.X]h | [Contract changes, versioning strategy] |
| Example: Add renewal endpoint | `Controllers/V2/PrescriptionController.cs` | No | 3h | New endpoint, backward compatible |

**API Subtotal:** [X.X] hours

#### 2.2.2 DTO/Contract Changes

| Task | File(s) to Modify | Breaking Change? | Estimate | Notes |
|------|-------------------|------------------|----------|-------|
| [Task description] | [Full file path] | Yes/No | [X.X]h | [New properties, serialization] |
| Example: Add renewal fields | `Models/PrescriptionRenewalDto.cs` | No | 0.5h | Optional field, backward compatible |

**DTO Subtotal:** [X.X] hours

#### 2.2.3 Database Changes (HealthBridge-Api)

| Task | Tables Affected | Migration Required? | Estimate | Notes |
|------|----------------|---------------------|----------|-------|
| [Task description] | [Table names] | Yes/No | [X.X]h | [Migration details] |

**Database Subtotal:** [X.X] hours

#### 2.2.4 Unit Tests (HealthBridge-Api)

**Existing Test Framework:** [xUnit / NUnit / MSTest]

| Task | Test File | Complexity | Estimate | Notes |
|------|-----------|------------|----------|-------|
| [What to test] | [Full test file path] | Low/Med/High | [X.X]h | [Test cases] |
| Example: Test renewal endpoint | `Tests/Controllers/PrescriptionControllerTests.cs` | Medium | 2h | Test request/response, validation |

**Unit Test Subtotal:** [X.X] hours

#### 2.2.5 API Documentation

| Task | Documentation File | Estimate | Notes |
|------|-------------------|----------|-------|
| [Task description] | [Swagger/OpenAPI file] | [X.X]h | [What to document] |
| Example: Update Swagger docs | `swagger.json` | 0.5h | New endpoint documentation |

**Documentation Subtotal:** [X.X] hours

**HealthBridge-Api Total:** [API + DTO + Database + Unit Tests + Documentation = X.X hours]

---

### 2.3 HealthBridge-Mobile (Flutter / Dart)

**Impact Level:** High / Medium / Low / None

**If None - Skip this repository**

#### 2.3.1 UI/Widget Changes

| Task | File(s) to Modify | Complexity | Estimate | Notes |
|------|-------------------|------------|----------|-------|
| [Task description] | [Full file path] | Low/Med/High | [X.X]h | [Widget implementation, state management] |
| Example: Add renewal button | `lib/prescriptions/prescription_detail_page.dart` | Medium | 3h | Confirmation dialog, loading state |

**UI Subtotal:** [X.X] hours

#### 2.3.2 State Management Changes

| Task | File(s) to Modify | Complexity | Estimate | Notes |
|------|-------------------|------------|----------|-------|
| [Task description] | [Full file path] | Low/Med/High | [X.X]h | [Provider/Riverpod changes] |
| Example: Update prescription provider | `lib/prescriptions/prescription_provider.dart` | Medium | 2h | Handle renewal API call + cache invalidation |

**State Management Subtotal:** [X.X] hours

#### 2.3.3 API Integration Changes

| Task | File(s) to Modify | Complexity | Estimate | Notes |
|------|-------------------|------------|----------|-------|
| [Task description] | [Full file path] | Low/Med/High | [X.X]h | [API client updates] |
| Example: Add renewal API method | `lib/api/prescription_api_client.dart` | Low | 1h | Add renewal method to client |

**API Integration Subtotal:** [X.X] hours

#### 2.3.4 Localization (Mobile)

| Task | File(s) to Modify | Estimate | Notes |
|------|-------------------|----------|-------|
| [Task description] | [.arb files] | [X.X]h | [Languages] |
| Example: Add renewal labels | `l10n/app_en.arb`, `l10n/app_es.arb` | 0.5h | 3 strings x 2 languages |

**Localization Subtotal:** [X.X] hours

#### 2.3.5 Unit Tests (Mobile)

**Existing Test Framework:** Flutter built-in test framework

| Task | Test File | Complexity | Estimate | Notes |
|------|-----------|------------|----------|-------|
| [What to test] | [Full test file path] | Low/Med/High | [X.X]h | [Test cases] |
| Example: Test renewal widget | `test/prescriptions/prescription_detail_page_test.dart` | Medium | 2h | Widget tests for renewal flow |

**Unit Test Subtotal:** [X.X] hours

#### 2.3.6 Integration Tests (Mobile)

| Task | Test File | Complexity | Estimate | Notes |
|------|-----------|------------|----------|-------|
| [What to test] | [Full test file path] | Low/Med/High | [X.X]h | [Integration points] |
| Example: E2E renewal workflow | `integration_test/prescription_renewal_test.dart` | Medium | 2.5h | Test full workflow with mock API |

**Integration Test Subtotal:** [X.X] hours

**HealthBridge-Mobile Total:** [UI + State + API + Localization + Unit Tests + Integration Tests = X.X hours]

---

## 3. Cross-Repository Tasks

**Tasks that span multiple repositories or require coordination**

### 3.1 Database Migrations

| Migration | Affected Databases | Rollback Plan | Estimate | Notes |
|-----------|-------------------|---------------|----------|-------|
| [Migration description] | [Database names] | [How to rollback] | [X.X]h | [Zero-downtime? Data migration?] |
| Example: No migrations needed | N/A | N/A | 0h | UI-only change |

**Migration Total:** [X.X] hours

### 3.2 API Contract Coordination

| Task | From Repo -> To Repo | Breaking Change? | Estimate | Notes |
|------|---------------------|------------------|----------|-------|
| [Contract change] | [Repo] -> [Repo] | Yes/No | [X.X]h | [Versioning, backward compatibility] |
| Example: Internal API update | HealthBridge-Web -> HealthBridge-Api | No | 0.5h | Coordinate deployment timing |

**API Coordination Total:** [X.X] hours

### 3.3 Shared Library Updates

| Library | Affected Repos | Estimate | Notes |
|---------|---------------|----------|-------|
| [Library name] | [List of repos] | [X.X]h | [What changes, versioning] |
| Example: No shared library changes | N/A | 0h | N/A |

**Shared Library Total:** [X.X] hours

**Cross-Repository Total:** [Migrations + API + Libraries = X.X hours]

---

## 4. DevOps & Infrastructure Tasks

### 4.1 Feature Flags

| Task | Configuration | Estimate | Notes |
|------|--------------|----------|-------|
| [Feature flag task] | [Where to configure] | [X.X]h | [Flag name, rollout strategy] |
| Example: Add prescription_renewal flag | Feature flag service | 0.5h | Enable per clinic for staged rollout |

**Feature Flag Total:** [X.X] hours

### 4.2 CI/CD Pipeline Changes

| Task | Pipeline File | Estimate | Notes |
|------|--------------|----------|-------|
| [Pipeline change] | [File path] | [X.X]h | [What changes needed] |
| Example: No pipeline changes | N/A | 0h | Existing pipeline sufficient |

**CI/CD Total:** [X.X] hours

### 4.3 Environment Configuration

| Task | Environments | Estimate | Notes |
|------|-------------|----------|-------|
| [Config change] | [Dev/Staging/Prod] | [X.X]h | [What to configure] |
| Example: No config changes | N/A | 0h | Feature flag handles everything |

**Environment Config Total:** [X.X] hours

### 4.4 Monitoring & Logging

| Task | Where | Estimate | Notes |
|------|-------|----------|-------|
| [Monitoring task] | [Tool/location] | [X.X]h | [What metrics, alerts] |
| Example: Add renewal event logging | Application Insights | 0.5h | Track renewal frequency and failure rate |

**Monitoring Total:** [X.X] hours

**DevOps Total:** [Feature Flags + CI/CD + Config + Monitoring = X.X hours]

---

## 5. Documentation Tasks

### 5.1 Technical Documentation

| Task | Document | Estimate | Notes |
|------|----------|----------|-------|
| [Doc task] | [File or wiki page] | [X.X]h | [What to document] |
| Example: Update architecture docs | `docs/prescription-workflows.md` | 1h | Document renewal flow and API contracts |

**Technical Docs Total:** [X.X] hours

### 5.2 User Documentation

| Task | Document | Estimate | Notes |
|------|----------|----------|-------|
| [Doc task] | [User guide location] | [X.X]h | [What to document, screenshots] |
| Example: Update clinician guide | User manual - Prescriptions section | 2h | Screenshots of renewal UI, workflow steps |

**User Docs Total:** [X.X] hours

### 5.3 API Documentation

| Task | Document | Estimate | Notes |
|------|----------|----------|-------|
| [Doc task] | [Swagger/API docs] | [X.X]h | [Endpoint docs, examples] |
| Example: No new API docs needed | N/A | 0h | Swagger auto-generated |

**API Docs Total:** [X.X] hours

**Documentation Total:** [Technical + User + API = X.X hours]

---

## 6. Testing & Quality Assurance Tasks

### 6.1 Manual Smoke Testing (Dev Team)

| Task | Scope | Estimate | Notes |
|------|-------|----------|-------|
| [Testing task] | [What to test] | [X.X]h | [Dev team's own testing before QA] |
| Example: Test renewal happy path | Local testing of success scenarios | 1h | Verify renewal creates new prescription record |
| Example: Test validation errors | Error scenarios | 0.5h | Verify drug interaction warnings display correctly |

**Smoke Testing Total:** [X.X] hours

### 6.2 Code Review Time

| Task | Estimate | Notes |
|------|----------|-------|
| [Review task] | [X.X]h | [PR review, addressing feedback] |
| Example: Code review | 2h | Review time + address feedback iterations |

**Code Review Total:** [X.X] hours

**Testing & QA Total:** [Smoke Testing + Code Review = X.X hours]

---

## 7. Risk & Contingency

### 7.1 Known Risks

| Risk | Impact | Mitigation | Contingency Hours |
|------|--------|------------|-------------------|
| [Risk description] | High/Med/Low | [How to prevent] | [+X.X]h |
| Example: Drug interaction database may be slow | Medium | Cache interaction results | +2h |
| Example: HIPAA compliance review needed | High | Schedule early compliance check | +3h |

**Risk Contingency:** [X.X] hours

### 7.2 Complexity Buffer

**Base estimate:** [Sum of all tasks above] hours
**Complexity multiplier:**
- Low complexity: +10%
- Medium complexity: +20%
- High complexity: +30%
- Very High complexity: +50%

**Complexity:** [Selected level]
**Buffer:** +[X]% = [X.X] hours

**Total with Buffer:** [Base + Risk + Complexity = X.X] hours

---

## 8. Total Development Estimate Summary

| Category | Estimate (Hours) | % of Total | Notes |
|----------|------------------|------------|-------|
| **HealthBridge-Web** | [X.X]h | [XX]% | Backend + Frontend + DB + Tests |
| **HealthBridge-Api** | [X.X]h | [XX]% | API + DTOs + Tests + Docs |
| **HealthBridge-Mobile** | [X.X]h | [XX]% | UI + State + API + Tests |
| **Cross-Repository** | [X.X]h | [XX]% | Migrations + Coordination |
| **DevOps** | [X.X]h | [XX]% | Feature flags + CI/CD + Monitoring |
| **Documentation** | [X.X]h | [XX]% | Technical + User + API docs |
| **Testing & QA (Dev)** | [X.X]h | [XX]% | Smoke testing + Code review |
| **Risk & Contingency** | [X.X]h | [XX]% | Buffers for unknowns |
| **TOTAL ESTIMATE** | **[X.X]h** | **100%** | **~[X.X] days** |

### Estimate Breakdown by Activity Type

| Activity Type | Estimate (Hours) | % of Total |
|---------------|------------------|------------|
| Implementation | [X.X]h | [XX]% |
| Unit Testing | [X.X]h | [XX]% |
| Integration Testing | [X.X]h | [XX]% |
| Documentation | [X.X]h | [XX]% |
| DevOps | [X.X]h | [XX]% |
| Risk Buffer | [X.X]h | [XX]% |

### Timeline Estimate

**Assumptions:**
- 1 developer day = 6-8 hours of focused work
- Parallel work possible across repositories
- Dependencies resolved before starting

**Sequential Timeline:** [X.X] days (if one developer does everything)
**Parallel Timeline:** [X.X] days (if optimal team assignment)
**Recommended Team Size:** [X] developers

**Sprint Estimation:**
- If 2-week sprint: [X story points] (assuming 1 point = 1 day)
- If 1-week sprint: [X story points]

---

## 9. Estimation Confidence & Assumptions

### 9.1 Confidence Level

**Overall Confidence:** High (+/-10%) | Medium (+/-20%) | Low (+/-30-50%)

**Confidence Factors:**
- **High Confidence:**
  - [What we're confident about - e.g., UI changes are straightforward]

- **Medium Confidence:**
  - [What has some uncertainty - e.g., Integration with e-Prescription registry needs verification]

- **Low Confidence:**
  - [What's very uncertain - e.g., External health system API behavior unclear]

### 9.2 Key Assumptions

**Technical Assumptions:**
- [ ] [Assumption 1 - e.g., Existing architecture supports the change without refactoring]
- [ ] [Assumption 2 - e.g., No breaking changes in HealthBridge-Api dependencies]
- [ ] [Assumption 3 - e.g., Test environments stable and accessible]

**Resource Assumptions:**
- [ ] [Assumption 1 - e.g., Developers familiar with prescription workflow codebase]
- [ ] [Assumption 2 - e.g., No parallel high-priority work]
- [ ] [Assumption 3 - e.g., QA team available for testing]

**Dependency Assumptions:**
- [ ] [Assumption 1 - e.g., No blocking dependencies on other teams]
- [ ] [Assumption 2 - e.g., Database access available]
- [ ] [Assumption 3 - e.g., Feature flag system ready]

### 9.3 Estimate Accuracy Factors

| Factor | Impact on Estimate | Mitigation |
|--------|-------------------|------------|
| [Factor 1] | +/-[X]% | [How to improve accuracy] |
| Developer experience | +/-20% | Pair programming for complex parts |
| Requirement changes | +30% | Freeze requirements before dev starts |
| Technical debt | +15% | Allocate refactoring time upfront |

---

## 10. Task Assignment Recommendations

### 10.1 Suggested Team Structure

**Lead Developer:**
- Responsibilities: [Cross-repo coordination, complex logic, code review]
- Estimated time: [X.X] hours

**Backend Developer:**
- Responsibilities: [HealthBridge-Web changes, API updates]
- Estimated time: [X.X] hours

**Frontend Developer:**
- Responsibilities: [UI changes, JavaScript updates]
- Estimated time: [X.X] hours

**Mobile Developer:**
- Responsibilities: [Flutter changes, mobile testing]
- Estimated time: [X.X] hours

**DevOps Engineer:**
- Responsibilities: [Feature flags, CI/CD, monitoring]
- Estimated time: [X.X] hours

### 10.2 Task Dependencies

**Critical Path:**
1. [Task 1 - must be done first]
2. [Task 2 - depends on Task 1]
3. [Task 3 - can parallel with Task 2]

**Parallel Workstreams:**
- Stream 1: [Tasks that can be done in parallel]
- Stream 2: [Independent tasks]

---

## 11. Review & Sign-off

| Role | Name | Review Date | Approval |
|------|------|-------------|----------|
| **Tech Lead** | [Name] | [Date] | [ ] Approved / [ ] Changes Requested |
| **Dev Team** | [Names] | [Date] | [ ] Approved / [ ] Changes Requested |
| **Product Owner** | [Name] | [Date] | [ ] Approved / [ ] Changes Requested |

**Comments/Feedback:**
- [Any concerns about the estimates]
- [Suggestions for optimization]
- [Questions about scope]

---

**Word Count:** XXX/800 words
**Estimation Completed:** YYYY-MM-DD
**Tech Lead:** [Name]
**Review Status:** [ ] Reviewed | [ ] Approved | [ ] In Development | [ ] Complete
```

---

## Usage Guidelines

### When to Use This Template

1. **After Requirements Analysis** - When requirements completeness >= 7/10
2. **Before Sprint Planning** - To size user stories accurately
3. **For Effort Estimation** - When management needs timeline/budget

### How to Fill It Out

1. **Reference Requirements Analysis** - Use impacted repository list from requirements doc
2. **Only Include Impacted Repos** - Skip repositories with "Impact Level: None"
3. **Search Codebase** - Use `Grep` and `Glob` tools to identify files to modify
4. **Be Specific** - Exact file paths, method names, complexity assessment
5. **Realistic Estimates** - Based on similar past work, include buffer
6. **Include Unit Tests** - Use whatever test framework exists in each repo

### Quality Checklist

- [ ] Only impacted repositories included (from requirements analysis)
- [ ] File paths are specific and accurate
- [ ] Task-level estimates provided (not just feature-level)
- [ ] Unit test framework identified for each repo
- [ ] Risk contingency included (20-30% buffer)
- [ ] Dependencies and critical path identified
- [ ] Word count <= 800 words
- [ ] Cross-referenced with requirements analysis document

---

## Estimation Best Practices

### Typical Estimates by Task Type

**Backend Changes:**
- Simple service modification: 1-2h
- New service method: 2-4h
- Complex clinical logic (e.g., drug interaction validation): 4-8h
- Database migration: 2-6h

**Frontend Changes:**
- Add simple button/element: 0.5-1h
- Modify form behavior: 1-3h
- New page/component: 4-8h
- Complex JavaScript/TypeScript: 2-4h

**Unit Tests:**
- Simple test method: 0.5-1h
- Complex test with mocks: 1-2h
- Integration test: 2-4h

**Documentation:**
- Update existing doc: 0.5-1h
- Create new doc with screenshots: 2-4h

### Complexity Multipliers

**Low Complexity (+10% buffer):**
- Well-defined requirements
- Similar to past work
- No cross-repo dependencies
- Clear implementation path

**Medium Complexity (+20% buffer):**
- Some unknowns
- Moderate cross-repo coordination
- Some new patterns/technologies
- Integration with 1-2 systems

**High Complexity (+30% buffer):**
- Many unknowns
- Heavy cross-repo dependencies
- New technologies/patterns
- Multiple system integrations (e.g., e-Prescription registry, insurance provider)
- Performance concerns

**Very High Complexity (+50% buffer):**
- Significant unknowns
- Architectural changes needed
- Many dependencies
- High risk of rework
- Compliance requirements (HIPAA, patient data regulations)

---

**Template Version:** 1.0
**Created:** 2026-02-27
**Related Templates:**
- `requirements-analysis-template.md` (prerequisite)
- `qa-test-plan-template.md` (companion)
