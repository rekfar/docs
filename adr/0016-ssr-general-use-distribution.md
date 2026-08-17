# ADR-0016 — The peak import reads the general-use Stedsnavn distribution

**Status:** Accepted (2026-08-17) — refines §3 and closes §5.5 of
[ADR-0012](0012-kartverket-primary-source.md); does not supersede it

## Context

[ADR-0012](0012-kartverket-primary-source.md) made Kartverket the primary source for peaks
and named **"Stedsnavn (komplett SSR)"** as the place-name dataset, with the standing
caveat that the specifics were *"to re-verify at build time"*. Writing the peak import is
that build time. Verifying it produced three findings that change what §3 says.

**The metadata UUID recorded in §3 does not resolve.** `08e96235-0166-4161-97bb-cb64c09f50eb`
returns *Not Found* from the Geonorge catalogue API. The live records are
`30caed2f-454e-44be-b5cc-26bb5c0110ca` (**Stedsnavn**) and
`e1c50348-962d-4047-8325-bdc265c853ed` (**Stedsnavn (komplett SSR)**). The same dead UUID
had been seeded into `ref.SourceDataset` as the SSR row's attribution link.

**Geonorge publishes two distributions of SSR, not one.** They differ by product
specification:

| | Stedsnavn | Stedsnavn (komplett SSR) |
| --- | --- | --- |
| Product specification | `StedsnavnForVanligBruk` | `stedsnavn` |
| Whole-country GML, EPSG:4258 | 138 MB zipped, 2.6 GB unpacked | 325 MB zipped |
| Scope | The names Kartverket publishes for map and general use | The complete register |

The complete register was **not parsed** for this decision; it is described here only as its
catalogue entry describes itself, *"komplett versjon av Stedsnavn fra sentralt
stedsnavnsregister (SSR)"*. Every figure below comes from the general-use extract, which was
parsed in full.

**The REST API cannot enumerate the register.** `ws.geonorge.no/stedsnavn/v1/navn` rejects a
wildcard-only search outright (*"Søkeparameteren kan ikke kun være et wildcard"*), so it is a
lookup service, not a bulk source. ADR-0012's choice of periodic bulk download was already
the decision; this removes the alternative entirely rather than merely preferring against it.

### What the general-use extract actually contains

Parsed on 2026-08-16, whole country:

- **1,059,349 places.** The `navneobjektgruppe` value `høyder` holds **175,109** of them:
  `ås` 51,041, `haug` 50,007, `fjell` 25,382, `berg` 16,032, `høyde` 10,237, `hei` 8,904,
  `rygg` 7,529, `topp` 4,566, `fjellkant` 1,303, and a long tail.
- **A place is not one coordinate.** Of the 29,937 `fjell` and `topp` features, 15,543 carry
  a single point and **14,357 carry two to sixteen**. Thirty-seven carry none.
- **A place is not one name.** Up to five per place, across Norwegian (27,000), North Sami
  (3,544), South Sami, Lule Sami, Kven, and a handful of others — with `navnestatus` values
  `hovednavn` (29,548), `sidenavn` (447), `undernavn` (198) and `historisk` (29). The
  general-use extract is therefore *not* free of name variants; choosing a display name is a
  rule the parser needs either way.
- **Coordinates are published in EPSG:4258 directly**, latitude first per
  `urn:ogc:def:crs:EPSG::4258`, at exactly six decimal places.

## Decision

1. **The peak import reads Stedsnavn — the `StedsnavnForVanligBruk` distribution** — as the
   whole-country GML in EPSG:4258, by direct download from
   `nedlasting.geonorge.no`. What a peak catalogue needs is one authoritative current name
   per place plus its stable identifier, which is what this product is published to provide;
   the complete register's additional name cases are a search-recall asset, not a catalogue
   one.
2. **`ref.SourceDataset.Code` stays `'ssr'`.** The stable identifier (`stedsnummer`), the
   licence (CC BY 4.0) and the attribution (*© Kartverket*) are identical across both
   distributions, so nothing downstream distinguishes them. Only the row's name, URL and
   `ProductSpecVersion` change, to describe the product actually read.
3. **`ProductSpecVersion` is `StedsnavnForVanligBruk 20231001`**, read from the GML's own
   namespace at every run rather than configured. An upstream specification change then
   announces itself in the file being parsed, which is the mitigation the
   [roadmap](../architecture/06-roadmap.md) asks for.
4. **EPSG:4258 is stored as SRID 4326 without transformation**, closing ADR-0012 §5.5. ETRS89
   is fixed to the Eurasian plate and has drifted from WGS84 by on the order of a metre since
   1989. That is smaller than the thing being located: SSR publishes a *representation point*,
   and half of all peaks carry several of them. Reprojecting would imply a precision the
   source does not have. The canonical-storage rule (NFR-INTEROP-2) is unaffected — one
   coordinate system is stored, and it is 4326.
5. **Elevation is sampled from `ws.geonorge.no/hoydedata/v1/punkt`**, which accepts
   `koordsys=4258` directly and up to **50 points per request**, returns the model that
   answered (`datakilde`), and returns a null height outside coverage. Every peak's points
   are sampled and the highest is taken as both its elevation and its position.
6. **The complete register stays a live option.** Because `stedsnummer` is the key in both,
   switching is a re-import rather than a migration — the same property that makes the whole
   reference store rebuildable.

**This ADR does not decide the peak-qualification rule.** ADR-0012 §5.1 and FR-REF-11 remain
open; what changes is that the rule now has measured inputs to be chosen against, and can be
re-applied without re-downloading anything.

## Consequences

### Positive

- ADR-0012 §5.5 (coordinate handling) closes with no reprojection code, no ProjNet dependency
  in the ingestion path, and no axis-order transform beyond reading the pair in the declared
  order.
- Less than half the download, and no filtering pass to strip name cases the catalogue would
  discard anyway.
- The figures the peak rule will be calibrated against come from the product that will
  actually be read, rather than from a near neighbour.
- A dead attribution link is corrected before it reaches the UI, where CC BY 4.0 requires it
  to work (NFR-LEGAL-2).

### Negative / accepted trade-offs

- **Historical and rejected spellings are not available for search.** If "find the peak by
  the name my grandfather used" ever becomes a requirement, it needs the complete register or
  the `/navn` lookup endpoint. Accepted: it is not a requirement, and the general-use extract
  still carries `sidenavn`, `undernavn` and some `historisk` names, so recall is reduced
  rather than absent.
- **It reads against the letter of ADR-0012 §3**, which named the complete register. Recorded
  here rather than by editing that ADR, per the [index](README.md)'s rule.
- **A sub-metre datum offset is knowingly ignored.** Defensible for a peak catalogue on a map;
  it would not be for survey work, and nothing in this project should later assume the stored
  coordinates are WGS84 to better than about a metre.

### Follow-ups

- [ ] Confirm the refresh cadence. Files dated 14 and 16 August 2026 suggest daily or near
      daily, but the catalogue record states no update frequency.
- [ ] Fail an ingestion run loudly if the GML namespace no longer matches the pinned
      `ProductSpecVersion`, rather than parsing on and hoping.
- [ ] Decide the display-name selection rule (language priority, `navnestatus`,
      `skrivemåtestatus`) — the extract supplies `språkprioritering` per place, which is the
      obvious basis.
- [ ] Carry forward ADR-0012 §5.3: how deletions are detected between refreshes is still
      open. The extract's per-place `oppdateringsdato` is now staged, which is the only signal
      it offers towards an answer.

## Sources

- Stedsnavn (general use): https://kartkatalog.geonorge.no/metadata/stedsnavn/30caed2f-454e-44be-b5cc-26bb5c0110ca
- Stedsnavn (komplett SSR): https://kartkatalog.geonorge.no/metadata/stedsnavn-komplett-ssr/e1c50348-962d-4047-8325-bdc265c853ed
- Direct download tree: https://nedlasting.geonorge.no/geonorge/Basisdata/Stedsnavn/GML/
- Product specification register: https://register.geonorge.no/register/versjoner/produktspesifikasjoner/kartverket/stedsnavn-for-vanlig-bruk
- Stedsnavn API user guide: https://www.kartverket.no/en/api-and-data/stedsnavndata/brukarrettleiing-stadnamn-api
- Høydedata point API (OpenAPI): https://ws.geonorge.no/hoydedata/v1/openapi.json
- Kartverket terms of use (CC BY 4.0, "© Kartverket"): https://www.kartverket.no/en/api-and-data/terms-of-use
