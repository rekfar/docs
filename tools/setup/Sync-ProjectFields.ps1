<#
.SYNOPSIS
    Create the custom fields the requirement issues need on the "Project management" board.

.DESCRIPTION
    Idempotent: fields that already exist are skipped. Nothing is ever deleted or renamed,
    because a field carries the values set on every item in the project.

    Dry run by default. Pass -Apply to make changes.

    Field choices, and where they depart from the plan in rekfar/docs#4:

      Requirement ID  TEXT           One FR per issue, so one value. Text, not single-select:
                                     73 options would be a menu nobody can use.
      Use case        TEXT           Deliberately NOT single-select. A requirement can serve
                                     several use cases (FR-LOG-8 serves UC-2, UC-6 and UC-13),
                                     and a single-select would silently drop all but one.
      Priority        SINGLE_SELECT  Genuinely single-valued, and the only scheduling axis
                                     the requirements documents actually carry.

    Layer has no field: it is multi-valued too (a requirement can need backend, webapp and
    database at once) and is already carried by the layer:* labels, which the board can
    filter on.

    There is no Phase field. The plan called for one, but nothing in the requirements
    documents assigns a roadmap phase to a requirement - only 3 of 73 rows carry a hint, as
    free text inside the Priority column - so the field had no source and would have been
    filled in by hand or not at all. Priority (M/S/C/W) is the scheduling axis instead.

    The built-in Status field is left alone. See the note this script prints.

    ASCII only. See Common.ps1.

.EXAMPLE
    .\Sync-ProjectFields.ps1
    Show what would change.

.EXAMPLE
    .\Sync-ProjectFields.ps1 -Apply
#>
[CmdletBinding()]
param(
    [int]    $ProjectNumber = 1,
    [switch] $Apply
)

. "$PSScriptRoot\..\Common.ps1"
$ErrorActionPreference = 'Stop'

Assert-GhScope -Scope 'project'

$wanted = @(
    [pscustomobject]@{ Name = 'Requirement ID'; DataType = 'TEXT';          Options = $null },
    [pscustomobject]@{ Name = 'Use case';       DataType = 'TEXT';          Options = $null },
    [pscustomobject]@{ Name = 'Priority';       DataType = 'SINGLE_SELECT'; Options = @('M - Must', 'S - Should', 'C - Could', 'W - Wont') }
)

if (-not $Apply) {
    Write-Host 'DRY RUN - nothing will be changed. Re-run with -Apply.' -ForegroundColor Cyan
}

$existing = @{}
foreach ($f in (Invoke-GhJson @('project', 'field-list', [string]$ProjectNumber, '--owner', $script:Owner, '--format', 'json')).fields) {
    $existing[$f.name] = $f
}

Write-Host ''
Write-Host ($script:Owner + ' project #' + $ProjectNumber) -ForegroundColor White

$created = 0
$skipped = 0

foreach ($f in $wanted) {
    if ($existing.ContainsKey($f.Name)) {
        Write-Plan -Action skip -Target $f.Name -Detail 'already exists'
        $skipped++
        continue
    }

    $detail = $f.DataType
    if ($f.Options) { $detail = $detail + ': ' + ($f.Options -join ' | ') }
    Write-Plan -Action create -Target $f.Name -Detail $detail
    $created++

    if ($Apply) {
        $args = @('project', 'field-create', [string]$ProjectNumber,
                  '--owner', $script:Owner,
                  '--name', $f.Name,
                  '--data-type', $f.DataType)
        if ($f.Options) { $args += @('--single-select-options', ($f.Options -join ',')) }
        Invoke-Gh $args | Out-Null
    }
}

Write-Host ''
if ($Apply) { $verb = 'Applied' } else { $verb = 'Dry run' }
Write-Host ($verb + ': ' + $created + ' to create, ' + $skipped + ' already present.')

# Status is deliberately not touched.
$status = $existing['Status']
if ($status) {
    $names = @($status.options | ForEach-Object { $_.name })
    if ($names -notcontains 'In Review') {
        Write-Host ''
        Write-Host 'Note: the built-in Status field has options: ' -NoNewline -ForegroundColor Yellow
        Write-Host ($names -join ', ') -ForegroundColor Yellow
        Write-Host '      The plan asks for an "In Review" option. This script will not add it:' -ForegroundColor Yellow
        Write-Host '      the GraphQL mutation replaces the entire option set rather than appending,' -ForegroundColor Yellow
        Write-Host '      so a mistake clears Status on every item already on the board. Add it by' -ForegroundColor Yellow
        Write-Host '      hand in the project settings - it takes a few seconds and cannot go wrong.' -ForegroundColor Yellow
        Write-Host '      Nothing depends on it: the traceability matrix derives "In review" from' -ForegroundColor Yellow
        Write-Host '      the pull request, not from this field (ADR-0014 decision 8).' -ForegroundColor Yellow
    }
}
