# Root Cause Analysis: HM-14205

## 1. Executive Summary

- **Bug Description:** Patient summary report's submit button was permanently disabled and provider selection did not work. The checkbox list's single-select mode (patient summary requires selecting exactly one provider) was broken — clicking a checkbox did not deselect others, count text did not update, and `checkSelectedProviderCount()` never enabled the submit button.
- **Causative PR/Commit:** HM-14180 (`cd7ef7942b`, Feb 9, 2026) — "Refactor selection count containers and toggle functionality across report menus for consistency and improved UX"
- **Root Cause Category:** Logic/Condition Errors
- **Preventability Verdict:** Preventable — unit/E2E tests for the patient summary single-select flow would have caught this immediately.

## 2. Bugfix Pattern Match

| Pattern | Match Status | Evidence |
|---------|-------------|----------|
| Edge Cases (26%) | PARTIAL | `checkSelectedProviderCount()` did not differentiate between single-select (patient summary) and multi-select (other reports) modes |
| Enum/Switch Incomplete (20%) | No Match | Not an enum issue |
| NULL Handling (18%) | No Match | Not a null reference issue |
| Logic/Condition Errors (16%) | **EXACT MATCH** | 3 logic errors: (1) C# called `FilterableCheckboxList.toggleOnClick()` directly, bypassing page override; (2) `listItem.checked !== true` checked wrong state (checkbox already toggled by browser before onclick fires); (3) `checkSelectedProviderCount()` treated all reports identically |
| Type Casting Errors (12%) | No Match | Not a type casting issue |
| Missing Implementation (8%) | PARTIAL | Centralized `filterableCheckboxList.js` did not include count text update logic that was present in the page-specific code |

**Primary Pattern:** Logic/Condition Errors (16%)
**Secondary Pattern:** Edge Cases (26%) + Missing Implementation (8%)
**Combined Score:** 50% of 2025 hotfixes match this pattern combination

**Why This Matters:** The HM-14180 refactoring centralized JavaScript checkbox logic from 3 pages into `filterableCheckboxList.js` + `HtmlFilterableCheckboxList.cs`. The centralized code only handled the common (multi-select) path correctly. The patient summary report's unique single-select behavior was not preserved because: (a) the C# control called the centralized function directly via namespace, bypassing page-level overrides, (b) the page's `toggleOnClick` had a logical condition error, and (c) `checkSelectedProviderCount()` lost its mode differentiation.

## 3. Timeline

| Event | Date | Details |
|-------|------|---------|
| Bug Introduced | 2026-02-09 | In HM-14180 commit `cd7ef7942b` (merged to Release-8/2026) |
| Bug Discovered | 2026-02-25 | Reported as HM-14205 |
| Bugfix Deployed | 2026-02-25 | In `HM-14205-Selecting-providers-on-patient-summary-report-does-not-work` (5 commits) |

## 4. Technical Root Cause

### Issue 1: C# control bypassed page-level function overrides

**Original Code (Buggy) — `HtmlFilterableCheckboxList.cs:132`:**
```csharp
toggleOnClickCall = "javascript:FilterableCheckboxList.toggleOnClick(this.getElementsByTagName('input')[0], ...)"
```

**Fixed Code — `HtmlFilterableCheckboxList.cs:132`:**
```csharp
toggleOnClickCall = "javascript:toggleOnClick(this.getElementsByTagName('input')[0], ...)"
```

The C# control emitted `FilterableCheckboxList.toggleOnClick()` (namespaced call), which always invoked the centralized code. `reportmenu.aspx` defines its own `toggleOnClick()` at global scope to handle single-select mode, but the namespaced call bypassed it entirely. The fix calls `toggleOnClick()` (global), allowing page overrides to work. A global fallback in `filterableCheckboxList.js` catches pages without overrides.

### Issue 2: Wrong condition in single-select logic

**Original Code (Buggy) — `reportmenu.aspx:488`:**
```javascript
if (allowSelectMultipleProviders === false && listItem.checked !== true) {
    for (const itemCheckbox of itemCheckboxes) {
        itemCheckbox.checked = "";
    }
}
```

**Fixed Code — `reportmenu.aspx:467`:**
```javascript
if (allowSelectMultipleProviders === false && listItem.name === 'providerid') {
    for (const itemCheckbox of itemCheckboxes) {
        if (itemCheckbox !== listItem && itemCheckbox.parentElement.value !== 1) {
            itemCheckbox.checked = false;
        }
    }
}
```

The `listItem.checked !== true` condition was logically wrong — when the browser fires `onclick`, the checkbox has **already been toggled**. So clicking to **check** a checkbox meant `listItem.checked` was already `true`, causing the condition to be `false`, and other checkboxes were never deselected. The fix uses `listItem.name === 'providerid'` to determine when single-select logic should apply, and excludes the clicked item from being unchecked.

### Issue 3: checkSelectedProviderCount() was mode-agnostic

**Original Code (Buggy):** Applied the same disabled/visible logic regardless of `allowSelectMultipleProviders`.

**Fixed Code:** Added `if (allowSelectMultipleProviders === false)` branch for patient summary, `else` for other reports where the submit button should always be enabled.

## 5. 5 Whys Analysis

1. **Why** was the submit button always disabled? → `checkSelectedProviderCount()` never detected a checked provider because the checkbox selection logic was broken.
2. **Why** was checkbox selection broken? → `HtmlFilterableCheckboxList.cs` called `FilterableCheckboxList.toggleOnClick()` (namespaced), bypassing the page's custom `toggleOnClick` that handled single-select mode.
3. **Why** did the C# code call the namespaced function? → The HM-14180 refactoring centralized the code but didn't account for pages needing custom overrides of `toggleOnClick`/`toggleAll`.
4. **Why** wasn't this caught during refactoring? → No automated tests exist for the patient summary report's provider selection flow — the single-select mode was only manually testable.
5. **Why** are there no tests for this flow? → **Systemic root cause:** Clinical report pages with JavaScript-heavy UI interactions have no E2E test coverage in any framework.

## 6. Preventability Assessment

| Layer | Could Prevent | Gap |
|-------|--------------|-----|
| Unit Tests | No | Bug is in client-side JavaScript interaction between C#-emitted onclick handlers and page-level overrides — not unit-testable |
| Integration Tests | No | Requires browser rendering to test onclick handler resolution |
| E2E Automated Tests | Yes | A Playwright test selecting a provider on the patient summary report and verifying submit button becomes enabled would catch this immediately |
| Manual Acceptance | Yes | Testing the patient summary report with provider selection was not part of the HM-14180 acceptance criteria |
| Code Review | Yes | Reviewer should have caught that `FilterableCheckboxList.toggleOnClick()` bypasses page overrides, and that `listItem.checked !== true` checks post-toggle state |
| Requirements | No | The refactoring requirements were correct; the implementation had logic errors |

## 7. Recommendations

1. **Add Playwright E2E test** for patient summary report: Select report type → select single provider → verify submit button enables → verify only one provider is selected at a time
2. **Add code review checklist item**: When refactoring shared JavaScript controls, verify that all consuming pages' custom overrides are still invoked (search for global-scope function definitions that override centralized ones)
3. **Add regression test for `reportmenu.aspx`**: Test both `allowSelectMultipleProviders = true` (normal reports) and `allowSelectMultipleProviders = false` (patient summary) paths
4. **Pattern prevention**: When centralizing page-specific JavaScript into shared modules, always test pages that had custom overrides of the extracted functions
