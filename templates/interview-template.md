# Business Interview Questionnaire — [Feature Name]

> Filled by: [Name / Role]
> Date: YYYY-MM-DD
> Corresponding Document: [Relative path to the feature document]
> Purpose: This questionnaire captures tacit business knowledge that cannot be read from
>          source code. docpilot reads your answers and distributes them into the
>          appropriate documentation sections automatically.

---

## Instructions

- Answer every question you can. Leave blank answers as `A:` (do not delete the question).
- Write answers in plain language — no need for technical precision.
- Longer answers are better. AI can summarize; it cannot invent facts.
- If a question doesn't apply to this feature, write `A: N/A — [brief reason]`.
- Save this file at: `00-business-context/interview-[feature-name].md`
- Then run docpilot Operation E (Integrate Business Context) to apply your answers.

---

## Section 1: Feature Purpose

**Q1. What business problem does this feature solve?**

A:

---

**Q2. Who are the primary users of this feature? How often do they use it?**

A:

---

**Q3. Where does this feature fit in the overall business process?
(What step comes before it? What step comes after it?)**

A:

---

## Section 2: Business Rules

**Q4. Which fields in this feature are truly important?
Which are legacy fields that are rarely used or no longer relevant?**

A:

---

**Q5. Are there any status values or flags in this feature?
What do they mean in business terms?**

A: (Example: status=3 means "Manager Rejected" — not a system suspension)

---

**Q6. Are there any operations that have strict preconditions in business practice
but are not enforced or obvious in the code?**

A: (Example: "Users must complete Step A before clicking Save on this screen,
but the system does not prevent them from skipping it")

---

**Q7. Are there operations that only specific people are allowed to perform?
What determines who can do it?**

A: (Example: "Only the department head can approve; the system checks role X,
but there is also an informal rule that the direct manager must sign off first")

---

## Section 3: Data and Integration

**Q8. Where does the data for this feature come from?
Is any data imported from an external system?**

A: (Example: "The product list is pulled nightly from the ERP system.
Real-time data is not available.")

---

**Q9. Where does the data produced by this feature go?
Are there downstream systems that depend on it?**

A: (Example: "Approved orders are picked up by the scheduling system every hour.
If approval is delayed past 16:00, the order misses today's production batch.")

---

**Q10. Are there any fields whose values are meaningful codes that require
a lookup table to understand?**

A: (Example: "The `dept_type` field uses codes: 01=Direct, 02=Indirect, 03=Admin.
This mapping is not in the database — it's only documented in the HR policy manual.")

---

## Section 4: Known Issues and Notes

**Q11. Are there any operations where users commonly make mistakes
or frequently get confused?**

A: (Example: "Users often forget to click Refresh after changing the date filter.
The screen does not auto-refresh and shows stale data.")

---

**Q12. Are there any known bugs or temporary workarounds currently in use?**

A: (Example: "If two users edit the same record at the same time, one person's changes
will be silently lost. The workaround is to communicate before editing.")

---

**Q13. Are there any unwritten rules that everyone on the team knows
but that are not documented anywhere?**

A: (Example: "Never run the batch job on the last business day of the month —
it conflicts with the finance close process and can cause double-counting.")

---

## Section 5: Additional Context

**Q14. Is there anything else about this feature that you think is important
but that the questions above did not cover?**

A:

---
