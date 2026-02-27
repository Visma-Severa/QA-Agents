# E2E Test Recommendations: HM-14205

## 1. Summary

HM-14205 exposed a gap in E2E test coverage for the **clinical report menu** (`WebInterface/clinical/report/reportmenu.aspx`), specifically the **patient summary report** flow. The page has two distinct behavioral modes:
- **Multi-select** (most reports): Select multiple providers, submit button always enabled
- **Single-select** (patient summary): Select exactly one provider, submit button disabled until selection

No E2E tests exist for either mode. The bug (submit button always disabled, single-select not working) went undetected for 16 days. Playwright is the correct framework since this is in the Clinical Reports functional area.

## 2. Existing Coverage Analysis

| Repository | Existing Tests | Coverage Status |
|------------|---------------|-----------------|
| Selenium | None found for clinical reports | N/A — Clinical Reports is outside Selenium scope |
| Playwright | `SeparateReportsPage.ts` exists for monthly compliance reports; no tests for patient summary or report menu provider selection | Gap — Framework covers Clinical but missing report menu tests |
| Mobile | No relevant tests | N/A — Patient summary is desktop-only |

**Fetched latest from E2E test repositories.**

### Existing Playwright Infrastructure

The Playwright repo already has:
- Navigation to clinical reports: `navbarUtils.ts:178` → `clickSeparateReportsLink()`
- Page object for separate reports: `pages/clinical/separate_reports/separateReportsPage.ts`
- Test that navigates to separate reports: `08_monthly_compliance.spec.ts:272`

**Gap:** No page object for the report menu (`reportmenu.aspx`) and no tests for:
- Report type selection (patient summary vs other reports)
- Provider checkbox list behavior
- Submit button enable/disable logic
- Single-select vs multi-select mode switching

## 3. Recommended Test Scenarios

### Scenario 1: Patient Summary - Provider Selection Enables Submit Button

- **Priority:** P0 (Critical — direct regression from HM-14205)
- **Repository:** Playwright (HealthBridge-E2E-Tests)
- **Preconditions:**
  - Clinic with at least 2 providers who have patient data
  - User logged in with clinical report access
- **Steps:**
  1. Navigate to Clinical → Reports
  2. Select "Patient summary" from report type dropdown
  3. Verify submit button is disabled (no provider selected)
  4. Click on first provider checkbox in the provider list
  5. Verify submit button becomes enabled
  6. Verify the selected provider count shows "Selected: 1"
- **Expected Result:** Submit button is enabled after selecting one provider

### Scenario 2: Patient Summary - Single Select Mode (Only One Provider at a Time)

- **Priority:** P0 (Critical — direct regression from HM-14205)
- **Repository:** Playwright (HealthBridge-E2E-Tests)
- **Preconditions:**
  - Clinic with at least 3 providers
  - User on patient summary report
- **Steps:**
  1. Navigate to Clinical → Reports → select "Patient summary"
  2. Select Provider A
  3. Verify Provider A is checked, submit button enabled
  4. Select Provider B
  5. Verify Provider A is unchecked, Provider B is checked
  6. Verify submit button remains enabled (one provider still selected)
- **Expected Result:** Only one provider can be selected at a time in patient summary mode

### Scenario 3: Multi-Select Report - Multiple Providers

- **Priority:** P1 (Important — validates the other mode works)
- **Repository:** Playwright (HealthBridge-E2E-Tests)
- **Preconditions:**
  - Clinic with at least 3 providers
  - User on a multi-select report (e.g., appointment journal)
- **Steps:**
  1. Navigate to Clinical → Reports → select a multi-select report type
  2. Select Provider A
  3. Select Provider B
  4. Verify both Provider A and B are checked
  5. Verify submit button is enabled
  6. Verify count shows "Selected: 2"
- **Expected Result:** Multiple providers can be selected, submit button always enabled

### Scenario 4: Report Type Switch - Mode Transition

- **Priority:** P1 (Important — validates mode switching)
- **Repository:** Playwright (HealthBridge-E2E-Tests)
- **Preconditions:**
  - Clinic with providers
  - User on report menu
- **Steps:**
  1. Select a multi-select report type
  2. Select 3 providers
  3. Verify submit button enabled, count shows "Selected: 3"
  4. Switch to "Patient summary"
  5. Verify all providers are deselected
  6. Verify submit button becomes disabled
  7. Select one provider
  8. Verify submit button becomes enabled
- **Expected Result:** Switching to patient summary clears selections and switches to single-select mode

### Scenario 5: Toggle All - Patient Summary Mode

- **Priority:** P2 (Medium — edge case)
- **Repository:** Playwright (HealthBridge-E2E-Tests)
- **Preconditions:**
  - Clinic with providers, patient summary report selected
- **Steps:**
  1. Navigate to Clinical → Reports → select "Patient summary"
  2. Click "Select all" / toggle all checkbox
  3. Verify behavior is appropriate for single-select mode (all deselected or only first selected)
  4. Verify submit button state is correct
- **Expected Result:** Toggle all in single-select mode does not leave submit button in broken state

## 4. Implementation Code

### Page Object: ReportMenuPage

```typescript
// pages/clinical/reports/reportMenuPage.ts
import { type Page, type Locator } from "@playwright/test"

export default class ReportMenuPage {
  readonly page: Page
  readonly reportTypeDropdown: Locator
  readonly submitReportButton: Locator
  readonly noProviderSelectedMessage: Locator
  readonly providerCheckboxes: Locator
  readonly selectAllProvidersCheckbox: Locator
  readonly providersCountContainer: Locator

  constructor(page: Page) {
    this.page = page
    this.reportTypeDropdown = page.locator("#reportselect")
    this.submitReportButton = page.locator("#submitReportButton")
    this.noProviderSelectedMessage = page.locator("#noproviderselected")
    this.providerCheckboxes = page.locator("input[name='providerid']")
    this.selectAllProvidersCheckbox = page.locator("#selectAllProviders")
    this.providersCountContainer = page.locator("[name='providerscountcontainer']")
  }

  public async selectReportType(value: string): Promise<void> {
    await this.reportTypeDropdown.selectOption(value)
    // Wait for UI to update after report type change
    await this.page.waitForTimeout(500)
  }

  public async selectPatientSummary(): Promise<void> {
    // Value "8" corresponds to patient summary
    await this.selectReportType("8")
  }

  public async selectAppointmentJournal(): Promise<void> {
    // Value "1" corresponds to appointment journal (a multi-select report)
    await this.selectReportType("1")
  }

  public async clickProvider(index: number): Promise<void> {
    const checkboxes = this.page.locator(
      "input[name='providerid']:not([id='selectAllProviders'])"
    )
    // Click the parent li to trigger the onclick handler (same as user interaction)
    const parentLi = checkboxes.nth(index).locator("..")
    await parentLi.click()
  }

  public async getCheckedProviderCount(): Promise<number> {
    const checkboxes = this.page.locator("input[name='providerid']:checked")
    return await checkboxes.count()
  }

  public async isSubmitEnabled(): Promise<boolean> {
    return !(await this.submitReportButton.isDisabled())
  }
}
```

### Test File: Patient Summary Report Tests

```typescript
// tests/09_patient_summary_report.spec.ts
import { test, expect } from "@playwright/test"
import LoginPage from "../pages/loginPage"
import NavbarUtils from "../pages/navbarUtils"
import ReportMenuPage from "../pages/clinical/reports/reportMenuPage"

test.describe.serial("09 Patient Summary Report Tests", () => {
  let loginPage: LoginPage
  let navBarUtils: NavbarUtils
  let reportMenuPage: ReportMenuPage

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page)
    navBarUtils = new NavbarUtils(page)
    reportMenuPage = new ReportMenuPage(page)

    await loginPage.login()
    // Navigate to clinical reports
    await navBarUtils.clickClinicalLink()
    // Navigate to report menu page
    await page.goto("/clinical/report/reportmenu.aspx")
  })

  test("01 Patient summary - selecting provider enables submit button", async () => {
    await test.step("Select patient summary report type", async () => {
      await reportMenuPage.selectPatientSummary()
    })

    await test.step("Verify submit button is disabled initially", async () => {
      expect(await reportMenuPage.isSubmitEnabled()).toBe(false)
    })

    await test.step("Select first provider", async () => {
      await reportMenuPage.clickProvider(0)
    })

    await test.step("Verify submit button becomes enabled", async () => {
      expect(await reportMenuPage.isSubmitEnabled()).toBe(true)
    })
  })

  test("02 Patient summary - only one provider selectable at a time", async () => {
    await test.step("Select patient summary report type", async () => {
      await reportMenuPage.selectPatientSummary()
    })

    await test.step("Select first provider", async () => {
      await reportMenuPage.clickProvider(0)
      expect(await reportMenuPage.getCheckedProviderCount()).toBe(1)
    })

    await test.step("Select second provider - first should be deselected", async () => {
      await reportMenuPage.clickProvider(1)
      expect(await reportMenuPage.getCheckedProviderCount()).toBe(1)
      expect(await reportMenuPage.isSubmitEnabled()).toBe(true)
    })
  })

  test("03 Multi-select report - multiple providers can be selected", async () => {
    await test.step("Select a multi-select report type", async () => {
      await reportMenuPage.selectAppointmentJournal()
    })

    await test.step("Select multiple providers", async () => {
      await reportMenuPage.clickProvider(0)
      await reportMenuPage.clickProvider(1)
      expect(await reportMenuPage.getCheckedProviderCount()).toBe(2)
    })

    await test.step("Verify submit button is enabled", async () => {
      expect(await reportMenuPage.isSubmitEnabled()).toBe(true)
    })
  })

  test("04 Switching from multi-select to patient summary resets selections", async () => {
    await test.step("Start with multi-select report and select providers", async () => {
      await reportMenuPage.selectAppointmentJournal()
      await reportMenuPage.clickProvider(0)
      await reportMenuPage.clickProvider(1)
      expect(await reportMenuPage.getCheckedProviderCount()).toBe(2)
    })

    await test.step("Switch to patient summary", async () => {
      await reportMenuPage.selectPatientSummary()
    })

    await test.step("Verify selections reset and submit disabled", async () => {
      expect(await reportMenuPage.getCheckedProviderCount()).toBe(0)
      expect(await reportMenuPage.isSubmitEnabled()).toBe(false)
    })

    await test.step("Select one provider - submit should enable", async () => {
      await reportMenuPage.clickProvider(0)
      expect(await reportMenuPage.isSubmitEnabled()).toBe(true)
    })
  })
})
```

## 5. Regression Suite Integration

### Integration Steps

1. **Create page object:** `pages/clinical/reports/reportMenuPage.ts` — Place alongside existing `separateReportsPage.ts`
2. **Create test file:** `tests/09_patient_summary_report.spec.ts` — Follows the existing numbering convention (after `08_monthly_compliance`)
3. **Add navigation helper:** Add a `clickReportsLink()` method to `navbarUtils.ts` for navigating to the clinical report menu
4. **Test data requirements:**
   - Existing test clinic must have at least 2-3 providers with patient data
   - The clinic must have the patient summary report enabled
5. **CI/CD:** Tests will run in the existing Playwright GitHub Actions workflow — no infrastructure changes needed

### Priority Implementation Order

| Priority | Test | Effort | Prevents |
|----------|------|--------|----------|
| P0 | Scenario 1 (submit button enable) | Low | HM-14205 exact regression |
| P0 | Scenario 2 (single-select mode) | Low | HM-14205 exact regression |
| P1 | Scenario 3 (multi-select mode) | Low | Validates normal path |
| P1 | Scenario 4 (mode switching) | Medium | Transition edge cases |
| P2 | Scenario 5 (toggle all in single-select) | Low | Edge case coverage |

**Estimated total effort:** 1-2 days (page object + 4-5 tests + CI integration)
