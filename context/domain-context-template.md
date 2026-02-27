# Domain: [Area Name] — Agent Context

> **Purpose:** Provides domain-specific regulatory, business, and compliance knowledge for QA agent analysis.
> **Used by:** Requirements Analysis, Code Review, Acceptance Tests agents — when analyzing features in this domain.
> **Maintainer:** QA Team + Domain Expert
> **Last Updated:** YYYY-MM-DD
> **Review Status:** [ ] Verified by Domain Expert | [ ] Verified by PO

---

## How Agents Use This File

1. **Identify functional area** from the ticket (e.g., Prescriptions, Patient Records, Staff Scheduling)
2. **Load matching domain file:** `context/domain-<area>.md`
3. **Cross-reference requirements** against regulatory rules and business rules below
4. **Flag gaps** where requirements don't address mandatory domain constraints
5. **Include domain-specific edge cases** in analysis that generic checks would miss

**Decision Logic:**
- Ticket mentions [area keywords]? → Load this file
- Requirements touch [external system]? → Check Integration Requirements section
- Feature involves [calculations/dates/amounts]? → Check Validation Rules section
- Feature has [compliance deadlines]? → Check Compliance Calendar section

---

## Quick Reference: Regulatory Requirements

> List mandatory legal/regulatory rules that features in this domain MUST comply with.

| Rule ID | Requirement | Regulation/Source | Compliance Level | Impact if Missed |
|---------|-------------|-------------------|------------------|------------------|
| REG-001 | [What must the system do?] | [Law/regulation name, e.g., HIPAA, FDA 21 CFR Part 11, CMS CoP] | Mandatory / Recommended | [Regulatory citation / Patient safety risk / Financial penalty] |
| REG-002 | [What must the system do?] | [Law/regulation name] | Mandatory / Recommended | [Regulatory citation / Patient safety risk / Financial penalty] |

---

## Business Rules

> Domain-specific business rules that may not be in requirements but are assumed knowledge.

| Rule ID | Rule | Description | Edge Cases | Source |
|---------|------|-------------|------------|--------|
| BIZ-001 | [Rule name] | [What the system must enforce] | [Known edge cases] | [Internal policy / Industry standard / Source file] |
| BIZ-002 | [Rule name] | [What the system must enforce] | [Known edge cases] | [Internal policy / Industry standard / Source file] |

---

## Common Edge Cases (Domain-Specific)

> Scenarios that generic edge case checklists miss but are critical in this domain.

| Scenario | Required Behavior | Regulatory Basis | Severity if Missed |
|----------|-------------------|------------------|--------------------|
| [Domain-specific scenario, e.g., "Prescription for controlled substance with no DEA number on file"] | [What should happen, e.g., "Block e-prescribing; require manual verification"] | [Regulation or N/A, e.g., "DEA Schedule II-V rules"] | Critical / High / Medium |
| [Domain-specific scenario] | [What should happen] | [Regulation or N/A] | Critical / High / Medium |

---

## Integration Requirements

> External systems this domain interacts with and their constraints.

| External System | Data Exchange | Direction | Format | Deadlines | Error Handling |
|-----------------|---------------|-----------|--------|-----------|----------------|
| [System name, e.g., "State Prescription Drug Monitoring Program (PDMP)"] | [What data?, e.g., "Controlled substance dispensing records"] | Send / Receive / Both | [HL7/FHIR/X12/JSON/CSV] | [When?, e.g., "Within 24 hours of dispensing"] | [Retry / Queue / Fail] |

---

## Validation Rules

> Domain-specific validation that goes beyond generic field validation.

| Field / Calculation | Rule | Error Handling | Regulatory Basis |
|---------------------|------|----------------|------------------|
| [Field or calculation name, e.g., "Medication dosage"] | [Specific validation rule, e.g., "Must be within therapeutic range for patient weight/age"] | [What to show user, e.g., "Warning: dosage exceeds recommended range"] | [Regulation or business rule, e.g., "Clinical safety protocol"] |

---

## Compliance Calendar

> Recurring deadlines that features in this domain must respect.

| What | When | Who Reports | Penalty for Late | System Impact |
|------|------|-------------|------------------|---------------|
| [Reporting obligation, e.g., "PDMP reporting"] | [Deadline, e.g., "24 hours after dispensing"] | [Pharmacist / Clinician / System auto] | [Consequence, e.g., "State regulatory fine"] | [What system must do, e.g., "Auto-submit after dispensing event"] |

---

## Terminology

> Domain-specific terms with abbreviations and definitions for the health management domain.

| English Term | Abbreviation | Definition |
|-------------|-------------|------------|
| [Term, e.g., "Drug Enforcement Administration"] | [DEA] | [Brief definition, e.g., "Federal agency regulating controlled substances"] |

---

## File Naming Convention

Domain context files follow the pattern: `domain-<area>.md`

| Functional Area | File Name | Keywords (trigger loading) |
|-----------------|-----------|---------------------------|
| [Area, e.g., "Prescriptions"] | `domain-prescriptions.md` | [keyword1, keyword2, keyword3, e.g., "prescription, medication, dosage, refill, e-prescribing"] |

---

## Maintenance Notes

**When to update this file:**
- Regulatory changes (new laws, updated deadlines, changed thresholds)
- New business rules discovered from production incidents
- Domain expert review reveals inaccuracies
- New external system integrations added

**Review cadence:** Quarterly or after any regulatory change

**`[VERIFY]` tags:** Items marked `[VERIFY]` need domain expert confirmation before being treated as authoritative. Agents should still flag these items in analysis but note the verification status.

---

**Template Version:** 1.0
**Created:** 2026-02-27
