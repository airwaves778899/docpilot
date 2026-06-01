# [Project Name] — Known Issues and Workarounds

> Maintained by: [Name / Role]
> Last Updated: YYYY-MM-DD
> Purpose: Record known bugs, design limitations, and temporary workarounds so the team
>          does not rediscover the same problems repeatedly. docpilot reads this file
>          and includes relevant entries in the Troubleshooting sections of feature docs.

---

## How to Use This File

1. Add an entry for every confirmed issue, even if it has no fix yet.
2. Keep the "Workaround" section updated as the team discovers better interim solutions.
3. Update "Status" when an issue is fixed or a permanent fix is scheduled.
4. After editing, run docpilot Operation E (Integrate Business Context) to propagate into docs.

**Issue Block Template:**

```
## Issue: [Issue Title]

**Discovered**: YYYY-MM-DD
**Affected Scope**: [Which features or users encounter this]
**Symptom**: [What the user sees — error message, wrong data, hang, etc.]
**Root Cause**: [Known or suspected cause]
**Workaround**: [Current procedure to handle it]
**Permanent Fix**: [Planned resolution, or "Under Discussion" / "No fix planned"]
**Status**: Pending Fix / Scheduled (vX.X / YYYY-MM) / Closed / Will Not Fix (reason)
```

---

## Example Entry

## Issue: Concurrent Save Causes Silent Data Loss

**Discovered**: 2026-03-15
**Affected Scope**: Order Entry screen — any user with edit access.
**Symptom**: If two users open the same order simultaneously and both click Save,
the second save succeeds but silently overwrites the first user's changes.
No error message is displayed.
**Root Cause**: The optimistic lock version field exists in the entity but the
controller/service does not pass it back to the save operation, so version checks are bypassed.
**Workaround**: Team has agreed to verbally coordinate before editing shared orders.
A sticky note is placed near each workstation as a reminder.
**Permanent Fix**: Fix the controller/service to include the version field in the update call. Estimated: v2.3 (2026-Q3).
**Status**: Scheduled (v2.3 / 2026-Q3)

---
<!-- Add your project's known issues below this line -->

## Issue: [Issue Title]

**Discovered**: YYYY-MM-DD
**Affected Scope**:
**Symptom**:
**Root Cause**:
**Workaround**:
**Permanent Fix**:
**Status**:

---

## Issue: [Issue Title]

**Discovered**: YYYY-MM-DD
**Affected Scope**:
**Symptom**:
**Root Cause**:
**Workaround**:
**Permanent Fix**:
**Status**:

---
