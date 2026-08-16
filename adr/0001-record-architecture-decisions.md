# ADR-0001 — Record architecture decisions

**Status:** Accepted

## Context

Rekfar is a long-running hobby project with a single maintainer and long gaps
possible between work sessions. Decisions made now need to be understandable later,
by a future maintainer or a future version of the same person. Some important
decisions are also being **deferred** on purpose, and those open questions must not
be lost.

## Decision

We will record significant architectural decisions as **Architecture Decision
Records (ADRs)** stored in `docs/adr/`, using a lightweight status/context/decision/
consequences format. Deferred decisions are recorded with status `Deferred` so open
questions stay visible (Principle P8).

## Consequences

- There is a durable, versioned decision log alongside the code.
- The cost is small: a short markdown file per decision.
- Superseding, not editing, is how decisions change, preserving history.
- The [ADR index](README.md) must be kept up to date.
