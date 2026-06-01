# [Project Name] — Glossary Supplement

> Maintained by: [Name / Role]
> Last Updated: YYYY-MM-DD
> Purpose: Supplement the AI-generated glossary (00-glossary.md) with terms that require
>          business knowledge to define accurately. Also resolves 🔴 [Needs Confirmation]
>          markers on undefined terms.
>          docpilot reads this file and merges entries into 00-glossary.md automatically.

---

## How to Use This File

1. Add a row for each term that appears in the code but needs a business-level definition.
2. Focus on:
   - Abbreviations that aren't obvious (e.g., "SKU", "PO", "RFQ")
   - Status codes and their business meaning (e.g., status=3 means "Manager Rejected")
   - Internal project codenames or workflow stages
   - Terms shared with external systems that have different names internally
3. After adding entries, run docpilot Operation E (Integrate Business Context) to merge into 00-glossary.md.

---

## Term Entries

| Term | Business Definition | Notes |
|------|---------------------|-------|
| [TERM] | [What it means in business terms] | [Optional: code value, source system, DB column, etc.] |
| [TERM] | [What it means in business terms] | |
| [TERM] | [What it means in business terms] | |

---

## Example Entries

*(Replace these with your own project's terms)*

| Term | Business Definition | Notes |
|------|---------------------|-------|
| SKU | Stock Keeping Unit. A unique identifier for each distinct product or product variant. | Maps to `product_code` in the inventory table. |
| PO | Purchase Order. A buyer-issued document authorizing a purchase from a supplier. | Corresponds to `order_id` in the orders table. |
| RFQ | Request for Quotation. A formal request sent to suppliers to get price quotes. | Precedes a PO in the procurement workflow. |
| status=3 | Rejected. The request was reviewed and sent back for revision. | Replace with your actual status values: e.g., 1=Draft, 2=Submitted, 3=Rejected, 4=Approved |
| SLA | Service Level Agreement. The agreed response or resolution time for a support ticket. | Used to calculate `due_at` in the ticket model. |
