param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    [string]$Note = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$cleanVer = $Version.TrimStart('v')
$tagVer = "v$cleanVer"
$today = Get-Date -Format "yyyy-MM-dd"

# 1. Mettre à jour config.xml
$configPath = Join-Path $repoRoot "config.xml"
$configContent = Get-Content -Path $configPath -Raw -Encoding UTF8
$configContent = $configContent -replace 'version="[^"]+"', "version=`"$cleanVer`""
[System.IO.File]::WriteAllText($configPath, $configContent, [System.Text.UTF8Encoding]::new($false))

# 2. Mettre à jour index.html
$indexPath = Join-Path $repoRoot "index.html"
$indexContent = Get-Content -Path $indexPath -Raw -Encoding UTF8
$indexContent = $indexContent -replace '(<span class="app-version" id="appVersion">)[^<]+(</span>)', "`${1}$tagVer`${2}"
[System.IO.File]::WriteAllText($indexPath, $indexContent, [System.Text.UTF8Encoding]::new($false))

# 3. Générer l'entrée dans CHANGELOG.md
$changelogPath = Join-Path $repoRoot "CHANGELOG.md"
$existing = Get-Content -Path $changelogPath -Raw -Encoding UTF8

$entry = "## [$tagVer] - $today`r`n"
if ($Note) {
    $entry += "### Modifications`r`n- $Note`r`n`r`n"
} else {
    $recentCommits = git -C $repoRoot log -n 5 --pretty=format:"- %s (``%h``)"
    $entry += "### Modifications`r`n" + ($recentCommits -join "`r`n") + "`r`n`r`n"
}
$entry += "---`r`n`r`n"

$marker = "---`r`n`r`n## ["
if ($existing -match "---\r?\n\r?\n## \[") {
    $updated = $existing -replace "---\r?\n\r?\n## \[", "---`r`n`r`n$entry## ["
} else {
    $updated = $existing + "`r`n" + $entry
}
[System.IO.File]::WriteAllText($changelogPath, $updated, [System.Text.UTF8Encoding]::new($false))

Write-Host "Version mise à jour vers $tagVer dans config.xml, index.html et CHANGELOG.md."
