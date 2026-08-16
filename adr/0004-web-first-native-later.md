# ADR-0004 — Web first, native app later

**Status:** Accepted

## Context

Rekfar should eventually be pleasant to use on a phone in the field, which points
toward a native app (live GPS recording, offline maps). But a native app is more
expensive to build and operate, and app-store distribution adds friction. The web is
the fastest, cheapest way to reach users and validate the concept, and a responsive
web app already covers most needs (logging, planning, browsing the map).

## Decision

Build the **web application first**. Treat a **native mobile app as a later, optional
phase** (roadmap Phase 4). To keep that door open, put all business logic and user
data behind a clean, **versioned API** that a future native client can reuse.

## Consequences

- Fastest path to a usable product at the lowest cost (Principles P1, P6).
- The API-first boundary (see [application architecture](../architecture/04-application-architecture.md))
  is a mild upfront constraint that pays off if/when the native app is built.
- Field-only features (live **track recording (sporing)**, offline areas) wait for the
  native phase; the web MVP uses **GPX import** instead.
- The data model must avoid web-only assumptions so it serves both clients.
