# [Project Name] — Cross-System Integration Map

> Maintained by: [Name / Role]
> Last Updated: YYYY-MM-DD
> Purpose: Document how this system integrates with external systems, especially aspects
>          that source code alone cannot explain. docpilot reads this file and adds the
>          content to architecture-level documentation automatically.

---

## How to Use This File

1. Add a section for each external system this project integrates with.
2. Describe the integration method, data flow, field mappings, and any non-obvious rules.
3. Include contact information for the responsible party on the external side.
4. After editing, run docpilot Operation E (Integrate Business Context) to propagate into docs.

**Section Template:**

```
## Integration with [External System Name]

**Integration Method**: [API / DB View / FTP / Batch Job / Manual Transfer]
**Data Flow**: [Direction and frequency — e.g., "This system pulls from ERP nightly at 02:00"]
**Field Mapping**:

| This System | External System | Notes |
|-------------|----------------|-------|
| [field]     | [field]        | [description] |

**Important Notes**: [Anything that would cause confusion without this context]
**Contact**: [External system owner name and contact method]
```

---

## Example Entry

## Integration with ERP System

**Integration Method**: DB View (read-only) — this system reads from ERP views, never writes back.
**Data Flow**: ERP pushes to shared views nightly. This system queries on demand.
**Field Mapping**:

| This System | ERP Field | Notes |
|-------------|-----------|-------|
| `product.cid` | `NEW_CPNO` (first 10 chars) | Truncated — ERP stores 20 chars, we use 10 |
| `order.moNo` | `MO_NO` | Manufacturing order number — same value, different table |
| `employee.empId` | `EMP_ID` | HR system uses the same ID; join is safe |

**Important Notes**: The ERP view `V_PROD_STATUS` is refreshed at 02:00 daily.
Any status changes made in ERP after midnight will not appear here until the next day.
Do not use this system for real-time production status queries.
**Contact**: ERP System Team — [contact method]

---
<!-- Add your project's integration mappings below this line -->

## Integration with [External System Name]

**Integration Method**:
**Data Flow**:
**Field Mapping**:

| This System | External System | Notes |
|-------------|----------------|-------|
|  |  |  |

**Important Notes**:
**Contact**:

---

## Integration with [External System Name]

**Integration Method**:
**Data Flow**:
**Field Mapping**:

| This System | External System | Notes |
|-------------|----------------|-------|
|  |  |  |

**Important Notes**:
**Contact**:

---
