# Glossary — Domain Terms (English / Norwegian)

The canonical vocabulary for Rekfar. Documentation uses the **English** term
with the **Norwegian** term in parentheses on first use. UI copy uses the
Norwegian term. Where a term is a proper name of a Norwegian service or dataset,
the Norwegian name is authoritative.

## Core domain

| English | Norwegian | Definition |
| --- | --- | --- |
| Trip / outing | **tur** | A single outdoor journey on foot. The umbrella term for anything logged. |
| Hike | **fottur** | A trip primarily walking on trails or terrain, without technical climbing. |
| Summit trip / climb | **topptur** | A trip whose goal is reaching a specific summit. Central to the app's identity. |
| Mountain top / peak / summit | **fjelltopp** (pl. *fjelltopper*) | A named high point that can be a trip's destination. |
| Summit / peak (generic high point) | **topp** | Any peak; `fjelltopp` when specifically a mountain. |
| Trail / route | **tursti / turrute** | A marked or established path. `turrute` is the more formal "route". |
| Ascent (elevation gained) | **stigning** | Total metres climbed on a trip. |
| Elevation / altitude | **høyde (moh. = meter over havet)** | Height above sea level. `moh.` = "metres above sea level". |
| Trip log / logbook | **turloggbok** | The personal record of trips — the domain concept Rekfar is built around. |
| Log entry | **turføring / loggføring** | A single recorded trip in the logbook. |
| Trip plan / planned trip | **turplan / planlagt tur** | A future trip the user intends to do. |
| Wishlist / bucket list | **ønskeliste** | Collection of peaks or trips the user wants to do. |
| Peak bagging | **toppjakt / topplogging** | Collecting summits as an activity; ticking off peaks. |
| Track / GPS track | **spor (GPS-spor)** | The recorded line of where the user actually went. |
| Route (planned line) | **rute / trasé** | The intended line of a trip, distinct from the recorded track. |
| Waypoint / point of interest | **veipunkt / interessepunkt** | A marked point (cabin, viewpoint, parking, junction). |
| Cabin / hut | **hytte** (pl. *hytter*) | A mountain cabin, often DNT-operated; a common trip node. |
| Trailhead / start point | **utgangspunkt / startpunkt** | Where a trip begins (often a parking area). |
| Difficulty grade | **gradering / vanskelighetsgrad** | How hard a trip is (see grading below). |
| Season / conditions | **sesong / føre** | Time of year and surface conditions (snow, ice, bare ground). |

## Map & geodata

| English | Norwegian | Definition |
| --- | --- | --- |
| Map | **kart** | The map view. |
| Topographic map | **topografisk kart** | Terrain map with contour lines; the default base map. |
| Base map / background layer | **bakgrunnskart** | The underlying map tiles. |
| Map layer | **kartlag** | A toggleable overlay (peaks, trails, cabins, user trips). |
| Contour line | **høydekurve** | Line of constant elevation on a topographic map. |
| Marker / pin | **markør / nål** | A point drawn on the map. |
| Bounding box / extent | **utstrekning** | The visible geographic area. |

## Grading (difficulty)

Rekfar will present difficulty using the widely recognised Norwegian
colour-coded scale for marked trails, with room for a climbing/alpine grade later.

| English | Norwegian | Colour |
| --- | --- | --- |
| Easy | **enkel** | Green (grønn) |
| Moderate | **middels** | Blue (blå) |
| Demanding | **krevende** | Red (rød) |
| Expert / very demanding | **ekspert / svært krevende** | Black (svart) |

> Note: For technical summits an alpine grade (e.g. UIAA / Norwegian climbing
> grades) may be added later; see the [data architecture](architecture/03-data-architecture.md).

## External services & data sources (proper names)

| Name | What it is |
| --- | --- |
| **Kartverket** | The Norwegian Mapping Authority. Publishes free topographic map tiles, place names, and elevation data. |
| **Norgeskart / Topografisk norgeskart** | Kartverket's topographic base map (available as WMS/WMTS tiles). |
| **Geonorge** | The national portal for Norwegian geospatial data and metadata. |
| **Turrutebasen (Tur- og friluftsruter)** | Kartverket's national dataset of hiking, skiing, and cycling routes. Object types include *Fotrute*, *Skiløype*, *Sykkelrute*, *AnnenRute*, and *Ruteinfopunkt*. Rekfar's route source. |
| **Ruteinfopunkt** | Turrutebasen's route-infrastructure points: trailheads, parking, toilets, viewpoints. |
| **N50 Kartdata** | Kartverket's topographic dataset for the 1:25 000–1:100 000 range. Contains the *Turisthytte* theme — Rekfar's cabin source. |
| **Turisthytte** | A tourist cabin in N50 (building type 956), with *navn*, *eier* (DNT / Statskog / Fjellstyre / annen), and *betjeningsgrad*. |
| **Betjeningsgrad** | A cabin's service level: **betjent** (staffed, meals served), **selvbetjent** (self-service, provisions for sale), **ubetjent** (unstaffed, no provisions). |
| **SSR (Sentralt stedsnavnregister)** | Kartverket's central register of Norwegian place names — Rekfar's source of peak names and coordinates. Each place has a stable *stedsnummer*. |
| **Stedsnavn API** | Kartverket's open REST/JSON service over SSR (`ws.geonorge.no/stedsnavn/v1/`); no login or API key. |
| **Høydedata / DTM** | Kartverket's elevation / digital terrain model data. Peak elevations are sampled from it, since SSR carries no height. |
| **DNT (Den Norske Turistforening)** | The Norwegian Trekking Association. Operates many of Norway's cabins and marked trails, and reports changes into Kartverket's datasets — so DNT's cabins reach Rekfar via N50, not directly. |
| **UT.no** | DNT's public trip portal. Rekfar may link out to it for a human-written description, but sources no data from it — the link is optional and often absent. |
| **Strava** | Popular activity-tracking service; the primary GPS integration for automatic check-ins. |
| **Garmin (Garmin Connect)** | Activity-tracking platform; an alternative / later GPS integration. |

## Application concepts

| English | Norwegian | Definition |
| --- | --- | --- |
| User / account | **bruker / konto** | A person using the app and their profile. |
| Dashboard / home | **oversikt / hjem** | The landing view summarising activity. |
| Statistics | **statistikk** | Aggregated numbers (peaks bagged, total ascent, trips per year). |
| Photo | **bilde** | An image attached to a trip. |
| Note / description | **notat / beskrivelse** | Free-text notes on a trip. |
| Import (GPX) | **import (GPX)** | Loading a GPS track file into the app. |
| Export | **eksport** | Saving user data out of the app. |
| Private diary note | **dagboknotat** | A personal, private note on a trip, visible only to its author. |
| Public guestbook | **gjestebok** | A public book of greetings attached to a summit, cabin, or route (the Norwegian mountain guestbook tradition). |
| Greeting (guestbook entry) | **gjestebokhilsen / hilsen** | A short public message a user posts to a place's guestbook when they visit. |
| Activity import | **aktivitetsimport** | Bringing in a recorded activity from a connected GPS service (e.g. Strava). |
| Auto check-in | **automatisk avkryssing** | Automatically marking a peak/cabin/route as visited from an imported activity (user-confirmable). |
| Connected service | **tilkoblet tjeneste** | An external account (Strava, Garmin) the user has linked via OAuth. |
| Friend / connection | **venn** | Another user a person is connected to (later-stage feature). |
| Tag a user | **merke / tagge** | Naming another user on a logged trip (later-stage feature). |
