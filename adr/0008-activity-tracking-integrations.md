# ADR-0008 — Activity-tracking service integrations (Strava primary)

**Status:** Accepted

## Context

Many hikers already record their trips with GPS on **Strava**, **Garmin**, or similar
services. Requiring them to also log the trip by hand in Rekfar is friction and a
reason logs go stale. If Rekfar can read a user's uploaded activities, it can
**automatically "check off"** the peaks, cabins, and routes they visited and attach the
track — turning logging into a mostly automatic process. This directly supports the
low-friction logging ideas in the [use cases](../use-cases/use-cases.md#ideas--opportunities-idea-backlog).

## Decision

1. Rekfar will **integrate with GPS activity-tracking services**:
   - **Strava — primary** (broadest adoption, documented API + webhooks).
   - **Garmin — alternative / later** (Garmin Connect; access is more gated).
   - Others (e.g. direct GPX upload, Polar, Suunto) — possible later behind the same
     abstraction.
2. When a user **connects** their account (via **OAuth**) and a new activity is
   uploaded to the external service, Rekfar ingests the activity (via **webhooks**
   where available, otherwise polling), attaches the **track (spor)**, and **matches**
   it against known peaks, cabins, and routes to **auto-check** them in the logbook.
3. **Auto-detected check-ins are user-confirmable.** Matching (e.g. track high point
   near a known summit, or passing a cabin) can produce false positives, so proposed
   check-ins are surfaced for the user to confirm or dismiss rather than applied
   silently.
4. Integrations sit behind a **provider-agnostic activity-integration interface** so
   adding or removing a provider does not ripple through the app.

## Consequences

- **Positive:** dramatically lowers logging friction; keeps the log current with little
  effort; reuses tracks users already have. Strong fit with the product's "calm,
  personal log" identity.
- **Third-party dependency & terms:** OAuth credentials/secrets to manage; per-provider
  rate limits and API terms to respect (Strava's terms permit non-commercial use, which
  fits this project's premise; branding/attribution rules apply). Garmin API access
  typically requires an application/approval.
- **Matching algorithm needed:** proximity/high-point matching against the Kartverket
  reference data (see [ADR-0012](0012-kartverket-primary-source.md)); quality of
  auto-check depends on it — hence user confirmation.
- **Privacy:** connecting an external account and importing tracks is sensitive; it is
  opt-in, and imported data stays private by default (P9). Users can disconnect and can
  delete imported activities.
- **Manual GPX import remains** as the no-integration baseline (FR-DATA), so the app is
  useful even without connecting a service.
- Phased: not in the MVP; see the [roadmap](../architecture/06-roadmap.md).
