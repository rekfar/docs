# Architecture Principles

These principles are the ground rules every architectural decision should respect.
They are adapted from TOGAF's Preliminary Phase, but written for a **single-maintainer
hobby project** rather than an enterprise. Each principle has a short rationale and
a practical implication.

Format: **Statement** — *Rationale* — *Implication*.

## P1. Hobby-first, cost-minimal

**The project must be runnable and maintainable by one person at near-zero cost.**
*Rationale:* Rekfar is explicitly not intended to earn money at any stage, so
running costs and operational burden are the real constraints, not revenue.
*Implication:* Prefer free tiers, open data, and managed/serverless hosting. Avoid
components that require constant attention or paid licences. If a feature forces a
paid dependency, it must be justified against this principle.

## P2. Norway-scoped by design

**The domain, data, and map are scoped to Norway.**
*Rationale:* A narrow scope lets us use high-quality national data (Kartverket's
place-name, elevation, topographic, and trail datasets) and a coherent domain model
instead of lowest-common-denominator
global data. *Implication:* It is acceptable to hard-assume Norwegian coordinate
systems, place-name sources, and language. See
[ADR-0002](../adr/0002-scope-norway-only.md).

## P3. Open data over proprietary data

**Prefer open, free, officially maintained Norwegian data sources.**
*Rationale:* Aligns with P1 (cost) and gives authoritative, well-maintained data.
*Implication:* Kartverket map tiles and elevation, SSR place names, N50 Kartdata, and
Turrutebasen are first-choice sources. Respect their attribution and licence terms
("© Kartverket", CC BY 4.0). Cache where allowed to reduce load and improve resilience.

## P4. User owns their data

**A user's trips, plans, photos, and tracks belong to the user and are portable.**
*Rationale:* This is a personal logbook; lock-in would betray its purpose.
*Implication:* Support standard import/export (GPX for tracks; a documented JSON
export for the full log). No feature should make user data unextractable.

## P5. Norwegian UI, English documentation, bilingual domain terms

**The interface is Norwegian; documentation is English; domain terms carry both.**
*Rationale:* Matches the intended audience (Norwegian hikers) while keeping the
codebase and docs approachable to a broad developer audience.
*Implication:* Build for internationalisation (i18n) from the start even though
only Norwegian ships first, so English UI can be added without rework. See
[ADR-0003](../adr/0003-language-strategy.md).

## P6. Web first, but do not paint the mobile app into a corner

**Ship a web app first; keep a native app viable as a later phase.**
*Rationale:* The web reaches users fastest and is cheapest to run; a native app is
a nice-to-have. *Implication:* Keep business logic and data access behind a clean
API so a future native client can reuse it. Avoid web-only assumptions in the data
model. See [ADR-0004](../adr/0004-web-first-native-later.md).

## P7. Simple before clever

**Choose the simplest architecture that meets the requirement.**
*Rationale:* Complexity is the main enemy of a one-person project's longevity.
*Implication:* Start with a modular monolith and a single database. Introduce
services, queues, or extra infrastructure only when a concrete need appears.

## P8. Decisions are recorded, and deferral is a valid decision

**Significant choices — including the choice to defer — are captured as ADRs.**
*Rationale:* A future maintainer (or future you) needs the "why", and open
questions should be explicit rather than implicit. *Implication:* Tech stack and
map provider are recorded as **deferred** ADRs
([0005](../adr/0005-tech-stack-deferred.md),
[0006](../adr/0006-map-provider-deferred.md)) until we choose.

## P9. Privacy by default

**Collect the minimum personal data; keep location data private by default.**
*Rationale:* Trip locations and home trailheads are sensitive; the app should be
trustworthy. *Implication:* Trips are private unless the user explicitly shares.
Minimise accounts data. Comply with GDPR obligations for personal data even as a
hobby project.

## P10. Accessible and mobile-friendly

**The web app must work well on a phone and meet basic accessibility standards.**
*Rationale:* Hikers check plans and log trips from their phones, often outdoors.
*Implication:* Responsive design, readable outdoors, works on modest connections,
and targets WCAG 2.1 AA where reasonable.
