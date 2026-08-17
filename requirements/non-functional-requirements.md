# Non-Functional Requirements (NFRs)

Quality attributes the system must satisfy, with IDs for traceability. These are
sized for a **hobby project** (Principle P1) — deliberately modest where enterprise
systems would be strict.

Unlike the [functional requirements](functional-requirements.md), an `NFR-*` gets **no
GitHub issue** — it is a standing constraint rather than a unit of work, and would never
close. Reference NFR IDs from pull requests and ADRs instead; that is where the evidence
they hold belongs. See [ADR-0014](../adr/0014-requirements-traceability.md).

## Cost & operations (NFR-COST) — P1

| ID | Requirement |
| --- | --- |
| NFR-COST-1 | Running the service at hobby scale should cost approximately nothing (free tiers or a single small instance). |
| NFR-COST-2 | The system must be operable by a single maintainer without on-call duties. |
| NFR-COST-3 | Prefer managed/serverless components to reduce operational effort, subject to NFR-COST-1. |

## Performance (NFR-PERF) — P10

| ID | Requirement |
| --- | --- |
| NFR-PERF-1 | The map view should become interactive within ~3 seconds on a typical mobile connection. |
| NFR-PERF-2 | Feature queries for the current map extent should return within ~500 ms at expected data volumes. |
| NFR-PERF-3 | The app should remain usable on modest/older phones and on slower outdoor connections. |

## Usability & accessibility (NFR-UX) — P10, P5

| ID | Requirement |
| --- | --- |
| NFR-UX-1 | The UI is fully in Norwegian (**nb-NO**) and uses the domain vocabulary from the glossary. |
| NFR-UX-2 | The UI is responsive and mobile-first; core tasks work well on a phone. |
| NFR-UX-3 | Target WCAG 2.1 AA for colour contrast, keyboard use, and screen-reader labels where reasonable. |
| NFR-UX-4 | The map must remain legible outdoors (contrast, marker size, touch targets). |
| NFR-UX-5 | Logging a simple completed trip should take no more than a couple of minutes. |

## Security (NFR-SEC) — P9

| ID | Requirement |
| --- | --- |
| NFR-SEC-1 | All traffic is over HTTPS/TLS. |
| NFR-SEC-2 | Passwords are stored using a strong, salted hashing algorithm; secrets are never committed to the repository. |
| NFR-SEC-3 | User-data endpoints require authentication and enforce per-user access control. |
| NFR-SEC-4 | Public endpoints are rate-limited and validate all input. |
| NFR-SEC-5 | Dependencies are kept reasonably up to date; known-vulnerable versions are avoided. |

## Privacy & compliance (NFR-PRIV) — P9

| ID | Requirement |
| --- | --- |
| NFR-PRIV-1 | Trips and location data are private by default; sharing is explicit. |
| NFR-PRIV-2 | The system collects the minimum personal data necessary. |
| NFR-PRIV-3 | Users can export all their data and delete their account (GDPR data subject rights). |
| NFR-PRIV-4 | No third-party advertising or behavioural tracking. |
| NFR-PRIV-5 | Personal data is hosted in an EEA-appropriate region where practical. |

## Reliability & data safety (NFR-REL) — P4

| ID | Requirement |
| --- | --- |
| NFR-REL-1 | User data is backed up automatically; a restore path is documented. |
| NFR-REL-2 | Reference data is rebuildable from source and need not be backed up. |
| NFR-REL-3 | Hobby-grade availability is acceptable (no HA/SLA); brief downtime is tolerable. |
| NFR-REL-4 | Data loss of user trips/plans/photos is not acceptable — this is the one hard reliability line. |

## Portability & maintainability (NFR-MAINT) — P4, P7, P8

| ID | Requirement |
| --- | --- |
| NFR-MAINT-1 | Avoid hard vendor lock-in that would trap user data or force a rewrite. |
| NFR-MAINT-2 | Business logic sits behind a versioned API reusable by a future native client. |
| NFR-MAINT-3 | The codebase favours simplicity; new infrastructure is added only on demonstrated need. |
| NFR-MAINT-4 | Significant decisions are recorded as ADRs. |
| NFR-MAINT-5 | Documentation is kept in the repository and in English; domain terms are bilingual. |

## Interoperability (NFR-INTEROP) — P3, P4

| ID | Requirement |
| --- | --- |
| NFR-INTEROP-1 | Tracks import/export use GPX; geometry interchange uses GeoJSON where relevant. |
| NFR-INTEROP-2 | Canonical coordinates are stored in WGS84 (EPSG:4326); transforms happen at the edges. |
| NFR-INTEROP-3 | External data-source attribution and licence terms are honoured and surfaced in the UI. |

## Legal (NFR-LEGAL) — P3

| ID | Requirement |
| --- | --- |
| NFR-LEGAL-1 | Only data sources whose licences permit this use are used. |
| NFR-LEGAL-2 | The required **"© Kartverket"** attribution is displayed wherever map tiles or reference data appear; it covers every Kartverket dataset we use (all CC BY 4.0). |
| NFR-LEGAL-3 | Third-party terms are respected, including branding/attribution and non-commercial conditions: Kartverket (CC BY 4.0), Strava, Garmin. |

## Third-party integrations (NFR-INTEG) — ADR-0012, ADR-0008

| ID | Requirement |
| --- | --- |
| NFR-INTEG-1 | External integrations (Kartverket data sources, Strava, Garmin) sit behind provider-agnostic interfaces so a provider can be added or replaced without wide changes. |
| NFR-INTEG-2 | The app degrades gracefully when an external service is unavailable: cached reference data and manual logging still work. |
| NFR-INTEG-3 | OAuth tokens and API secrets for connected services are stored securely and never committed to the repository. |
| NFR-INTEG-4 | Per-provider rate limits are respected; ingestion uses webhooks where available and backs off on errors. |
| NFR-INTEG-5 | Connecting an external account is opt-in; a user can disconnect and delete imported data at any time. |
| NFR-INTEG-6 | Reference data is held as a **local copy rebuildable from published Kartverket datasets**, so an upstream outage never affects runtime and a re-import restores it. |

## Public / user-generated content (NFR-CONTENT) — ADR-0009, P9

| ID | Requirement |
| --- | --- |
| NFR-CONTENT-1 | Private diary content is never exposed publicly; only explicit public greetings appear in guestbooks. |
| NFR-CONTENT-2 | Public guestbook content can be moderated (reported and removed) and has basic spam/abuse protection. |
| NFR-CONTENT-3 | When social features exist, shared content (wishlists, tags) is visible only to the audience the user chooses. |
