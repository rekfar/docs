# Setup tooling

One-off, idempotent scripts that put the GitHub side of
[ADR-0014](../../adr/0014-requirements-traceability.md) in place: the labels, the project
fields, and the milestones the requirement issues are filed against.

These are **setup**, not the traceability tooling itself. `tools/traceability` — which creates
and reconciles the requirement issues and generates the matrix — is separate and comes later.

## The scripts

| Script | Touches | What |
| --- | --- | --- |
| `Sync-Labels.ps1` | all four repos | Creates the label set in [`labels.json`](labels.json) |
| `Sync-ProjectFields.ps1` | project #1 | Creates the custom fields on "Project management" |
| `Sync-Milestones.ps1` | `docs` | Creates the roadmap-phase milestones |

All three:

- **Dry run by default.** They print exactly what they would do; pass `-Apply` to do it.
- **Are idempotent.** A second run reports only skips.
- **Never delete or rename.** A label, field, or milestone carries data on issues that already
  reference it. Removals are reported so you can decide, not performed.

```powershell
.\Sync-Labels.ps1                 # show
.\Sync-Labels.ps1 -Apply          # do
.\Sync-Labels.ps1 -Repo docs      # narrow it
```

They need `gh` authenticated with the `repo` and `project` scopes:

```
gh auth refresh -s project
```

Each script checks the scope it needs up front, so a missing one fails immediately with the
command to fix it rather than half-way through.

## Two conventions worth knowing before editing these

**The `.ps1` files are ASCII only.** Windows PowerShell 5.1 reads a BOM-less `.ps1` as the
system ANSI code page, so a UTF-8 em dash arrives as a smart quote — which PowerShell treats
as a string delimiter, producing a parse error nowhere near the actual character. Keeping the
scripts ASCII means they behave the same in Windows PowerShell and in `pwsh` on CI. Data files
may hold any character, but must be **read explicitly as UTF-8**, which is why `Sync-Labels.ps1`
uses `File::ReadAllText(..., UTF8)` rather than `Get-Content`.

**Configuration is JSON, not YAML.** The plan said `labels.yml`. Neither Windows PowerShell nor
`pwsh` can parse YAML without an installed module, and ADR-0014 chose PowerShell precisely so
there would be no build or install step. `ConvertFrom-Json` is built in. Nothing else in this
project needs a YAML parser: the workflow files and issue forms are parsed by GitHub, not by us.

## Where this departs from the plan in rekfar/docs#4

| Planned | Actual | Why |
| --- | --- | --- |
| Label per requirement ID | Group labels only (`FR-MAP`, ...) | 73 labels x 4 repos is unusable; the ID is in the issue title and body |
| All labels in all repos | `requirement` everywhere; the rest only in `docs` | Requirement issues live in `docs`. `requirement` is needed everywhere because the work-item template applies it |
| *Use case* single-select | **Text** | A requirement can serve several use cases (FR-LOG-8 serves UC-2, UC-6, UC-13); a single-select would silently drop all but one |
| *Layer* single-select | **No field** — the `layer:*` labels | Multi-valued too, and labels already handle it. The board can filter on labels |
| Status: Backlog / In Progress / In Review / Done | Left as Todo / In Progress / Done | See below |

### The Status field is not modified

`Sync-ProjectFields.ps1` prints a note instead of changing it. The GraphQL mutation for
single-select options **replaces the whole option set** rather than appending to it, so a
mistake clears Status on every item already on the board. Adding "In Review" by hand in the
project settings takes seconds and cannot go wrong.

Nothing depends on it either way: the traceability matrix derives *In review* from the pull
request, not from this field ([ADR-0014](../../adr/0014-requirements-traceability.md)
decision 8).

## What is on GitHub after running these

- **25 labels** — `requirement` in all four repos; 13 `FR-*` group labels, 4 `priority:*`,
  and 4 `layer:*` in `docs`
- **4 project fields** — Requirement ID (text), Use case (text), Priority (single-select),
  Phase (single-select)
- **5 milestones in `docs`** — Phase 1 to Phase 4, and Later

The other repositories' own milestones are untouched.
