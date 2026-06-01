# [Project Name] — Business Rules Supplement

> Maintained by: [Name / Role]
> Last Updated: YYYY-MM-DD
> Purpose: Record business rules that exist in practice but are not visible in source code.
>          docpilot reads this file before every documentation operation and integrates
>          these rules into the relevant feature documents.

---

## How to Use This File

1. Add a section for each functional module or feature area that has important business rules.
2. Use the rule block template below for each individual rule.
3. After adding rules, run docpilot Operation E (Integrate Business Context) to propagate them into documentation.

**Rule Block Template:**

```
## [Module or Feature Name]

### Rule: [Rule Title]
**Description**: [Detailed explanation of this business rule]
**Source**: [Who defined it? Contract clause? Regulation? Management decision?]
**Exceptions**: [Any exception cases]
**Related Features**: [Which screens or processes are affected]
```

---

## Example Entry

## Order Management

### Rule: Orders Cannot Be Deleted After Approval
**Description**: Once an order status reaches "Approved" (status=3), it cannot be deleted.
Users must submit a cancellation request through the PM instead.
**Source**: Finance department policy — audit trail requirement.
**Exceptions**: System administrators can force-delete for data correction purposes only.
**Related Features**: Order List screen, Order Detail screen, Cancellation Request workflow

---
<!-- Add your project's business rules below this line -->

## [Module Name]

### Rule: [Rule Title]
**Description**:
**Source**:
**Exceptions**:
**Related Features**:

---

## [Module Name]

### Rule: [Rule Title]
**Description**:
**Source**:
**Exceptions**:
**Related Features**:

---
