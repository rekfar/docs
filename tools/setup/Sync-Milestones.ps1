<#
.SYNOPSIS
    Create the "Later" milestone in rekfar/docs, where the requirement issues live.

.DESCRIPTION
    There is exactly one milestone here, and it is not a phase.

    The plan originally called for milestones mirroring the phases in
    architecture/06-roadmap.md. They were dropped: nothing in the requirements documents
    assigns a phase to a requirement, so no tool could fill them in and they would have
    decayed into hand-maintained guesses. Priority (M/S/C/W) is the scheduling axis the
    documents actually carry, and it is already a label and a project field.

    "Later" stays because ADR-0014 decision 3 depends on it: the six MoSCoW W requirements
    get issues like every other requirement, parked here rather than left absent, so that
    promoting one is a priority change and not a creation event.

    Only rekfar/docs is touched. The other repositories have their own working milestones
    ("Show peaks on map", "Webapp MVP", "Database MVP") which are the maintainer's and are
    none of this script's business.

    Idempotent, matched by title. Nothing is renamed or closed: a milestone carries the
    issues assigned to it.

    Dry run by default. Pass -Apply to make changes.

    ASCII only. See Common.ps1.

.EXAMPLE
    .\Sync-Milestones.ps1

.EXAMPLE
    .\Sync-Milestones.ps1 -Apply
#>
[CmdletBinding()]
param(
    [string] $Repo = 'docs',
    [switch] $Apply
)

. "$PSScriptRoot\Common.ps1"
$ErrorActionPreference = 'Stop'

Assert-GhScope -Scope 'repo'

$wanted = @(
    [pscustomobject]@{
        Title       = 'Later'
        Description = 'Scheduled out, not forgotten. Where MoSCoW W requirements are parked (ADR-0014 decision 3).'
    }
)

$full = "$script:Owner/$Repo"

if (-not $Apply) {
    Write-Host 'DRY RUN - nothing will be changed. Re-run with -Apply.' -ForegroundColor Cyan
}

$existing = @{}
foreach ($m in (Invoke-GhJson @('api', "repos/$full/milestones?state=all&per_page=100"))) {
    $existing[$m.title] = $m
}

Write-Host ''
Write-Host $full -ForegroundColor White

$created = 0
$skipped = 0

foreach ($m in $wanted) {
    if ($existing.ContainsKey($m.Title)) {
        Write-Plan -Action skip -Target $m.Title -Detail 'already exists'
        $skipped++
        continue
    }

    Write-Plan -Action create -Target $m.Title
    $created++

    if ($Apply) {
        Invoke-Gh @('api', '--method', 'POST', "repos/$full/milestones",
                    '-f', "title=$($m.Title)",
                    '-f', "description=$($m.Description)") | Out-Null
    }
}

Write-Host ''
if ($Apply) { $verb = 'Applied' } else { $verb = 'Dry run' }
Write-Host ($verb + ': ' + $created + ' to create, ' + $skipped + ' already present.')
