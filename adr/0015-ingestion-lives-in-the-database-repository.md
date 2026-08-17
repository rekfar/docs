# ADR-0015 — Reference-data ingestion lives in the database repository

**Status:** Accepted (2026-08-17) — refines the **Reference-data ingestion** component in
[application architecture §2](../architecture/04-application-architecture.md#2-component-responsibilities)
and building block **T8** in [ADR-0010](0010-tech-stack-dotnet-azure-sql.md); supersedes
neither

## Context

The [application architecture](../architecture/04-application-architecture.md) lists
**Reference-data ingestion** as one module of the API's modular monolith, and notes in §6
that *"splitting the ingestion job into a scheduled task/worker is the only likely early
separation."* [ADR-0010](0010-tech-stack-dotnet-azure-sql.md) put the scheduled Kartverket
job on GitHub Actions (T8). Neither says which **repository** the code lives in, because
when they were written there was only one candidate.

There are now four: `docs`, `database`, `backend`, and `webapp`.
[ADR-0013](0013-schema-owned-by-sql-database-project.md) gave `database` a defined
responsibility — the schema — and observed that either that repository owns something or it
has little reason to exist. The question this ADR answers is whether ingestion is part of
that something.

The Phase 1 peak catalogue seed made it live. Four forces decided it:

1. **What ingestion consumes is the schema, not the domain.** The peak import streams a
   2.6 GB GML file, calls an HTTP elevation service, bulk-copies into staging tables, and
   runs one set-based `MERGE`. It needs `ingest.SsrPlace`, `ingest.ElevationSample` and
   `ref.Peak` — all defined in `database` — and it needs no trip logic, no authorisation, no
   API surface, and no entity graph. The staging tables it writes exist for it alone and are
   useful to nothing else in the system.
2. **The backend does not exist yet, and the catalogue is on the Phase 1 critical path.**
   The `backend` repository is empty. Placing the first code there means standing up a
   solution, an EF Core model, and a hosting story *before* a single peak can be imported —
   ordering the work by repository layout rather than by what the
   [roadmap](../architecture/06-roadmap.md) needs next.
3. **The operational runbook is already here.** `docs/operations.md` in `database` documents
   rebuilding reference data, what a re-import does, and how to read `ingest.Run` afterwards.
   The procedure and the program that performs it belong in the same place.
4. **A schema change and its only writer should move together.** A new staging column and
   the code that fills it are one change. Split across repositories they are two pull
   requests, two CI runs, and a window in which the pair disagrees — the same class of drift
   [ADR-0013](0013-schema-owned-by-sql-database-project.md) accepted as the real cost of
   defining the model twice. There is no reason to volunteer for a second instance of it.

## Decision

1. **Reference-data ingestion lives in the `database` repository**, as
   `src/Rekfar.Ingest.Peaks` — a .NET console application built from the same solution and
   the same commit as the `.dacpac` it writes against.
2. **It uses ADO.NET, not EF Core.** `SqlBulkCopy` for the staging load and set-based T-SQL
   for the merge. This is not a relaxation of
   [ADR-0010](0010-tech-stack-dotnet-azure-sql.md)'s choice of EF Core with
   NetTopologySuite: that is the *backend's* query and mapping layer, and an entity graph is
   the wrong instrument for loading tens of thousands of rows and merging them in one
   statement. Using EF here would also add a third definition of the model to a project that
   already accepts two.
3. **It runs from a scheduled GitHub Actions workflow in this repository**, connecting as
   **its own least-privileged database user** — `INSERT`/`UPDATE` on `ref` and `ingest`, and
   nothing on `app` or `auth`. It must not reuse the `db_owner` deployment principal from
   [docs/operations.md](https://github.com/rekfar/database/blob/main/docs/operations.md); a
   job that refreshes reference data has no business being able to read a diary note.
4. **The API remains the only reader.** Ingestion writes `ref`; the API's Peak/Route/Cabin
   catalogue module serves `/peaks`. The logical component split in the application
   architecture is unchanged — this ADR places one component's code, it does not merge two.
5. **The trigger for revisiting is named:** when the backend exists *and* a second dataset
   job (N50 cabins, Turrutebasen routes) is written, re-examine whether the three jobs
   belong together in a worker alongside the API. Moving them is a project move plus a
   workflow move; nothing about the schema changes.

## Consequences

### Positive

- The Phase 1 peak catalogue is unblocked without waiting on a backend that has not been
  started.
- Schema and writer change in one pull request, proved by one CI run. The existing pipeline
  already stands up SQL Server, publishes the `dacpac`, and runs the smoke tests, so
  ingestion tests get a real database for free rather than needing their own harness.
- Implementation stays in the maintainer's SQL Server fluency, which
  [ADR-0010](0010-tech-stack-dotnet-azure-sql.md) and
  [ADR-0013](0013-schema-owned-by-sql-database-project.md) both identified as the most
  effective available mitigation for the single-maintainer bandwidth risk (P7).
- Reference data stays genuinely rebuildable (NFR-INTEG-6): the rebuild procedure, the
  program, and the schema it targets are one artefact set, not three coordinated ones.

### Negative / accepted trade-offs

- **The `database` repository is no longer only the schema.** Its stated responsibility in
  [ADR-0013](0013-schema-owned-by-sql-database-project.md) widens, and it now carries two
  toolchains — declarative T-SQL and a C# console app. This is the real cost, and it is why
  this decision is written down rather than assumed.
- **It sits against the letter of the application architecture**, which draws ingestion
  inside the API. The *logical* architecture is unaffected — ingestion is still its own
  component with its own responsibility — but a reader of the diagram will not find its code
  where the diagram implies.
- **Two writers to `ref` become possible** once the API can also touch reference data. The
  schema's constraints are what keep them honest, which is the position
  [ADR-0013](0013-schema-owned-by-sql-database-project.md) already took deliberately.
- **A second least-privileged database principal** to create, grant, and remember.

### Follow-ups

- [ ] Create the ingestion database user and grant it `ref` and `ingest` rights only; record
      the grant in `docs/operations.md` alongside the deployment principal.
- [ ] Add the federated credential for the ingestion workflow, or confirm the deployment one
      can be reused with a different database user.
- [ ] Decide and record the refresh cadence per dataset (ADR-0012 §5.3 is still open on
      delta handling; a full re-import is the fallback and is cheap enough).
- [ ] Revisit this placement when the backend exists and a second dataset job is written.

## Sources

- Application architecture, component responsibilities and deployment shape:
  [04-application-architecture.md](../architecture/04-application-architecture.md)
- The schema, its conventions, and the reference-data rebuild runbook:
  https://github.com/rekfar/database
- SqlBulkCopy: https://learn.microsoft.com/dotnet/api/system.data.sqlclient.sqlbulkcopy
