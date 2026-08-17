# Traceability matrix

> **Generated file - do not edit.**
> Written by `tools/traceability/Build-Matrix.ps1`. Any hand-edit is overwritten on the
> next run. The requirement text is owned by
> [functional-requirements.md](functional-requirements.md); the status is owned by the
> issues and pull requests. This file only joins them ([ADR-0014](../adr/0014-requirements-traceability.md)).

Non-functional requirements are deliberately absent: they get no issues, because a
standing constraint never closes. See
[non-functional-requirements.md](non-functional-requirements.md).

## Summary

| Status | Requirements |
| --- | --- |
| Not started | 67 |
| Deferred | 6 |
| **Total** | **73** |

## By requirement group

| Group | Total | Implemented | In progress | Not started | Deferred |
| --- | --- | --- | --- | --- | --- |
| FR-ACC | 6 | 0 | 0 | 6 | 0 |
| FR-ACT | 7 | 0 | 0 | 7 | 0 |
| FR-BOOK | 6 | 0 | 0 | 6 | 0 |
| FR-DATA | 4 | 0 | 0 | 4 | 0 |
| FR-I18N | 2 | 0 | 0 | 2 | 0 |
| FR-LOG | 8 | 0 | 0 | 8 | 0 |
| FR-MAP | 8 | 0 | 0 | 8 | 0 |
| FR-PEAK | 5 | 0 | 0 | 5 | 0 |
| FR-PLAN | 6 | 0 | 0 | 6 | 0 |
| FR-REF | 11 | 0 | 0 | 11 | 0 |
| FR-SHARE | 2 | 0 | 0 | 0 | 2 |
| FR-SOCIAL | 4 | 0 | 0 | 0 | 4 |
| FR-STAT | 4 | 0 | 0 | 4 | 0 |

## By use case

| Use case | Requirements | Implemented |
| --- | --- | --- |
| [UC-1](../use-cases/use-cases.md) Register and set up an account | 5 | 0 / 5 |
| [UC-2](../use-cases/use-cases.md) Log a completed summit trip (turføring) | 10 | 0 / 10 |
| [UC-3](../use-cases/use-cases.md) Plan a future trip (turplanlegging) | 5 | 0 / 5 |
| [UC-4](../use-cases/use-cases.md) Build a wishlist / bucket list (ønskeliste) | 5 | 0 / 5 |
| [UC-5](../use-cases/use-cases.md) Explore the map (kartutforsking) | 8 | 0 / 8 |
| [UC-6](../use-cases/use-cases.md) Browse a peak and see personal history (toppdetalj) | 4 | 0 / 4 |
| [UC-7](../use-cases/use-cases.md) Import a GPX track (spor-import) | 3 | 0 / 3 |
| [UC-8](../use-cases/use-cases.md) See statistics (statistikk) | 4 | 0 / 4 |
| [UC-9](../use-cases/use-cases.md) Export data / delete account (mine data) | 3 | 0 / 3 |
| [UC-10](../use-cases/use-cases.md) Refresh reference data (maintainer) | 9 | 0 / 9 |
| [UC-11](../use-cases/use-cases.md) Share a trip (later) | 2 | 0 / 2 |
| [UC-12](../use-cases/use-cases.md) Look up a place's details and external reference | 5 | 0 / 5 |
| [UC-13](../use-cases/use-cases.md) Auto-check a summit from a Strava activity (automatisk avkryssing) | 7 | 0 / 7 |
| [UC-14](../use-cases/use-cases.md) Private diary note and public greeting (dagbok + gjestebok) | 6 | 0 / 6 |
| [UC-15](../use-cases/use-cases.md) Connect with friends, tag, and share a wishlist (later stage) | 4 | 0 / 4 |

## Requirements

### FR-ACC-1

A visitor can register an account (email + password, or OAuth).

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-ACC](functional-requirements.md#account--profile-fr-acc--capability-c9) |
| Capability | C9 |
| Use cases | UC-1 |
| Issue | none |

### FR-ACC-2

A user can log in and log out securely.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-ACC](functional-requirements.md#account--profile-fr-acc--capability-c9) |
| Capability | C9 |
| Use cases | UC-1 |
| Issue | none |

### FR-ACC-3

A user can view and edit their profile (display name, locale).

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-ACC](functional-requirements.md#account--profile-fr-acc--capability-c9) |
| Capability | C9 |
| Use cases | UC-1 |
| Issue | none |

### FR-ACC-4

A user can set a default privacy level; default is **private**.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-ACC](functional-requirements.md#account--profile-fr-acc--capability-c9) |
| Capability | C9 |
| Use cases | UC-1 |
| Issue | none |

### FR-ACC-5

A user can delete their account and all personal data.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-ACC](functional-requirements.md#account--profile-fr-acc--capability-c9) |
| Capability | C9 |
| Use cases | UC-9 |
| Issue | none |

### FR-ACC-6

A user can reset a forgotten password.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-ACC](functional-requirements.md#account--profile-fr-acc--capability-c9) |
| Capability | C9 |
| Issue | none |

### FR-LOG-1

A user can create a **completed trip (tur)** with a date and a type (**fottur** / **topptur**).

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-LOG](functional-requirements.md#trip-logging-fr-log--capability-c1) |
| Capability | C1 |
| Use cases | UC-2 |
| Issue | none |

### FR-LOG-2

A user can associate one or more **peaks (fjelltopper)** with a trip.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-LOG](functional-requirements.md#trip-logging-fr-log--capability-c1) |
| Capability | C1 |
| Use cases | UC-2 |
| Issue | none |

### FR-LOG-3

A user can record ascent (**stigning**, in metres), difficulty (**gradering**), and conditions (**føre**).

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-LOG](functional-requirements.md#trip-logging-fr-log--capability-c1) |
| Capability | C1 |
| Use cases | UC-2, UC-7 |
| Issue | none |

### FR-LOG-4

A user can add free-text notes (**notat**) to a trip.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-LOG](functional-requirements.md#trip-logging-fr-log--capability-c1) |
| Capability | C1 |
| Use cases | UC-2 |
| Issue | none |

### FR-LOG-5

A user can attach one or more photos (**bilde**) to a trip.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | C (later phase) |
| Group | [FR-LOG](functional-requirements.md#trip-logging-fr-log--capability-c1) |
| Capability | C1 |
| Use cases | UC-2 |
| Issue | none |

### FR-LOG-6

A user can edit and delete their own trips.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-LOG](functional-requirements.md#trip-logging-fr-log--capability-c1) |
| Capability | C1 |
| Use cases | UC-2 |
| Issue | none |

### FR-LOG-7

A user can view a trip detail page with map, photos, and stats.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-LOG](functional-requirements.md#trip-logging-fr-log--capability-c1) |
| Capability | C1 |
| Use cases | UC-2 |
| Issue | none |

### FR-LOG-8

When a trip includes a peak, that peak is marked as **bagged (toppet)** for the user.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-LOG](functional-requirements.md#trip-logging-fr-log--capability-c1) |
| Capability | C1 |
| Use cases | UC-2, UC-6, UC-13 |
| Issue | none |

### FR-BOOK-1

A user can write **private diary notes (dagboknotat)** on a trip, visible only to them.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-BOOK](functional-requirements.md#logbook--private-diary--public-guestbook-fr-book--capability-c1--see-adr-0009) |
| Capability | C1 |
| Use cases | UC-14 |
| Issue | none |

### FR-BOOK-2

Private is the default; a diary note is never published automatically.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-BOOK](functional-requirements.md#logbook--private-diary--public-guestbook-fr-book--capability-c1--see-adr-0009) |
| Capability | C1 |
| Use cases | UC-14 |
| Issue | none |

### FR-BOOK-3

A user can post a **public greeting (gjestebokhilsen)** to a summit's, cabin's, or route's **guestbook (gjestebok)** when logging a visit.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-BOOK](functional-requirements.md#logbook--private-diary--public-guestbook-fr-book--capability-c1--see-adr-0009) |
| Capability | C1 |
| Use cases | UC-14 |
| Issue | none |

### FR-BOOK-4

A place's page displays its public guestbook entries (author, date, greeting).

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-BOOK](functional-requirements.md#logbook--private-diary--public-guestbook-fr-book--capability-c1--see-adr-0009) |
| Capability | C1 |
| Use cases | UC-14 |
| Issue | none |

### FR-BOOK-5

Posting a public greeting is an explicit, separate action from writing a private note.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-BOOK](functional-requirements.md#logbook--private-diary--public-guestbook-fr-book--capability-c1--see-adr-0009) |
| Capability | C1 |
| Use cases | UC-14 |
| Issue | none |

### FR-BOOK-6

The maintainer/administrator can moderate and remove public guestbook content.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-BOOK](functional-requirements.md#logbook--private-diary--public-guestbook-fr-book--capability-c1--see-adr-0009) |
| Capability | C1 |
| Use cases | UC-14 |
| Issue | none |

### FR-PLAN-1

A user can create a **planned trip (planlagt tur)** with a target peak and optional target date.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-PLAN](functional-requirements.md#trip-planning--wishlist-fr-plan--capabilities-c2-c3) |
| Capability | C2, C3 |
| Use cases | UC-3 |
| Issue | none |

### FR-PLAN-2

Planned trips are shown on the map in a style distinct from completed trips.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-PLAN](functional-requirements.md#trip-planning--wishlist-fr-plan--capabilities-c2-c3) |
| Capability | C2, C3 |
| Use cases | UC-3 |
| Issue | none |

### FR-PLAN-3

A user can convert a planned trip into a completed trip.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-PLAN](functional-requirements.md#trip-planning--wishlist-fr-plan--capabilities-c2-c3) |
| Capability | C2, C3 |
| Use cases | UC-3 |
| Issue | none |

### FR-PLAN-4

A user can add a peak (or trip idea) to a **wishlist (ønskeliste)**.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-PLAN](functional-requirements.md#trip-planning--wishlist-fr-plan--capabilities-c2-c3) |
| Capability | C2, C3 |
| Use cases | UC-4 |
| Issue | none |

### FR-PLAN-5

A user can convert a wishlist item into a planned trip.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-PLAN](functional-requirements.md#trip-planning--wishlist-fr-plan--capabilities-c2-c3) |
| Capability | C2, C3 |
| Use cases | UC-4 |
| Issue | none |

### FR-PLAN-6

A user can attach a chosen route (**rute**) to a planned trip.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | C |
| Group | [FR-PLAN](functional-requirements.md#trip-planning--wishlist-fr-plan--capabilities-c2-c3) |
| Capability | C2, C3 |
| Use cases | UC-3 |
| Issue | none |

### FR-MAP-1

The app shows a topographic map (**topografisk kart**) of Norway with pan and zoom.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-MAP](functional-requirements.md#map--visualisation-fr-map--capability-c4) |
| Capability | C4 |
| Use cases | UC-5 |
| Issue | none |

### FR-MAP-2

The map shows known **mountain tops (fjelltopper)** as markers.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-MAP](functional-requirements.md#map--visualisation-fr-map--capability-c4) |
| Capability | C4 |
| Use cases | UC-3, UC-5 |
| Issue | none |

### FR-MAP-3

The map shows the user's completed and planned trips.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-MAP](functional-requirements.md#map--visualisation-fr-map--capability-c4) |
| Capability | C4 |
| Use cases | UC-2, UC-5 |
| Issue | none |

### FR-MAP-4

The user can toggle map layers (**kartlag**): peaks, trips, trails.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-MAP](functional-requirements.md#map--visualisation-fr-map--capability-c4) |
| Capability | C4 |
| Use cases | UC-5 |
| Issue | none |

### FR-MAP-5

The map fetches features for the current extent (**utstrekning**) efficiently.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-MAP](functional-requirements.md#map--visualisation-fr-map--capability-c4) |
| Capability | C4 |
| Use cases | UC-5 |
| Issue | none |

### FR-MAP-6

The map shows marked **trails/routes (turruter)** as a layer.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-MAP](functional-requirements.md#map--visualisation-fr-map--capability-c4) |
| Capability | C4 |
| Use cases | UC-5 |
| Issue | none |

### FR-MAP-7

Clicking a peak or trip marker opens its details.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-MAP](functional-requirements.md#map--visualisation-fr-map--capability-c4) |
| Capability | C4 |
| Use cases | UC-5 |
| Issue | none |

### FR-MAP-8

Required data-source attribution (e.g. "© Kartverket") is displayed on the map.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-MAP](functional-requirements.md#map--visualisation-fr-map--capability-c4) |
| Capability | C4 |
| Use cases | UC-5 |
| Issue | none |

### FR-PEAK-1

A user can search peaks by name.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-PEAK](functional-requirements.md#peak--trail-catalogue-fr-peak--capabilities-c5-c6) |
| Capability | C5, C6 |
| Use cases | UC-4, UC-6 |
| Issue | none |

### FR-PEAK-2

A user can view a peak detail: name, elevation (**moh.**), location, and whether they have bagged it.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-PEAK](functional-requirements.md#peak--trail-catalogue-fr-peak--capabilities-c5-c6) |
| Capability | C5, C6 |
| Use cases | UC-4, UC-6 |
| Issue | none |

### FR-PEAK-3

A user can filter peaks by area (**kommune / region / fjellområde**) and elevation.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-PEAK](functional-requirements.md#peak--trail-catalogue-fr-peak--capabilities-c5-c6) |
| Capability | C5, C6 |
| Use cases | UC-4, UC-6 |
| Issue | none |

### FR-PEAK-4

A user can browse trails near a peak or location.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-PEAK](functional-requirements.md#peak--trail-catalogue-fr-peak--capabilities-c5-c6) |
| Capability | C5, C6 |
| Issue | none |

### FR-PEAK-5

A visitor (not logged in) can browse the public peak catalogue read-only.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | C |
| Group | [FR-PEAK](functional-requirements.md#peak--trail-catalogue-fr-peak--capabilities-c5-c6) |
| Capability | C5, C6 |
| Issue | none |

### FR-STAT-1

A user can see totals: peaks bagged, total ascent, number of trips.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-STAT](functional-requirements.md#statistics--achievements-fr-stat--capabilities-c7-c8) |
| Capability | C7, C8 |
| Use cases | UC-2, UC-8 |
| Issue | none |

### FR-STAT-2

A user can see trips and ascent per year.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-STAT](functional-requirements.md#statistics--achievements-fr-stat--capabilities-c7-c8) |
| Capability | C7, C8 |
| Use cases | UC-8 |
| Issue | none |

### FR-STAT-3

A user can see stats broken down by area/region.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | C |
| Group | [FR-STAT](functional-requirements.md#statistics--achievements-fr-stat--capabilities-c7-c8) |
| Capability | C7, C8 |
| Use cases | UC-8 |
| Issue | none |

### FR-STAT-4

A user earns simple achievements/milestones (**bragder**).

| | |
| --- | --- |
| Status | **Not started** |
| Priority | C |
| Group | [FR-STAT](functional-requirements.md#statistics--achievements-fr-stat--capabilities-c7-c8) |
| Capability | C7, C8 |
| Use cases | UC-8 |
| Issue | none |

### FR-DATA-1

A user can import a **GPX** file to attach a track (**spor**) to a trip.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-DATA](functional-requirements.md#import--export-fr-data--capability-c10) |
| Capability | C10 |
| Use cases | UC-7 |
| Issue | none |

### FR-DATA-2

Length and ascent are computed from an imported track.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-DATA](functional-requirements.md#import--export-fr-data--capability-c10) |
| Capability | C10 |
| Use cases | UC-7, UC-13 |
| Issue | none |

### FR-DATA-3

A user can export all their data as documented JSON.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-DATA](functional-requirements.md#import--export-fr-data--capability-c10) |
| Capability | C10 |
| Use cases | UC-9 |
| Issue | none |

### FR-DATA-4

A user can export a trip's track as GPX.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | C |
| Group | [FR-DATA](functional-requirements.md#import--export-fr-data--capability-c10) |
| Capability | C10 |
| Use cases | UC-9 |
| Issue | none |

### FR-ACT-1

A user can connect a **Strava** account via OAuth.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-ACT](functional-requirements.md#activity-tracking-integrations-fr-act--see-adr-0008) |
| Use cases | UC-13 |
| Issue | none |

### FR-ACT-2

New activities uploaded to a connected service are imported (via webhook or polling).

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-ACT](functional-requirements.md#activity-tracking-integrations-fr-act--see-adr-0008) |
| Use cases | UC-13 |
| Issue | none |

### FR-ACT-3

An imported activity is matched against known peaks, cabins, and routes and proposes **auto check-ins (automatisk avkryssing)**.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-ACT](functional-requirements.md#activity-tracking-integrations-fr-act--see-adr-0008) |
| Use cases | UC-13 |
| Issue | none |

### FR-ACT-4

Proposed auto check-ins are **user-confirmable** before being applied to the logbook.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-ACT](functional-requirements.md#activity-tracking-integrations-fr-act--see-adr-0008) |
| Use cases | UC-13 |
| Issue | none |

### FR-ACT-5

An imported activity attaches its **track (spor)** to the created or updated trip.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-ACT](functional-requirements.md#activity-tracking-integrations-fr-act--see-adr-0008) |
| Use cases | UC-13 |
| Issue | none |

### FR-ACT-6

A user can connect **Garmin** (or other services) via the same mechanism.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | C |
| Group | [FR-ACT](functional-requirements.md#activity-tracking-integrations-fr-act--see-adr-0008) |
| Issue | none |

### FR-ACT-7

A user can disconnect a service and delete data imported from it.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-ACT](functional-requirements.md#activity-tracking-integrations-fr-act--see-adr-0008) |
| Issue | none |

### FR-REF-1

The system can ingest and normalise peaks from open Norwegian sources.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-REF](functional-requirements.md#reference-data--sources-ingestion--linking-fr-ref--capabilities-c5-c6-c12--see-adr-0012) |
| Capability | C5, C6, C12 |
| Use cases | UC-10 |
| Issue | none |

### FR-REF-2

The system can ingest trails/routes from **Turrutebasen** ("Tur- og friluftsruter").

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-REF](functional-requirements.md#reference-data--sources-ingestion--linking-fr-ref--capabilities-c5-c6-c12--see-adr-0012) |
| Capability | C5, C6, C12 |
| Use cases | UC-10 |
| Issue | none |

### FR-REF-3

Ingested reference data records its **source dataset and fetch date** and can be refreshed.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-REF](functional-requirements.md#reference-data--sources-ingestion--linking-fr-ref--capabilities-c5-c6-c12--see-adr-0012) |
| Capability | C5, C6, C12 |
| Use cases | UC-10 |
| Issue | none |

### FR-REF-4

Ingestion can run on a schedule without manual steps.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | C |
| Group | [FR-REF](functional-requirements.md#reference-data--sources-ingestion--linking-fr-ref--capabilities-c5-c6-c12--see-adr-0012) |
| Capability | C5, C6, C12 |
| Use cases | UC-10 |
| Issue | none |

### FR-REF-5

Core reference data on **peaks, routes, and cabins** is sourced from **Kartverket** open datasets (SSR, Høydedata, N50 Kartdata, Turrutebasen).

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-REF](functional-requirements.md#reference-data--sources-ingestion--linking-fr-ref--capabilities-c5-c6-c12--see-adr-0012) |
| Capability | C5, C6, C12 |
| Use cases | UC-10, UC-12 |
| Issue | none |

### FR-REF-6

Each peak, route, and cabin stores a stable **Kartverket identifier** (`stedsnummer` for SSR places, `lokalid` for N50 / Turrutebasen objects).

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-REF](functional-requirements.md#reference-data--sources-ingestion--linking-fr-ref--capabilities-c5-c6-c12--see-adr-0012) |
| Capability | C5, C6, C12 |
| Use cases | UC-10, UC-12 |
| Issue | none |

### FR-REF-7

A peak, route, or cabin **may** store an optional **deep link to a UT.no page**; the field is **nullable** and the app renders correctly without it.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-REF](functional-requirements.md#reference-data--sources-ingestion--linking-fr-ref--capabilities-c5-c6-c12--see-adr-0012) |
| Capability | C5, C6, C12 |
| Use cases | UC-12 |
| Issue | none |

### FR-REF-8

Where such a link exists, a user can open it to read a full human-written description.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-REF](functional-requirements.md#reference-data--sources-ingestion--linking-fr-ref--capabilities-c5-c6-c12--see-adr-0012) |
| Capability | C5, C6, C12 |
| Use cases | UC-12 |
| Issue | none |

### FR-REF-9

**Cabins (hytter)** are available as reference places and as trip waypoints, sourced from N50 `Turisthytte` (with `betjeningsgrad` and `eier`); trailheads and parking come from Turrutebasen `Ruteinfopunkt`.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-REF](functional-requirements.md#reference-data--sources-ingestion--linking-fr-ref--capabilities-c5-c6-c12--see-adr-0012) |
| Capability | C5, C6, C12 |
| Use cases | UC-10, UC-12 |
| Issue | none |

### FR-REF-10

Peak names and coordinates come from **SSR**; elevation (**moh.**) is derived by sampling **Kartverket Høydedata (DTM)** and the two are reconciled at ingestion.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-REF](functional-requirements.md#reference-data--sources-ingestion--linking-fr-ref--capabilities-c5-c6-c12--see-adr-0012) |
| Capability | C5, C6, C12 |
| Use cases | UC-10 |
| Issue | none |

### FR-REF-11

A **documented, versioned rule** defines which SSR points qualify as a peak (`navneobjekttype` set plus an elevation and/or prominence threshold), so the catalogue is reproducible.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-REF](functional-requirements.md#reference-data--sources-ingestion--linking-fr-ref--capabilities-c5-c6-c12--see-adr-0012) |
| Capability | C5, C6, C12 |
| Use cases | UC-10 |
| Issue | none |

### FR-SHARE-1

A user can share a single trip via a link.

| | |
| --- | --- |
| Status | **Deferred** |
| Priority | W (Phase 3) |
| Group | [FR-SHARE](functional-requirements.md#sharing-fr-share--capability-c11-later) |
| Capability | C11 |
| Use cases | UC-11 |
| Issue | none |

### FR-SHARE-2

A user can enable a public profile.

| | |
| --- | --- |
| Status | **Deferred** |
| Priority | W (Phase 3) |
| Group | [FR-SHARE](functional-requirements.md#sharing-fr-share--capability-c11-later) |
| Capability | C11 |
| Use cases | UC-11 |
| Issue | none |

### FR-SOCIAL-1

A user can connect with other users as **friends (venner)**.

| | |
| --- | --- |
| Status | **Deferred** |
| Priority | W (later) |
| Group | [FR-SOCIAL](functional-requirements.md#connections-between-users-fr-social--capability-c11-later-stage) |
| Capability | C11 |
| Use cases | UC-15 |
| Issue | none |

### FR-SOCIAL-2

A user can **share a wishlist (ønskeliste)** with friends.

| | |
| --- | --- |
| Status | **Deferred** |
| Priority | W (later) |
| Group | [FR-SOCIAL](functional-requirements.md#connections-between-users-fr-social--capability-c11-later-stage) |
| Capability | C11 |
| Use cases | UC-15 |
| Issue | none |

### FR-SOCIAL-3

A user can **tag other users (merke/tagge)** on a logged trip.

| | |
| --- | --- |
| Status | **Deferred** |
| Priority | W (later) |
| Group | [FR-SOCIAL](functional-requirements.md#connections-between-users-fr-social--capability-c11-later-stage) |
| Capability | C11 |
| Use cases | UC-15 |
| Issue | none |

### FR-SOCIAL-4

A user controls who can see shared content and can approve/decline connections and tags.

| | |
| --- | --- |
| Status | **Deferred** |
| Priority | W (later) |
| Group | [FR-SOCIAL](functional-requirements.md#connections-between-users-fr-social--capability-c11-later-stage) |
| Capability | C11 |
| Use cases | UC-15 |
| Issue | none |

### FR-I18N-1

All UI strings are provided through an i18n layer; **nb-NO** ships first.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | M |
| Group | [FR-I18N](functional-requirements.md#internationalisation-fr-i18n--principle-p5) |
| Use cases | UC-1 |
| Issue | none |

### FR-I18N-2

The architecture supports adding **en** without code changes to features.

| | |
| --- | --- |
| Status | **Not started** |
| Priority | S |
| Group | [FR-I18N](functional-requirements.md#internationalisation-fr-i18n--principle-p5) |
| Issue | none |
