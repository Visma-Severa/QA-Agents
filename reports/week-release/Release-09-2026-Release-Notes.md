# HealthBridge Release Notes - Release 09/2026

**Release Date:** Week 9, 2026
**Version:** Release-09/2026

---

## Highlights

- **New Prescription Handling UI** - A redesigned prescription management experience for viewing, editing, and uploading prescriptions directly in HealthBridge
- **Smarter Automation Rule Copying** - Copy referral automation rules between companies with automatic mapping and category matching
- **Improved Referral Overview** - See allocated credit notes directly in the "Referrals to be checked" view

---

## What's New and Improved

### Referrals & Prescriptions

- **Open Prescriptions Management** (HM-14211) - You can now view, create, edit, and delete prescriptions from a dedicated prescription handling page. Upload prescription images by dragging and dropping files, and manage prescription line items with copay calculations directly in the interface.

- **Automation Rule Copying Enhancements** (HM-14278, HM-14279) - When copying referral automation rules to another company, the system now automatically matches categories by mapping codes and dimensions by name. You'll also see a detailed result summary showing which rules were copied successfully and which encountered issues.

- **Credit Note Visibility in Approval** (HM-14267) - The "Referrals to be checked" view now shows which referrals have allocated credit notes, making it easier to identify referrals that have already been partially or fully credited.

- **Order Dimensions** (HM-14249) - Fixed an issue where dimensions attached to order lines were not displayed correctly when the order had no linked referrals yet.

### Clinical Data & Reporting

- **Clinical Statement and Balance Sheet Accuracy** (HM-14233) - Improved rounding precision when importing clinical data, preventing small decimal discrepancies between the clinical statement and balance sheet totals.

- **Insurance Form 6b** (HM-14210) - Fixed an error that occurred when opening insurance form 6b in certain configurations.

- **Category List Editing** (HM-14283) - Fixed an issue where changes could not be saved in the category list view for newly created companies.

### Appointments & Scheduling

- **MediCollect Appointment Due Date Editing** (HM-14227) - You can now change the due date on appointments that are in collection with HealthBridge MediCollect, subject to a minimum tolerance period.

### Store & Subscriptions

- **Starter Package Stability** (HM-14253) - Fixed an issue where special needs associated with the Starter package could be incorrectly deactivated when re-selecting the same package in the store.

### Security

- **Dependency Security Update** (HM-14261) - Updated Microsoft.SemanticKernel.Core to address a critical security vulnerability.

---

## User Interface Changes

### New UI Elements
- New **Open Prescriptions** list page with search, filtering, and bulk actions
- New **Prescription Edit** page with line item management and prescription image display
- Prescription **file upload** with drag-and-drop support (JPG, PNG, PDF)
- **Copy Results Modal** for automation rule copying -- shows per-company and per-rule results

### Improved UI Elements
- Referral "Referrals to be checked" widget now displays credit note allocation status
- Automation rule copy dialog now includes mapping and category linking options

---

## Bug Fixes

- **Referrals**: Fixed missing dimensions on order lines when no referral was linked yet (HM-14249)
- **Insurance**: Fixed an error when opening insurance form 6b with non-integer element values (HM-14210)
- **Clinical Data**: Fixed rounding discrepancies in imported clinical data causing statement / balance sheet mismatch (HM-14233)
- **Category List**: Fixed inability to save changes in category list for fresh companies (HM-14283)
- **Store**: Fixed incorrect deactivation of Starter package special needs during re-selection (HM-14253)

---

## Technical Notes

- **Database Migration:** Schema changes for prescription handling -- 2 new tables (`MedicalPrescriptionCopay`, `MedicalPrescriptionRow`), columns added/modified on `MedicalPrescription` and `LinkedCard` tables
- **Feature Flag:** Open Prescriptions UI is gated behind the `NewPrescriptionHandling` company special need

---

**Need Help?** Contact HealthBridge Support
**Documentation:** https://support.healthbridge.app

*Release notes generated for Release-09/2026*
