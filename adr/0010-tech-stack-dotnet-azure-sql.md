# ADR-0010 — Technology stack: .NET on Azure with Azure SQL spatial

**Status:** Accepted (2026-08-14) — supersedes [ADR-0005](0005-tech-stack-deferred.md)

## Context

[ADR-0005](0005-tech-stack-deferred.md) deferred the stack until the start of roadmap
[Phase 1](../architecture/06-roadmap.md), and the roadmap names resolving it as the
first thing to do because it blocks all implementation.

Three concrete stacks were worked up and compared against the six selection criteria in
[technology architecture §2](../architecture/05-technology-architecture.md#2-selection-criteria-how-we-will-decide):

- **A** — ASP.NET Core + Azure SQL Database (spatial) + React SPA
- **B** — Next.js full-stack on Netlify + PostgreSQL/PostGIS on Neon
- **C** — Python FastAPI + PostgreSQL/PostGIS + React SPA

The full comparison, including cost figures and the case for each option, is in
[Technology Stack Options](../architecture/tech-stack-options.md).

Two facts drove the outcome more than any framework comparison:

1. **Azure has no perpetual free tier for managed PostgreSQL**, but **does have one for
   Azure SQL Database** (100,000 vCore seconds, 32 GB data and 32 GB backup per database
   per month, up to 10 databases per subscription, renewing monthly for the lifetime of
   the subscription). Under [P1](../architecture/principles.md#p1-hobby-first-cost-minimal)
   this is decisive: PostGIS on Azure is a permanent monthly bill, Azure SQL is not.
2. **The maintainer is strongest in C# and familiar with SQL Server.** The roadmap's own
   risk register names *single-maintainer bandwidth* as a live risk, and
   [P7](../architecture/principles.md#p7-simple-before-clever) makes simplicity a
   principle. For a one-person hobby project, fluency is an architectural input, not a
   convenience.

The counter-argument — that PostGIS is the better geospatial engine — is real but
smaller than it appears. The queries this application actually issues (peaks within the
map extent, peaks within *n* metres of a track's high point, storing and redrawing a
route line) are all within SQL Server `geography`'s range, and the
[data architecture](../architecture/03-data-architecture.md) already stores in
EPSG:4326, which is where PostGIS's reprojection advantage would otherwise have paid off.

## Decision

Adopt **Option A** for roadmap Phase 1:

| Block | Choice |
| --- | --- |
| T1 — Web client | React + Vite + TypeScript SPA; `react-i18next` with `nb-NO` as the first locale |
| T2 — API runtime | ASP.NET Core Minimal APIs (C#), modular monolith, versioned at `/v1`, OpenAPI-generated |
| T3 — Datastore | Azure SQL Database on the free offer; `geography` columns with spatial indexes; EF Core with **NetTopologySuite** |
| T4 — Object storage | Azure Blob Storage (EEA region) for photos and GPX |
| T5 — Map | Kartverket topographic tiles rendered with **MapLibre GL** — see [ADR-0011](0011-map-kartverket-maplibre.md) |
| T6 — Geospatial libs | NetTopologySuite (geometry), ProjNet (EPSG transforms), a GPX parser |
| T7 — Hosting | API on Azure Container Apps (consumption, scale-to-zero); client on **Netlify** for the prototype, with Azure Static Web Apps as a later option |
| T8 — CI/CD | GitHub Actions, also running the scheduled Kartverket ingestion job |
| T9 — Auth | ASP.NET Core Identity, email + password, cookie/JWT; OAuth addable later |
| T10 — Observability | Structured logs plus a free-tier error tracker |

Two constraints are part of this decision, not optional refinements:

- **The domain layer uses NetTopologySuite geometry types, never provider-specific
  spatial SQL.** NTS is the same geometry model Npgsql uses for PostGIS, so migrating to
  PostGIS later is a provider swap plus a data migration rather than a rewrite. This is
  [P4](../architecture/principles.md#p4-user-owns-their-data) applied to the schema.
- **The client is a standalone SPA that talks to the API over HTTP only.** No
  server-rendered coupling to the .NET application. The web client and a future native
  client are peers, per [P6](../architecture/principles.md#p6-web-first-but-do-not-paint-the-mobile-app-into-a-corner).

The **map provider decision is independent of this ADR** and can be accepted separately:
Kartverket tiles are CC BY 4.0 for commercial and non-commercial use, and MapLibre GL is
a JavaScript library regardless of which backend wins.

## Consequences

### Positive

- Running cost is effectively zero and stays zero: the Azure SQL free offer is perpetual
  rather than a 12-month promotion, and the Container Apps consumption plan's free grant
  (180,000 vCPU-seconds, 360,000 GiB-seconds, 2 million requests per month) exceeds
  anything this project will generate.
- Implementation proceeds in the maintainer's strongest language, which is the most
  effective mitigation available for the single-maintainer bandwidth risk.
- The `/v1` API boundary required by [P6](../architecture/principles.md#p6-web-first-but-do-not-paint-the-mobile-app-into-a-corner)
  is structural — a separate project — rather than a convention to be maintained.
- The Netlify account is used from day one for the client, so a working prototype does
  not wait on Azure hosting decisions.
- Roadmap Phase 1 is unblocked.

### Negative / accepted trade-offs

- **SQL Server spatial is thinner than PostGIS.** No in-database coordinate
  transformation, a smaller geospatial tooling ecosystem, and fewer analytical
  functions. Reprojection happens in application code with ProjNet. Accepted because the
  documented queries do not need more.
- **Serverless auto-pause causes cold starts.** After idle periods the first query can
  take tens of seconds to resume. Must be measured and tuned before the Phase 1 exit
  review; mitigations are the auto-pause delay setting or a lightweight warm-up ping.
- **Two deploy targets** (Netlify client, Azure API) means CORS configuration and two
  pipelines.
- **Sharing code with a future native app is weaker than Option B's React/React Native
  story.** Mitigated by the generated OpenAPI client; .NET MAUI is also open.

### Follow-ups

- [ ] Measure the route-geometry volume from Turrutebasen — the one number that could
      still flip this to a PostGIS option.
- [ ] Test Azure SQL free-tier resume time from auto-pause with a realistic spatial query.
- [x] Confirm Kartverket's tile URL template, zoom range, and caching terms — done
      2026-08-14; recorded in [ADR-0011](0011-map-kartverket-maplibre.md), which
      supersedes ADR-0006.
- [ ] Confirm the Kartverket dataset access paths (SSR API, N50 and Turrutebasen
      downloads, Høydedata) and decide the peak-qualification rule before the Phase 1
      peak-catalogue seed ([roadmap](../architecture/06-roadmap.md)) — see
      [ADR-0012](0012-kartverket-primary-source.md).
- [ ] Confirm EEA region availability for Azure SQL, Container Apps, and Blob Storage.
- [x] On acceptance: set this ADR to `Accepted`, set ADR-0005 to
      `Superseded by ADR-0010`, and update the [ADR index](README.md) — done 2026-08-14.
