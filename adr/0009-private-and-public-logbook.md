# ADR-0009 — Two-tier logbook: private diary and public guestbook

**Status:** Accepted

## Context

A "logbook" (*loggbok*) naturally has two very different modes:

- A **private diary (dagbok)** — personal notes to yourself about a trip: how it felt,
  who you were with, conditions, things to remember. Nobody else should see these.
- A **public guestbook (gjestebok)** — the Norwegian mountain tradition of signing the
  book at a summit or in a cabin with a short greeting. This is a shared, public message
  attached to a place, visible to others.

Rekfar should support both. The distinction matters for the data model and,
critically, for privacy (Principle P9): the two must never be confused.

## Decision

1. Every trip supports **private log entries (dagboknotat)** — diary-form notes visible
   **only to the author**. This is the default and requires no sharing decision.
2. **Reference places** — summits (fjelltopp), cabins (hytte), and routes (turrute) —
   can carry a **public guestbook (gjestebok)**: short, public **greetings
   (gjestebokhilsen)** that a user can post when they log a visit, shown on that place's
   page (a "greeting at the top / for the cabin").
3. **Privacy is explicit and directional:** private is the default; posting a public
   greeting is a deliberate, separate action. A private diary note is never
   auto-published; a public greeting is never private.
4. **Moderation:** public guestbook content is user-generated and therefore needs light
   moderation (report/remove) and basic spam/abuse handling, owned by the maintainer
   (extends the administrator role in the [business architecture](../architecture/02-business-architecture.md)).

## Consequences

- **Data model** gains a **visibility** dimension on log content and a **guestbook**
  associated with reference places (see [data architecture](../architecture/03-data-architecture.md)).
- **Privacy by default (P9)** is preserved: the sensitive content (diary, locations)
  stays private; only explicit greetings are public.
- **New responsibility:** moderation of public content — kept lightweight, matching the
  hobby scale (P1/P7).
- The public guestbook is a mild, place-centred form of "social" that does **not** turn
  the app into a social network; broader social features (friends, tagging) are a
  separate, later decision (see the [roadmap](../architecture/06-roadmap.md) and
  FR-SOCIAL).
