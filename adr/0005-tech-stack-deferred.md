# ADR-0005 — Technology stack

**Status:** Superseded by [ADR-0010](0010-tech-stack-dotnet-azure-sql.md)

## Context

The web client framework, API runtime, and datastore are foundational choices that
shape the whole build. However, at the current planning stage we deliberately chose
**not** to commit yet (the maintainer selected "decide later"). The
[technology architecture](../architecture/05-technology-architecture.md) defines the
building blocks (T1–T10) and the selection criteria; this ADR records the deferral
and the shortlist so the decision can be made quickly when Phase 1 starts.

## Decision (deferral)

The concrete technology stack is **deferred** until the start of roadmap **Phase 1
(MVP)**. Documentation and architecture are kept **stack-agnostic** until then.

When we decide, the choice must satisfy the selection criteria in the technology
architecture, especially: near-zero cost (P1), single-maintainer operability (P1/P7),
**first-class geospatial support** (a spatial datastore such as PostGIS or SpatiaLite),
native-app friendliness (P6), and portability/no lock-in (P4).

### Shortlist to choose from (non-binding)

- **Web + API framework:** Next.js (React/TS) · SvelteKit (TS) · React+Vite SPA with a
  separate API (Node/TS, Python/FastAPI, or Go).
- **Datastore (must be spatial):** PostgreSQL + PostGIS (default recommendation) ·
  SQLite + SpatiaLite (simplest/cheapest).
- **Object storage:** S3-compatible free tier · single-VM volume.
- **Hosting:** managed PaaS free tier + managed Postgres · single small VM.
- **Auth:** email+password (hashed) · OAuth provider · managed auth free tier.

A leading candidate combination consistent with the principles is **Next.js +
PostgreSQL/PostGIS + MapLibre + S3-compatible storage**, because it is free at hobby
scale, spatial-capable, and offers a clean path to a React Native app later — but this
is **not yet decided**.

## Consequences

- Phase 1 cannot start implementation until this ADR is resolved; the
  [roadmap](../architecture/06-roadmap.md) flags it as the first thing to decide.
- Keeping docs stack-agnostic costs a little abstraction now but avoids rework if the
  choice changes.
- When decided, this ADR is superseded by an `Accepted` ADR naming the exact stack and
  versions.
