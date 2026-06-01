<#
.SYNOPSIS
    docpilot Security Scan — S01 through S10
    Scans Java/ZK MVVM project source code for common security issues.

.DESCRIPTION
    Runs 10 automated security checks against Java source files, ZUL files,
    properties files, and pom.xml. Outputs findings to the console and
    optionally writes a Markdown report.

.PARAMETER SourceRoot
    Root directory of the project source code to scan.
    Example: C:\Projects\my-app\src

.PARAMETER DocsRoot
    (Optional) Root directory of the documentation output.
    If provided, the security report is written to:
    [DocsRoot]\99-devops\security-report.md

.PARAMETER ProjectName
    (Optional) Name of the project, used in the report header.
    Defaults to the directory name of SourceRoot.

.EXAMPLE
    .\security-scan.ps1 -SourceRoot "C:\Projects\my-app\src"

.EXAMPLE
    .\security-scan.ps1 -SourceRoot "C:\Projects\my-app\src" `
                        -DocsRoot "C:\Docs\my-app_doc" `
                        -ProjectName "My Application"

.NOTES
    Part of the docpilot skill — https://github.com/airwaves778899/docpilot
    MIT License
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot,

    [Parameter(Mandatory = $false)]
    [string]$DocsRoot = "",

    [Parameter(Mandatory = $false)]
    [string]$ProjectName = ""
)

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

if (-not (Test-Path $SourceRoot)) {
    Write-Error "Source root directory not found: $SourceRoot"
    exit 1
}

if ([string]::IsNullOrEmpty($ProjectName)) {
    $ProjectName = (Get-Item $SourceRoot).Name
}

$scanDate = Get-Date -Format "yyyy-MM-dd"
$findings = [System.Collections.Generic.List[PSObject]]::new()
$issueNumber = 0

function Add-Finding {
    param($Id, $Severity, $Type, $FilePath, $LineNumber, $Line, $Recommendation)
    $script:issueNumber++
    $findings.Add([PSCustomObject]@{
        Num            = $script:issueNumber
        Id             = $Id
        Severity       = $Severity
        Type           = $Type
        File           = $FilePath -replace [regex]::Escape($SourceRoot), '[SOURCE_ROOT]'
        Line           = $LineNumber
        Content        = $Line.Trim()
        Recommendation = $Recommendation
    })
}

Write-Host ""
Write-Host "================================================================"
Write-Host "  docpilot Security Scan"
Write-Host "  Project : $ProjectName"
Write-Host "  Source  : $SourceRoot"
Write-Host "  Date    : $scanDate"
Write-Host "================================================================"
Write-Host ""

# ---------------------------------------------------------------------------
# S01 — Hardcoded Credentials
# ---------------------------------------------------------------------------

Write-Host "=== [S01] Hardcoded Credentials (passwords, API keys) ==="
$s01Results = Get-ChildItem $SourceRoot -Recurse -Include "*.java","*.properties","*.xml" -ErrorAction SilentlyContinue |
    Select-String -Pattern '(?i)(password|passwd|secret|apikey|api_key)\s*=\s*["''][^$\{][^"'']{3,}' |
    Select-Object Path, LineNumber, Line

foreach ($r in $s01Results) {
    Write-Host "  [HIGH] $($r.Path):$($r.LineNumber)"
    Write-Host "         $($r.Line.Trim())"
    Add-Finding -Id "S01" -Severity "High" -Type "Hardcoded Credential" `
        -FilePath $r.Path -LineNumber $r.LineNumber -Line $r.Line `
        -Recommendation "Move to external properties file; exclude from version control."
}
if ($s01Results.Count -eq 0) { Write-Host "  No issues found." }
Write-Host ""

# ---------------------------------------------------------------------------
# S02 — SQL Injection
# ---------------------------------------------------------------------------

Write-Host "=== [S02] SQL Injection (native SQL with string concatenation) ==="
$s02Results = Get-ChildItem $SourceRoot -Recurse -Include "*.java" -ErrorAction SilentlyContinue |
    Select-String -Pattern '(createNativeQuery|createQuery|executeQuery).*\+' |
    Select-Object Path, LineNumber, Line

foreach ($r in $s02Results) {
    Write-Host "  [HIGH] $($r.Path):$($r.LineNumber)"
    Write-Host "         $($r.Line.Trim())"
    Add-Finding -Id "S02" -Severity "High" -Type "SQL Injection" `
        -FilePath $r.Path -LineNumber $r.LineNumber -Line $r.Line `
        -Recommendation "Use JPA named parameters (:paramName) or Criteria API instead of concatenation."
}
if ($s02Results.Count -eq 0) { Write-Host "  No issues found." }
Write-Host ""

# ---------------------------------------------------------------------------
# S03 — Role Enforcement Commented Out
# ---------------------------------------------------------------------------

Write-Host "=== [S03] Role Enforcement Commented Out ==="
$s03Results = Get-ChildItem $SourceRoot -Recurse -Include "*.java" -ErrorAction SilentlyContinue |
    Select-String -Pattern '//\s*@(PreAuthorize|Secured|RolesAllowed|isManager|isAdmin|RoleUtil)' |
    Select-Object Path, LineNumber, Line

foreach ($r in $s03Results) {
    Write-Host "  [HIGH] $($r.Path):$($r.LineNumber)"
    Write-Host "         $($r.Line.Trim())"
    Add-Finding -Id "S03" -Severity "High" -Type "Disabled Role Enforcement" `
        -FilePath $r.Path -LineNumber $r.LineNumber -Line $r.Line `
        -Recommendation "Confirm if intentional. If not, restore the annotation immediately."
}
if ($s03Results.Count -eq 0) { Write-Host "  No issues found." }
Write-Host ""

# ---------------------------------------------------------------------------
# S04 — @PreAuthorize Syntax Issues
# ---------------------------------------------------------------------------

Write-Host "=== [S04] @PreAuthorize Syntax (review each occurrence) ==="
$s04Results = Get-ChildItem $SourceRoot -Recurse -Include "*.java" -ErrorAction SilentlyContinue |
    Select-String -Pattern "@PreAuthorize" |
    Select-Object Path, LineNumber, Line

foreach ($r in $s04Results) {
    Write-Host "  [MED]  $($r.Path):$($r.LineNumber)"
    Write-Host "         $($r.Line.Trim())"
    Add-Finding -Id "S04" -Severity "Medium" -Type "@PreAuthorize Syntax" `
        -FilePath $r.Path -LineNumber $r.LineNumber -Line $r.Line `
        -Recommendation "Verify syntax is correct, e.g. hasAnyRole('ROLE_A', 'ROLE_B') with correct delimiters."
}
if ($s04Results.Count -eq 0) { Write-Host "  No issues found." }
Write-Host ""

# ---------------------------------------------------------------------------
# S05 — Sensitive Data in Logs / printStackTrace
# ---------------------------------------------------------------------------

Write-Host "=== [S05] Sensitive Data in Logs or printStackTrace ==="
$s05Results = Get-ChildItem $SourceRoot -Recurse -Include "*.java" -ErrorAction SilentlyContinue |
    Select-String -Pattern '(printStackTrace|System\.out\.print|log\.debug.*password|log\.info.*password)' |
    Select-Object Path, LineNumber, Line

foreach ($r in $s05Results) {
    Write-Host "  [MED]  $($r.Path):$($r.LineNumber)"
    Write-Host "         $($r.Line.Trim())"
    Add-Finding -Id "S05" -Severity "Medium" -Type "Sensitive Data Exposure" `
        -FilePath $r.Path -LineNumber $r.LineNumber -Line $r.Line `
        -Recommendation "Replace printStackTrace() with log.error('message', e). Remove sensitive fields from log statements."
}
if ($s05Results.Count -eq 0) { Write-Host "  No issues found." }
Write-Host ""

# ---------------------------------------------------------------------------
# S06 — ZUL Textbox Without Input Constraint
# ---------------------------------------------------------------------------

Write-Host "=== [S06] ZUL Textbox Missing Input Constraint ==="
$s06Results = Get-ChildItem $SourceRoot -Recurse -Include "*.zul" -ErrorAction SilentlyContinue |
    Select-String -Pattern '<textbox(?!.*constraint)' |
    Select-Object Path, LineNumber, Line

foreach ($r in $s06Results) {
    Write-Host "  [MED]  $($r.Path):$($r.LineNumber)"
    Write-Host "         $($r.Line.Trim())"
    Add-Finding -Id "S06" -Severity "Medium" -Type "Missing Input Validation" `
        -FilePath $r.Path -LineNumber $r.LineNumber -Line $r.Line `
        -Recommendation "Add ZK constraint attribute or server-side validation for this textbox."
}
if ($s06Results.Count -eq 0) { Write-Host "  No issues found." }
Write-Host ""

# ---------------------------------------------------------------------------
# S07 — XSS Risk
# ---------------------------------------------------------------------------

Write-Host "=== [S07] XSS Risk (raw HTML injection) ==="
$s07Results = Get-ChildItem $SourceRoot -Recurse -Include "*.zul","*.java" -ErrorAction SilentlyContinue |
    Select-String -Pattern '(innerHTML|outerHTML|setRawValue|Clients\.evalJavaScript)' |
    Select-Object Path, LineNumber, Line

foreach ($r in $s07Results) {
    Write-Host "  [MED]  $($r.Path):$($r.LineNumber)"
    Write-Host "         $($r.Line.Trim())"
    Add-Finding -Id "S07" -Severity "Medium" -Type "XSS Risk" `
        -FilePath $r.Path -LineNumber $r.LineNumber -Line $r.Line `
        -Recommendation "Avoid innerHTML and setRawValue. Use ZK safe methods like setLabel() instead."
}
if ($s07Results.Count -eq 0) { Write-Host "  No issues found." }
Write-Host ""

# ---------------------------------------------------------------------------
# S08 — Outdated Dependencies
# ---------------------------------------------------------------------------

Write-Host "=== [S08] Dependency Versions (review pom.xml) ==="
$s08Results = Get-ChildItem $SourceRoot -Recurse -Include "pom.xml" -ErrorAction SilentlyContinue |
    Select-String -Pattern '<version>' |
    Select-Object Path, LineNumber, Line

foreach ($r in $s08Results) {
    Write-Host "  [LOW]  $($r.Path):$($r.LineNumber) $($r.Line.Trim())"
    Add-Finding -Id "S08" -Severity "Low" -Type "Dependency Version" `
        -FilePath $r.Path -LineNumber $r.LineNumber -Line $r.Line `
        -Recommendation "Run 'mvn dependency-check:check' or OWASP Dependency Check to identify CVEs."
}
if ($s08Results.Count -eq 0) { Write-Host "  No pom.xml files found." }
Write-Host ""

# ---------------------------------------------------------------------------
# S09 — OptimisticLockException Not Handled
# ---------------------------------------------------------------------------

Write-Host "=== [S09] OptimisticLockException May Not Be Caught ==="
$s09Results = Get-ChildItem $SourceRoot -Recurse -Include "*.java" -ErrorAction SilentlyContinue |
    Select-String -Pattern 'catch\s*\(Exception' |
    Select-Object Path, LineNumber, Line

foreach ($r in $s09Results) {
    Write-Host "  [LOW]  $($r.Path):$($r.LineNumber)"
    Write-Host "         $($r.Line.Trim())"
    Add-Finding -Id "S09" -Severity "Low" -Type "OptimisticLockException Risk" `
        -FilePath $r.Path -LineNumber $r.LineNumber -Line $r.Line `
        -Recommendation "Add explicit catch(OptimisticLockException e) before catch(Exception e) and prompt the user to retry."
}
if ($s09Results.Count -eq 0) { Write-Host "  No issues found." }
Write-Host ""

# ---------------------------------------------------------------------------
# S10 — Empty Catch Blocks
# ---------------------------------------------------------------------------

Write-Host "=== [S10] Empty Catch Blocks (swallowed exceptions) ==="
$s10Results = Get-ChildItem $SourceRoot -Recurse -Include "*.java" -ErrorAction SilentlyContinue |
    Select-String -Pattern 'catch\s*\([^)]+\)\s*\{(\s*\/\/[^\n]*)?\s*\}' |
    Select-Object Path, LineNumber, Line

foreach ($r in $s10Results) {
    Write-Host "  [LOW]  $($r.Path):$($r.LineNumber)"
    Write-Host "         $($r.Line.Trim())"
    Add-Finding -Id "S10" -Severity "Low" -Type "Empty Catch Block" `
        -FilePath $r.Path -LineNumber $r.LineNumber -Line $r.Line `
        -Recommendation "Add at minimum log.error('Unexpected error', e) to avoid silent failures."
}
if ($s10Results.Count -eq 0) { Write-Host "  No issues found." }
Write-Host ""

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

$highCount   = ($findings | Where-Object { $_.Severity -eq "High"   }).Count
$medCount    = ($findings | Where-Object { $_.Severity -eq "Medium" }).Count
$lowCount    = ($findings | Where-Object { $_.Severity -eq "Low"    }).Count

Write-Host "================================================================"
Write-Host "  Scan Complete"
Write-Host "  Total Issues : $($findings.Count)"
Write-Host "  High         : $highCount"
Write-Host "  Medium       : $medCount"
Write-Host "  Low          : $lowCount"
Write-Host "================================================================"
Write-Host ""

# ---------------------------------------------------------------------------
# Write Markdown Report (if DocsRoot is provided)
# ---------------------------------------------------------------------------

if (-not [string]::IsNullOrEmpty($DocsRoot)) {
    $reportDir  = Join-Path $DocsRoot "99-devops"
    $reportPath = Join-Path $reportDir "security-report.md"

    if (-not (Test-Path $reportDir)) {
        New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    }

    $severityIcon = @{ "High" = "🔴 High"; "Medium" = "🟡 Medium"; "Low" = "🟢 Low" }

    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("# $ProjectName — Security Scan Report")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("> Scan Date: $scanDate")
    [void]$sb.AppendLine("> Source Path: $SourceRoot")
    [void]$sb.AppendLine("> Scan Scope: Full project — Java + ZUL + properties + pom.xml")
    [void]$sb.AppendLine("> Total Issues: $($findings.Count)  |  High: $highCount  |  Medium: $medCount  |  Low: $lowCount")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("## Issue List")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("| # | Severity | ID | Type | File | Line | Finding | Recommended Fix |")
    [void]$sb.AppendLine("|---|----------|----|------|------|------|---------|-----------------|")

    foreach ($f in $findings) {
        $sev = $severityIcon[$f.Severity]
        $content = $f.Content -replace '\|', '\|'
        [void]$sb.AppendLine("| $($f.Num) | $sev | $($f.Id) | $($f.Type) | ``$($f.File)`` | $($f.Line) | ``$content`` | $($f.Recommendation) |")
    }

    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("## Severity Definitions")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("| Severity | Description |")
    [void]$sb.AppendLine("|----------|-------------|")
    [void]$sb.AppendLine("| 🔴 High | Directly exploitable — fix immediately |")
    [void]$sb.AppendLine("| 🟡 Medium | Risk present but requires specific conditions — fix in next release |")
    [void]$sb.AppendLine("| 🟢 Low | Best practice recommendation — schedule for improvement |")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("## Items Requiring Manual Review")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("The following cannot be detected by automated scanning and require human judgment:")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("| Item | How to Confirm |")
    [void]$sb.AppendLine("|------|----------------|")
    [void]$sb.AppendLine("| Session timeout configuration | Check web.xml or Spring Security settings |")
    [void]$sb.AppendLine("| CSRF protection | Check ZK or Spring Security CSRF token configuration |")
    [void]$sb.AppendLine("| Data access isolation | Confirm query conditions restrict data to the correct user/tenant |")
    [void]$sb.AppendLine("| Password storage | Confirm BCrypt or equivalent hashing — not plaintext |")

    $sb.ToString() | Set-Content -Path $reportPath -Encoding UTF8
    Write-Host "Report written to: $reportPath"
}
