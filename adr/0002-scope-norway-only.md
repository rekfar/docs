# ADR-0002 — Scope the product to Norway only

**Status:** Accepted

## Context

Hiking/summit apps can be global, but global coverage forces lowest-common-denominator
data and generic maps. Norway has excellent **free, authoritative** geodata
(Kartverket topographic maps, place names, elevation) and national trail and cabin data
(Turrutebasen, N50 Kartdata). The maintainer and intended users are Norwegian.
The project premise fixes the geography to Norway.

## Decision

The product is **scoped to Norway** for the foreseeable future: Norwegian map data,
Norwegian peaks and trails, Norwegian place names, and a Norwegian audience.

## Consequences

- **Positive:** We can rely on high-quality national datasets and a coherent domain
  model; the map looks and behaves like what Norwegian hikers expect; it becomes a
  differentiator versus global apps (Principle P2, P3).
- We can hard-assume Norwegian coordinate systems (ETRS89/UTM 32–35) at the edges and
  Norwegian place-name sources.
- **Trade-off:** Users hiking abroad are not served. This is an accepted limitation.
- Expanding beyond Norway later would require new data sources and is explicitly out
  of scope; it would need its own ADR.
