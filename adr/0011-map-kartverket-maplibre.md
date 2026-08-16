# ADR-0011 — Map provider & renderer: Kartverket raster tiles + MapLibre GL

**Status:** Accepted (2026-08-14) — supersedes [ADR-0006](0006-map-provider-deferred.md)

## Context

[ADR-0006](0006-map-provider-deferred.md) deferred the choice of base-map tiles and
rendering library, with a non-binding lean toward Kartverket tiles rendered with
MapLibre GL, pending confirmation of Kartverket's current tile endpoint and terms.
[ADR-0010](0010-tech-stack-dotnet-azure-sql.md) (accepted) already assumes this
combination as building block T5, and the [roadmap](../architecture/06-roadmap.md)
lists the decision as one to close before Phase 1 build starts.

The open facts were verified on **2026-08-14** against Kartverket's embedding
documentation, the live WMTS capabilities document, and Kartverket's terms of use:

- **Tile URL template (Web Mercator):**
  `https://cache.kartverket.no/v1/wmts/1.0.0/topo/default/webmercator/{z}/{y}/{x}.png`
  — the colour topographic layer. A greyscale variant (`topograatone`) and raster
  scans (`toporaster`, `sjokartraster`) exist on the same scheme.
- **Tile matrix sets:** `webmercator` (zoom levels **0–18**), plus `utm32n`,
  `utm33n`, `utm35n` for UTM projections. Capabilities:
  `https://cache.kartverket.no/v1/wmts/1.0.0/WMTSCapabilities.xml`.
- **Licence:** Kartverket's free products are **CC BY 4.0**. Attribution
  **"© Kartverket"** is required wherever the map appears, linked to
  kartverket.no when possible.
- **Caveat:** at detail zoom levels (~12–20) the cache serves data from the
  **Geovekst** collaboration. Displaying it in a service is fine under standard
  terms, but **copying or repurposing the data** (e.g. bulk-downloading and
  re-hosting tiles) requires rights-holder permission.

## Decision

- **Tiles:** Kartverket's topographic Norway map (`topo` layer) from the
  `cache.kartverket.no` WMTS, consumed as a **raster source in Web Mercator**
  using the URL template above. Tiles are loaded directly by the browser and
  **never stored, proxied, or re-hosted** by Rekfar (respecting the Geovekst
  caveat).
- **Renderer:** **MapLibre GL JS** — open source, no API key, strong mobile/touch
  support, and a native path to vector tiles later (Kartverket has an
  experimental vector-tile service) without changing libraries.
- **Attribution:** the MapLibre attribution control always shows
  **"© Kartverket"** (FR-MAP-8, NFR-LEGAL-2). The same string covers the reference
  datasets too, since they are all Kartverket CC BY 4.0 products
  ([ADR-0012](0012-kartverket-primary-source.md)); any future non-Kartverket source is
  appended as its data is added.
- The map stays behind the provider-agnostic component boundary defined in the
  [application architecture](../architecture/04-application-architecture.md), as
  ADR-0006 required.

## Consequences

- FR-MAP-1 (topographic map with pan/zoom) is implementable immediately with a
  free, authoritative, Norwegian source; running cost stays zero (P1, P3).
- Zoom is capped at level 18 in Web Mercator — ample for trip logging.
- Rekfar depends on `cache.kartverket.no` availability at runtime; accepted,
  as it is national infrastructure and the map degrades to "tiles unavailable"
  without taking the app down (NFR-INTEG-2 spirit).
- No offline map areas in the web MVP (would require tile storage and therefore
  Geovekst permission); revisit for the native app phase.
- Vector tiles are a later optimisation, not a new decision — MapLibre supports
  both.

## Sources

- Kartverket — embedding maps (URL templates, attribution):
  https://www.kartverket.no/en/on-land/kart/bygge-inn-kart-pa-nett
- Live WMTS capabilities (layers, tile matrix sets, zoom range):
  https://cache.kartverket.no/v1/wmts/1.0.0/WMTSCapabilities.xml
- Kartverket — terms of use (CC BY 4.0, attribution, Geovekst caveat):
  https://www.kartverket.no/api-og-data/vilkar-for-bruk
- Kartverket — experimental vector tiles:
  https://github.com/kartverket/kartverket.vectortiles
