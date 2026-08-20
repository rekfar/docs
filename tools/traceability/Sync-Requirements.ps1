<#
.SYNOPSIS
    Create and reconcile one GitHub issue per functional requirement (ADR-0014).

.DESCRIPTION
    Reads requirements/functional-requirements.md and makes rekfar/docs match it: an issue
    for every FR that has none, and a refreshed generated block on the ones that exist.

    Idempotent. Dry run by default; pass -Apply.

    What it will never do:
      - touch anything below the traceability:end marker in an issue body. Acceptance
        criteria and discussion belong to the maintainer.
      - close, delete, or rename an issue. An issue whose requirement has disappeared is
        reported for a human to decide about.
      - create a second issue for a requirement that already has one.

    Exit code 1 if -FailOnMissing is set and any requirement has no issue. That is how the
    workflow turns "somebody added a table row and forgot to run sync" into a red build.

    ASCII only. See tools/Common.ps1.

.EXAMPLE
    .\Sync-Requirements.ps1
    Show what would change.

.EXAMPLE
    .\Sync-Requirements.ps1 -Group FR-ACC -Apply
    Create just one group first, so a mistake in the generated body costs six issues.

.EXAMPLE
    .\Sync-Requirements.ps1 -Apply
#>
[CmdletBinding()]
param(
    [string]   $Repo = 'docs',
    [string[]] $Group,
    [switch]   $Apply,
    [switch]   $FailOnMissing,
    [string]   $ShowBody,
    [int]      $ThrottleMs = 1500
)

. "$PSScriptRoot\..\Common.ps1"
. "$PSScriptRoot\Requirements.ps1"
$ErrorActionPreference = 'Stop'

$full = "$script:Owner/$Repo"
$docsBlobBase = "https://github.com/$full/blob/main/requirements/functional-requirements.md"

$BeginMarker = '<!-- traceability:begin - generated from requirements/functional-requirements.md; do not edit -->'
$EndMarker   = '<!-- traceability:end -->'

$priorityLabel = @{ M = 'priority:must'; S = 'priority:should'; C = 'priority:could'; W = 'priority:wont' }
$priorityWord  = @{ M = 'Must';          S = 'Should';          C = 'Could';          W = "Won't" }

function New-GeneratedBlock {
    param([Parameter(Mandatory)] $Requirement)

    $r = $Requirement
    $lines = [System.Collections.Generic.List[string]]::new()

    $lines.Add($BeginMarker)
    $lines.Add("Requirement: $($r.Id)")
    $lines.Add('')
    $lines.Add($r.Text)
    $lines.Add('')

    $priority = $priorityWord[$r.Priority]
    if ($r.PriorityNote) { $priority = "$priority $($r.PriorityNote)" }
    $lines.Add("- **Priority:** $($r.Priority) - $priority")

    if ($r.Capabilities.Count -gt 0) {
        $lines.Add("- **Capability:** " + ($r.Capabilities -join ', '))
    }

    if ($r.UseCases.Count -gt 0) {
        $ucs = @($r.UseCases | Sort-Object { [int]($_ -replace '\D', '') })
        $lines.Add("- **Use cases:** " + ($ucs -join ', '))
    }
    else {
        $lines.Add('- **Use cases:** none reference this requirement')
    }

    $lines.Add("- **Documentation:** [$($r.Group) in functional-requirements.md]($docsBlobBase#$($r.GroupAnchor))")

    if ($r.Retired) {
        $lines.Add('')
        $lines.Add('**This requirement is marked Retired in the requirements table.**')
    }

    $lines.Add($EndMarker)

    return ($lines -join "`n")
}

function New-IssueBody {
    param([Parameter(Mandatory)] $Requirement)

    return (New-GeneratedBlock -Requirement $Requirement) + @"


## Acceptance criteria

_Not defined yet. Fill these in when this requirement comes up for work; everything below
the marker above is yours and sync will not touch it._

- [ ]
"@
}

function Merge-IssueBody {
    <#
        Replace only the generated block, keeping everything the maintainer wrote.
        An issue without markers is adopted: the block is prepended and the existing body
        kept underneath.
    #>
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Existing,
        [Parameter(Mandatory)][string] $Block
    )

    $begin = $Existing.IndexOf($BeginMarker)
    $end = $Existing.IndexOf($EndMarker)

    if ($begin -ge 0 -and $end -gt $begin) {
        $after = $Existing.Substring($end + $EndMarker.Length)
        return $Existing.Substring(0, $begin) + $Block + $after
    }

    if ([string]::IsNullOrWhiteSpace($Existing)) { return $Block }
    return $Block + "`n`n" + $Existing.TrimStart()
}

function Get-RequirementIdFromIssue {
    param([Parameter(Mandatory)] $Issue)

    $body = ''
    if ($Issue.body) { $body = $Issue.body }
    if ($body -match '(?m)^\s*Requirement:\s*(?<id>FR-[A-Z0-9]+-\d+)\s*$') { return $Matches['id'] }
    if ($Issue.title -match '^(?<id>FR-[A-Z0-9]+-\d+)\b') { return $Matches['id'] }
    return $null
}

# ---------------------------------------------------------------------------------------

if ($ShowBody) {
    # Print exactly what would be posted, without touching GitHub or needing a token.
    $r = (Get-RequirementInventory).Requirements | Where-Object { $_.Id -eq $ShowBody }
    if (-not $r) { throw "No such requirement: $ShowBody" }
    Write-Host ("TITLE: $($r.Id): " + (ConvertTo-PlainText -Markdown $r.Text)) -ForegroundColor Cyan
    Write-Host '--- body ---' -ForegroundColor Cyan
    New-IssueBody -Requirement $r
    exit 0
}

Assert-GhScope -Scope 'repo'

$inventory = Get-RequirementInventory
$requirements = $inventory.Requirements
if ($Group) { $requirements = @($requirements | Where-Object { $Group -contains $_.Group }) }

if (-not $Apply) {
    Write-Host 'DRY RUN - nothing will be changed. Re-run with -Apply.' -ForegroundColor Cyan
}
Write-Host ("Requirements in scope: {0}" -f $requirements.Count)

# Milestone titles to numbers: the REST API identifies a milestone by number.
$milestoneNumbers = @{}
foreach ($m in (Invoke-GhJson @('api', "repos/$full/milestones?state=all&per_page=100"))) {
    $milestoneNumbers[$m.title] = $m.number
}

# Existing requirement issues, indexed by requirement ID.
$issues = Invoke-GhJson @('issue', 'list', '--repo', $full, '--label', 'requirement',
                          '--state', 'all', '--limit', '500',
                          '--json', 'number,title,body,labels,milestone,state,url')

$byRequirement = @{}
$duplicates = [System.Collections.Generic.List[string]]::new()
$orphans = [System.Collections.Generic.List[object]]::new()

$knownIds = @{}
foreach ($r in $inventory.Requirements) { $knownIds[$r.Id] = $true }

foreach ($issue in $issues) {
    $id = Get-RequirementIdFromIssue -Issue $issue
    if (-not $id) {
        $orphans.Add([pscustomobject]@{ Issue = $issue; Reason = 'no requirement ID in title or body' })
        continue
    }
    if (-not $knownIds.ContainsKey($id)) {
        $orphans.Add([pscustomobject]@{ Issue = $issue; Reason = "$id is not in functional-requirements.md" })
        continue
    }
    if ($byRequirement.ContainsKey($id)) {
        $duplicates.Add("$id is claimed by #$($byRequirement[$id].number) and #$($issue.number)")
        continue
    }
    $byRequirement[$id] = $issue
}

if ($duplicates.Count -gt 0) {
    throw ("The 1:1 rule is broken - two issues claim the same requirement:`n  " + ($duplicates -join "`n  "))
}

Write-Host ("Existing requirement issues: {0}" -f $byRequirement.Count)
Write-Host ''

$counts = @{ create = 0; update = 0; skip = 0; warn = 0 }
$missing = [System.Collections.Generic.List[string]]::new()

foreach ($r in ($requirements | Sort-Object Group, { [int]($_.Id -replace '^.*-', '') })) {
    $block = New-GeneratedBlock -Requirement $r
    $title = "$($r.Id): " + (ConvertTo-PlainText -Markdown $r.Text)
    if ($title.Length -gt 250) { $title = $title.Substring(0, 247) + '...' }

    $wantLabels = @('requirement', $r.Group, $priorityLabel[$r.Priority])
    $wantMilestone = $null
    if ($r.Priority -eq 'W') { $wantMilestone = 'Later' }

    $issue = $null
    if ($byRequirement.ContainsKey($r.Id)) { $issue = $byRequirement[$r.Id] }

    if (-not $issue) {
        $missing.Add($r.Id)
        Write-Plan -Action create -Target $r.Id -Detail ($wantLabels -join ' ')
        $counts.create++

        if ($Apply) {
            # Created through the REST API rather than `gh issue create` so the title and
            # body travel in a JSON file instead of on a command line. See Invoke-GhApiJson.
            $payload = @{
                title  = $title
                body   = (New-IssueBody -Requirement $r)
                labels = @($wantLabels)
            }
            if ($wantMilestone) {
                if (-not $milestoneNumbers.ContainsKey($wantMilestone)) {
                    throw "Milestone '$wantMilestone' does not exist in $full. Run tools/setup/Sync-Milestones.ps1 -Apply first."
                }
                # The REST API takes a milestone number; only the CLI accepts a title.
                $payload.milestone = $milestoneNumbers[$wantMilestone]
            }
            Invoke-GhApiJson -Endpoint "repos/$full/issues" -Method POST -Body $payload | Out-Null

            # Issue creation is content-creating, so it is governed by GitHub's secondary
            # rate limit rather than the hourly one. 73 issues fired as fast as the API
            # accepts them will trip it.
            Start-Sleep -Milliseconds $ThrottleMs
        }
        continue
    }

    $changes = [System.Collections.Generic.List[string]]::new()

    $existingBody = ''
    if ($issue.body) { $existingBody = $issue.body }
    $newBody = Merge-IssueBody -Existing $existingBody -Block $block
    if ($newBody -ne $existingBody) { $changes.Add('body') }

    if ($issue.title -ne $title) { $changes.Add('title') }

    $haveLabels = @($issue.labels | ForEach-Object { $_.name })
    $addLabels = @($wantLabels | Where-Object { $haveLabels -notcontains $_ })
    # Only priority labels are exclusive; other labels the maintainer added are theirs.
    $stalePriority = @($haveLabels | Where-Object { $_ -like 'priority:*' -and $_ -ne $priorityLabel[$r.Priority] })
    if ($addLabels.Count -gt 0) { $changes.Add('labels +' + ($addLabels -join ',')) }
    if ($stalePriority.Count -gt 0) { $changes.Add('labels -' + ($stalePriority -join ',')) }

    if ($changes.Count -eq 0) {
        Write-Plan -Action skip -Target $r.Id
        $counts.skip++
        continue
    }

    Write-Plan -Action update -Target ("$($r.Id)  #$($issue.number)") -Detail ($changes -join '; ')
    $counts.update++

    if ($Apply) {
        # Title and body through the API, for the same reason as creation.
        $patch = @{}
        if ($changes -contains 'title') { $patch.title = $title }
        if ($changes -contains 'body') { $patch.body = $newBody }
        if ($patch.Count -gt 0) {
            Invoke-GhApiJson -Endpoint "repos/$full/issues/$($issue.number)" -Method PATCH -Body $patch | Out-Null
        }

        # Labels stay on the CLI. Their values are short ASCII names with no quoting
        # hazard, and --add-label/--remove-label change only the labels named. Sending
        # labels in the PATCH would replace the whole set and silently drop any the
        # maintainer added by hand.
        $ghArgs = @('issue', 'edit', [string]$issue.number, '--repo', $full)
        $labelChange = $false
        foreach ($l in $addLabels) { $ghArgs += @('--add-label', $l); $labelChange = $true }
        foreach ($l in $stalePriority) { $ghArgs += @('--remove-label', $l); $labelChange = $true }
        if ($labelChange) { Invoke-Gh $ghArgs | Out-Null }
    }
}

foreach ($o in $orphans) {
    Write-Plan -Action warn -Target ("#$($o.Issue.number)") -Detail $o.Reason
    $counts.warn++
}

Write-Host ''
if ($Apply) { $verb = 'Applied' } else { $verb = 'Dry run' }
Write-Host ($verb + ': ' + $counts.create + ' to create, ' + $counts.update + ' to update, ' +
            $counts.skip + ' already correct, ' + $counts.warn + ' to review.')

if ($FailOnMissing -and $missing.Count -gt 0) {
    Write-Host ''
    Write-Error ("These requirements have no issue. Run Sync-Requirements.ps1 -Apply:`n  " +
                 ($missing -join ', '))
    exit 1
}
