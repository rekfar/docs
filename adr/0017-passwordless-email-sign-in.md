# ADR-0017 — Auth (T9): passwordless email sign-in, no stored passwords

**Status:** Accepted (2026-09-05) — refines the **T9** row of
[ADR-0010](0010-tech-stack-dotnet-azure-sql.md); the rest of that ADR stands.

## Context

[ADR-0010](0010-tech-stack-dotnet-azure-sql.md) named *ASP.NET Core Identity, email +
password, cookie/JWT, OAuth addable later* as building block **T9 — Auth**. That was a
working assumption carried over from the deferred
[ADR-0005](0005-tech-stack-deferred.md), not a decision taken on its own evidence, and
[technology architecture §T9](../architecture/05-technology-architecture.md#t9--auth)
still lists the block as open.

Phase 1 now needs it closed: **FR-ACC-1** (register), **FR-ACC-2** (log in and out), and
**FR-ACC-3** (profile) are the next MVP slice, and every user-data endpoint depends on
whatever this decides (NFR-SEC-3). The five candidate approaches are compared in
[user-accounts-mvp-plan.md](../architecture/user-accounts-mvp-plan.md); this ADR records
the choice and the reasoning that survived it.

The forces that decided it:

- **[P7](../architecture/principles.md#p7-simple-before-clever) — one maintainer.** A
  password is not one feature. It is hashing policy, strength rules, a reset flow
  (FR-ACC-6), lockout tuning, and a credential-stuffing surface to watch indefinitely.
- **[P9](../architecture/principles.md#p9-privacy-by-default) / NFR-PRIV-2 — minimum
  data.** A password is personal data we would hold, protect, and be liable for, in a
  product whose account is otherwise an email address, a display name, and a locale.
- **The email channel is required anyway.** FR-ACC-1 means confirming the address, so
  transactional email is a Phase 1 dependency whatever we choose. Passwordless reuses
  exactly that channel rather than adding a second credential system beside it.
- **[P1](../architecture/principles.md#p1-hobby-first-cost-minimal) — cost.** Free tiers
  exist for transactional email at hobby volume; no paid identity tier is needed.

## Decision

**Rekfar stores no user passwords.** Sign-in is a **one-time code sent to the user's
email address**, issued and verified by **ASP.NET Core Identity**, which remains the user
store and session issuer as ADR-0010 chose.

1. **One credential, one flow.** The user enters an email address and receives a
   short numeric code; entering it correctly signs them in. If no account exists for that
   address, one is created on first successful verification — so **FR-ACC-1 and FR-ACC-2
   are the same screen**, and verifying the code *is* the email confirmation. No password
   field exists anywhere in the product, and no password hash is ever populated.
2. **A code, not a magic link.** ADR-0010 puts the SPA and the API on different origins,
   so a link would land on the client and have to exchange its token through the API
   regardless. A code additionally survives the common case of requesting sign-in on a
   laptop and reading the mail on a phone.
3. **Code handling.** Single-use, short-lived (~10 minutes), capped at a small number of
   attempts before invalidation, and never held in recoverable form — either derived by a
   TOTP-style token provider or stored only as a hash. The request endpoint is
   rate-limited per address and per client (NFR-SEC-4) and responds identically whether or
   not the address is known.
4. **Session transport: an `HttpOnly` cookie**, not a bearer token the SPA keeps in
   JS-reachable storage. Where the client is not served under the same registrable domain
   as the API, the cookie is `SameSite=None; Secure` behind a strict CORS origin allowlist,
   with an anti-forgery header required on state-changing requests. Log out clears the
   session server-side, not only the cookie (FR-ACC-2).
5. **The account row lives in the `auth` schema of the SQL Database Project**
   ([ADR-0013](0013-schema-owned-by-sql-database-project.md)) — email, email-confirmed,
   display name, locale, default privacy, timestamps — not in a backend-generated
   migration.
6. **Additive later, not a fork.** Social OAuth (Google/GitHub), passkeys, or even a
   password sit on the same Identity user row if we ever want them. Nothing here forecloses
   them, and none is in Phase 1.

**Sub-decision, since closed:** the transactional email provider is **Azure Communication
Services Email**, sending from a verified custom domain in an EEA geography and
authenticated by managed identity so no API key exists —
[ADR-0018](0018-acs-email-transactional-provider.md).

## Consequences

### Positive

- **A database leak exposes no credentials.** There is nothing to crack, reuse, or stuff.
- **Work removed, not added:** no hashing policy, no strength meter, no reset flow, no
  lockout tuning. **FR-ACC-6 (reset a forgotten password) is retired** — with no password
  there is nothing to reset, and requesting a fresh code *is* the recovery flow.
- Registration and login are one screen and one endpoint pair, which is the shortest path
  to UC-1 and the least Norwegian UI copy to write.
- NFR-SEC-2's password-hashing obligation is satisfied vacuously; the remaining obligation
  is that no secret is committed.
- A future native client (P6) uses the same flow — a code typed into the app — with no
  server-side change.

### Negative / accepted trade-offs

- **Login now depends on email delivery at runtime.** A slow or blocked inbox is a slow or
  blocked login, and spam filtering becomes a UX risk that a password would not have.
  Mitigated by domain authentication (SPF/DKIM) and by keeping session lifetimes long
  enough that sign-in is infrequent.
- **The inbox is the single point of compromise.** This is already true of any system with
  a password-reset flow; passwordless makes it explicit rather than worse.
- **No recovery when the email account itself is lost.** With a password there is at least
  a second factor of the user's memory. **Losing the email address means losing the
  account**, and this is accepted deliberately: no recovery requirement is being raised to
  replace FR-ACC-6. For a hobby log whose data is exportable (P4) and whose account is three
  fields, a recovery channel would be more machinery — and more identity-proofing risk —
  than the loss it prevents. Revisit if real users hit it.
- We depend on one more third-party service in the request path for sign-in
  (NFR-INTEG-2 spirit), on a free tier whose limits could change.

### Follow-ups

- [ ] **NFR-SEC-2** reworded — it assumed stored passwords. *(done in this change)*
- [ ] **FR-ACC-1** reworded — it said "email + password, or OAuth". *(done in this change)*
- [x] **FR-ACC-6** (reset a forgotten password) **retired** in `functional-requirements.md`
      — the row stays, marked `Retired`, per the
      [requirements README](../requirements/README.md). **No replacement requirement** is
      raised for email-account recovery; see the trade-off above.
- [x] **Issue [#19](https://github.com/rekfar/docs/issues/19)** (FR-ACC-6) closed by hand as
      not planned — `sync` reports an orphaned issue but does not close it.
- [ ] Run `tools/traceability sync` for real after the FR-ACC-1 edit; the CI workflow only
      dry-runs it, so the issue body stays stale until someone does.
- [x] Email provider chosen and recorded as [ADR-0018](0018-acs-email-transactional-provider.md).

## Alternatives

Compared in full in
[user-accounts-mvp-plan.md §3](../architecture/user-accounts-mvp-plan.md#3-the-approaches).
In short: **email + password** (A) carries the cost this ADR exists to avoid;
**social OAuth only** (C) is cheaper still but requires every Norwegian hiker to hold a
Google or GitHub account and routes them through a third party (P9, NFR-PRIV-5);
a **managed identity provider** (D) adds a dependency and a hosted login page to own for a
product whose entire account is three fields; **passkeys** (E) are the best long-term
answer but need an account-recovery path underneath them anyway — which, done by email,
is this decision.
