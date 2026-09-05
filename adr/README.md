# Architecture Decision Records (ADRs)

An **ADR** captures a single significant architectural decision: the context, the
decision, and its consequences. They are the project's decision log and map to
TOGAF's governance (Phase G) and change management (Phase H) in a lightweight way.

We also record decisions we have deliberately **deferred** (status `Deferred`), so
the open questions are explicit rather than forgotten (Principle P8).

## Format

Each ADR uses this structure:

- **Status:** Proposed | Accepted | Deferred | Superseded by ADR-XXXX
- **Context:** The forces at play — requirements, constraints, principles.
- **Decision:** What we decided (or that we chose to defer, and until when).
- **Consequences:** The results, trade-offs, and follow-ups.

## Index

| ADR | Title | Status |
| --- | --- | --- |
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | Accepted |
| [0002](0002-scope-norway-only.md) | Scope the product to Norway only | Accepted |
| [0003](0003-language-strategy.md) | Language strategy (Norwegian UI, English docs, bilingual terms) | Accepted |
| [0004](0004-web-first-native-later.md) | Web first, native app later | Accepted |
| [0005](0005-tech-stack-deferred.md) | Technology stack | Superseded by ADR-0010 |
| [0006](0006-map-provider-deferred.md) | Map provider & renderer | Superseded by ADR-0011 |
| [0007](0007-utno-primary-source.md) | UT.no as the primary source for tops, routes, and cabins | Superseded by ADR-0012 |
| [0008](0008-activity-tracking-integrations.md) | Activity-tracking service integrations (Strava primary) | Accepted |
| [0009](0009-private-and-public-logbook.md) | Two-tier logbook: private diary and public guestbook | Accepted |
| [0010](0010-tech-stack-dotnet-azure-sql.md) | Technology stack: .NET on Azure with Azure SQL spatial | Accepted |
| [0011](0011-map-kartverket-maplibre.md) | Map provider & renderer: Kartverket raster tiles + MapLibre GL | Accepted |
| [0012](0012-kartverket-primary-source.md) | Kartverket as the primary source for peaks, routes, and cabins | Accepted |
| [0013](0013-schema-owned-by-sql-database-project.md) | The database schema is owned by a SQL Database Project (DACPAC) | Accepted |
| [0014](0014-requirements-traceability.md) | Requirements traceability: one issue per functional requirement | Accepted |
| [0015](0015-ingestion-lives-in-the-database-repository.md) | Reference-data ingestion lives in the database repository | Accepted |
| [0016](0016-ssr-general-use-distribution.md) | The peak import reads the general-use Stedsnavn distribution | Accepted |
| [0017](0017-passwordless-email-sign-in.md) | Auth (T9): passwordless email sign-in, no stored passwords | Accepted |

## Adding a new ADR

Copy the format above into `NNNN-short-title.md`, use the next number, set the status,
and add a row to this index. Never edit the meaning of an accepted ADR — instead add a
new one that supersedes it and update the old one's status to `Superseded by ADR-NNNN`.
