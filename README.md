# Rekfar — Documentation

All documentation for Rekfar is written in **English** and follows an adapted
**TOGAF** (The Open Group Architecture Framework) structure. TOGAF's full
Architecture Development Method (ADM) is designed for large enterprises, but here it
is deliberately **right-sized for a hobby project** — we keep the artefacts that
add clarity and skip the heavy governance ceremony.

## How these documents map to TOGAF ADM

| TOGAF ADM phase | Purpose | Document |
| --- | --- | --- |
| Preliminary + Principles | Ground rules the architecture must respect | [architecture/principles.md](architecture/principles.md) |
| A — Architecture Vision | The problem, stakeholders, scope, and target picture | [architecture/01-architecture-vision.md](architecture/01-architecture-vision.md) |
| B — Business Architecture | Actors, capabilities, and business processes | [architecture/02-business-architecture.md](architecture/02-business-architecture.md) |
| C — Data Architecture | The domain model and data sources | [architecture/03-data-architecture.md](architecture/03-data-architecture.md) |
| C — Application Architecture | Logical application components and their interactions | [architecture/04-application-architecture.md](architecture/04-application-architecture.md) |
| D — Technology Architecture | Platform, hosting, and technology building blocks | [architecture/05-technology-architecture.md](architecture/05-technology-architecture.md) |
| D — Technology Architecture (supporting) | Three concrete candidate stacks compared, as input to ADR-0005 | [architecture/tech-stack-options.md](architecture/tech-stack-options.md) |
| E/F — Opportunities, Solutions & Migration | Roadmap and phased delivery | [architecture/06-roadmap.md](architecture/06-roadmap.md) |
| Requirements Management | Functional and non-functional requirements (central to all phases) | [requirements/](requirements/) |
| — (supporting) | Concrete user-facing behaviour | [use-cases/use-cases.md](use-cases/use-cases.md) |
| G/H — Governance & Change Management | How decisions are recorded and evolved | [adr/](adr/) |

## Reading order

If you are new to the project, read in this order:

1. [Architecture Vision](architecture/01-architecture-vision.md) — what and why.
2. [Glossary](glossary.md) — the shared vocabulary (English / Norwegian).
3. [Use Cases](use-cases/use-cases.md) — what users do.
4. [Business Architecture](architecture/02-business-architecture.md) — capabilities and actors.
5. [Data](architecture/03-data-architecture.md) → [Application](architecture/04-application-architecture.md) → [Technology](architecture/05-technology-architecture.md) architecture.
6. [Requirements](requirements/) and the [Roadmap](architecture/06-roadmap.md).
7. [ADRs](adr/) for the reasoning behind specific decisions.

## Documentation conventions

- **Language:** Documentation is in English. UI copy is in Norwegian (see
  [ADR-0003](adr/0003-language-strategy.md)).
- **Domain terms:** Written in English with the Norwegian term in parentheses on
  first use in a document, e.g. *summit trip (topptur)*. The
  [glossary](glossary.md) is the canonical list.
- **Decisions:** Significant or hard-to-reverse choices are captured as
  [Architecture Decision Records](adr/). Decisions we have deliberately *not* made
  yet (e.g. tech stack, map provider) are recorded as **deferred** ADRs so the
  open questions are explicit.
- **Diagrams:** Where diagrams help, they are written as
  [Mermaid](https://mermaid.js.org/) fenced code blocks so they render on GitHub
  and stay in version control as text.
