# Functional Requirements

Requirements are grouped by capability and given stable IDs so they can be traced
from the [business architecture](../architecture/02-business-architecture.md) and
[use cases](../use-cases/use-cases.md). Priority uses **MoSCoW**: **M** = Must (MVP),
**S** = Should, **C** = Could, **W** = Won't (this time / out of scope for now).

Domain terms follow the [glossary](../glossary.md).

## Account & profile (FR-ACC) — capability C9

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-ACC-1 | A visitor can register an account (email + password, or OAuth). | M |
| FR-ACC-2 | A user can log in and log out securely. | M |
| FR-ACC-3 | A user can view and edit their profile (display name, locale). | M |
| FR-ACC-4 | A user can set a default privacy level; default is **private**. | M |
| FR-ACC-5 | A user can delete their account and all personal data. | S |
| FR-ACC-6 | A user can reset a forgotten password. | S |

## Trip logging (FR-LOG) — capability C1

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-LOG-1 | A user can create a **completed trip (tur)** with a date and a type (**fottur** / **topptur**). | M |
| FR-LOG-2 | A user can associate one or more **peaks (fjelltopper)** with a trip. | M |
| FR-LOG-3 | A user can record ascent (**stigning**, in metres), difficulty (**gradering**), and conditions (**føre**). | M |
| FR-LOG-4 | A user can add free-text notes (**notat**) to a trip. | M |
| FR-LOG-5 | A user can attach one or more photos (**bilde**) to a trip. | C (later phase) |
| FR-LOG-6 | A user can edit and delete their own trips. | M |
| FR-LOG-7 | A user can view a trip detail page with map, photos, and stats. | M |
| FR-LOG-8 | When a trip includes a peak, that peak is marked as **bagged (toppet)** for the user. | M |

## Logbook — private diary & public guestbook (FR-BOOK) — capability C1 / see [ADR-0009](../adr/0009-private-and-public-logbook.md)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-BOOK-1 | A user can write **private diary notes (dagboknotat)** on a trip, visible only to them. | M |
| FR-BOOK-2 | Private is the default; a diary note is never published automatically. | M |
| FR-BOOK-3 | A user can post a **public greeting (gjestebokhilsen)** to a summit's, cabin's, or route's **guestbook (gjestebok)** when logging a visit. | S |
| FR-BOOK-4 | A place's page displays its public guestbook entries (author, date, greeting). | S |
| FR-BOOK-5 | Posting a public greeting is an explicit, separate action from writing a private note. | M |
| FR-BOOK-6 | The maintainer/administrator can moderate and remove public guestbook content. | S |

## Trip planning & wishlist (FR-PLAN) — capabilities C2, C3

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-PLAN-1 | A user can create a **planned trip (planlagt tur)** with a target peak and optional target date. | M |
| FR-PLAN-2 | Planned trips are shown on the map in a style distinct from completed trips. | M |
| FR-PLAN-3 | A user can convert a planned trip into a completed trip. | M |
| FR-PLAN-4 | A user can add a peak (or trip idea) to a **wishlist (ønskeliste)**. | S |
| FR-PLAN-5 | A user can convert a wishlist item into a planned trip. | S |
| FR-PLAN-6 | A user can attach a chosen route (**rute**) to a planned trip. | C |

## Map & visualisation (FR-MAP) — capability C4

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-MAP-1 | The app shows a topographic map (**topografisk kart**) of Norway with pan and zoom. | M |
| FR-MAP-2 | The map shows known **mountain tops (fjelltopper)** as markers. | M |
| FR-MAP-3 | The map shows the user's completed and planned trips. | M |
| FR-MAP-4 | The user can toggle map layers (**kartlag**): peaks, trips, trails. | M |
| FR-MAP-5 | The map fetches features for the current extent (**utstrekning**) efficiently. | M |
| FR-MAP-6 | The map shows marked **trails/routes (turruter)** as a layer. | S |
| FR-MAP-7 | Clicking a peak or trip marker opens its details. | M |
| FR-MAP-8 | Required data-source attribution (e.g. "© Kartverket") is displayed on the map. | M |

## Peak & trail catalogue (FR-PEAK) — capabilities C5, C6

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-PEAK-1 | A user can search peaks by name. | M |
| FR-PEAK-2 | A user can view a peak detail: name, elevation (**moh.**), location, and whether they have bagged it. | M |
| FR-PEAK-3 | A user can filter peaks by area (**kommune / region / fjellområde**) and elevation. | S |
| FR-PEAK-4 | A user can browse trails near a peak or location. | S |
| FR-PEAK-5 | A visitor (not logged in) can browse the public peak catalogue read-only. | C |

## Statistics & achievements (FR-STAT) — capabilities C7, C8

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-STAT-1 | A user can see totals: peaks bagged, total ascent, number of trips. | M |
| FR-STAT-2 | A user can see trips and ascent per year. | S |
| FR-STAT-3 | A user can see stats broken down by area/region. | C |
| FR-STAT-4 | A user earns simple achievements/milestones (**bragder**). | C |

## Import / export (FR-DATA) — capability C10

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-DATA-1 | A user can import a **GPX** file to attach a track (**spor**) to a trip. | S |
| FR-DATA-2 | Length and ascent are computed from an imported track. | S |
| FR-DATA-3 | A user can export all their data as documented JSON. | S |
| FR-DATA-4 | A user can export a trip's track as GPX. | C |

## Activity-tracking integrations (FR-ACT) — see [ADR-0008](../adr/0008-activity-tracking-integrations.md)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-ACT-1 | A user can connect a **Strava** account via OAuth. | S |
| FR-ACT-2 | New activities uploaded to a connected service are imported (via webhook or polling). | S |
| FR-ACT-3 | An imported activity is matched against known peaks, cabins, and routes and proposes **auto check-ins (automatisk avkryssing)**. | S |
| FR-ACT-4 | Proposed auto check-ins are **user-confirmable** before being applied to the logbook. | S |
| FR-ACT-5 | An imported activity attaches its **track (spor)** to the created or updated trip. | S |
| FR-ACT-6 | A user can connect **Garmin** (or other services) via the same mechanism. | C |
| FR-ACT-7 | A user can disconnect a service and delete data imported from it. | S |

## Reference data — sources, ingestion & linking (FR-REF) — capabilities C5, C6, C12 / see [ADR-0012](../adr/0012-kartverket-primary-source.md)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-REF-1 | The system can ingest and normalise peaks from open Norwegian sources. | M |
| FR-REF-2 | The system can ingest trails/routes from **Turrutebasen** ("Tur- og friluftsruter"). | S |
| FR-REF-3 | Ingested reference data records its **source dataset and fetch date** and can be refreshed. | M |
| FR-REF-4 | Ingestion can run on a schedule without manual steps. | C |
| FR-REF-5 | Core reference data on **peaks, routes, and cabins** is sourced from **Kartverket** open datasets (SSR, Høydedata, N50 Kartdata, Turrutebasen). | M |
| FR-REF-6 | Each peak, route, and cabin stores a stable **Kartverket identifier** (`stedsnummer` for SSR places, `lokalid` for N50 / Turrutebasen objects). | M |
| FR-REF-7 | A peak, route, or cabin **may** store an optional **deep link to a UT.no page**; the field is **nullable** and the app renders correctly without it. | S |
| FR-REF-8 | Where such a link exists, a user can open it to read a full human-written description. | S |
| FR-REF-9 | **Cabins (hytter)** are available as reference places and as trip waypoints, sourced from N50 `Turisthytte` (with `betjeningsgrad` and `eier`); trailheads and parking come from Turrutebasen `Ruteinfopunkt`. | S |
| FR-REF-10 | Peak names and coordinates come from **SSR**; elevation (**moh.**) is derived by sampling **Kartverket Høydedata (DTM)** and the two are reconciled at ingestion. | S |
| FR-REF-11 | A **documented, versioned rule** defines which SSR points qualify as a peak (`navneobjekttype` set plus an elevation and/or prominence threshold), so the catalogue is reproducible. | M |

## Sharing (FR-SHARE) — capability C11 (later)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-SHARE-1 | A user can share a single trip via a link. | W (Phase 3) |
| FR-SHARE-2 | A user can enable a public profile. | W (Phase 3) |

## Connections between users (FR-SOCIAL) — capability C11 (later stage)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-SOCIAL-1 | A user can connect with other users as **friends (venner)**. | W (later) |
| FR-SOCIAL-2 | A user can **share a wishlist (ønskeliste)** with friends. | W (later) |
| FR-SOCIAL-3 | A user can **tag other users (merke/tagge)** on a logged trip. | W (later) |
| FR-SOCIAL-4 | A user controls who can see shared content and can approve/decline connections and tags. | W (later) |

## Internationalisation (FR-I18N) — Principle P5

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-I18N-1 | All UI strings are provided through an i18n layer; **nb-NO** ships first. | M |
| FR-I18N-2 | The architecture supports adding **en** without code changes to features. | S |
