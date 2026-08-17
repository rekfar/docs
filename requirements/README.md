# Requirements

Requirements are the centre of TOGAF's Requirements Management phase: every other document
either produces them or consumes them. This page is the **working convention** — what lives
where, how a requirement connects to the work that implements it, and what to do when
something changes.

The decision behind it is [ADR-0014](../adr/0014-requirements-traceability.md).

## The documents

| File | Contents | Maintained |
| --- | --- | --- |
| [functional-requirements.md](functional-requirements.md) | 73 `FR-*` requirements, grouped by capability, with MoSCoW priority | **By hand** — the source of truth |
| [non-functional-requirements.md](non-functional-requirements.md) | `NFR-*` quality attributes | **By hand** |
| `traceability.md` | Every `FR-*` with its current status, issue, pull request, and merge date | **Generated** — never edit |

`traceability.md` is written by `tools/traceability`. Editing it by hand is pointless: the
next scheduled run overwrites it.

## The ID scheme

```
FR-MAP-2        functional requirement, group MAP, number 2
NFR-PERF-1      non-functional requirement, group PERF, number 1
UC-5            use case 5
C4              business capability 4
```

Two rules make the IDs worth relying on:

- **An ID is permanent.** Never reused, never renumbered. Issues, pull requests, commit
  messages, and ADRs point at these strings.
- **A dropped requirement is retired, not deleted.** Mark it `Retired` in the table and leave
  the row. Deleting it silently breaks every reference to it.

## How a requirement connects to the work

```
UC-5                        use-cases/use-cases.md
  ↓
FR-MAP-2                    functional-requirements.md          ← the source of truth
  ↓
issue rekfar/docs#123       one issue per FR, created by `sync`
  ↓
issue rekfar/webapp#31      optional sub-issue, where the work is
  ↓
PR rekfar/webapp#32         "Fixes rekfar/docs#123"
  ↓
merge commit
  ↓
traceability.md             generated — joins the text to the state
```

### One issue per functional requirement

Every `FR-*` has exactly one issue, and it lives in **`rekfar/docs`** — next to the
requirement text, and not in a code repository, because a requirement such as `FR-MAP-2`
is delivered by `database`, `backend`, and `webapp` together.

**Non-functional requirements get no issues.** An `NFR-*` is a standing constraint that would
never close. Reference them from pull requests and ADRs instead; that is where the evidence
they hold belongs.

### Where the work happens

The requirement issue is not where the code gets written. Two ways to connect the two:

- **Straight through** — the pull request that implements the requirement writes
  `Fixes rekfar/docs#123` in its body. The cross-repository form is required; a plain
  `Fixes #123` in `webapp` closes `webapp#123`, which is a different issue entirely.
- **Via sub-issues** — where a requirement needs a work item per layer, add the code-repo
  issues as **sub-issues** of the `docs` requirement issue. GitHub then tracks completion
  natively.

### Referencing a requirement anywhere else

Put the ID in the text. In an issue body, a pull request, a commit message, or an ADR, the
literal string `FR-MAP-2` is the link — the tooling and GitHub search both find it. There is
no label per requirement ID; labels stay coarse (`requirement`, the group, the priority, the
layer).

## Recipes

### Add a new requirement

1. Add a row to the right group table in `functional-requirements.md`, with the next unused
   number in that group. Never fill a gap left by a retired requirement.
2. If a use case exercises it, add it to that use case's **Requirements** line in
   `use-cases.md`.
3. Run `sync`. The issue is created, labelled, and milestoned.

### Change a requirement's wording or priority

Edit the table row and run `sync`. It rewrites the generated block at the top of the issue
body and re-applies the priority label. Anything you wrote **below** the marker comment in
the issue — acceptance criteria, discussion — is left alone.

### Retire a requirement

Mark the row `Retired` in the table. `sync` reports the orphaned issue; close it by hand.
Nothing is deleted, and the ID is not reused.

### Promote a `W` requirement

The six `W` ("Won't — this time") requirements already have issues, parked with
`priority:wont` and a **Later** milestone. Change the priority in the table and run `sync`;
the existing issue is re-labelled and re-milestoned. No new issue is created.

## What is generated, and when

`tools/traceability` has two entry points over one parser, in PowerShell 7:

| Command | Does |
| --- | --- |
| `sync` | Creates and reconciles the requirement issues from the tables. Idempotent; dry-run by default. |
| `matrix` | Regenerates `traceability.md` from the issues and their linked pull requests. |

The workflow in `.github/workflows/traceability.yml` runs `matrix` daily, on demand, and on
any push touching `requirements/**`; it runs `sync` in dry-run mode and **fails** if a
requirement has no issue, so a new table row cannot be quietly forgotten.

Status in `traceability.md` is derived, never asserted:

| Status | Means |
| --- | --- |
| Deferred | Issue open at priority `W` — scheduled out, not forgotten |
| Not started | Issue open, nothing linked |
| In progress | An open pull request is linked |
| In review | The linked pull request is ready for review |
| Implemented | The issue was closed by a merged pull request |
| Retired | Marked in the requirements table |

The **Project board is a view, not a source of truth.** Its fields are for filtering; the
generator never reads them.

## Related

- [ADR-0014](../adr/0014-requirements-traceability.md) — the decision and its trade-offs
- [Use cases](../use-cases/use-cases.md) — what the requirements serve
- [Business architecture](../architecture/02-business-architecture.md) — the capabilities the
  groups map to
- [Roadmap](../architecture/06-roadmap.md) — which phase a requirement belongs to
