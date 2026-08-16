# Use Cases & Personas

Concrete descriptions of who uses Rekfar and what they do. These make the
[business architecture](../architecture/02-business-architecture.md) and
[requirements](../requirements/functional-requirements.md) tangible. Domain terms
follow the [glossary](../glossary.md).

## Personas

### Persona 1 — Ingrid, the weekend peak-bagger (primary)

Ingrid, 34, lives in Bergen and does a **summit trip (topptur)** most weekends in
season. She has a folder of photos and a vague memory of "have I done that one?".
She wants a **map of Norway** where she can see every peak she has bagged, add the
ones she still wants, and log a new trip in a couple of minutes with a photo and how
much she climbed. She mostly uses her phone.
*Cares about:* speed of logging, the map, "done vs want-to-do", stats over the years.

### Persona 2 — Ola, the methodical planner

Ola, 52, plans trips carefully in advance. He keeps a **wishlist (ønskeliste)** of
peaks and researches routes before going. He wants to plan a trip, mark it on the
map, and later turn it into a completed log. He often imports a **GPX** track after
the trip.
*Cares about:* planning, routes, GPX import, elevation profiles, accuracy.

### Persona 3 — Kari, the occasional hiker

Kari, 28, hikes a few times a year and is not a "peak collector". She wants a simple,
pretty record of her outings with photos and notes, without a complicated tool.
*Cares about:* simplicity, photos, Norwegian UI, nothing overwhelming.

### Persona 4 — You, the maintainer

Runs the service, refreshes reference data, and keeps costs near zero.
*Cares about:* low operational burden, portability, good documentation.

## Use cases

Each use case lists the primary actor, the goal, the main flow, and the requirements
it exercises.

### UC-1 — Register and set up an account

- **Actor:** Visitor → Hiker. **Goal:** Get an account, private by default.
- **Flow:** Register (email/OAuth) → confirm → set display name and locale (nb-NO) →
  default privacy = private → land on the map/overview.
- **Requirements:** FR-ACC-1..4, FR-I18N-1, NFR-PRIV-1.

### UC-2 — Log a completed summit trip (turføring)

- **Actor:** Ingrid. **Goal:** Record a topptur quickly.
- **Main flow:** "New trip" → type = topptur → date → search & select **peak
  (fjelltopp)** → enter ascent, difficulty, conditions → add a **private diary note
  (dagboknotat)** → save. The peak is marked **bagged**; the trip appears on the map
  and in stats. (Photo attachment comes in a later phase.)
- **Alt:** The trip was previously planned → pick the planned trip and complete it.
- **Requirements:** FR-LOG-1..8, FR-MAP-3, FR-STAT-1.

### UC-3 — Plan a future trip (turplanlegging)

- **Actor:** Ola. **Goal:** Plan a trip and see it on the map.
- **Flow:** Find a peak on the map or in the catalogue → create **planned trip** with
  target date → optionally attach a chosen **route (rute)** → it shows in the
  "planned" style. Later, convert it to a completed trip.
- **Requirements:** FR-PLAN-1..3, FR-PLAN-6, FR-MAP-2.

### UC-4 — Build a wishlist / bucket list (ønskeliste)

- **Actor:** Ola / Ingrid. **Goal:** Collect peaks to do.
- **Flow:** Browse/search peaks → add to wishlist → later convert an item into a
  planned trip.
- **Requirements:** FR-PLAN-4..5, FR-PEAK-1..3.

### UC-5 — Explore the map (kartutforsking)

- **Actor:** Any hiker. **Goal:** See peaks, trips, and trails on a topographic map.
- **Flow:** Open map → pan/zoom → toggle layers (peaks, my trips, trails) → the app
  loads features for the current extent → tap a marker to open details. Attribution
  is visible.
- **Requirements:** FR-MAP-1..8.

### UC-6 — Browse a peak and see personal history (toppdetalj)

- **Actor:** Ingrid. **Goal:** See a peak's info and whether she has done it.
- **Flow:** Open a peak → see name, elevation (moh.), location, and "bagged / not yet",
  plus her own past trips to it.
- **Requirements:** FR-PEAK-1..3, FR-LOG-8.

### UC-7 — Import a GPX track (spor-import)

- **Actor:** Ola. **Goal:** Attach the actual track to a trip.
- **Flow:** Open a trip → import GPX → the track is attached; length and ascent are
  computed and shown, with an elevation profile.
- **Requirements:** FR-DATA-1..2, FR-LOG-3.

### UC-8 — See statistics (statistikk)

- **Actor:** Ingrid. **Goal:** Look back on activity.
- **Flow:** Open stats → see peaks bagged, total ascent, trips per year, and (later)
  breakdown by region and achievements.
- **Requirements:** FR-STAT-1..4.

### UC-9 — Export data / delete account (mine data)

- **Actor:** Any hiker. **Goal:** Control over their data.
- **Flow:** Settings → export all data (JSON) / export track (GPX) / delete account.
- **Requirements:** FR-DATA-3..4, FR-ACC-5, NFR-PRIV-3.

### UC-10 — Refresh reference data (maintainer)

- **Actor:** Maintainer/system. **Goal:** Keep peaks/trails current.
- **Flow:** Scheduled job downloads and normalises peaks/trails/cabins/elevation from the
  **Kartverket** datasets (SSR, Høydedata, N50, Turrutebasen); applies the peak rule;
  records source dataset + fetch date; makes them available to the app.
- **Requirements:** FR-REF-1..6, FR-REF-9..11. See
  [ADR-0012](../adr/0012-kartverket-primary-source.md).

### UC-11 — Share a trip (later)

- **Actor:** Hiker. **Goal:** Show a trip to a friend.
- **Flow:** Open a trip → enable share link → send it. Everything else stays private.
- **Requirements:** FR-SHARE-1..2 (Phase 3).

### UC-12 — Look up a place's details and external reference

- **Actor:** Any hiker. **Goal:** Learn about a summit, route, or cabin.
- **Flow:** Open a **peak (fjelltopp)**, **route (turrute)**, or **cabin (hytte)** in
  Rekfar → see the authoritative facts Kartverket provides (official name, elevation,
  location; for a cabin also its **service level (betjeningsgrad)** and owner). Where an
  external description link is known, follow it for a fuller human-written write-up —
  that link is optional, so the page must be complete and useful without it. Rekfar
  holds the reference data plus the user's own diary and guestbook content.
- **Requirements:** FR-REF-5..9. See [ADR-0012](../adr/0012-kartverket-primary-source.md).

### UC-13 — Auto-check a summit from a Strava activity (automatisk avkryssing)

- **Actor:** Ingrid (Strava connected). **Goal:** Log a trip without manual entry.
- **Flow:** Ingrid records a **topptur** on Strava and uploads it → Rekfar imports
  the activity, attaches the **track (spor)**, and detects the summit near the track's
  high point → it **proposes a check-in** → Ingrid **confirms** → a trip is created and
  the peak is marked bagged.
- **Alt:** Ingrid dismisses a false-positive proposal; nothing is logged.
- **Requirements:** FR-ACT-1..5, FR-LOG-8, FR-DATA-2. See [ADR-0008](../adr/0008-activity-tracking-integrations.md).

### UC-14 — Private diary note and public greeting (dagbok + gjestebok)

- **Actor:** Kari. **Goal:** Keep private thoughts and leave a public greeting.
- **Flow:** On a logged trip → write a **private diary note (dagboknotat)** only she can
  see. Optionally → post a **public greeting (gjestebokhilsen)** to the summit's or
  cabin's **guestbook (gjestebok)**, which appears on that place's page for others.
- **Requirements:** FR-BOOK-1..6. See [ADR-0009](../adr/0009-private-and-public-logbook.md).

### UC-15 — Connect with friends, tag, and share a wishlist (later stage)

- **Actor:** Hiker. **Goal:** Do trips socially.
- **Flow:** Add another user as a **friend (venn)** → **tag (merke/tagge)** them on a
  completed trip → **share a wishlist (ønskeliste)** with them. The user controls the
  audience and can approve/decline connections and tags.
- **Requirements:** FR-SOCIAL-1..4 (later stage).

## Traceability summary

| Use case | Capabilities | Key requirements |
| --- | --- | --- |
| UC-1 | C9 | FR-ACC |
| UC-2 | C1, C5 | FR-LOG, FR-STAT |
| UC-3 | C2 | FR-PLAN |
| UC-4 | C3, C5 | FR-PLAN, FR-PEAK |
| UC-5 | C4, C6 | FR-MAP |
| UC-6 | C5 | FR-PEAK |
| UC-7 | C1, C10 | FR-DATA |
| UC-8 | C7, C8 | FR-STAT |
| UC-9 | C9, C10 | FR-DATA, FR-ACC |
| UC-10 | C12 | FR-REF |
| UC-11 | C11 | FR-SHARE |
| UC-12 | C5, C6 | FR-REF |
| UC-13 | C1, C12 | FR-ACT |
| UC-14 | C1, C11 | FR-BOOK |
| UC-15 | C11 | FR-SOCIAL |

---

# Ideas & Opportunities (idea backlog)

Beyond the core, here are refinements and ideas to strengthen the concept. They are
**not commitments** — they are a backlog to pull from, tagged by how well they fit the
hobby-project constraints. Treat anything that adds cost or ops burden with the
"simple before clever" (P7) and "cost-minimal" (P1) principles in mind.

## Sharpening the core identity

- **"Livsliste for norske topper" (a life list for Norwegian summits).** Lean into the
  peak-bagging identity: the single most motivating view is *"peaks done vs peaks
  to go"* on one map. Make that the hero of the product.
- **Done / Planned / Wishlist as three visual states** of the same peak on the map
  (e.g. filled, outlined, dimmed). One glance tells the whole story.
- **"On this day" / year-in-review.** A gentle look-back ("your trips in 2026: 18
  peaks, 24 000 m ascent") — high delight, low cost, uses data you already have.

## Smart use of Norwegian open data (aligns with P3)

- **Curated peak lists people already chase:** e.g. the classic lists like the highest
  peaks, county high points (*fylkestopper*), or "peaks over 2000 m". Turn these into
  built-in challenges/collections users can tick off. This is a strong, cheap
  differentiator that only makes sense for a Norway-scoped app.
- **Auto-suggest the peak from a GPX track:** when a track's high point is near a known
  peak, offer to tag it — removes friction from logging.
- **Elevation profile & auto-ascent** from Kartverket Høydedata so users don't have to
  enter ascent by hand.
- **Trailhead & parking (utgangspunkt) hints** from Turrutebasen's `Ruteinfopunkt`, and
  **tourist cabins (turisthytter)** — DNT's among them — as optional waypoints from N50
  Kartdata, complete with service level and owner.
- **Conditions/season awareness (føre):** let a trip note snow/bare-ground; later,
  surface simple seasonal hints (many Norwegian summits are winter vs summer routes).

## Logging delight & low friction

- **Fast "log this now" flow** optimised for one-handed phone use after a summit.
- **Photo-first logging:** drop a photo, and pre-fill date/location from its metadata
  (with the user's consent, respecting privacy — P9).
- **Templates / repeat trips:** "log another ascent of a peak I've done before" in one tap.
- **Personal notes that matter to hikers:** companions, gear, weather, "would do again".

## Insight & motivation (gamification, kept tasteful)

- **Achievements (bragder)** that are meaningful, not spammy: "10 peaks over 1500 m",
  "a summit in every season", "first peak in a new *fylke*".
- **Maps of coverage:** shade the *kommuner/fjellområder* where you've been — a
  satisfying "explorer" view.
- **Streaks and totals** (annual ascent equal to Everest, etc.) — playful, optional.

## Trust, privacy, and portability (aligns with P4/P9)

- **Private by default, share by choice.** Position privacy as a feature versus
  global fitness apps.
- **Real export, real delete.** Make "your data is yours" a visible promise.

## Longer-term / stretch (weigh carefully against P1/P7)

- **Live GPS recording (sporing)** — natural in the Phase 4 native app, not the web MVP.
- **Offline map areas** for out-of-coverage trips (native app).
- **Lightweight social later:** follow a friend, a shared "we did this together" trip —
  only if it never compromises the private-first core.
- **Weather integration** (e.g. MET Norway / Yr) for planning — useful but adds an
  external dependency; keep optional.
- **Ski-touring mode:** the same model extends to winter *topptur på ski*; the
  activity field already anticipates this.

## Explicit non-goals (to protect the concept)

- Not a fitness tracker or training-load tool.
- Not a global app — Norway focus is a feature, not a limitation (P2).
- Not a social network — sharing stays minimal and optional.
- Not a business — no ads, no subscriptions, ever (project premise).
