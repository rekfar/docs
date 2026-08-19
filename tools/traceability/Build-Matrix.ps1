<#
.SYNOPSIS
    Regenerate requirements/traceability.md from the requirement issues and their pull requests.

.DESCRIPTION
    Joins the hand-written requirement text to the state GitHub already knows, and writes the
    result to requirements/traceability.md. Status is derived on every run, never stored, so a
    missed webhook or a failed run is corrected by the next one rather than persisting
    (ADR-0014 decision 7).

    Requirements with no issue still appear, as "Not started". That is the half of a
    traceability matrix that carries information.

    Writes nothing unless the content changed, so the workflow can commit unconditionally
    and produce no commit when there is nothing to say.

    ASCII only. See tools/Common.ps1.

.EXAMPLE
    .\Build-Matrix.ps1
    Write requirements/traceability.md.

.EXAMPLE
    .\Build-Matrix.ps1 -Check
    Exit 1 if the file on disk is out of date. Used by the workflow.
#>
[CmdletBinding()]
param(
    [string] $Repo = 'docs',
    [string] $OutputPath,
    [switch] $Check
)

. "$PSScriptRoot\..\Common.ps1"
. "$PSScriptRoot\Requirements.ps1"
$ErrorActionPreference = 'Stop'

$full = "$script:Owner/$Repo"
if (-not $OutputPath) { $OutputPath = Join-Path (Get-DocsRoot) 'requirements\traceability.md' }

$statusOrder = @{
    'Retired'      = 0
    'Implemented'  = 1
    'In review'    = 2
    'In progress'  = 3
    'Not started'  = 4
    'Deferred'     = 5
}

function Get-RequirementIssues {
    <#
        One query for the issues, their state, and the pull requests that closed them.
        closedByPullRequestsReferences is what makes the PR/merge columns possible without
        anyone writing them down.
    #>
    $query = @'
query($owner: String!, $repo: String!, $cursor: String) {
  repository(owner: $owner, name: $repo) {
    issues(first: 100, after: $cursor, labels: ["requirement"], states: [OPEN, CLOSED]) {
      pageInfo { hasNextPage endCursor }
      nodes {
        number
        title
        url
        state
        body
        closedAt
        labels(first: 20) { nodes { name } }
        closedByPullRequestsReferences(first: 10, includeClosedPrs: true) {
          nodes {
            number
            url
            state
            isDraft
            merged
            mergedAt
            repository { nameWithOwner }
            mergeCommit { oid url }
          }
        }
      }
    }
  }
}
'@

    $queryFile = Join-Path ([System.IO.Path]::GetTempPath()) 'rekfar-traceability-query.graphql'
    [System.IO.File]::WriteAllText($queryFile, $query, [System.Text.Encoding]::ASCII)

    $all = [System.Collections.Generic.List[object]]::new()
    $cursor = $null

    while ($true) {
        $args = @('api', 'graphql', '-F', "query=@$queryFile", '-F', "owner=$script:Owner", '-F', "repo=$Repo")
        if ($cursor) { $args += @('-F', "cursor=$cursor") }

        $page = (Invoke-GhJson $args).data.repository.issues
        foreach ($n in $page.nodes) { $all.Add($n) }

        if (-not $page.pageInfo.hasNextPage) { break }
        $cursor = $page.pageInfo.endCursor
    }

    Remove-Item $queryFile -ErrorAction SilentlyContinue
    return $all
}

function Get-DerivedStatus {
    param($Requirement, $Issue)

    if ($Requirement.Retired) { return 'Retired' }
    if (-not $Issue) {
        if ($Requirement.Priority -eq 'W') { return 'Deferred' }
        return 'Not started'
    }

    $prs = @($Issue.closedByPullRequestsReferences.nodes)

    if ($Issue.state -eq 'CLOSED') {
        if ($prs | Where-Object { $_.merged }) { return 'Implemented' }
        # Closed without a merged pull request: real, and worth showing as itself rather
        # than being rounded up to Implemented.
        return 'Closed, no merged PR'
    }

    $open = @($prs | Where-Object { $_.state -eq 'OPEN' })
    if ($open | Where-Object { -not $_.isDraft }) { return 'In review' }
    if ($open.Count -gt 0) { return 'In progress' }
    if ($Requirement.Priority -eq 'W') { return 'Deferred' }
    return 'Not started'
}

function Format-Cell {
    # A literal pipe would end the table cell.
    param([AllowEmptyString()][string] $Text)
    if (-not $Text) { return '' }
    return ($Text -replace '\|', '\|')
}

# ---------------------------------------------------------------------------------------

Assert-GhScope -Scope 'repo'

$inventory = Get-RequirementInventory
$issues = Get-RequirementIssues

$byRequirement = @{}
foreach ($issue in $issues) {
    $id = $null
    if ($issue.body -and $issue.body -match '(?m)^\s*Requirement:\s*(?<id>FR-[A-Z0-9]+-\d+)\s*$') { $id = $Matches['id'] }
    elseif ($issue.title -match '^(?<id>FR-[A-Z0-9]+-\d+)\b') { $id = $Matches['id'] }
    if ($id -and -not $byRequirement.ContainsKey($id)) { $byRequirement[$id] = $issue }
}

$rows = [System.Collections.Generic.List[object]]::new()
foreach ($r in $inventory.Requirements) {
    $issue = $null
    if ($byRequirement.ContainsKey($r.Id)) { $issue = $byRequirement[$r.Id] }

    $prs = @()
    $merged = $null
    if ($issue) {
        $prs = @($issue.closedByPullRequestsReferences.nodes)
        $mergedPr = $prs | Where-Object { $_.merged } | Select-Object -First 1
        if ($mergedPr) { $merged = $mergedPr }
    }

    $rows.Add([pscustomobject]@{
        Requirement = $r
        Issue       = $issue
        Prs         = $prs
        Merged      = $merged
        Status      = (Get-DerivedStatus -Requirement $r -Issue $issue)
    })
}

# ---- render ---------------------------------------------------------------------------

$out = [System.Collections.Generic.List[string]]::new()

$out.Add('# Traceability matrix')
$out.Add('')
$out.Add('> **Generated file - do not edit.**')
$out.Add('> Written by `tools/traceability/Build-Matrix.ps1`. Any hand-edit is overwritten on the')
$out.Add('> next run. The requirement text is owned by')
$out.Add('> [functional-requirements.md](functional-requirements.md); the status is owned by the')
$out.Add('> issues and pull requests. This file only joins them ([ADR-0014](../adr/0014-requirements-traceability.md)).')
$out.Add('')
$out.Add('Non-functional requirements are deliberately absent: they get no issues, because a')
$out.Add('standing constraint never closes. See')
$out.Add('[non-functional-requirements.md](non-functional-requirements.md).')
$out.Add('')

# Summary by status.
$out.Add('## Summary')
$out.Add('')
$out.Add('| Status | Requirements |')
$out.Add('| --- | --- |')
foreach ($g in ($rows | Group-Object Status | Sort-Object { $statusOrder[$_.Name] }, Name)) {
    $out.Add("| $($g.Name) | $($g.Count) |")
}
$out.Add("| **Total** | **$($rows.Count)** |")
$out.Add('')

# By group.
$out.Add('## By requirement group')
$out.Add('')
$out.Add('| Group | Total | Implemented | In progress | Not started | Deferred |')
$out.Add('| --- | --- | --- | --- | --- | --- |')
foreach ($g in ($rows | Group-Object { $_.Requirement.Group } | Sort-Object Name)) {
    $t = $g.Group
    $impl = @($t | Where-Object { $_.Status -eq 'Implemented' }).Count
    $prog = @($t | Where-Object { $_.Status -in @('In progress', 'In review') }).Count
    $none = @($t | Where-Object { $_.Status -eq 'Not started' }).Count
    $def  = @($t | Where-Object { $_.Status -eq 'Deferred' }).Count
    $out.Add("| $($g.Name) | $($g.Count) | $impl | $prog | $none | $def |")
}
$out.Add('')

# By use case.
$out.Add('## By use case')
$out.Add('')
$out.Add('| Use case | Requirements | Implemented |')
$out.Add('| --- | --- | --- |')
foreach ($uc in $inventory.UseCaseTitles.Keys) {
    $serving = @($rows | Where-Object { $_.Requirement.UseCases -contains $uc })
    if ($serving.Count -eq 0) { continue }
    $impl = @($serving | Where-Object { $_.Status -eq 'Implemented' }).Count
    $title = Format-Cell (ConvertTo-PlainText -Markdown $inventory.UseCaseTitles[$uc])
    $out.Add("| [$uc](../use-cases/use-cases.md) $title | $($serving.Count) | $impl / $($serving.Count) |")
}
$out.Add('')

# The matrix itself, one heading per requirement so every ID has a stable deep link.
$out.Add('## Requirements')
$out.Add('')

foreach ($row in $rows) {
    $r = $row.Requirement
    $out.Add("### $($r.Id)")
    $out.Add('')
    $out.Add($r.Text)
    $out.Add('')

    $facts = [System.Collections.Generic.List[string]]::new()
    $facts.Add("| Status | **$($row.Status)** |")
    $priority = $r.Priority
    if ($r.PriorityNote) { $priority = "$priority $($r.PriorityNote)" }
    $facts.Add("| Priority | $priority |")
    $facts.Add("| Group | [$($r.Group)](functional-requirements.md#$($r.GroupAnchor)) |")
    if ($r.Capabilities.Count -gt 0) { $facts.Add("| Capability | $($r.Capabilities -join ', ') |") }
    if ($r.UseCases.Count -gt 0) {
        $ucs = @($r.UseCases | Sort-Object { [int]($_ -replace '\D', '') })
        $facts.Add("| Use cases | $($ucs -join ', ') |")
    }

    if ($row.Issue) {
        $facts.Add("| Issue | [#$($row.Issue.number)]($($row.Issue.url)) |")
    }
    else {
        $facts.Add('| Issue | none |')
    }

    if ($row.Prs.Count -gt 0) {
        $links = @($row.Prs | ForEach-Object {
            $label = $_.repository.nameWithOwner + '#' + $_.number
            "[$label]($($_.url))"
        })
        $facts.Add("| Pull requests | $($links -join ', ') |")
    }

    if ($row.Merged) {
        $when = ''
        if ($row.Merged.mergedAt) { $when = ([datetime]$row.Merged.mergedAt).ToString('yyyy-MM-dd') }
        $facts.Add("| Merged | $when |")
        if ($row.Merged.mergeCommit) {
            $short = $row.Merged.mergeCommit.oid.Substring(0, 7)
            $facts.Add("| Commit | [``$short``]($($row.Merged.mergeCommit.url)) |")
        }
    }

    $out.Add('| | |')
    $out.Add('| --- | --- |')
    foreach ($f in $facts) { $out.Add($f) }
    $out.Add('')
}

$content = ($out -join "`n").TrimEnd() + "`n"

$existing = ''
if (Test-Path $OutputPath) { $existing = Read-Utf8 -Path $OutputPath }

if ($existing -eq $content) {
    Write-Host 'traceability.md is up to date.'
    exit 0
}

if ($Check) {
    Write-Error 'traceability.md is out of date. Run tools/traceability/Build-Matrix.ps1.'
    exit 1
}

[System.IO.File]::WriteAllText($OutputPath, $content, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("Wrote {0} ({1} requirements)." -f $OutputPath, $rows.Count)
