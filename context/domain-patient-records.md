# Domain: Patient Records & Medical History — Agent Context

> **Purpose:** Patient records, medical history, chart management, and healthcare compliance regulatory/business rules for HealthBridge. Enables agents to flag domain-specific gaps that code-level analysis would miss.
> **Used by:** Requirements Analysis, Code Review, Acceptance Tests, Bugfix RCA agents — when analyzing patient records, demographics, chart management, or health data sharing features.
> **Maintainer:** QA Team + Clinical Records Domain Expert
> **Last Updated:** 2026-02-27
> **Review Status:** [ ] Verified by Domain Expert | [ ] Verified by PO

---

## How Agents Use This File

1. **Load when:** Ticket involves patient demographics, medical history, chart notes, allergies, diagnoses (ICD-10), procedures (CPT), consent management, health data sharing, or clinical documentation
2. **Cross-reference:** Check if requirements address the regulatory rules below
3. **Flag gaps:** If a patient records feature doesn't mention consent workflows, data access logging, or code validation — flag it
4. **Edge cases:** Add patient-records-specific edge cases (identity matching, duplicate detection, consent revocation, multi-facility access) to analysis
5. **Integration checks:** Verify FHIR interoperability, HL7 messaging, and external system data sharing requirements are addressed

**Trigger keywords:** patient record, medical history, chart, demographics, allergy, diagnosis, ICD-10, ICD-11, CPT, procedure code, consent, HIPAA, health information, PHI, clinical note, progress note, discharge summary, problem list, immunization, vital signs, encounter, referral

---

## Quick Reference: Regulatory Requirements

| Rule ID | Requirement | Regulation/Source | Compliance | Impact if Missed |
|---------|-------------|-------------------|------------|------------------|
| PR-REG-001 | All access to protected health information (PHI) must be logged with user, timestamp, and action type | HIPAA Security Rule (45 CFR 164.312) | Mandatory | Regulatory audit failure, potential fines |
| PR-REG-002 | Patients must be able to request access to their own health records within 30 days | HIPAA Privacy Rule (45 CFR 164.524) | Mandatory | Patient rights violation, regulatory penalty |
| PR-REG-003 | Minimum necessary standard: only disclose the minimum PHI required for the intended purpose | HIPAA Privacy Rule (45 CFR 164.502(b)) | Mandatory | Over-disclosure of sensitive health data |
| PR-REG-004 | Diagnosis codes must use current ICD-10-CM classification for claims and clinical documentation | CMS/AMA ICD-10-CM coding guidelines | Mandatory | Claim denials, incorrect clinical documentation |
| PR-REG-005 | Procedure codes must use valid CPT (Current Procedural Terminology) codes for billing and documentation | AMA CPT coding system | Mandatory | Claim denials, billing errors |
| PR-REG-006 | Patient consent must be obtained and documented before sharing PHI with third parties | HIPAA Privacy Rule (45 CFR 164.508) | Mandatory | Unauthorized disclosure, legal liability |
| PR-REG-007 | Electronic health records must support FHIR R4 interoperability for data exchange | 21st Century Cures Act / ONC Final Rule | Mandatory | Interoperability non-compliance |
| PR-REG-008 | Substance abuse treatment records require additional consent protections (42 CFR Part 2) | 42 CFR Part 2 | Mandatory | Unauthorized disclosure of addiction records |

---

## Business Rules

| Rule ID | Rule | Description | Edge Cases | Source |
|---------|------|-------------|------------|--------|
| PR-BIZ-001 | Patient identity matching | Patient lookup uses probabilistic matching on name, DOB, SSN last 4, and facility MRN to prevent duplicates and mismatches | Hyphenated names, name changes, shared DOB (twins), missing SSN | `PatientMatchingService.cs` |
| PR-BIZ-002 | Allergy severity classification | Allergies classified as Mild / Moderate / Severe / Life-threatening; life-threatening allergies trigger hard-stop alerts on medication orders | New allergy added while prescription is in progress; allergy severity reclassified | `AllergyClassification.cs` |
| PR-BIZ-003 | Problem list management | Active problems must use validated ICD-10-CM codes; resolved problems retain code but change status; deleted problems create audit trail | Code versioning when ICD-10 is updated annually; orphaned codes from deprecated classifications | `ProblemListService.cs` |
| PR-BIZ-004 | Consent scope hierarchy | Consent can be granted at Global (all records), Category (e.g., lab only), or Document level; revocation at any level cascades to child records | Partial consent (allow labs but not mental health); consent revoked while data transfer is in progress | `ConsentHierarchyService.cs` |
| PR-BIZ-005 | Chart note co-signing | Notes by residents/trainees require attending physician co-signature within 72 hours; unsigned notes are flagged and cannot be used for billing | Attending physician changes department; unsigned note past deadline; multiple co-signers needed | `ChartNoteCosignService.cs` |
| PR-BIZ-006 | Multi-facility patient record | A patient may have records at multiple facilities; each facility maintains its own record with a shared MPI (Master Patient Index) linking | Record merge when duplicate detected; record unmerge when incorrectly linked; facility-specific data access restrictions | `MasterPatientIndexService.cs` |
| PR-BIZ-007 | Clinical document versioning | Amendments to signed clinical notes create a new version while preserving the original; addenda are appended, not edits | Amendment after billing submission; multiple amendments to same note; amendment by non-original author | `ClinicalDocumentVersioning.cs` |

---

## ICD-10-CM Code Reference

### Code Structure

| Component | Format | Example | Description |
|-----------|--------|---------|-------------|
| Category | 3 characters (alpha + 2 digits) | `E11` | Type 2 diabetes mellitus |
| Subcategory | 4th-5th character after decimal | `E11.6` | With other specified complications |
| Extension | 6th-7th character | `E11.65` | With hyperglycemia |
| Laterality | Specific positions | `M79.631` | Right foot (1=right, 2=left, 9=unspecified) |

### Validation Rules

| Rule | Description | Error Handling |
|------|-------------|----------------|
| Format | Must match pattern: `[A-TV-Z][0-9][0-9](\.[0-9A-Z]{1,4})?` | Reject with "Invalid ICD-10 code format" |
| Active code | Code must be active in current fiscal year's ICD-10-CM release | Warning: "Code deprecated in current release" |
| Specificity | Claims require the most specific code available (no truncated codes) | Warning: "Code requires greater specificity for billing" |
| Decimal point | Codes with 4+ characters must include decimal after 3rd character | Auto-correct: insert decimal if missing |

---

## CPT Procedure Code Reference

### Code Ranges

| Range | Category | Examples |
|-------|----------|---------|
| 00100-01999 | Anesthesia | 00100 (anesthesia for procedures on head) |
| 10004-69990 | Surgery | 27447 (total knee replacement) |
| 70010-79999 | Radiology | 71046 (chest X-ray, 2 views) |
| 80047-89398 | Pathology/Lab | 80053 (comprehensive metabolic panel) |
| 90281-99607 | Medicine | 99213 (office visit, established patient) |
| 99202-99499 | Evaluation & Management | 99284 (ED visit, high severity) |

### Validation Rules

| Rule | Description | Error Handling |
|------|-------------|----------------|
| Format | 5 digits, no decimal | Reject with "Invalid CPT code format" |
| Active code | Code must be in current year's CPT codebook | Warning: "Code not found in current CPT release" |
| Modifier support | Modifiers (e.g., -25, -59) must be from valid modifier list | Reject invalid modifiers |

---

## Consent Workflow Rules

### Consent Types

| Type | Scope | Required For | Revocable |
|------|-------|-------------|-----------|
| Treatment Consent | Specific procedure/treatment | All clinical interventions | Yes (before procedure) |
| General PHI Consent | All health information sharing | Default on admission | Yes (any time) |
| Research Consent | De-identified data for studies | Clinical trials, research | Yes (any time) |
| Third-Party Sharing | Specific external recipient | Insurance, referrals, family access | Yes (any time) |
| Substance Abuse | Addiction/behavioral health records | Any disclosure of 42 CFR Part 2 data | Yes (any time) |
| Mental Health | Psychotherapy notes | Sharing notes with non-treating providers | Yes (any time) |

### Consent State Machine

| Current State | Allowed Transitions | Triggered By |
|--------------|-------------------|-------------|
| Not Requested | Requested | System/provider initiates |
| Requested | Granted, Declined | Patient response |
| Granted | Revoked, Expired | Patient revocation, time expiry |
| Declined | Requested (re-request) | Provider re-requests |
| Revoked | Requested (re-request) | Provider re-requests |
| Expired | Requested (renewal) | System auto-renewal prompt |

---

## Common Edge Cases (Domain-Specific)

| Scenario | Required Behavior | Regulatory Basis | Severity |
|----------|-------------------|------------------|----------|
| **Patient with no allergies vs unreported allergies** | System must distinguish between "No Known Allergies (NKA)" and "Allergies Not Assessed" — both must be explicitly recorded | Patient safety best practice | Critical |
| **Duplicate patient records detected** | Merge workflow must consolidate records without losing data; merged record retains all clinical data from both sources | MPI integrity | Critical |
| **Consent revoked during active data transfer** | In-flight data transfers must complete but no NEW transfers initiated; audit log records the timing | HIPAA Privacy Rule | Critical |
| **ICD-10 code deprecated mid-year** | Active problems using deprecated codes must flag for review; existing claims with old codes remain valid | CMS coding guidelines | High |
| **Patient identity mismatch (wrong patient record accessed)** | Hard-stop alert, force re-verification, log potential breach event | HIPAA Security Rule | Critical |
| **Chart note co-sign deadline expired** | Flag note as "unsigned past deadline"; restrict use for billing; notify attending and department head | Facility policy | High |
| **Multi-facility record access without consent** | Block access; log attempt; notify compliance officer | HIPAA Privacy Rule | High |
| **Amendment to signed clinical note** | Create new version preserving original; both versions visible; amendment clearly marked | HIPAA Privacy Rule (45 CFR 164.526) | High |
| **`FirstOrDefault()` on patient record lookups** | Any patient search using `FirstOrDefault()` MUST null-check before accessing members — patient may not exist | Defensive coding (18% of hotfixes) | High |
| **Empty allergy list vs null allergy data** | Empty list = NKA documented; null = allergies never assessed. Different clinical significance. | Patient safety | High |
| **Substance abuse record included in general query** | 42 CFR Part 2 records must be excluded from general PHI queries unless specific consent exists | 42 CFR Part 2 | Critical |

---

## Data Sharing Rules

### Who Can Access What

| Role | Demographics | Clinical Notes | Lab Results | Mental Health | Substance Abuse |
|------|-------------|----------------|-------------|---------------|-----------------|
| Treating Physician | Full | Full | Full | With consent | With 42 CFR consent |
| Nurse (assigned) | Full | Full | Full | With consent | With 42 CFR consent |
| Specialist (referral) | Summary | Relevant only | Relevant only | With consent | With 42 CFR consent |
| Billing Staff | Limited (insurance) | No | CPT codes only | No | No |
| Patient (self) | Full | Full | Full | Full (own) | Full (own) |
| Researcher | De-identified | De-identified | De-identified | With IRB + consent | With IRB + consent |
| Insurance Company | As authorized | As authorized | As authorized | With consent | With 42 CFR consent |

---

## Integration Requirements

| External System | Data Exchange | Direction | Format | Deadlines | Error Handling |
|-----------------|---------------|-----------|--------|-----------|----------------|
| **FHIR R4 APIs** | Patient demographics, allergies, conditions, medications | Both | FHIR JSON (R4) | Real-time | Retry + fallback to cached data |
| **HL7 v2 ADT** | Admission/Discharge/Transfer events | Receive | HL7 v2.x pipe-delimited | Real-time | Queue + retry; dead letter for malformed messages |
| **External EMR Systems** | Clinical document exchange (CCD/CDA) | Both | C-CDA XML | Per request | Queue + retry |
| **Master Patient Index (MPI)** | Patient identity matching | Both | HL7 PIX/PDQ or FHIR | Real-time | Retry; manual resolution for uncertain matches |
| **Insurance Eligibility** | Patient insurance verification | Receive | X12 270/271 | Before encounter | Cache + manual fallback |
| **Public Health Reporting** | Immunization records, reportable conditions | Send | HL7 VXU / eCR FHIR | Within statutory deadlines | Queue + retry |

---

## Validation Rules

| Field / Calculation | Rule | Error Handling | Regulatory Basis |
|---------------------|------|----------------|------------------|
| ICD-10 code | Must match format `[A-TV-Z][0-9][0-9](\.[0-9A-Z]{1,4})?` and exist in active codebook | Reject invalid codes; warn on deprecated codes | CMS coding guidelines |
| CPT code | Must be 5-digit code in current CPT codebook | Reject invalid codes | AMA CPT system |
| Patient DOB | Must be valid date, not in future, not more than 150 years ago | Error if invalid range | Data integrity |
| SSN (last 4) | Must be exactly 4 digits if provided; optional field | Format validation only | Data integrity |
| Allergy status | Must be one of: NKA, NKDA, Active Allergies, Not Assessed | Error if not set before medication order | Patient safety |
| Consent status | Must be Granted before any PHI disclosure to third parties | Block disclosure; log attempt | HIPAA Privacy Rule |
| Chart note signature | Must be signed by author within facility policy deadline (typically 72h) | Flag as unsigned; restrict billing use | Facility policy |
| Encounter date | Must not be in the future; must be within active encounter period | Error if outside valid range | Data integrity |
| PHI access log | Must record user ID, patient ID, timestamp, action type for every access | System error if logging fails (fail-safe) | HIPAA Security Rule |

---

## Terminology

| English Term | Abbreviation | Definition |
|-------------|-------------|------------|
| Protected Health Information | PHI | Individually identifiable health information |
| Electronic Health Record | EHR | Digital version of a patient's medical history |
| Master Patient Index | MPI | System that matches patient identities across facilities |
| Medical Record Number | MRN | Facility-specific patient identifier |
| International Classification of Diseases | ICD-10 | Diagnosis coding system (10th revision) |
| Current Procedural Terminology | CPT | Procedure/service coding system |
| Health Level 7 | HL7 | Healthcare data exchange standard |
| Fast Healthcare Interoperability Resources | FHIR | Modern healthcare API standard (R4) |
| Consolidated Clinical Document Architecture | C-CDA | Standard for clinical document exchange |
| Continuity of Care Document | CCD | Summary of patient health information |
| Admission/Discharge/Transfer | ADT | Patient movement events within a facility |
| No Known Allergies | NKA | Patient has no documented allergies |
| No Known Drug Allergies | NKDA | Patient has no documented drug allergies |
| Problem List | - | Active and resolved diagnoses for a patient |
| Progress Note | - | Clinical documentation of a patient encounter |
| Discharge Summary | - | Summary documentation when patient leaves care |
| History and Physical | H&P | Initial comprehensive patient assessment |
| Chief Complaint | CC | Primary reason for the patient encounter |

---

## Lessons from Production Bugs

| Bug | Root Cause | Domain Lesson | Pattern |
|-----|-----------|---------------|---------|
| HM-14050 | `FirstOrDefault()` returned null when patient had been transferred to another facility and record was archived | Patient record lookups must always null-check — transferred or archived patients may not return results | NULL Handling (18%) |
| HM-13822 | Allergy list returned empty array instead of null for "Not Assessed" status, causing system to treat patient as NKA | Must distinguish between empty list (NKA) and null/not-assessed — different clinical significance | Edge Cases (28%) |
| HM-14190 | Consent revocation processed but in-flight FHIR data transfer continued, sharing records after revocation | Consent state changes must be checked at point of data emission, not just at query time | Logic/Condition (16%) |
| HM-13955 | ICD-10 code `R69` (Illness, unspecified) accepted for billing claims, causing mass denials | Claims require specific codes, not unspecified; validation must enforce specificity rules for billing context | Data Validation (10%) |

---

## Agent Checklist: Patient Records Requirements

When analyzing patient records-related requirements, verify these are addressed:

- [ ] **PHI access logging:** Does the feature access patient data? If yes, is every access logged with user, timestamp, and action type?
- [ ] **Consent workflow:** Does the feature share PHI with third parties? If yes, is consent verification included?
- [ ] **ICD-10/CPT validation:** Does the feature create or modify diagnoses/procedures? If yes, are codes validated against active codebooks?
- [ ] **Allergy status handling:** Does the feature interact with allergy data? If yes, does it distinguish between NKA, NKDA, active allergies, and not assessed?
- [ ] **Patient matching:** Does the feature involve patient lookup? If yes, is the matching algorithm handling edge cases (name changes, twins, missing data)?
- [ ] **Multi-facility access:** Does the feature allow cross-facility record access? If yes, are consent and authorization checks in place?
- [ ] **42 CFR Part 2:** Does the feature touch substance abuse records? If yes, is additional consent protection enforced?
- [ ] **Chart note versioning:** Does the feature modify signed clinical notes? If yes, is amendment/addendum workflow followed?
- [ ] **Null safety on lookups:** Does the code use `FirstOrDefault()` for patient/record lookups? If yes, is null check present?
- [ ] **FHIR interoperability:** Does the feature exchange data with external systems? If yes, does it use FHIR R4 format?
- [ ] **Minimum necessary:** Does the feature expose PHI? If yes, does it limit disclosure to the minimum necessary for the purpose?

---

**File Version:** 1.0
**Created:** 2026-02-27
**Next Review:** 2026-Q2 (or after regulatory/coding updates)
