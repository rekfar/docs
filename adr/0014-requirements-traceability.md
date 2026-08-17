# ADR-0014 — Requirements traceability: one issue per functional requirement

**Status:** Accepted (2026-08-17)

## Context

The documentation already gives every requirement a stable ID — `FR-<GROUP>-<n>` and
`NFR-<GROUP>-<n>` in [requirements/](../requirements/), `UC-n` in
[use-cases.md](../use-cases/use-cases.md) — and the
[roadmap](../architecture/06-roadmap.md) and several ADRs reference those IDs. What the IDs do **not** yet reach is the work: nothing connects
`FR-MAP-2` to the issue, pull request, and commit that implement it. Asking "is this
requirement built?" means reading four repositories and guessing.

Issue [#4](https://github.com/rekfar/docs/issues/4) proposed closing that gap with the
standard requirements-tracking pattern: an ID per requirement, an issue per requirement, a
`fixes #N` in the pull request, and a documentation file kept current by automation.

Four forces shaped how that pattern is applied here.

1. **The requirement inventory is a set of markdown tables, and it should stay that way.**
   73 functional requirements are rows in tables grouped by capability. The tables are
   readable, diffable, and already linked from the architecture documents. Restructuring them
   into a section per requirement — which is what per-requirement anchors would need — trades
   that readability for a linking convenience.

2. **Status is the part that rots.** A `Status:` line hand-maintained next to 73 requirements
   is accurate the week it is written. GitHub already knows whether an issue is open, which
   pull request closed it, and when it merged. Writing that down a second time creates two
   answers to one question, and the documentation is always the stale one.

3. **A requirement does not belong to a repository.** `FR-MAP-2` ("the map shows known
   mountain tops as markers") needs a table in `database`, an endpoint in `backend`, and a
   layer in `webapp`. Any single repository is the wrong home for it two thirds of the time.

4. **Work is spread across four repositories, but `GITHUB_TOKEN` is not.** The workflow #4
   sketches — each code repository writing back into `docs` when a pull request merges —
   needs a personal access token with write access to `docs` stored as a secret in three
   places, and three near-identical workflows. It is also event-sourced: one missed or failed
   run leaves the documentation wrong permanently, with nothing to detect it.

## Decision

1. **The existing IDs are kept**, unchanged. `UC-1`, `FR-MAP-2`, `NFR-PERF-1` — not the
   zero-padded `UC-001`/`REQ-002` scheme #4 sketched. Renumbering would touch every document
   and invalidate every reference already written.

2. **An ID is permanent.** It is never reused and never renumbered once assigned. A
   requirement that is dropped is marked **Retired** in the table and keeps its row; it is
   not deleted. This is the same stance [ADR-0013](0013-schema-owned-by-sql-database-project.md)
   takes for reference rows, and for the same reason: something out there already points at it.

3. **Every functional requirement gets exactly one GitHub issue — 1:1.** All 73, including
   the six at priority `W`. A `W` requirement is a real requirement that has been scheduled
   out, so it carries `priority:wont` and a **Later** milestone rather than being absent;
   promoting it is then a priority change rather than a creation event.

4. **Non-functional requirements get no issues.** An `NFR-*` is a standing quality constraint,
   not a unit of work — it would never close, and a permanently-open issue is noise on a
   board. NFR IDs stay referenceable from ADRs, issues, and pull requests, and where an NFR
   needs evidence that it holds, that evidence belongs in an ADR or a pull request
   description.

5. **All requirement issues live in `rekfar/docs`**, next to the requirement text, because of
   force 3. The work still happens where the code is, by two mechanisms:
   - a pull request in a code repository closes the requirement with the cross-repository
     form `Fixes rekfar/docs#123`; and
   - where a requirement needs a separate work item per layer, the `docs` issue is the
     **parent** and the code-repository issues are **sub-issues**.

   The 1:1 relation is preserved in both cases: one requirement, one requirement issue.

6. **Requirement text and requirement status have separate owners.**
   [functional-requirements.md](../requirements/functional-requirements.md) owns the text,
   by hand. The issue and its linked pull requests own the status. Neither is copied into
   the other; a generated `requirements/traceability.md` joins them and is the only place
   both appear. It carries a real heading per requirement, which also gives every requirement
   the stable deep link the tables cannot (force 1).

7. **The automation pulls; it does not push.** One scheduled workflow in `docs` re-derives
   the entire matrix from the issues on every run. A missed event is corrected by the next
   run instead of persisting, and no repository needs write access to another (force 4).

8. **The Project board is a view, not a source of truth.** Its custom fields exist for
   filtering; the generator never reads them. Otherwise status lives in three places and
   disagrees in two.

9. **The tooling is PowerShell 7 driving `gh api graphql`**, in `tools/traceability/`. No
   build step, present on `ubuntu-latest`, and runnable locally in the maintainer's own shell
   for dry runs. It has two entry points over one parser: `sync`, which creates and
   reconciles the issues from the tables, and `matrix`, which regenerates the document.

10. **The generated part of an issue body is delimited.** Everything above a marker comment is
    regenerated from the requirements table on every `sync`; everything below it — acceptance
    criteria, discussion, decisions — belongs to the maintainer and is never touched. This is
    what makes correcting a requirement's wording safe after its issue exists.

## Consequences

### Positive

- "Is `FR-MAP-2` built?" has one answer, derived rather than asserted, and the path from a
  use case to a merge commit is navigable in both directions.
- A requirement that nobody has started is **visible** — it has an open issue and a row in
  the matrix — instead of being invisible by omission. This is the half of a traceability
  matrix that carries information.
- Correcting a requirement's wording propagates to its issue on the next run (decision 10),
  so the tables stay the place to edit.
- Nothing has to be remembered at merge time beyond `Fixes rekfar/docs#N`, which the pull
  request template supplies.
- The tooling is a few PowerShell files and a workflow — no service, no database, no hosting
  (P1, P7).

### Negative / accepted trade-offs

- **73 issues in `docs` is a lot of issues**, and creating them produces a notification burst
  and dominates the activity feed for a day. Accepted: the alternative — feature-shaped
  issues covering several requirements each — makes "is this requirement done?" a judgement
  call rather than a query.
- **Requirement issues are one repository away from the code.** A maintainer working in
  `webapp` sees the requirement issue in `docs`, not locally. Sub-issues (decision 5) reduce
  this but do not remove it.
- **Cross-repository closing keywords are quieter than the local form.** `Fixes
  rekfar/docs#123` works, but a typo fails silently — the pull request merges and the
  requirement stays open. The scheduled matrix run is what surfaces it.
- **The 1:1 rule will occasionally be a poor fit.** Some requirements are a day's work and
  some are a month's; the issue is the same size either way. Sub-issues absorb the large
  ones.
- **A second small tool to maintain**, with its own dependency on GitHub's GraphQL schema and
  on the exact shape of the requirements tables. A change to either breaks the run — loudly,
  by decision 7, which is the intended failure mode.

### Follow-ups

- [ ] Build `sync` and `matrix` before creating any issues; 73 cannot be opened by hand.
- [ ] Run `sync` group by group (`FR-ACC` first, six issues) so a mistake in the generated
      body costs six issues to fix rather than 73.
- [ ] Make `sync` pause between creations and back off on `403`. Issue creation is subject to
      GitHub's secondary rate limit, independently of the hourly one.
- [ ] Grant the `project` scope (`gh auth refresh -s project`) before the tooling writes
      Project fields; the current token has `repo`, `read:org`, `workflow`, `gist`.
- [ ] Confirm the workflow may commit `requirements/traceability.md` to `main` under whatever
      branch protection is in place.
- [ ] Decide whether `UC-*` should get the same treatment later. Deliberately out of scope
      here: 15 use cases are readable as a table, and their status is implied by the
      requirements beneath them.

### Relationship to other decisions

Implements the requirements-management practice that [ADR-0001](0001-record-architecture-decisions.md)
established for decisions, and satisfies NFR-MAINT-4 and NFR-MAINT-5. Does not supersede any
ADR. The generated/hand-written split follows the same "name one owner per artefact"
reasoning as [ADR-0013](0013-schema-owned-by-sql-database-project.md).

## Sources

- Issue [#4 — Setup requirement traceability](https://github.com/rekfar/docs/issues/4), and
  its sub-issues [#5](https://github.com/rekfar/docs/issues/5),
  [#6](https://github.com/rekfar/docs/issues/6), [#7](https://github.com/rekfar/docs/issues/7).
- Linking a pull request to an issue, including the cross-repository form:
  https://docs.github.com/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue
- Sub-issues: https://docs.github.com/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues
- Rate limits for the REST API (secondary limits on content creation):
  https://docs.github.com/rest/using-the-rest-api/rate-limits-for-the-rest-api
