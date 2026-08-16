# ADR-0003 — Language strategy

**Status:** Accepted

## Context

The audience is Norwegian hikers, so the interface should be Norwegian. But the code
and documentation should be approachable to a broad developer audience, and English
is the lingua franca of software. Domain terms (topptur, fjelltopp, turrute) are
naturally Norwegian and carry meaning that shouldn't be lost in translation. English
UI may be wanted later.

## Decision

1. The **user interface** is in **Norwegian (nb-NO)** only at first. English UI is a
   possible later addition.
2. All **documentation** is written in **English**.
3. **Domain terms** are written in **English with the Norwegian term in parentheses**
   on first use in a document (e.g. *summit trip (topptur)*), governed by the
   [glossary](../glossary.md).
4. The application is built with an **internationalisation (i18n)** layer from the
   start — only Norwegian ships first, but adding English must not require reworking
   features.

## Consequences

- The UI matches its audience; documentation and code stay widely approachable
  (Principle P5).
- i18n from day one is a small upfront cost that avoids a painful retrofit
  (requirements FR-I18N-1..2).
- The glossary becomes a canonical, maintained artefact both languages depend on.
- Slight overhead: contributors must keep UI strings out of code and in the i18n layer.
