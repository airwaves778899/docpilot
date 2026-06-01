---
name: docpilot
description: >
  AI-guided code documentation skill for any software project.
  Generates, verifies, and maintains technical documentation by reading source code.
  Trigger when user says: "produce documentation", "verify docs", "fix documentation",
  "security scan", "business context", or equivalent in any language.
  Supports: generate new docs from source, verify existing docs against code,
  add single doc, security scan, integrate business context supplements.
---

# Software Project Documentation Pattern

## Startup Wizard

**Before every session, the following guided steps must be executed in order. Do not skip.**
Use `AskUserQuestion` to collect required information step by step. The user clicks or types — the AI must not modify any files until Step 6 is confirmed.

---

### Step 1: Choose Operation Type

Ask the user:

```
Question: "Please select the operation to perform"
Options:
  A. Generate new documentation from source code (new project, no existing docs)
  B. Verify and correct existing documentation (docs exist, compare with code and fix)
  C. Add a single document (for a specific feature or Class)
  D. Security scan (scan code for security issues, produce a report)
  E. Integrate business context (read [Business Context] markers and 00-business-context/ to update docs)
```

---

### Step 1.5: Choose Output Language

Ask the user:

```
Question: "What language should the documentation be written in?"
Options:
  A. English (default — recommended for open source / international teams)
  B. 繁體中文 (Traditional Chinese)
  C. 简体中文 (Simplified Chinese)
  D. 日本語 (Japanese)
  E. Other (select Other and specify)
```

Store the selected language as `[DOC_LANGUAGE]`.
All generated documentation content — headings, descriptions, notes, 🔴 markers — must be written in `[DOC_LANGUAGE]`.
Code identifiers, file paths, and command examples remain in their original language regardless of `[DOC_LANGUAGE]`.

---

### Step 2: Enter Source Code Path

Ask the user:

```
Question: "Please enter the project source code root directory path"
Hint options:
  A. [SOURCE_ROOT]\[project-name]  (e.g. Eclipse or VS Code workspace)
  B. Other path (select Other to enter manually)
```

After receiving the path, verify the directory exists using PowerShell. If it does not exist, notify the user and ask again.

---

### Step 3: Enter Documentation Path

Ask the user:

```
Question: "Please enter the directory where Markdown documentation will be stored"
Hint options:
  A. [DOCS_ROOT]\[project-name]_doc
  B. A doc\ subdirectory within the source root
  C. Other path (select Other to enter manually)
```

If the directory does not exist, ask whether to create it automatically.

---

### Step 4: Select Scope

Ask the user:

```
Question: "What is the scope for this session?"
Options:
  A. Entire project (all documents)
  B. Specific subdirectory (e.g. only process 02-project/)
  C. Specific feature or Class name
  D. Only documents with 🔴 markers
```

If B or C is selected, use Other to ask for the specific name.

---

### Step 5: Upload Supplemental Materials (Optional)

Ask the user:

```
Question: "Do you have supplemental materials to provide for understanding business logic?"
Options:
  A. No, start immediately
  B. Upload documents (requirements specs, design files, legacy documentation, etc.)
  C. Provide business context as text (paste directly into the chat)
  D. Both
```

If B or D:
- Inform the user: "Please drag files into the chat to upload. Supported formats: .pdf, .docx, .md, .txt, .xlsx"
- Wait for upload, then read and analyze
- Use the analysis as context for subsequent operations

If C or D:
- Inform the user: "Please type your business context description directly, and it will be integrated into the documentation."

---

### Step 6: Review Summary and Confirm

Summarize the collected information and ask for final confirmation:

```
Question: "Please confirm the following settings are correct. Execution begins immediately after confirmation."

Summary:
  Operation:        [Step 1]
  Source Code Path: [Step 2]
  Docs Path:        [Step 3]
  Scope:            [Step 4]
  Supplemental:     [Step 5]

Options:
  A. Confirm — start execution
  B. Reset — start over from Step 1
```

After confirmation, execute based on the selected operation type. For large projects (more than 10 documents), automatically enable the parallel agent strategy.

---

### Uploaded Document Analysis Rules

After the user uploads supplemental documents, extract content by type:

| Document Type | Analysis Focus |
|--------------|----------------|
| Requirements spec (.docx / .pdf) | Business rules, feature descriptions, acceptance criteria |
| Design document | Architecture decisions, data flow, integration approach |
| Legacy documentation | Compare with existing docs, identify outdated or conflicting content |
| Excel (.xlsx) | Field definitions, code lookup tables, terminology |
| Markdown / plain text | Use directly as business context supplement |

After analysis, automatically:
- Extract business terms → add to glossary
- Extract business rules → add to `business-rules.md`
- Resolve 🔴 markers → integrate into main text and remove marker
- Discover conflicts → add new 🔴 and describe the conflict

---

## Core Principle: No Guessing, No Skipping

**Confirmed content** → write directly into the document
**Uncertain content** → insert a red marker; never guess or omit

### 🔴 [Needs Confirmation] Marker Format (with Owner)

```
> 🔴 **[Needs Confirmation | Owner: Data Owner / DevOps / PM / Developer / Integration System]**
> Specific description of what is unclear and what needs to be confirmed.
```

Owner Reference:

| Owner | Applicable Situations |
|-------|----------------------|
| `Data Owner / DBA` | Database schema, data model, index/constraint definitions |
| `DevOps / Infrastructure` | Deployment procedures, environment config, CI/CD pipelines, server settings |
| `PM / Business Owner` | Business rules, process design, functional requirements, domain definitions |
| `Developer / Engineer` | Code logic, library behavior, cross-module integration, implementation intent |
| `Integration System` | Connected systems, third-party APIs, data exchange protocols, external contracts |

**A marker must be inserted in the following situations:**
- Description cannot be traced and verified directly from source code
- Involves external system behavior
- Uses hedging language ("should", "probably", "assumed to be")
- Source file encoding prevents content from being read
- DB schema details need DBA confirmation
- Deployment SOP needs DevOps input
- Business rules have no clear code correspondence

---

## 8 Verification Rules

When comparing a document against source code, check each rule in order:

### Rule 1: Data Model Completeness
- Field/property names, storage keys, and types match the actual schema or definition
- Any constraints (nullable, unique, default value) are fully documented

### Rule 2: Reference / Foreign Key Fields
- Fields used for joins or references but not directly declared in the model must be documented separately in the relationship table
- Note which layer controls the write (the join/reference side)

### Rule 3: Non-Persistent / Computed Fields
- In-memory, computed, or transient fields with side effects (e.g., syncing another field on set) must be documented
- Mark clearly as "not stored / runtime only"

### Rule 4: Service / Repository Method Completeness
- List ALL methods in the service interface or repository, not only those used by the current screen/API
- Include query variants, overloads, save, delete

### Rule 5: Unimplemented Handlers
- Event handlers, commands, or callbacks with empty bodies must be marked:
  "Empty implementation — feature not yet implemented"

### Rule 6: UI Control Visibility (two layers)
- Container-level visibility (e.g., hidden section, collapsed panel) and individual element visibility must be documented separately
- Explain what happens when the container is shown — which elements become visible

### Rule 7: Unresolved Notes
- Any question marks or "needs confirmation" in notes must be resolved by checking source code, or replaced with a 🔴 marker
- Never leave unanswered questions in documentation

### Rule 8: File Paths / Identifiers
- Routes, component paths, class names, module names referenced in docs must actually exist in the source code
- Anything not found → 🔴 marker

---

## Document Types (Four)

Select the appropriate type based on content nature. A single project can have multiple types:

| Type | Purpose | When to Use |
|------|---------|-------------|
| **Reference** | Records "what is it" | Data model fields, service methods, UI element descriptions |
| **How-to Guide** | Explains "how to do X" | Manual operations, data corrections, specific task workflows |
| **Explanation** | Explains "why it was designed this way" | Architecture decisions, design rationale, special business logic background |
| **Troubleshooting** | Resolves "what went wrong" | Common errors, failure modes, diagnostic steps |

> When generating new documentation, include at least a Reference document. Architecture documents must also include an Explanation document.

---

## Document Structure Standards

### Reference Type (per functional module)

```markdown
# [Feature ID] — [Feature Name]

> Page/Route Title: [actual title shown to user]
> Last Updated: YYYY-MM-DD

## Feature Description
[What problem this feature solves, who uses it]

## Location
[File path, route, URL, or component path]
Handler/Controller: [fully qualified name or path]

## Data Model
[Table name, schema, or data structure name]

| Field / Property | Storage Key | Type | Description |
|-----------------|-------------|------|-------------|

## UI / Interaction Description
[Fields, buttons, validation rules, color coding, etc.]

## Service / API Layer

| Method / Endpoint | Description |
|------------------|-------------|

## Technical Debt & Known Issues
[Empty implementations, commented-out code, potential bugs]

## Notes
[Verified business rules, deprecated fields, special logic]
```

### Explanation Type (Architecture Decision Record)

```markdown
## Decision: [Decision Name]

> Decision Date: YYYY-MM-DD
> Status: Active / Deprecated / Under Discussion

### Background
[What problem or requirement was being addressed]

### Decision
[What approach was chosen]

### Rationale
[Why this approach was chosen over alternatives]

### Consequences
[What impact or constraints this decision introduces]
```

### Troubleshooting Type

```markdown
## Problem: [Problem Description]

**Symptom**: [What error or abnormal behavior the user sees]
**Root Cause**: [Underlying cause]
**Resolution Steps**:
1. ...
2. ...
**Prevention**: [How to avoid recurrence]
```

---

## Deprecated Feature Standard Format

When encountering deprecated fields, methods, or features, record with this format:

```markdown
> ⚠️ **[Deprecated]**
> - **Deprecated Version / Date**: v1.x / YYYY-MM-DD (use "Legacy" if unknown)
> - **Reason**: [Why it was deprecated]
> - **Replacement**: [What replaced it, or "None — removed directly"]
> - **Code Status**: commented-out / still present but unused / deleted
```

---

## Glossary Standard

Each project's documentation directory must contain `00-glossary.md` recording domain terms and system-specific vocabulary:

```markdown
# Glossary

| Term | Description |
|------|-------------|
| [Term] | [Definition, including business meaning and system correspondence] |
```

The following terms must be added to the glossary when encountered in generated documentation:
- Abbreviations and acronyms used in the codebase or domain
- Business-specific nouns that are not self-explanatory
- Internal codes, status values, or enum constants with business meaning
- Cross-system shared concepts, integration points, or shared identifiers

---

## Three Operation Flows

### Operation A: Generate New Documentation from Source Code

1. Scan the source directory to understand module structure
2. Create `00-glossary.md` recording project terminology
3. Determine document categories and produce Reference and Explanation documents
4. Write confirmed content; insert 🔴 markers with owners for uncertain content
5. Use the deprecated format for any deprecated features encountered

### Operation B: Verify and Correct Existing Documentation

1. Read the existing document
2. Read the corresponding source code (data models, service/repository layer, controllers/handlers, UI templates)
3. Apply all 8 verification rules in order
4. Errors found → correct directly; uncertain items → insert 🔴 marker with owner
5. Deprecated features found → add the deprecated format block
6. Update the `Last Updated` date

### Operation C: Add a Single Document

Specify a feature or class name, find the corresponding source code, and produce a document following the type and structure standards — applying the core principle throughout.

---

## Token Efficiency Strategy

Reading entire source files wastes tokens. Follow this order — stop as soon as you have enough information:

### Phase 1: Structural Scan (low cost — do this first, always)

Use grep / search to extract only what you need:

```bash
# Get all public function/method signatures (not full bodies)
grep -rn "^pub fn\|^def \|^func \|^export function\|^public " [SOURCE_ROOT]/src --include="*.rs"

# Get all struct/class/interface definitions (first line only)
grep -rn "^pub struct\|^class \|^interface \|^type .* struct" [SOURCE_ROOT]/src

# Get all module-level doc comments
grep -rn "^//!\|^///\|^\"\"\"" [SOURCE_ROOT]/src | head -50

# List all files with line counts (scope the reading budget)
find [SOURCE_ROOT]/src -name "*.ext" | xargs wc -l | sort -rn | head -20
```

**PowerShell equivalent:**
```powershell
# Signatures only
Get-ChildItem "[SOURCE_ROOT]" -Recurse -Filter "*.ext" |
    Select-String "^pub fn|^def |^public " | Select-Object Path, LineNumber, Line

# File size ranking
Get-ChildItem "[SOURCE_ROOT]" -Recurse -Filter "*.ext" |
    Sort-Object Length -Descending | Select-Object Name, Length -First 20
```

### Phase 2: Selective Reading (medium cost — targeted files only)

After the structural scan, read **only** the files that contain the information you need:
- Entry point / main file: always read (defines the overall structure)
- Core data model files: read fully
- Utility / helper files: read first 30–50 lines only (signatures + doc comments)
- Test files: skip unless documenting test coverage

### Phase 3: Deep Read (high cost — only when 🔴 marker would otherwise be inserted)

If a 🔴 marker would be needed because something is unclear, try one targeted deep read first:
- Use line-range reading if the file is large (e.g., lines 100–150 of a 500-line file)
- If still unclear after one targeted read → insert 🔴 marker rather than reading more

### For Large Projects: One-Pass Architecture Scan

Before generating any document, do a single architecture scan across the whole project:
1. List all files with their sizes
2. Grep for top-level definitions (structs, classes, functions, routes)
3. Read only entry points and core model files
4. Write the architecture overview first
5. Reuse the scan results for all subsequent feature documents — never re-scan

This eliminates redundant file reads across multiple documents in the same project.

---

## Large Projects: Parallel Agent Strategy

When a project has more than 10 documents, group by function (5–7 documents per group) and dispatch multiple agents simultaneously.

Each agent prompt must include:
- Source code path and documentation path
- List of document paths assigned to this agent
- All 8 verification rules (complete text)
- 🔴 marker format (including owner rules)
- Deprecated feature standard format
- The "no guessing, no skipping" principle

---

## Reading Source Code

Use whichever tool fits your environment and language. The goal is always to verify that what is written in the document actually matches what exists in the code.

**Linux / macOS (bash / grep):**
```bash
# Find files containing a pattern
grep -rn "pattern" [SOURCE_ROOT] --include="*.py"
grep -rn "pattern" [SOURCE_ROOT] --include="*.ts"

# Find all model / entity definitions
grep -rl "class.*Model\|@dataclass\|@Entity\|interface.*Schema" [SOURCE_ROOT]

# Find all service / repository / controller files
find [SOURCE_ROOT] -name "*.py" | xargs grep -l "class.*Service\|class.*Repository"

# Find commented-out code blocks (potential deprecated features)
grep -rn "^#\s\|^//\s\|^--\s" [SOURCE_ROOT] | grep -i "deprecated\|disabled\|old\|TODO\|FIXME"
```

**Windows (PowerShell):**
```powershell
# Read a file
Get-Content "[SOURCE_ROOT]\path\to\file.ext" -Encoding UTF8

# Find files by extension and content pattern
Get-ChildItem "[SOURCE_ROOT]" -Recurse -Filter "*.ext" |
    Select-String "pattern" -List | Select-Object Path

# Find commented-out code (deprecated field detection)
Get-ChildItem "[SOURCE_ROOT]" -Recurse -Include "*.ext" |
    Select-String "//.*deprecated\|#.*disabled" | Select-Object Path, LineNumber, Line
```

Adapt the file extension filter (`*.java`, `*.py`, `*.ts`, `*.go`, `*.cs`, etc.) and search patterns to match your project's language and conventions.

---

## Operation D: Security Scan

After documentation is generated or verified, optionally run a security scan to identify code security issues and record them in the documentation.

### Trigger

Execute when the user says "security scan", "security review", or "scan for security issues".

### Step 1: Invoke security-review skill (if available)

If a `security-review` skill is available in the environment, invoke it first to scan the full project.
If not available, proceed directly to Step 2.

### Step 2: Automated Scan

Run the scan script at `[SOURCE_ROOT]/../scripts/security-scan.ps1 -SourceRoot "[SOURCE_ROOT]"`,
or search for the following patterns using grep, ripgrep, or any text search tool available in your environment.

Adapt file extensions (`*.py`, `*.ts`, `*.go`, `*.cs`, `*.java`, etc.) to match your project language.

**S01 — Hardcoded Credentials**
Search all source and config files for patterns like:
`password=`, `secret=`, `api_key=`, `token=` followed by a literal value (not a variable reference).

**S02 — SQL Injection Risk**
Search for database query functions that accept string concatenation:
`query(` + `"..."` + variable, or raw SQL string building patterns.

**S03 — Disabled Authorization Checks**
Search for commented-out access control code:
Lines starting with `//`, `#`, or `--` that contain `auth`, `role`, `permission`, `admin`, `guard`.

**S04 — Authorization Config Syntax**
Search for all authorization annotations or decorators (e.g. `@requires_auth`, `@login_required`, `[Authorize]`, middleware guards) and verify the syntax matches the framework's documentation.

**S05 — Sensitive Data Exposure**
Search for stack trace printing and debug logging that may include passwords or tokens:
`printStackTrace`, `print(traceback`, `console.log`, `fmt.Println` in production code paths.

**S06 — Missing Input Validation**
Search for user-facing form inputs or API parameters that lack validation constraints or sanitization.

**S07 — XSS Risk**
Search for raw HTML injection patterns:
`innerHTML`, `outerHTML`, `dangerouslySetInnerHTML`, `eval(`, `document.write(`.

**S08 — Outdated Dependencies**
Search dependency manifest files (`package.json`, `requirements.txt`, `go.mod`, `pom.xml`, `Gemfile`, etc.) for version declarations and cross-reference with known CVE databases.

**S09 — Broad Exception Catches**
Search for catch-all exception handlers that may silently swallow errors:
`catch (Exception`, `except Exception`, `rescue StandardError`, `catch (_)`.

**S10 — Empty Exception Handlers**
Search for completely empty catch/except blocks with no logging or re-throw.

### Step 3: Produce Security Report

Write scan results to: `[DOCS_ROOT]\99-devops\security-report.md`

### Security Report Format

```markdown
# [Project Name] Security Scan Report

> Scan Date: YYYY-MM-DD
> Source Path: [SOURCE_ROOT]
> Scan Scope: Full project source and config files

---

## Issue List

| # | Severity | Type | File | Line | Description | Recommended Fix |
|---|----------|------|------|------|-------------|-----------------|
| 1 | 🔴 High | Hardcoded Credential | ... | ... | ... | ... |
| 2 | 🟡 Medium | SQL Injection | ... | ... | ... | ... |
| 3 | 🟢 Low | Missing Input Validation | ... | ... | ... | ... |

---

## Severity Definitions

| Severity | Description |
|----------|-------------|
| 🔴 High | Directly exploitable — fix immediately |
| 🟡 Medium | Risk present but requires specific conditions — fix in next release |
| 🟢 Low | Best practice recommendation — schedule for improvement |

---

## Items Requiring Manual Review

| Item | How to Confirm |
|------|----------------|
| Session / token timeout | Check framework auth config or middleware settings |
| CSRF protection | Confirm anti-CSRF tokens or SameSite cookie policy is in place |
| Data access isolation | Confirm queries are scoped to the authenticated user / tenant |
| Password / secret storage | Confirm hashing (bcrypt, argon2, etc.) — not plaintext or reversible encryption |
```

---

## Operation E: Integrate Business Context

Before executing any operation, check business supplement information in this order:

1. **Read order (highest to lowest priority)**:
   - All `.md` files in `[DOCS_ROOT]/00-business-context/`
   - All `[Business Context]` markers in existing documents
   - All `[DOCS_ROOT]/00-business-context/interview-*.md` questionnaires

2. **Integration rules**:
   - `[Business Context]` marker content → promote to main text, remove 🔴
   - Rules in `business-rules.md` → add to the "Notes" section of the relevant feature document
   - Terms in `glossary-additions.md` → merge into glossary, remove the corresponding 🔴
   - Content in `integration-map.md` → add to cross-system section of architecture docs
   - Questionnaire answers in `interview-*.md` → distribute to feature description, notes, and glossary

3. **Unresolved 🔴 markers**:
   - If business context does not cover a 🔴, leave the marker unchanged
   - If business context partially addresses a 🔴, update the marker text to "Partial context provided — still needs confirmation: [remaining question]"

---

## Business Context Supplement Layers

### Layer 1 — Inline Response to 🔴 Markers

The simplest method. The project owner adds a reply directly below a 🔴 marker:

**Format:**
```
> **[Business Context | Name YYYY-MM-DD]** Explanation content here.
```

**Example:**
```markdown
> 🔴 **[Needs Confirmation | Owner: PM]** The business definition of "PrePM" is unclear.

> **[Business Context | Jane 2026-06-01]** PrePM refers to the pre-project stage before
> a formal project number is assigned. Used to track potential client negotiations.
> This 🔴 can be removed after review.
```

**AI Processing Rules:**
- When `[Business Context]` is seen → treat as human-verified information
- On the next Operation B (verify and correct), integrate the supplement into main text and remove the corresponding 🔴
- If the supplement is still insufficient, retain the 🔴 and add: "Partial context provided — still needs confirmation: ..."

### Layer 2 — Business Context Directory

A `00-business-context/` folder maintained by the project owner, read automatically before every operation.

**Directory structure:**
```
[project]_doc/
└── 00-business-context/
    ├── business-rules.md       # Business rules not visible in code
    ├── glossary-additions.md   # Domain term definitions
    ├── integration-map.md      # Cross-system integration details
    └── known-issues.md         # Known bugs and workarounds
```

### Layer 3 — Business Interview Questionnaire

A structured 14-question form filled by the project owner. Each functional module gets one questionnaire, placed in the documentation directory.

**Output path:** `00-business-context/interview-[feature-name].md`

See `templates/interview-template.md` for the full questionnaire.
