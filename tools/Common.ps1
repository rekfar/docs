<#
    Shared helpers for the setup scripts. Dot-source it:  . "$PSScriptRoot\Common.ps1"

    ASCII only, deliberately. Windows PowerShell 5.1 reads a BOM-less .ps1 as the system
    ANSI code page, so a UTF-8 em dash arrives as a smart quote and PowerShell treats it
    as a string delimiter. Keeping these files ASCII avoids depending on the encoding.
#>

Set-StrictMode -Version Latest

$script:Owner = 'rekfar'

function Get-GhPath {
    # gh is not always on PATH: a fresh `winget install` does not reach an already-running
    # shell. Fall back to the default install location before giving up.
    $cmd = Get-Command gh -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $candidates = @(
        (Join-Path $env:ProgramFiles 'GitHub CLI\gh.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'GitHub CLI\gh.exe'),
        (Join-Path $env:LOCALAPPDATA 'GitHubCLI\gh.exe')
    )
    foreach ($c in $candidates) { if ($c -and (Test-Path $c)) { return $c } }

    throw 'gh (GitHub CLI) not found. Install it with: winget install --id GitHub.cli'
}

function Invoke-Gh {
    # Run gh and return stdout. Throws on a non-zero exit, so a failed call cannot be
    # mistaken for an empty result.
    param([Parameter(Mandatory)][string[]] $Arguments)

    $gh = Get-GhPath
    $out = & $gh @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "gh $($Arguments -join ' ') failed with exit code ${LASTEXITCODE}:`n$out"
    }
    return ($out | Out-String)
}

function Invoke-GhJson {
    param([Parameter(Mandatory)][string[]] $Arguments)

    $text = Invoke-Gh -Arguments $Arguments
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }
    return $text | ConvertFrom-Json
}

function Assert-GhScope {
    <#
        Fail early and legibly rather than part-way through a run.

        A GitHub Actions installation token (GITHUB_TOKEN) reports no scopes at all - its
        permissions come from the workflow's `permissions:` block instead. So the absence of
        a "Token scopes:" line means "cannot tell", not "missing", and the check steps aside.
        A token that does report its scopes is held to them.
    #>
    param([Parameter(Mandatory)][string] $Scope)

    $gh = Get-GhPath
    $status = (& $gh auth status 2>&1 | Out-String)

    if ($status -notmatch 'Token scopes:') { return }

    if ($status -notmatch "'[^']*\b$([regex]::Escape($Scope))\b[^']*'") {
        throw "The gh token is missing the '$Scope' scope. Grant it with: gh auth refresh -s $Scope"
    }
}

function Write-Plan {
    # One consistent line per action, so a dry run reads like the diff it will apply.
    param(
        [Parameter(Mandatory)][ValidateSet('create', 'update', 'skip', 'warn')][string] $Action,
        [Parameter(Mandatory)][string] $Target,
        [string] $Detail
    )

    $colour = @{ create = 'Green'; update = 'Yellow'; skip = 'DarkGray'; warn = 'Red' }[$Action]
    $line = '  {0,-7} {1}' -f $Action, $Target
    if ($Detail) { $line = $line + '  (' + $Detail + ')' }
    Write-Host $line -ForegroundColor $colour
}

function Invoke-GhApiJson {
    <#
        Call the REST API with a JSON request body supplied as a FILE.

        Content is never passed as a command-line argument. Windows PowerShell and pwsh
        quote native arguments differently, and neither survives a value containing a
        double quote: the argument is split and gh reports "unknown arguments ... please
        quote all values that have spaces".

        FR-MAP-8 is the requirement that found this - its text contains
        (e.g. "Kartverket") - and FR-REF-2 would have been next. Escaping the quotes would
        work today and break on the next shell that changes its rules, so the content goes
        in a file instead and no shell ever parses it.
    #>
    param(
        [Parameter(Mandatory)][string] $Endpoint,
        [Parameter(Mandatory)][ValidateSet('POST', 'PATCH', 'PUT')][string] $Method,
        [Parameter(Mandatory)][hashtable] $Body
    )

    $json = $Body | ConvertTo-Json -Depth 10
    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        # UTF-8 with no BOM: a BOM makes gh fail to parse the payload.
        [System.IO.File]::WriteAllText($tmp, $json, (New-Object System.Text.UTF8Encoding($false)))
        return Invoke-GhJson @('api', $Endpoint, '--method', $Method, '--input', $tmp)
    }
    finally {
        Remove-Item $tmp -ErrorAction SilentlyContinue
    }
}
