# ADR-0020 — The private diary note is the trip's notes field — no diary-note entity

**Status:** Accepted (2026-11-18) — refines decision 1 of
[ADR-0009](0009-private-and-public-logbook.md) and the domain model in
[data architecture §3](../architecture/03-data-architecture.md#3-key-entities); supersedes
nothing

## Context

[ADR-0009](0009-private-and-public-logbook.md) gave the logbook two tiers: a private diary
on a trip and a public guestbook on a place. The data model then carried the private tier
twice — a `notes` field on `TRIP` (FR-LOG-4, "free-text notes") and a separate `DIARY_NOTE`
entity with its own `/trips/{id}/notes` resource (FR-BOOK-1, "private diary notes"). UC-2's
flow asks for one thing: "add a private diary note" while logging the trip.

Two places for the same words means the user has to guess which one to write in, and the
client, the export and the deletion path each have to handle both. Nothing in the use cases
needs several dated notes per trip.

## Decision

1. **A trip has one private notes field, and that field is the diary note
   (dagboknotat).** FR-LOG-4 and FR-BOOK-1 describe the same field.
2. **There is no `DIARY_NOTE` entity** and no `/trips/{id}/notes` resource. The note is read
   and written with the trip.
3. **The note is private unconditionally.** It is visible only to the trip's owner and is
   outside the trip's `privacy` setting: when per-trip sharing arrives (FR-SHARE-1), a
   shared trip is shared *without* its notes.

## Consequences

- **ADR-0009 stands.** The two tiers remain and still cannot cross: the private one is a
  field on a trip, the public one a `GUESTBOOK_ENTRY` on a place. FR-BOOK-2 and
  NFR-CONTENT-1 hold by construction — there is no operation that publishes a trip's notes.
- **One fewer table, resource and form**
  ([P7](../architecture/principles.md#p7-simple-before-clever)).
- **Notes are available at every trip status** ([ADR-0019](0019-trip-lifecycle-status.md)):
  a note written on a wish stays on the trip when it is planned and completed.
- **Given up:** several separate, individually dated notes on one trip. If that is ever
  wanted it is an additive entity later; the single field would remain as the trip's note.
- **Requirement text is unchanged.** FR-LOG-4 and FR-BOOK-1..2 keep their IDs and wording
  and are closed together by the same work.
