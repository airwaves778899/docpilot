# docpilot installer for Windows
# Usage: irm https://raw.githubusercontent.com/.../install.ps1 | iex
$SkillDir = "$env:USERPROFILE\.claude\skills"
$SkillFile = "$SkillDir\docpilot.md"
$RepoUrl = "https://raw.githubusercontent.com/airwaves778899/docpilot/main/skill/SKILL.md"

Write-Host "📚 Installing docpilot..."
New-Item -ItemType Directory -Path $SkillDir -Force | Out-Null
Invoke-WebRequest -Uri $RepoUrl -OutFile $SkillFile -UseBasicParsing
Write-Host "✅ docpilot installed to $SkillFile"
Write-Host ""
Write-Host "Restart Claude Code or Cowork, then say:"
Write-Host '  "produce documentation for my project"'
