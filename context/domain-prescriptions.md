# Domain Context: Prescriptions & Medications

Use this file when analyzing features related to prescriptions, medications, pharmacy, or e-prescription integrations. This context applies to changes in any repository (HealthBridge-Web, HealthBridge-Api, HealthBridge-Mobile) that touch prescription-related functionality.

---

## Regulatory Requirements

All prescription-related features must comply with the following regulations:

- **Licensed Prescriber Requirement**: All prescriptions must be signed by a licensed physician with a valid, non-expired medical license. The system must verify license status at the time of signing.
- **Controlled Substance Authorization**: Controlled substances (Schedule II-V) require additional authorization, including prescriber DEA number validation and patient identity verification.
- **National e-Prescription Registry Compliance**: Electronic prescriptions must conform to the National e-Prescription Registry message format (version 3.2+). Non-compliant messages are rejected at the registry.
- **Audit Trail**: Every prescription action (create, modify, cancel, dispense) must be logged with timestamp, actor, and reason. Audit logs are immutable.
- **Prescription Validity Periods**:
  - Standard medications: 12 months from issue date
  - Controlled substances: 30 days from issue date
  - Antibiotics: 10 days from issue date
  - Emergency prescriptions: 72 hours from issue date

---

## Business Rules

| Rule | Description | Edge Cases |
|------|-------------|------------|
| Dosage Calculation | Calculated based on patient weight, age, and condition. System suggests dosage range; prescriber confirms or overrides with documented reason. | Pediatric patients (weight-based), elderly (reduced clearance), renal impairment (adjusted dosage) |
| Drug Interactions | System cross-checks all active medications for the patient, including over-the-counter and supplements. Severity levels: Critical (block), Warning (confirm), Info (display). | Single medication still requires supplement check; interactions across multiple prescribers |
| Prescription Renewal | Chronic medications eligible for auto-renewal. System generates renewal 14 days before expiry. Prescriber must approve within 7 days or prescription lapses. | Insurance expiry before renewal date, dosage change during renewal period, prescriber license expiry |
| Generic Substitution | Pharmacist may substitute generic equivalent unless prescriber flags "Dispense as Written" (DAW). Patient allergy to inactive ingredients in generic must be checked. | Brand-only flags on prescription, patient allergy to filler/dye in generic, insurance covers only generic |
| Partial Dispensing | Pharmacist may partially dispense if full quantity unavailable. Remaining balance tracked for pickup within 72 hours. | Controlled substances cannot be partially dispensed; insurance billing for partial quantity |
| Prescription Transfer | Patient may request transfer to another pharmacy. Original pharmacy deactivates; receiving pharmacy activates. Only one active instance allowed. | Controlled substance transfer restrictions; cross-state transfer rules; pending partial dispense |

---

## Data Validation Rules

| Field | Validation | Error Message |
|-------|------------|---------------|
| Dosage | Numeric, greater than 0, less than or equal to max dosage for the specific drug | "Invalid dosage: must be between 0 and {max}" |
| Frequency | Enum value: daily, twice-daily, three-times-daily, weekly, bi-weekly, monthly, as-needed | "Invalid frequency" |
| Duration | 1-365 days for standard medications, 1-30 days for controlled substances, 1-10 days for antibiotics | "Duration exceeds maximum for this drug type" |
| Prescriber ID | Must be a valid medical license number, must not be expired, must have prescribing privileges | "Prescriber license expired or invalid" |
| Patient ID | Must match an active patient record, must not be a deceased or discharged patient | "Patient record not found or inactive" |
| Drug Code | Must exist in the approved drug formulary, must not be a recalled drug | "Drug not found in formulary or has been recalled" |
| Quantity | Positive integer, must not exceed 90-day supply for standard or 30-day supply for controlled | "Quantity exceeds maximum supply limit" |
| Pharmacy ID | Must be a registered pharmacy with active license | "Pharmacy not registered or license inactive" |

---

## Integration Points

The prescription module integrates with the following external and internal systems:

- **National e-Prescription Registry**: Submit new prescriptions, query prescription history, receive cancellation confirmations. Uses XML-based message format with digital signature. Timeout: 30 seconds.
- **Insurance Provider API**: Coverage verification before dispensing (real-time check). Returns: covered/not-covered/prior-auth-required. Must handle timeout gracefully (default to manual verification).
- **Pharmacy Inventory System**: Stock availability check before dispensing. Returns quantity on hand and expected restock date. Internal system, synchronous call.
- **Patient Allergy Database**: Cross-reference patient allergies before prescribing. Includes drug allergies, ingredient allergies, and reported sensitivities. Must be checked even for renewals (new allergies may have been recorded).
- **Drug Interaction Database**: Third-party service providing interaction severity data. Updated weekly. Cache locally with 24-hour TTL.
- **Prescriber License Registry**: External government registry to verify prescriber credentials. Checked at prescription signing and during scheduled nightly batch verification.

---

## Common Edge Cases (for Testing)

- Patient with no insurance --> cash payment workflow must be triggered; system must not block dispensing
- Drug recalled after prescription issued --> system must send notification to patient and prescriber; prescription must be flagged but not auto-cancelled (prescriber decides)
- Prescription transferred between pharmacies --> original must be deactivated atomically with activation at receiving pharmacy; race condition if both dispense simultaneously
- Multiple prescribers for same patient --> drug interaction check must aggregate medications across ALL prescribers, not just the current one
- Prescription for patient under 18 --> guardian consent required; guardian must be linked in patient record; if no guardian on file, block prescription
- After-hours emergency prescription --> temporary 72-hour authorization; must be confirmed by licensed prescriber within the validity window or auto-expires
- Prescriber license expires between prescription creation and dispensing --> dispensing must re-verify prescriber license; if expired, flag for review
- Patient allergy added after prescription created but before dispensing --> allergy check must run at dispense time, not only at creation time
- e-Prescription Registry downtime --> queue prescription for retry; allow manual override with documented reason; retry queue must process in FIFO order
- Duplicate prescription detection --> same drug, same patient, overlapping date range from different prescribers must trigger a warning

---

## Agent Checklist

When analyzing prescription-related features, verify the following:

- [ ] Check dosage validation against drug database limits (not hardcoded values)
- [ ] Verify drug interaction checks are comprehensive (all active medications, supplements)
- [ ] Confirm e-Prescription message format compliance (version 3.2+)
- [ ] Test controlled substance additional authorization flow (DEA number, patient verification)
- [ ] Validate prescription expiry date calculations for each drug type category
- [ ] Check insurance coverage verification is called before dispensing
- [ ] Verify audit trail logging for all prescription state changes
- [ ] Test partial dispensing logic and remaining balance tracking
- [ ] Confirm allergy checks run at both creation and dispensing time
- [ ] Validate prescriber license verification at signing time
- [ ] Check generic substitution respects DAW flags and patient allergies
- [ ] Test prescription transfer atomicity (no duplicate active prescriptions)
