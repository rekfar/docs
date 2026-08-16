# ADR-0006 — Map provider & renderer

**Status:** Superseded by [ADR-0011](0011-map-kartverket-maplibre.md)

## Context

The map is central to Rekfar, so the choice of **base-map tiles** and the
**client-side rendering library** matters. Norway's mapping authority, **Kartverket**,
publishes free topographic map tiles (Topografisk norgeskart) via WMS/WMTS, which
aligns strongly with the open-data and cost principles (P1, P3). The rendering library
(how tiles and overlays are drawn in the browser) is a separate choice. At the current
stage the maintainer chose to "decide later".

## Decision (deferral)

The map provider and renderer are **deferred** until the start of roadmap **Phase 1**.
The map is treated as an **abstract component** (see
[application architecture](../architecture/04-application-architecture.md)) with a
provider-agnostic interface, so the specific choice can be swapped with minimal impact.

### Constraints the eventual choice must respect

- **Tiles:** strongly prefer **Kartverket topographic tiles** (free, authoritative,
  Norwegian) — respecting attribution ("© Kartverket") and terms of use.
- **Renderer:** prefer an **open-source** library to avoid lock-in and cost —
  candidates: **MapLibre GL** (vector, modern) or **Leaflet** (simple, raster-friendly,
  large plugin ecosystem).
- Commercial options (Mapbox, MapTiler) are allowed only if a free tier clearly wins
  and the paid-dependency risk is accepted against P1.
- Must support: a topographic base layer, toggleable overlays (peaks, trips, trails),
  bounding-box feature loading, and good mobile/touch behaviour (P10).

### Leading (non-binding) candidate

**Kartverket topographic tiles rendered with MapLibre GL** — free, open, Norwegian,
no lock-in. Not yet decided.

## Consequences

- The map component is designed behind an abstraction now, a small amount of extra
  structure that preserves flexibility.
- Data-source **attribution** is a firm requirement regardless of choice
  (FR-MAP-8, NFR-LEGAL-2).
- Confirming Kartverket's current tile terms is a roadmap watch-item before MVP.
- When decided, this ADR is superseded by an `Accepted` ADR naming the provider and
  renderer.
