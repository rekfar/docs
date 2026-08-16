# ADR-0013 — The database schema is owned by a SQL Database Project (DACPAC)

**Status:** Accepted (2026-08-16) — refines building block **T3** in
[ADR-0010](0010-tech-stack-dotnet-azure-sql.md); does not supersede it

## Context

[ADR-0010](0010-tech-stack-dotnet-azure-sql.md) chose Azure SQL Database with
`geography` columns, accessed through **EF Core with NetTopologySuite**. It named the
datastore and the access library but left one thing unstated: **which artefact defines the
schema**. "EF Core" is an answer to how the application queries the database, not to what
decides which tables exist.

That question became live when work started on the `database` repository, which sits
alongside `docs`, `backend`, and `webapp`. Either that repository owns the schema or it has
little reason to exist.

Three options were considered:

- **A** — A **SQL Database Project** in the `database` repository: declarative T-SQL, one
  file per object, built to a `.dacpac` and deployed with `SqlPackage`.
- **B** — **EF Core migrations** in the `backend` repository, with `database` reduced to
  documentation, seed scripts, and a local dev environment.
- **C** — **Ordered, immutable SQL migration scripts** in the `database` repository, applied
  by a runner such as DbUp or Flyway.

Four forces decided it:

1. **The same argument that decided ADR-0010 applies again.** That ADR treated the
   maintainer's fluency as an architectural input rather than a convenience, and recorded
   that the maintainer is *"strongest in C# and familiar with SQL Server."* The second half
   of that sentence points at option A as clearly as the first half pointed at .NET.
2. **The schema is where a mistake is most expensive.** Trip data loss is the one hard
   reliability line in the project (NFR-REL-4). A declarative definition means a pull
   request shows the schema as it will be rather than as a replay of history, and the deploy
   tool computes its own change script and can be told to refuse anything that would discard
   data.
3. **The separation the data architecture depends on has to be enforced somewhere.**
   "User data is backed up, reference data is rebuildable" (NFR-REL-2, NFR-INTEG-6) is a
   property of how the schema is arranged, not of application code. So are the invariants
   behind [ADR-0009](0009-private-and-public-logbook.md) (private and public content never
   cross over) and NFR-INTEROP-2 (canonical geometry is WGS84 and nothing else).
4. **Option C's cost is paid every day for a benefit needed rarely.** Ordered scripts give
   precise control over each change, but the current schema is then knowable only by
   replaying history, and the deployed state has to be reconciled by hand. For a
   single-maintainer project that is the wrong trade (P7).

Microsoft's own guidance treats this combination as a normal one: SQL database projects are
documented as a way to *"track the source of truth for database state, including development
with an object-relational mapper (ORM) such as EF Core."*

## Decision

1. **The schema is defined in the `database` repository** as an SDK-style SQL Database
   Project (`Microsoft.Build.Sql`), declaratively, one `.sql` file per object. `dotnet build`
   produces a `.dacpac`; that artefact is the schema.
2. **Deployment is `SqlPackage /Action:Publish`**, which computes the change script from the
   difference between the artefact and the target database. Two publish settings are part of
   this decision, not tuning: **`BlockOnPossibleDataLoss` is on**, and
   **`DropObjectsNotInSource` is off** — removing an object produces a line in the deploy
   report to review rather than a `DROP` on the next push to `main`.
3. **EF Core is a query and mapping layer only.** `dotnet ef migrations` is not used against
   this database, because migrations would be a second, competing definition of the same
   schema. ADR-0010's choice of EF Core and NetTopologySuite for T3 is unchanged, as is its
   constraint that the domain layer uses NTS geometry types and never provider-specific
   spatial SQL.
4. **The `.dacpac` published by CI is what the backend's integration tests run against.**
   Tests stand up a real database from the artefact rather than reconstructing an
   approximation of it, so drift between the two repositories fails a build instead of
   surviving unnoticed.
5. **Four schemas** — `auth`, `app`, `ref`, `ingest` — make the
   [data architecture §1](../architecture/03-data-architecture.md) split structural, so the
   backup and rebuild policies can be stated per schema.
6. **Invariants that are properties of the data live in the schema as constraints**, not only
   in application code: geometry restricted to SRID 4326, a diary note that cannot be
   anything but private, a derived elevation that must carry the dataset and date it was
   sampled from, and reference rows that are retired rather than deleted so a peak somebody
   has logged survives a refresh.

The database collation is **`Norwegian_100_CI_AS`**, so `æ`, `ø` and `å` sort where a
Norwegian reader expects. This is **irreversible**: Azure SQL Database's documentation states
that collation *"can't be changed after database has been created"*, so getting it wrong
means creating a new database and migrating into it.

## Consequences

### Positive

- A schema change is reviewable as a diff of the schema itself. Nobody has to read a
  sequence of migrations to work out the current shape of a table.
- **Drift is detectable.** `SqlPackage /Action:DeployReport` against the live database
  reports nothing when it matches `main`; anything else is a manual change that needs to come
  back into the project.
- No migration-history table to repair, and no ordered-script bookkeeping.
- CI can prove things reading cannot: that the artefact deploys cleanly onto an empty
  database, and that publishing twice is a no-op.
- The `database` repository has a defined responsibility, and the backend has one less.
- Implementation proceeds in the maintainer's SQL Server fluency, which ADR-0010 already
  identified as the most effective available mitigation for the single-maintainer bandwidth
  risk.

### Negative / accepted trade-offs

- **The model is expressed twice** — once in the project, once in EF Core's mapping — and the
  two can drift. This is the real cost of the decision. Testing the backend against the
  published `.dacpac` (decision 4) turns drift into a failing build, but does not remove the
  duplication.
- **A declarative deploy infers intent.** A renamed column reads as a drop plus an add, and
  anything needing data to be moved or backfilled needs a hand-written pre-deployment script.
  A `BlockOnPossibleDataLoss` failure is the signal to write one — not to switch the setting
  off.
- **DacFx and SqlPackage are Microsoft tooling.** Moving to PostgreSQL/PostGIS, which
  ADR-0010 deliberately kept open, would mean re-expressing the schema. Accepted, because DDL
  is the cheap part of that migration: the data and the geometry model are the expensive
  parts, and the NTS constraint already keeps the latter portable (P4, NFR-MAINT-1).
- **The database holds no record of its own deployment history.** Deploy reports are kept as
  CI artefacts instead.
- One more pinned tool on the deploy path, bumped by hand after reading its changelog.

### Follow-ups

- [ ] Confirm the `ModelCollation` / `DefaultCollation` pairing builds cleanly — the project
      treats T-SQL warnings as errors, so a mismatch between LCID 1044 and
      `Norwegian_100_CI_AS` would fail the first build.
- [ ] Create the Azure SQL database **with `Norwegian_100_CI_AS`**. Irreversible; the portal
      defaults to `SQL_Latin1_General_CP1_CI_AS`.
- [ ] Set up the Entra app registration and federated credential so deployment needs no
      long-lived secret.
- [ ] Test a restore, and record both how long it took and whether the restored database
      stays inside the Azure SQL free offer — a restore creates a new database
      (NFR-REL-1).
- [ ] Add a scheduled drift check once the database is live.
- [ ] Decide the peak-qualification rule before seeding `ref.PeakRule`; the table ships empty
      on purpose. Carried from [ADR-0012](0012-kartverket-primary-source.md) §5.1 and
      FR-REF-11.
- [ ] Consider a pointer from ADR-0010's T3 row to this ADR. Not added, because the
      [ADR index](README.md) says never to edit an accepted ADR — a cross-reference arguably
      does not change its meaning, but that is a call for the maintainer, not a side effect
      of this one.

## Sources

- What are SQL database projects (declarative model, `.dacpac`, publish, EF Core as a
  consumer): https://learn.microsoft.com/sql/tools/sql-database-projects/sql-database-projects
- `Microsoft.Build.Sql` SDK: https://www.nuget.org/packages/Microsoft.Build.Sql
- `SqlPackage` publish action:
  https://learn.microsoft.com/sql/tools/sqlpackage/sqlpackage-publish
- ALTER DATABASE — collation cannot be changed after creation on Azure SQL Database:
  https://learn.microsoft.com/sql/t-sql/statements/alter-database-transact-sql?view=azuresqldb-current
- The implementation, conventions and operational runbook:
  https://github.com/rekfar/database
