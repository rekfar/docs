<#
.SYNOPSIS
    Create the roadmap-phase milestones in rekfar/docs, where the requirement issues live.

.DESCRIPTION
    The milestones mirror the phases in architecture/06-roadmap.md, plus "Later" for
    requirements scheduled out (MoSCoW W).

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
        Title       = 'Phase 1 - MVP'
        Description = 'Personal summit log on a map: account, map, peak catalogue, trip logging, planning, basic stats. See architecture/06-roadmap.md.'
    },
    [pscustomobject]@{
        Title       = 'Phase 2 - Richer logging and data'
        Description = 'GPX import, Strava, cabins, guestbook, trails layer, photos, wishlist, export, achievements.'
    },
    [pscustomobject]@{
        Title       = 'Phase 3 - Polish, sharing and reach'
        Description = 'Per-trip sharing, friends and tagging, more activity services, better stats, accessibility, English UI.'
    },
    [pscustomobject]@{
        Title       = 'Phase 4 - Native app'
        Description = 'Native client on the same API: live GPS recording, offline maps.'
    },
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
