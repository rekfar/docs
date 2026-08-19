# Traceability tooling

Two entry points over one parser, implementing
[ADR-0014](../../adr/0014-requirements-traceability.md).

| File | What |
| --- | --- |
| `Requirements.ps1` | The parser. Reads the requirements and use-case documents into one inventory. The only file that knows the markdown layout. |
| `Sync-Requirements.ps1` | Creates and reconciles one issue per functional requirement. |
| `Build-Matrix.ps1` | Regenerates [`requirements/traceability.md`](../../requirements/traceability.md). |

Both entry points are dry-run by default and need `gh` authenticated with the `repo` scope.

```powershell
.\Sync-Requirements.ps1                      # what would change
.\Sync-Requirements.ps1 -ShowBody FR-MAP-2   # exactly what would be posted
.\Sync-Requirements.ps1 -Group FR-ACC -Apply # one group at a time
.\Build-Matrix.ps1                           # rewrite the matrix
.\Build-Matrix.ps1 -Check                    # exit 1 if it is stale
```

## The one rule that matters

`sync` replaces **only** the text between these two markers in an issue body:

```
<!-- traceability:begin - generated from requirements/functional-requirements.md; do not edit -->
...
<!-- traceability:end -->
```

Everything below `traceability:end` — acceptance criteria, discussion, decisions — belongs to
the maintainer and is never read or written. An issue without the markers is *adopted*: the
block is prepended and the existing body kept underneath.

It also never closes, deletes, or renames an issue, and never creates a second issue for a
requirement that already has one. Two issues claiming the same ID is a hard error, because it
breaks the 1:1 rule the whole design rests on.

## Status is derived, never stored

`Build-Matrix.ps1` recomputes every status on every run from the issue and its linked pull
requests:

| Status | From |
| --- | --- |
| Retired | Marked in the requirements table |
| Implemented | Issue closed, with a merged pull request |
| Closed, no merged PR | Issue closed without one — shown as itself rather than rounded up |
| In review | An open, non-draft pull request is linked |
| In progress | An open draft pull request is linked |
| Not started | Issue open, nothing linked |
| Deferred | Priority `W`, nothing linked |

Requirements with no issue at all still appear. That is the half of a traceability matrix
that carries information.

## Two things that will bite you

**The scripts are ASCII only.** Windows PowerShell reads a BOM-less `.ps1` as the ANSI code
page, so a UTF-8 em dash decodes to a smart quote, which PowerShell treats as a string
delimiter. The failure is a parse error pointing nowhere near the character responsible — or
worse, a regex that silently stops matching. The use-case heading parser hit exactly this and
was returning zero use cases while looking fine. Documents may contain anything; they are read
explicitly as UTF-8 via `Read-Utf8`.

**Anchors are not slugified the obvious way.** GitHub drops punctuation and then turns each
remaining space into one hyphen, without collapsing runs. `Peak & trail catalogue` becomes
`peak--trail-catalogue`, with two hyphens. Collapsing them produces a link that silently lands
at the top of the file instead of the section, which is why `ConvertTo-GitHubAnchor` replaces
spaces one-for-one.

## What runs in CI

[`.github/workflows/traceability.yml`](../../.github/workflows/traceability.yml) runs daily, on
demand, and when the requirement or use-case documents change. It runs `sync` in dry-run with
`-FailOnMissing` — so a table row added without an issue is a red build, not a silent gap —
then regenerates the matrix and commits it if it changed.

The workflow's `push` trigger deliberately lists the individual source documents rather than
`requirements/**`, because the latter would include the file this workflow writes.

`GITHUB_TOKEN` reports no scopes — its permissions come from the workflow's `permissions:`
block — so `Assert-GhScope` treats "cannot tell" as "fine" and only enforces scopes on a token
that declares them.

## Not implemented

**Project board fields are not written.** `Sync-Requirements.ps1` sets labels and the
milestone, but does not add issues to the project or fill in Requirement ID / Use case /
Priority. The board is explicitly a view rather than a source of truth
([ADR-0014](../../adr/0014-requirements-traceability.md) decision 8), the project's built-in
auto-add workflow can put issues on it without help, and doing it here would cost roughly four
extra API calls per requirement for data that is already in the issue. Worth adding only if
the board turns out to be how the work actually gets read.
