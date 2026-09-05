# ADR-0018 — Sign-in email is sent by Azure Communication Services Email

**Status:** Accepted (2026-09-05) — closes the sub-decision left open by
[ADR-0017](0017-passwordless-email-sign-in.md).

## Context

[ADR-0017](0017-passwordless-email-sign-in.md) made the emailed one-time code the only
credential in Rekfar. That moved transactional email from a supporting concern to the
**critical path of every login**: if the mail does not arrive, nobody gets in. It named the
provider as the one open sub-decision, with three criteria — a genuinely free or near-free
tier at hobby volume ([P1](../architecture/principles.md#p1-hobby-first-cost-minimal)), an
EEA-appropriate region (NFR-PRIV-5), and custom-domain SPF/DKIM so codes reach the inbox.

Checking the candidates against those criteria on **2026-09-05** changed the shape of the
question:

| Candidate | Free tier | Where data sits | Blocker |
| --- | --- | --- | --- |
| **Azure Communication Services Email** | None — $0.00025/email + $0.00012/MB | Geography chosen at resource creation; **Europe and Norway** both offered | No free tier |
| **Scaleway TEM** | 300/month, then per-email | Entirely within the EU (`fr-par` only) | A second cloud account to run |
| **Resend** | 3,000/month, 100/day | Account data and logs in the US | Fails NFR-PRIV-5 |
| **Brevo** | 300/day | EU | Own logo in free-plan email |
| **Mailjet** | 6,000/month, 200/day | EU (France) | Own logo in free-plan email |
| **MailerSend** | 500/month, 100/day | EU | Free tier cut sharply in Dec 2025 |
| **Postmark** | None | US | Paid from the first production email |

Two things follow from the table. First, **"free" is worth very little here.** Beyond the
free allowances the credible options converge on roughly the same per-email price, and this
project's volume — a code per login for a single-maintainer hobby log — puts the whole
question in the range of **cents per month**. A free tier saves pocket change; it does not
decide anything.

Second, **a third party's logo has no business in a login email.** Brevo and Mailjet are
otherwise good EU citizens, but an email carrying someone else's branding is exactly what a
user is told to distrust when it contains a code. That reads as phishing, and this is the
one email Rekfar sends where being trusted is the entire point.

## Decision

Sign-in codes are sent by **Azure Communication Services Email**, with:

1. **The resource created in an EEA geography** — **Norway** where the offering allows it,
   Europe otherwise. Data at rest stays in the selected geography (NFR-PRIV-5,
   [P2](../architecture/principles.md#p2-norway-scoped-by-design)).
2. **Authentication by managed identity**, not an access key or connection string. The API
   already runs on Azure Container Apps ([ADR-0010](0010-tech-stack-dotnet-azure-sql.md)),
   so the Container App's identity is granted the send role directly. **There is no API key
   to store, rotate, or leak** — NFR-SEC-2 and NFR-INTEG-3 are satisfied structurally rather
   than by remembering to be careful.
3. **A verified custom domain with SPF and DKIM.** The Azure managed domain sends from a
   generated `azurecomm.net` subdomain, which is unacceptable for the mail that carries a
   login code.
4. **The sender behind a small interface in the backend**, so the provider is one class to
   replace. Scaleway TEM is the named fallback if Azure ever disappoints.

## Consequences

### Positive

- **No new account, console, vendor, or bill to administer.** Email joins the subscription
  that already holds the API, the database, and blob storage
  ([P7](../architecture/principles.md#p7-simple-before-clever)).
- **No credential exists to mishandle.** Managed identity removes the single most likely
  security mistake in a one-person project — a mail API key committed, logged, or pasted.
- Data at rest can sit **in Norway**, which is a better privacy answer than any candidate
  with a free tier offered, and a fitting one for a Norway-only product (ADR-0002).
- **No daily send cap.** Free tiers meter by day (100–300); a login flow that hits a daily
  ceiling is a login outage. Metered sending has no cliff.

### Negative / accepted trade-offs

- **Running cost is no longer exactly zero.** ADR-0010 could say the stack costs nothing;
  this puts a few cents a month against it. Accepted:
  [P1](../architecture/principles.md#p1-hobby-first-cost-minimal) asks for *cost-minimal*,
  and paying cents to avoid a second vendor and a stored secret is the cheaper trade in
  every currency that matters here. It does mean the subscription must stay in good standing
  for anyone to log in.
- **Sign-in now depends on Azure in one more way.** An ACS outage is a login outage, and the
  blast radius is no longer independent of the platform. Mitigated only by the fallback
  interface in decision 4.
- **A custom domain must be owned and its DNS configured** before the first real sign-in.
  This is a prerequisite of every candidate, but it is now on the critical path to FR-ACC-1.
- ACS Email is a plainer product than the specialists — no template editor, thinner
  analytics. Irrelevant for one transactional message; it would matter if Rekfar ever sends
  digests or newsletters.

## Sources

Verified **2026-09-05**:

- Azure Communication Services — email pricing ($0.00025/email, $0.00012/MB; no free tier):
  https://learn.microsoft.com/en-us/azure/communication-services/concepts/email-pricing
- Azure Communication Services — data residency and geography selection (Europe and Norway
  among the options):
  https://learn.microsoft.com/en-us/azure/communication-services/concepts/privacy
- Azure Communication Services — Microsoft Entra ID authentication, listed as supported for
  the Email SDK:
  https://learn.microsoft.com/en-us/azure/communication-services/concepts/authentication
- Scaleway Transactional Email — 300/month free tier, all data hosted and processed within
  the EU, SPF/DKIM required, `fr-par` only, 10,000/month default cap and no hourly quota:
  https://www.scaleway.com/en/docs/transactional-email/faq/ and
  https://www.scaleway.com/en/docs/transactional-email/reference-content/tem-capabilities-and-limits/

**Verification note:** the Azure and Scaleway figures above were read from those products'
own documentation. The remaining rows of the candidate table — Resend's US-held account data,
the Brevo and Mailjet free-plan logo, MailerSend's December 2025 free-tier change — come from
secondary reporting, because those vendors' own pricing pages were not reachable from the
environment this was written in. They are consistent across sources but should be
re-confirmed at the vendor before anyone acts on them; none of them is load-bearing for the
decision, which turns on managed identity and data residency rather than on a free tier.
