# docpilot — Wizard Flow Reference

This document provides the complete decision tree and behavior specification
for the 6-step startup wizard. Every docpilot session must complete these
steps in order before any file is read or modified.

---

## Overview

```
START
  │
  ▼
Step 1: Choose Operation
  │
  ├── A: Generate New Docs ──────────────────────────────────────────► Step 2
  ├── B: Verify Existing Docs ────────────────────────────────────────► Step 2
  ├── C: Add Single Document ─────────────────────────────────────────► Step 2
  ├── D: Security Scan ───────────────────────────────────────────────► Step 2
  └── E: Integrate Business Context ───────────────────────────────────► Step 2
                                                                          │
                                                                          ▼
                                                                       Step 2: Source Path
                                                                          │
                                                                    [Path valid?]
                                                                    Yes ──► Step 3
                                                                    No  ──► Re-ask
                                                                          │
                                                                          ▼
                                                                       Step 3: Docs Path
                                                                          │
                                                                   [Path exists?]
                                                                   Yes ──► Step 4
                                                                   No  ──► Ask to create
                                                                          │
                                                                          ▼
                                                                       Step 4: Scope
                                                                          │
                                                                          ▼
                                                                       Step 5: Supplemental (optional)
                                                                          │
                                                                          ▼
                                                                       Step 6: Confirm Summary
                                                                          │
                                                                   [Confirmed?]
                                                                   Yes ──► Execute
                                                                   No  ──► Back to Step 1
```

---

## Step 1: Choose Operation

**Question presented to user:**
> "Please select the operation to perform"

| Option | Code | What Happens Next |
|--------|------|-------------------|
| A | `OP_GENERATE` | Generate new documentation from source code |
| B | `OP_VERIFY` | Read existing docs + source code, apply 8 verification rules, fix errors |
| C | `OP_SINGLE` | Add one document for a specific feature or Class |
| D | `OP_SECURITY` | Run security scan (S01–S10), produce security report |
| E | `OP_INTEGRATE` | Read 00-business-context/ and [Business Context] markers, update docs |

**Behavior notes:**
- All options proceed to Step 2 to collect paths.
- For option D (Security Scan), Step 3 (docs path) is optional — if no docs path is given, the report is printed to console only.
- For option E (Integrate Business Context), Step 4 scope defaults to "entire project" but can be narrowed.

---

## Step 2: Source Code Root Path

**Question presented to user:**
> "Please enter the project source code root directory path"

**Validation rule:**
- After the user enters a path, verify the directory exists using PowerShell:
  ```powershell
  Test-Path "[entered-path]"
  ```
- If `$false` → inform the user: "The path `[entered-path]` was not found. Please check and re-enter."
- Re-ask until a valid path is provided.

**Path examples to offer as hints:**
```
[SOURCE_ROOT]\[project-name]     (Eclipse / IntelliJ workspace)
[OTHER_WORKSPACE]\[project-name] (VS Code or other)
Other — enter manually
```

**After a valid path is confirmed:**
- Store as `$SourceRoot`
- Proceed to Step 3

---

## Step 3: Documentation Output Directory

**Question presented to user:**
> "Please enter the directory where Markdown documentation will be stored"

**Hints to offer:**
```
[DOCS_ROOT]\[project-name]_doc    (separate docs folder)
[SOURCE_ROOT]\doc\                (inside the project)
Other — enter manually
```

**Validation rule:**
- Check if the directory exists:
  ```powershell
  Test-Path "[entered-path]"
  ```
- If it does not exist, ask:
  > "The directory `[entered-path]` does not exist. Create it now?"
  - Yes → create with `New-Item -ItemType Directory -Path "[entered-path]" -Force`
  - No → re-ask for a different path

**After a valid path is confirmed:**
- Store as `$DocsRoot`
- Proceed to Step 4

**Exception for Security Scan (Operation D):**
- If the user says they don't have a docs path, store `$DocsRoot = ""` and note that the report will be console-only.

---

## Step 4: Select Scope

**Question presented to user:**
> "What is the scope for this session?"

| Option | Code | Behavior |
|--------|------|----------|
| A | `SCOPE_ALL` | Process all documents in `$DocsRoot` (or all source files for a new project) |
| B | `SCOPE_DIR` | Ask: "Enter the subdirectory name (e.g., `02-project/`)" — process only that subdirectory |
| C | `SCOPE_CLASS` | Ask: "Enter the feature name or Class name (e.g., `OrderEntryVM`)" — locate and process only that class |
| D | `SCOPE_MARKERS` | Find all documents containing `🔴` markers and process only those |

**For options B and C:**
- Use a follow-up question with an open text field to collect the specific name
- For option C (class name), scan source code to confirm the class exists before proceeding

**Large project handling:**
- If scope is `SCOPE_ALL` and the number of document files exceeds 10, automatically enable parallel agent strategy:
  - Group files into batches of 5–7 documents
  - Each batch is dispatched to a separate agent with the full rule context
  - See the "Parallel Agent Strategy" section in SKILL.md for the required agent prompt template

---

## Step 5: Upload Supplemental Materials (Optional)

**Question presented to user:**
> "Do you have supplemental materials to provide for understanding business logic?"

| Option | Behavior |
|--------|----------|
| A — No | Skip to Step 6 immediately |
| B — Upload files | Instruct: "Please drag files into the chat. Supported: .pdf, .docx, .md, .txt, .xlsx" → wait for upload → analyze |
| C — Text input | Instruct: "Please type your business context description" → read input → store as supplemental context |
| D — Both | Handle file upload first, then text input |

**Document analysis by type:**

| File Type | What to Extract |
|-----------|----------------|
| `.pdf` / `.docx` (requirements) | Business rules, feature descriptions, acceptance criteria |
| `.pdf` / `.docx` (design docs) | Architecture decisions, data flow, integration patterns |
| `.docx` (legacy documentation) | Compare with current docs — flag outdated or conflicting content |
| `.xlsx` | Field definitions, code lookup tables, domain terminology |
| `.md` / `.txt` | Use directly as business context supplement |

**After analysis:**
- Extract business terms → queue for addition to glossary
- Extract business rules → queue for addition to `business-rules.md`
- Note any content that resolves existing 🔴 markers
- Note any content that conflicts with source code → new 🔴 markers needed

**All extracted context is held in memory for use during Step 6 execution — no files are written yet.**

---

## Step 6: Confirm Summary and Execute

**Summary presented to user:**

```
Please confirm the following settings are correct.
Execution begins immediately after confirmation.

  Operation:         [Step 1 selection]
  Source Code Path:  [Step 2 path]
  Docs Path:         [Step 3 path]
  Scope:             [Step 4 selection + detail]
  Supplemental:      [Step 5 — None / N files uploaded / Text provided]

Options:
  A. Confirm — start execution
  B. Reset — start over from Step 1
```

**On Confirm (A):**
- Begin the selected operation immediately
- Apply all collected context (supplemental materials, scope constraints)
- For `OP_GENERATE` and `OP_VERIFY` with large scope: check file count, enable parallel agents if > 10

**On Reset (B):**
- Clear all collected values
- Return to Step 1

---

## Execution Dispatch Table

After Step 6 confirmation, the operation proceeds as follows:

| Operation | First Action |
|-----------|-------------|
| `OP_GENERATE` | Scan source tree structure → identify modules → create 00-glossary.md → produce Reference docs |
| `OP_VERIFY` | Read existing docs → read source code → apply 8 rules → fix or mark |
| `OP_SINGLE` | Locate specific Class or feature in source → produce one document |
| `OP_SECURITY` | Run S01–S10 scans via PowerShell → produce security report |
| `OP_INTEGRATE` | Read 00-business-context/ → read [Business Context] markers → update docs |

---

## Error Handling

| Situation | Response |
|-----------|----------|
| Source path not found | Notify user, re-ask Step 2 |
| Docs path doesn't exist | Ask to create; if declined, re-ask Step 3 |
| Source file unreadable (encoding issue) | Insert 🔴 [Needs Confirmation \| Owner: Developer] marker noting the file could not be read |
| Uploaded file is empty or unreadable | Notify user, ask if they want to try again or skip |
| Class name from Step 4C not found in source | Notify user, ask for corrected name or different scope option |
| More than 10 documents in scope | Automatically activate parallel agent strategy — inform user before starting |

---

## Quick Reference: 🔴 Marker Format

```markdown
> 🔴 **[Needs Confirmation | Owner: DBA / DevOps / PM / Developer / External System Owner]**
> Specific description of what is unclear and what needs to be confirmed.
```

## Quick Reference: Business Context Supplement Format

```markdown
> **[Business Context | Name YYYY-MM-DD]** Explanation of the confirmed information.
```

When docpilot sees a `[Business Context]` reply adjacent to a 🔴 marker, it:
1. Promotes the supplement text into the document's main body
2. Removes the 🔴 marker
3. Updates the "Last Updated" date
