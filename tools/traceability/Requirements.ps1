<#
    The parser. Reads the hand-written requirements documents into a structured inventory
    that Sync-Requirements.ps1 and Build-Matrix.ps1 both work from.

    The documents are the source of truth (ADR-0014 decision 6), so this file is the only
    place that knows their layout. Nothing downstream re-reads the markdown.

    ASCII only. See tools/Common.ps1 for why.
#>

Set-StrictMode -Version Latest

function Get-DocsRoot {
    # tools/traceability -> tools -> repository root
    return (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

function Read-Utf8 {
    # Get-Content assumes the ANSI code page for a BOM-less file on Windows PowerShell,
    # which mangles every Norwegian character in the requirement text.
    param([Parameter(Mandatory)][string] $Path)
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function ConvertTo-PlainText {
    # Strip markdown emphasis. Issue titles and table cells render it literally.
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Markdown)

    if (-not $Markdown) { return '' }
    $t = $Markdown -replace '\*\*([^*]*)\*\*', '$1'
    $t = $t -replace '\*([^*]*)\*', '$1'
    $t = $t -replace '`([^`]*)`', '$1'
    $t = $t -replace '\[([^\]]*)\]\([^)]*\)', '$1'
    return $t.Trim()
}

function Expand-RequirementRange {
    <#
        Use cases write ranges: "FR-ACC-1..4" means FR-ACC-1 through FR-ACC-4.
        Returns the expanded list of IDs for one token; an unrecognised token returns nothing.
    #>
    param([Parameter(Mandatory)][string] $Token)

    $t = $Token.Trim()

    if ($t -match '^(?<g>(?:FR|NFR)-[A-Z0-9]+)-(?<a>\d+)\.\.(?<b>\d+)$') {
        $first = [int]$Matches['a']
        $last = [int]$Matches['b']
        if ($last -lt $first) { return @() }
        return ($first..$last | ForEach-Object { "$($Matches['g'])-$_" })
    }

    if ($t -match '^(?:FR|NFR)-[A-Z0-9]+-\d+$') { return @($t) }

    return @()
}

function Get-FunctionalRequirements {
    <#
        Parses requirements/functional-requirements.md.

        Rows look like:   | FR-ACC-1 | A visitor can register an account. | M |
        Group headings:   ## Trip logging (FR-LOG) - capability C1
                          ## Activity-tracking integrations (FR-ACT) - see ADR-0008
                          ## Reference data ... (FR-REF) - capabilities C5, C6, C12 / see ...

        The Priority cell is not uniform in the source: three rows read "W (later)",
        "W (Phase 3)" and "C (later phase)". The letter is required to come first; anything
        after it is kept as PriorityNote and otherwise ignored. A cell that does not begin
        with M, S, C or W is an error, not something to guess at.
    #>
    param([string] $Path)

    if (-not $Path) { $Path = Join-Path (Get-DocsRoot) 'requirements\functional-requirements.md' }

    $lines = (Read-Utf8 -Path $Path) -split "`r?`n"

    $requirements = [System.Collections.Generic.List[object]]::new()
    $problems = [System.Collections.Generic.List[string]]::new()
    $seen = @{}

    $group = $null
    $groupTitle = $null
    $capabilities = @()
    $anchor = $null

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        if ($line -match '^##\s+(?<title>.+)$') {
            $title = $Matches['title']

            if ($title -match '\((?<g>FR-[A-Z0-9]+)\)') {
                $group = $Matches['g']
                $groupTitle = ($title -replace '\s*\(FR-[A-Z0-9]+\).*$', '').Trim()
                $anchor = ConvertTo-GitHubAnchor -Heading $title

                $capabilities = @()
                if ($title -match 'capabilit(?:y|ies)\s+(?<c>C\d+(?:\s*,\s*C\d+)*)') {
                    $capabilities = @($Matches['c'] -split '\s*,\s*')
                }
            }
            else {
                $group = $null
            }
            continue
        }

        if ($line -notmatch '^\|\s*(?<id>FR-[A-Z0-9]+-\d+)\s*\|') { continue }

        $cells = @($line.Trim('|') -split '\|' | ForEach-Object { $_.Trim() })
        if ($cells.Count -lt 3) {
            $problems.Add("$($Matches['id']): row has $($cells.Count) cells, expected 3")
            continue
        }

        $id = $cells[0]
        $text = $cells[1]
        $priorityCell = $cells[2]

        if (-not $group) {
            $problems.Add("${id}: row appears before any '## ... (FR-XXX)' heading")
            continue
        }
        if (-not $id.StartsWith("$group-")) {
            $problems.Add("${id}: sits under the $group heading but does not belong to that group")
        }
        if ($seen.ContainsKey($id)) {
            $problems.Add("${id}: duplicate row (also at line $($seen[$id]))")
            continue
        }
        $seen[$id] = $i + 1

        if ($priorityCell -notmatch '^(?<p>[MSCW])\b\s*(?<note>.*)$') {
            $problems.Add("${id}: priority '$priorityCell' does not start with M, S, C or W")
            continue
        }
        $priority = $Matches['p']
        $priorityNote = $Matches['note'].Trim()

        $retired = $false
        if ($text -match '^\s*\*{0,2}Retired\b' -or $priorityNote -match '(?i)\bretired\b') { $retired = $true }

        $requirements.Add([pscustomobject]@{
            Id           = $id
            Group        = $group
            GroupTitle   = $groupTitle
            GroupAnchor  = $anchor
            Text         = $text
            Priority     = $priority
            PriorityNote = $priorityNote
            Capabilities = $capabilities
            Retired      = $retired
            UseCases     = @()
            Line         = $i + 1
        })
    }

    return [pscustomobject]@{
        Requirements = $requirements
        Problems     = $problems
    }
}

function ConvertTo-GitHubAnchor {
    <#
        GitHub's heading anchor rules: lower-case, drop anything that is not a letter,
        digit, space or hyphen, then each remaining space becomes one hyphen.

        Runs of spaces are NOT collapsed. A heading like "Peak & trail catalogue" loses the
        ampersand and keeps both spaces around it, so the anchor is "peak--trail-catalogue"
        with a double hyphen. Collapsing them here would produce a link that silently lands
        at the top of the file instead of the section.
    #>
    param([Parameter(Mandatory)][string] $Heading)

    $h = $Heading.ToLowerInvariant()
    $h = $h -replace '\[([^\]]*)\]\([^)]*\)', '$1'   # links -> their text
    $h = $h -replace '[*`_]', ''
    $h = $h -replace '[^a-z0-9 -]', ''
    $h = $h.Trim() -replace ' ', '-'
    return $h
}

function Get-UseCaseRequirements {
    <#
        Parses use-cases/use-cases.md for the requirement IDs each use case exercises.

        Headings:  ### UC-2 - Log a completed summit trip (turfoering)
        Lines:     - **Requirements:** FR-LOG-1..8, FR-MAP-3, FR-STAT-1.

        Returns a map of requirement ID -> list of use case IDs, plus the use case titles.
    #>
    param([string] $Path)

    if (-not $Path) { $Path = Join-Path (Get-DocsRoot) 'use-cases\use-cases.md' }

    $lines = (Read-Utf8 -Path $Path) -split "`r?`n"

    $map = @{}
    $titles = [ordered]@{}
    $current = $null

    foreach ($line in $lines) {
        if ($line -match '^###\s+(?<uc>UC-\d+)\b\s*(?<title>.*)$') {
            $current = $Matches['uc']
            # The source separates the ID from the title with an em dash. Rather than name
            # that character - a literal em dash in this file is mis-decoded by Windows
            # PowerShell, and the match then fails silently - drop any leading run of
            # non-alphanumerics, which covers a dash, a colon, or nothing at all.
            $titles[$current] = ($Matches['title'] -replace '^[^\p{L}\p{N}]+', '').Trim()
            continue
        }

        if (-not $current) { continue }
        if ($line -notmatch '\*\*Requirements:\*\*\s*(?<rest>.+)$') { continue }

        $rest = $Matches['rest']
        # Strip trailing prose such as "See [ADR-0012](...)" and any parenthetical notes.
        $rest = $rest -replace '\bSee\b.*$', ''
        $rest = $rest -replace '\([^)]*\)', ''

        # Split on separators, but not on the '..' inside a range such as FR-ACC-1..4.
        foreach ($token in ($rest -split '(?<!\.)[,;](?!\.)|\.(?!\.)(?!\d)')) {
            if ([string]::IsNullOrWhiteSpace($token)) { continue }
            foreach ($id in (Expand-RequirementRange -Token $token)) {
                if (-not $id.StartsWith('FR-')) { continue }   # NFRs are not tracked
                if (-not $map.ContainsKey($id)) { $map[$id] = [System.Collections.Generic.List[string]]::new() }
                if (-not $map[$id].Contains($current)) { $map[$id].Add($current) }
            }
        }
    }

    return [pscustomobject]@{
        Map    = $map
        Titles = $titles
    }
}

function Get-RequirementInventory {
    <#
        The joined inventory: every functional requirement, with the use cases that
        reference it. This is what both tools consume.

        Throws if the documents are inconsistent - a duplicate ID, a malformed priority,
        or a use case pointing at a requirement that does not exist. Silence here would
        mean a requirement quietly missing from the matrix (ADR-0014 decision 7).
    #>
    param(
        [string] $RequirementsPath,
        [string] $UseCasesPath,
        [switch] $WarnOnly
    )

    $fr = Get-FunctionalRequirements -Path $RequirementsPath
    $uc = Get-UseCaseRequirements -Path $UseCasesPath

    $byId = @{}
    foreach ($r in $fr.Requirements) { $byId[$r.Id] = $r }

    $problems = [System.Collections.Generic.List[string]]::new()
    foreach ($p in $fr.Problems) { $problems.Add($p) }

    foreach ($id in $uc.Map.Keys) {
        if ($byId.ContainsKey($id)) {
            $byId[$id].UseCases = @($uc.Map[$id])
        }
        else {
            $problems.Add("$id is referenced by $($uc.Map[$id] -join ', ') but has no row in functional-requirements.md")
        }
    }

    if ($problems.Count -gt 0) {
        $message = "The requirements documents are inconsistent:`n  " + ($problems -join "`n  ")
        if ($WarnOnly) { Write-Warning $message } else { throw $message }
    }

    return [pscustomobject]@{
        Requirements = $fr.Requirements
        UseCaseTitles = $uc.Titles
        Problems     = $problems
    }
}
