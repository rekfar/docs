# ADR-0007 — UT.no as the primary source for tops, routes, and cabins

**Status:** Superseded by [ADR-0012](0012-kartverket-primary-source.md)

## Context

Following [ADR-0002](0002-scope-norway-only.md), this ADR made **UT.no** — the Norwegian
Trekking Association's (DNT) public trip portal — and its underlying open data platform the
primary basis for Rekfar's reference data on summits, routes, and cabins, with a deep link
from every Rekfar entity to its UT.no page.

## Why it was superseded

Verification on 2026-08-14, before Phase 1 build start, found the platform's public API
unreachable — API paths returning 404, the main and developer sites timing out or refusing
connections — and a UT.no help-centre article confirming that DNT had **closed open access**
to the data after changes to their technical systems. The source is no longer maintained or
obtainable, so the decision could not be fulfilled.

[ADR-0012](0012-kartverket-primary-source.md) replaces it: **Kartverket** open datasets
(SSR, Høydedata, N50 Kartdata, Turrutebasen) become the primary source, and UT.no survives
only as an optional, nullable outbound link for human-written descriptions — a link target,
not a data source.
