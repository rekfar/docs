# ADR-0012 — Kartverket as the primary source for peaks, routes, and cabins

**Status:** Accepted (supersedes [ADR-0007](0007-utno-primary-source.md))

## Context

[ADR-0002](0002-scope-norway-only.md) scoped the product to Norway to exploit
high-quality national data. [ADR-0007](0007-utno-primary-source.md) picked **UT.no** and
its underlying open data platform as the primary source for Rekfar's core reference data,
then recorded in its own verification note that the public API was unreachable and that
DNT had closed open access. The platform is no longer maintained, so the dependency is not
merely risky — it is unavailable. Building the MVP on it is not possible.

**Kartverket** (the Norwegian Mapping Authority) publishes the same underlying facts as
free, versioned, openly licensed national datasets, distributed through **Geonorge**. It is
already in the architecture for base-map tiles ([ADR-0011](0011-map-kartverket-maplibre.md)),
place names, and elevation. This ADR promotes it from a complementary source to *the*
source for peaks, routes, and cabins.

Kartverket is also the *upstream* of much of what outdoor portals display: corrections to
trails and cabins are reported into Kartverket's datasets. Sourcing from Kartverket moves
Rekfar closer to the authoritative record, not further from it.

## Decision

1. **Kartverket is the primary basis** for Rekfar's core reference data on peaks, routes,
   and cabins, via four datasets (see §3).
2. **Access strategy:** **periodic bulk download into Rekfar's own store**, refreshed on a
   schedule, with the Stedsnavn REST API additionally usable for live name lookups. The
   app always reads its own copy. This is the same local-mirror shape ADR-0007 argued for,
   without the API key, rate limits, or upstream-availability coupling — the elaborate
   live-vs-mirror-vs-transporter trade-off in ADR-0007 no longer has anything to trade off.
3. **External identifier is mandatory (Must):** every reference entity (peak, route,
   cabin) stores a **stable Kartverket identifier** — `stedsnummer` for SSR places,
   `lokalid` for N50 and Turrutebasen objects — plus its source dataset and fetch date.
   This is the join key for refresh and reconciliation.
4. **Outbound UT.no link is optional (Should) and nullable:** entities *may* carry a deep
   link to a corresponding **UT.no** page for a human-written description. The field is
   nullable and the app must render correctly without it. **UT.no is a link target, never
   a data source.** How the field gets populated is an open question (§5).
5. **"What counts as a peak" is a documented rule we own** (§4), not an editorial
   judgement inherited from a curated upstream.
6. **Attribution:** all four datasets are Kartverket free products under **CC BY 4.0**;
   the single attribution string **"© Kartverket"**, linked where possible, satisfies every
   one of them (FR-MAP-8, NFR-LEGAL-2).

## 3. The Kartverket sources

All are free, openly licensed, and reachable via Geonorge. Specifics are **to re-verify at
build time**.

| Need | Source | Access | Key detail |
| --- | --- | --- | --- |
| Peak names, coordinates, stable id | **SSR — Stedsnavn (komplett SSR)** | REST/JSON at `https://ws.geonorge.no/stedsnavn/v1/`; no login, no API key. Full dataset also downloadable from Geonorge. | Endpoints `/navn`, `/sted`, `/punkt` (radius search), `/navneobjekttyper`; paging via `side` / `treffPerSide`; `koordsys` selects the coordinate system. **`stedsnummer` is the stable external id.** |
| Peak classification | same, `navneobjekttype` filter | `GET /navneobjekttyper` lists the legal values | Relevant types include `Fjell`, `Fjellområde`, `Topp`, `Berg`, `Haug`, `Ås`, `Høyde`, `Fjellside`, `Vidde` |
| Elevation (moh.) | **Kartverket Høydedata (DTM)** | WCS/WFS/WMS plus REST services from høydedata.no; an elevation-**profile** WPS API is also published | SSR returns a representation point but **no height** — elevation is sampled from the DTM at ingestion. The profile API also serves the Phase-2 trip elevation profile. |
| Cabins (hytter) | **N50 Kartdata → `Turisthytte`** | Geonorge download (FGDB, GML, PostGIS, SOSI) plus WMS/WMTS | Building type **956**. Properties `navn`, `eier` (DNT / Statskog / Fjellstyre / annen) and **`betjeningsgrad`** (`betjent` / `selvbetjent` / `ubetjent`) — a 1:1 fit with the existing `CABIN.kind` enum. |
| Routes / trails | **Turrutebasen — "Tur- og friluftsruter"** | Geonorge **download API** (service status: good), WMS, and WFS (service status: deficient — prefer the download API) | Object types `Fotrute`, `Skiløype`, `Sykkelrute`, `AnnenRute`, `Ruteinfopunkt`. Covers marked/signposted routes with a named maintenance responsibility. |
| Trailheads, parking, toilets, viewpoints | **Turrutebasen `Ruteinfopunkt`** | as above | A capability the previous source did not give us. |
| Topographic base map tiles | **Topografisk norgeskart** | WMTS/WMS | Unchanged — [ADR-0011](0011-map-kartverket-maplibre.md). |

## 4. What changes for Rekfar

### Gained

- **No API key, no rate limit, no closed-access risk.** Nothing to request, nothing to be
  refused. The single largest risk in the [roadmap](../architecture/06-roadmap.md)
  disappears.
- **One licence, one attribution string** instead of per-provider licence metadata on every
  mirrored record.
- **Trailhead, parking, and route-infrastructure points** via `Ruteinfopunkt`.
- **Cabin service level and owner** as first-class attributes rather than free-text tags.

### Lost, and how it is handled

1. **Curated prose, images, and difficulty grading.** Kartverket publishes geodata, not
   trip writing. Handled by the optional UT.no link (§Decision 4) and by Rekfar's own
   user-generated content — the private diary and public guestbook
   ([ADR-0009](0009-private-and-public-logbook.md)).
2. **The editorial notion of "a summit worth visiting."** SSR holds roughly a million place
   names. Rekfar must define the rule itself: a chosen set of `navneobjekttype` values plus
   an elevation and/or prominence (*primærfaktor*) threshold, documented and versioned so
   the catalogue is reproducible. Open question §5.1.
3. **Elevation as a quoted attribute.** It becomes *derived* by sampling the DTM, with its
   own accuracy caveat. `PEAK.elevationMeters` records the source and sampling date.
4. **One API with official client libraries.** Ingestion now spans three access modes —
   REST/JSON (SSR), bulk file download (N50), and download-API (Turrutebasen). The
   ingestion job (capability C12) is correspondingly larger.
5. **Pre-linked relationships** between routes, peaks, and cabins. These must be derived
   spatially at ingestion.

## 5. Open questions to close before/at build time

1. **Peak-qualification rule:** which `navneobjekttype` values, and what elevation and/or
   prominence threshold. Decide before the Phase 1 peak-catalogue seed
   ([roadmap](../architecture/06-roadmap.md)).
2. **UT.no link population:** whether the optional link can be resolved automatically
   (name + coordinate match against public UT.no pages), curated by hand for a small set,
   or left empty. Deliberately unresolved — the field is nullable so nothing blocks on it.
3. **Refresh cadence and delta handling** per dataset: N50 is redistributed weekly;
   Turrutebasen and SSR change continuously. Confirm whether a full re-download or a
   change feed is available, and how deletions are detected.
4. **Turrutebasen WFS reliability:** the WFS service status is reported as deficient;
   confirm the download API is sufficient for our needs.
5. **Coordinate handling:** Kartverket data ships in ETRS89/UTM (EPSG:25832–25835);
   confirm the reprojection to WGS84 at ingestion
   ([03-data-architecture.md](../architecture/03-data-architecture.md) §5).

## Consequences

- **Positive:** reference data is a rebuildable local copy of published national datasets.
  An upstream outage cannot affect runtime, there is no key to lose and no partner
  relationship to maintain, and the licence position is simple and uniform (P1, P3, P7;
  NFR-INTEG).
- **New work we own:** a documented peak-qualification rule, a DTM elevation-sampling step,
  three ingestion paths instead of one, spatial derivation of route/peak/cabin
  relationships, and coordinate reprojection.
- **Model impact:** each reference entity carries a **Kartverket external id** plus source
  dataset and fetch date (Must) and a **nullable UT.no link** (Should) — reflected in the
  [data architecture](../architecture/03-data-architecture.md).
- **Requirements impact:** the former `FR-UT-*` block is folded into `FR-REF-*` in the
  [functional requirements](../requirements/functional-requirements.md); the deep-link
  requirements drop from Must to Should, and a new Must covers the peak-qualification rule.
- **Roadmap impact:** the former top risk — dependency on the closed UT.no data platform —
  is removed;
  "defining a peak" is promoted from a watch-item to an MVP decision.
- Supersedes [ADR-0007](0007-utno-primary-source.md), which is reduced to a stub.

## Sources

- Kartverket — outdoor recreation datasets and APIs: https://www.kartverket.no/en/api-and-data/friluftsliv
- Kartverket — Stedsnavn API user guide: https://www.kartverket.no/en/api-and-data/stedsnavndata/brukarrettleiing-stadnamn-api
- Stedsnavn (komplett SSR) dataset: https://kartkatalog.geonorge.no/metadata/stedsnavn-komplett-ssr/08e96235-0166-4161-97bb-cb64c09f50eb
- Turrutebasen — Tur- og friluftsruter: https://register.geonorge.no/det-offentlige-kartgrunnlaget/tur-og-friluftsruter/d1422d17-6d95-4ef1-96ab-8af31744dd63
- N50 Kartdata: https://register.geonorge.no/det-offentlige-kartgrunnlaget/n50-kartdata/ea192681-d039-42ec-b1bc-f3ce04c189ac
- N50 `betjeningsgrad` code list: https://register.geonorge.no/sosi-kodelister/kartdata/betjeningsgrad
- N50 `BygningstypeKode` (956 = turisthytte): https://register.geonorge.no/sosi-kodelister/kartdata/bygningstypekode
- Kartverket — Høydedata og dybdedata: https://www.kartverket.no/en/api-and-data/terrengdata
- Kartverket — terms of use (CC BY 4.0, "©Kartverket"): https://www.kartverket.no/en/api-and-data/terms-of-use
