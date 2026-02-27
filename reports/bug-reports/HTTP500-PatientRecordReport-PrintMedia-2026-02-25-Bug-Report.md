# Bug Report: HTTP 500 - Patient Record Report Print Media Handler Crash

**Detected:** 2026-02-25
**Branch/Version:** master (staging: stg.healthbridge.app)
**Repository:** HealthBridge-Web
**Severity:** Medium
**Complexity:** Medium
**Hotfix Pattern:** 28% Edge Case (unhandled server-side error in print handler)

---

## 1. Error Summary

HTTP 500 Internal Server Error occurs when users attempt to print Patient Record Reports (Patient record summaries). The print media handler `chprintmedia.asp` crashes when processing `pr_reportscase.asp` as the target page, rendering a blank page with empty title (`HealthBridge :: `) and full navigation shell but no content.

---

## 2. Steps to Reproduce

**Preconditions:**
- User with clinical data / medical records access rights
- Company with active patient records (PatientCategory entries)
- Staging environment: stg.healthbridge.app

**Steps:**
1. Navigate to Medical Records > Patient Record Reports (`ClinicalData/Report/pr_reports.asp`)
2. Trigger print view (adds `view=noh` to URL, which rights.asp auto-redirects to `chprintmedia.asp`)
3. Observe HTTP 500 error with blank page

**Stability:** Needs verification (observed on staging 2026-02-25T10:08:37Z, CompanyID 131563)

---

## 3. Expected vs. Actual Behaviour

**Expected Behaviour:**
Print format selection page displays with HTML/PDF export options for Patient Record Reports.

**Actual Behaviour:**
Server returns HTTP 500. Page renders navigation shell with empty title `HealthBridge :: ` and no content area. No user-facing error message displayed.

---

## 4. Root Cause Analysis (Medium Confidence - 65%)

**Affected Files:**
- `wwwroot/tableui/print/chprintmedia.asp` - Print media handler
- `wwwroot/tableui/ClinicalData/Report/pr_reports.asp:8` - Sets `this_setpage = "ClinicalData/Report/pr_reportscase.asp"`

**Root Cause:**
The error occurs in `chprintmedia.asp` after the page header renders. The handler performs a `SystemPage` lookup against the `Page` table in the Reference database, then reads the target file from disk via `FileSystemObject`. The 500 error likely originates from one of:

1. **Page not registered** in `Page` table for `pr_reportscase.asp` - `send_simple_Error()` may fail if translation key is missing
2. **`CLng(pageObj.ArchitechtureID)`** fails on unexpected DB value
3. **File system read failure** when `fso.OpenTextFile()` encounters path/permission issues on staging

**Code Snippet:**
```asp
' chprintmedia.asp - Potential failure points
Set pageObj = New SystemPage
pageObj.pageidentification = pid          ' "ClinicalData/Report/pr_reportscase.asp"
If Not pageObj.search Then
    send_simple_Error(dict("eisivua"))    ' Could fail if translation missing
End If
pageObj.Movenext
...
If CLng(pageObj.ArchitechtureID) = 2 Then ' CLng fails on unexpected value
```

**Server-side logs (IIS/Datadog/SystemError table) required for definitive root cause.**

---

## 5. Impact Assessment

**Severity Justification:**
Medium - Patient Record Report printing is a secondary feature. Users can still view reports on-screen; only the print/export workflow is broken.

**User Impact:** Medium
**Estimated Affected Users:** ~5-10% (users who print patient record reports)
**Data Integrity Risk:** No (read-only print operation)
**Regression Risk:** Low (legacy code, unchanged since initial import)
**Workaround Available:** Yes - View reports on-screen and use browser Print (Ctrl+P) instead

**Affected Features:**
- Patient Record Report printing (PDF/HTML export)
- Potentially other legacy Classic ASP report print handlers using `chprintmedia.asp`

---

## 6. Recommended Fix

**Fix Approach:**
1. Check server-side logs to identify the exact error line
2. Add defensive error handling in `chprintmedia.asp` around `SystemPage` lookup and `FileSystemObject` operations
3. Verify `pr_reportscase.asp` is registered in the `Page` table on staging

**Estimated Effort:** 0.5-1 day (pending log analysis)

**Files to Change:**
- `wwwroot/tableui/print/chprintmedia.asp` - Add `On Error Resume Next` with proper error reporting
- Potentially: Reference database `Page` table - Add missing page registration

**Suggested Code Change:**
```asp
Set pageObj = New SystemPage
pageObj.pageidentification = pid
If Not pageObj.search Then
    send_simple_Error("Page not found: " & Server.HTMLEncode(pid))
    Response.End
End If
```

**Prevention:**
- [ ] Verify all printable ASP pages are registered in the Page table
- [ ] Add structured error logging to `chprintmedia.asp` (log to SystemError table)
- [ ] Add E2E test for printing patient record reports

---

## 7. Test Data & Configuration

**Test Account:**
- User with Medical Records rights
- Company with active patient records (PatientCategory entries with `IsHidden <> 1`)

**Test Data:**
```sql
-- Verify patient records exist for test company
SELECT ID, Name FROM PatientCategory WHERE IsHidden <> 1 AND CompanyID = <CompanyID>
-- Verify page registration
SELECT * FROM Page WHERE PageIdentification = 'ClinicalData/Report/pr_reportscase.asp'
```

**Configuration:**
- Environment: Staging (stg.healthbridge.app)
- Browser: Any
- Language: English (tested), likely all languages affected

---

## 8. Related Issues & Test Coverage

**Similar Past Issues:**
- No recent git history changes to `pr_reportscase.asp` (only original import commit)
- `chprintmedia.asp` last modified in HM-12835 (PDF conversion with ABCPdf)

**Same Bug Pattern in Codebase:**
- `chprintmedia.asp` is the single print handler for ALL Classic ASP report pages
- If root cause is missing Page table entry, other legacy reports may have similar issues
- The `rights.asp:167` redirect logic feeds ALL `view=noh` requests through `chprintmedia.asp`

**Related Test Coverage:**
- Unit Tests: Missing (Classic ASP, no unit test framework)
- Integration Tests: Missing
- E2E Tests: Missing (no Selenium/Playwright coverage for Patient Record Report printing)

**Automation Priority:** Medium (secondary feature, print workflow)

**Recommended Test Type:** E2E (Selenium - navigate to Patient Record Reports, trigger print)

---

## 9. JIRA Fields

**Component:** Reporting
**Affected Version:** Current staging (staticversion-7825022026)
**Fix Version:** Next Release
**Labels:** `edge-case`, `report`, `print`, `medium-severity`, `classic-asp`, `staging`
**Priority:** P3 (Medium)
**Assignee:** Clinical Data / Reporting Team
**Epic Link:** N/A

---

## Error Details

```
Type: Document
Response Code: 500
Request: GET /tableui/print/chprintmedia.asp?pid=ClinicalData/Report/pr_reportscase.asp&oview=noh&page_transaction=131563
Origin: /tableui/ClinicalData/Report/pr_reports.asp?page_transaction=131563
Timestamp: 2026-02-25T10:08:37.500617Z
Session ID: 1259534111
Company: Sunrise Health Clinic (ID: 131563)
```

---

*Generated by: @healthbridge-qa-bug-report agent*
*Report Date: 2026-02-25*
*Word Count: ~570/600*
