<#
.SYNOPSIS
    Create or update the requirement-tracking labels across the rekfar repositories.

.DESCRIPTION
    Reads labels.json and reconciles each repository against it. Idempotent: a second run
    reports only skips. Labels are never deleted. A label removed from labels.json is
    reported and left in place, because open issues may still carry it.

    Dry run by default. Pass -Apply to make changes.

    ASCII only. See the note in Common.ps1.

.EXAMPLE
    .\Sync-Labels.ps1
    Show what would change.

.EXAMPLE
    .\Sync-Labels.ps1 -Apply
    Apply it.

.EXAMPLE
    .\Sync-Labels.ps1 -Repo docs -Apply
    Only the docs repository.
#>
[CmdletBinding()]
param(
    [string]   $ConfigPath,
    [string[]] $Repo,
    [switch]   $Apply
)

. "$PSScriptRoot\..\Common.ps1"
$ErrorActionPreference = 'Stop'

# Not defaulted in the param block: Windows PowerShell does not populate $PSScriptRoot there.
if (-not $ConfigPath) { $ConfigPath = Join-Path $PSScriptRoot 'labels.json' }

Assert-GhScope -Scope 'repo'

# Read as UTF-8 explicitly. Get-Content assumes the ANSI code page for a BOM-less file on
# Windows PowerShell, which would send mangled label descriptions to GitHub.
$config = [System.IO.File]::ReadAllText($ConfigPath, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
$wanted = $config.labels

if ($Repo) {
    $repos = $Repo
}
else {
    $repos = $wanted.repos | ForEach-Object { $_ } | Sort-Object -Unique
}

if (-not $Apply) {
    Write-Host 'DRY RUN - nothing will be changed. Re-run with -Apply.' -ForegroundColor Cyan
}

$counts = @{ create = 0; update = 0; skip = 0; warn = 0 }

foreach ($r in $repos) {
    $full = "$script:Owner/$r"
    Write-Host ''
    Write-Host $full -ForegroundColor White

    $existing = @{}
    $listed = Invoke-GhJson @('label', 'list', '--repo', $full, '--limit', '200', '--json', 'name,color,description')
    foreach ($l in $listed) { $existing[$l.name] = $l }

    $wantedHere = @($wanted | Where-Object { $_.repos -contains $r })

    foreach ($l in $wantedHere) {
        $have = $existing[$l.name]

        if (-not $have) {
            Write-Plan -Action create -Target $l.name -Detail $l.description
            $counts.create++
            if ($Apply) {
                Invoke-Gh @('label', 'create', $l.name, '--repo', $full,
                            '--color', $l.color, '--description', $l.description) | Out-Null
            }
            continue
        }

        # gh reports the colour without a leading '#', in lower case.
        $drift = @()
        if ($have.color -ne $l.color.ToLower()) {
            $drift += 'colour ' + $have.color + ' -> ' + $l.color.ToLower()
        }
        if ($have.description -ne $l.description) { $drift += 'description' }

        if ($drift.Count -gt 0) {
            Write-Plan -Action update -Target $l.name -Detail ($drift -join ', ')
            $counts.update++
            if ($Apply) {
                Invoke-Gh @('label', 'edit', $l.name, '--repo', $full,
                            '--color', $l.color, '--description', $l.description) | Out-Null
            }
        }
        else {
            Write-Plan -Action skip -Target $l.name
            $counts.skip++
        }
    }

    # Labels whose namespace this tool owns, but that are no longer in labels.json.
    $ownedPrefixes = @('FR-', 'priority:', 'layer:')
    foreach ($name in $existing.Keys) {
        $isOurs = $false
        if ($name -eq 'requirement') { $isOurs = $true }
        foreach ($p in $ownedPrefixes) { if ($name.StartsWith($p)) { $isOurs = $true } }

        if ($isOurs -and -not ($wantedHere.name -contains $name)) {
            Write-Plan -Action warn -Target $name -Detail 'not in labels.json; left in place, remove by hand if intended'
            $counts.warn++
        }
    }
}

if ($Apply) { $verb = 'Applied' } else { $verb = 'Dry run' }
Write-Host ''
Write-Host ($verb + ': ' + $counts.create + ' to create, ' + $counts.update + ' to update, ' +
            $counts.skip + ' already correct, ' + $counts.warn + ' to review.')
