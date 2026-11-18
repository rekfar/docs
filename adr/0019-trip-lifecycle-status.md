# ADR-0019 — A trip has one lifecycle: wishlist, planned, completed — no wishlist entity

**Status:** Accepted (2026-11-18) — refines the domain model in
[data architecture §2–3](../architecture/03-data-architecture.md#2-conceptual-domain-model)
and the component list in
[application architecture §2](../architecture/04-application-architecture.md#2-component-responsibilities);
supersedes nothing

## Context

Three use cases describe the same thing at three points in its life:
[UC-4](../use-cases/use-cases.md) collects peaks the user wants to do, UC-3 plans a trip to
one, and UC-2 logs the trip once it is done. The requirements already treat the steps as
conversions — FR-PLAN-5 turns a wishlist item into a planned trip, FR-PLAN-3 turns a planned
trip into a completed one.

The data model honoured that for two of the three. `TRIP.status` was `planned | completed`,
"unifying planning and logging", while the wishlist was a separate `WISHLIST_ITEM` entity,
with its own **Wishlist** module in the application architecture and its own `/wishlist`
resource beside `/plans` and `/trips`.

That exception costs more than it gives:

- FR-PLAN-5 becomes "create a trip, copy the fields, delete the item" — two writes that must
  agree — where FR-PLAN-3 is a change to one column.
- "What is this peak to me?" on the map (bagged, planned, wished for) needs two sources
  merged in the client.
- Notes written on a wishlist item have to be carried over by hand.
- A second table, module and resource for one maintainer to own
  ([P7](../architecture/principles.md#p7-simple-before-clever)).

Nothing is built yet for UC-2..4, so the change is free now and a data migration later.

## Decision

1. **`Trip.status` takes three values: `wishlist`, `planned`, `completed`.** A trip may be
   created in any of them and moves between them by changing the status.
2. **There is no wishlist entity.** `WISHLIST_ITEM` is removed from the model. "The
   wishlist" is the user's trips with status `wishlist`.
3. **There is no Wishlist module and no `/wishlist` or `/plans` resource.** One Trip module
   and one `/trips` resource, filtered by status.
4. **The status is not the only difference, and the rules that follow from it are part of
   this decision:**
   - *Fields follow the status.* A `completed` trip requires a date; a `wishlist` trip has
     none — a wish with a date is a plan. Ascent, difficulty and conditions describe an
     outcome.
   - *Only `completed` counts.* A peak is bagged (FR-LOG-8) when a completed trip references
     it. That is derived, never stored, and statistics read completed trips only.
   - *A peak's state is derived from its trips*, by precedence: completed, else planned,
     else wishlist. Each trip keeps its own status, so a bagged peak can be planned again.
   - *The wishlist is a set.* At most one `wishlist` trip per user and peak; adding a peak
     that is already there changes nothing.

## Consequences

- **Simpler everywhere:** one table family, one module, one resource, one form in the
  client; FR-PLAN-3 and FR-PLAN-5 are the same operation.
- **The wishlist stays a product concept.** Capability C3, UC-4, FR-PLAN-4..5 and the
  glossary term *ønskeliste* are unchanged in meaning; no requirement ID or wording changes.
- **Every reader of trips must state the status it means.** A query that forgets the filter
  counts wishes as ascents. The bagged derivation and the statistics are where tests belong.
- **Validation is per status**, in the API and backed by constraints in the schema, rather
  than a single "required fields" rule.
- **Sharing a wishlist later** (FR-SOCIAL-2) is sharing a filtered set of trips, not a list
  object — there is no list to attach an audience to, so that design starts from the trip's
  privacy.
- **The wishlist moves into Phase 1** of the [roadmap](../architecture/06-roadmap.md): once
  logging and planning exist it is two more values of one field, not a feature of its own.
- **A status can move backwards.** Setting a completed trip back to planned is an ordinary
  edit — a correction — and the per-status rules are checked on the result.
- **Decided separately:** `Trip.notes` is the private diary note
  ([ADR-0020](0020-diary-note-is-trip-notes.md)).
