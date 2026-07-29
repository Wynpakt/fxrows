# Play Store — fxrows (first publication)

Prioritized sequence for the first upload under the **Wynpakt organization
account**. Every Console step that needs text has a **copy-paste draft**.

**Calendar (organization):** about **1–3 days** of your work + Google review after
the production submit (often a few days for a first app). No 14-day tester wait.

> Personal accounts created after Nov 2023 need a closed test (≥12 testers,
> 14 days) before production — **does not apply here** (organization account).
> Details:
> [Google Help](https://support.google.com/googleplay/android-developer/answer/14151465).

---

## Reference

| | |
|---|---|
| Account | Organization account **Wynpakt** |
| Package / App ID | `com.wynpakt.fxrows` (immutable after first upload) |
| Privacy policy | `https://wynpakt.com/app/fxrows/privacy/` (canonical; repo source: [`docs/privacy.md`](privacy.md)) |
| Icon | [`store/icon-512.png`](../store/icon-512.png) |
| Feature graphic | [`store/feature-graphic-1024x500.png`](../store/feature-graphic-1024x500.png) |
| AAB | `fxrows.aab` on [GitHub Releases](https://github.com/Wynpakt/fxrows/releases) (workflow `android-apk.yml`) |
| Signing | GitHub Secrets / keystore — see [README](../README.md#signing-keystore-one-time-setup-via-secrets) |
| Support email | `fxrows@wynpakt.com` |
| Privacy contact | `privacy@wynpakt.com` (see [`docs/privacy.md`](privacy.md)) |

**Copy hygiene:** Do not claim settlement/transaction benchmarks. Describe
Frankfurter default as aggregated / indicative rates — not as unmodified ECB
reference rates. Older sideloads under `com.fxboard.fxboard` are a **different**
app.

---

## 0. Prerequisites (check today)

Done when all items below are true — then Phase A.

1. [Play Console](https://play.google.com/console) → account **Wynpakt** /
   organization; identity/org verification complete.
2. Production track usable for the organization **without** the 12/14 gate
   (dashboard shows no “Apply for production” block due to closed test).
3. Release keystore exists and secrets are set (or you create them in Phase A) —
   no upload without a signed AAB.
4. Privacy URL is publicly reachable over HTTPS (or you host it in Phase A).
5. Icon + feature graphic live under `store/`. Phone screenshots committed:
   `store/phone-screenshot-01.png` … `phone-screenshot-08.png`.

---

## Phase A — Blocking prep (first; parallel OK)

**Done-when:** Keystore/secrets OK, privacy URL live, screenshots ready,
support contact `fxrows@wynpakt.com`, listing copy below ready to paste.

### A1. Signing keystore

If secrets are already set: skip. Otherwise create a keystore once and store it
as GitHub Actions secrets — guide:
[README — Signing keystore](../README.md#signing-keystore-one-time-setup-via-secrets).

Keep an offline backup of the keystore file + passwords (loss means users must
reinstall; Play App Signing protects the *app-signing* key, not the upload key).

### A2. Publish privacy URL

**Privacy policy URL (canonical):**

```
https://wynpakt.com/app/fxrows/privacy/
```

Repo source: [`docs/privacy.md`](privacy.md). Use the same URL in the app
(`FxrowsLegal.privacyPolicyUrl`) and in Phase B.

### A3. Screenshots

Committed under [`store/`](../store/):

| File | Typical use |
|------|-------------|
| [`phone-screenshot-01.png`](../store/phone-screenshot-01.png) … [`04.png`](../store/phone-screenshot-04.png) | Convert grid / UI |
| [`phone-screenshot-05.png`](../store/phone-screenshot-05.png) … [`08.png`](../store/phone-screenshot-08.png) | Settings / sources |

Play needs ≥2 phone screenshots; upload a suitable subset (convert + settings).

### A4. Support contact

Listing / general support: **`fxrows@wynpakt.com`**.  
Privacy policy inquiries: **`privacy@wynpakt.com`** (see [privacy.md](privacy.md)).

### A5. Prepare listing copy

Short description: max. **80 characters**. Tone: calm, precise — no
“live trading” hype ([PRODUCT.md](../PRODUCT.md)).

**Draft — App name:**

```
fxrows
```

**Draft — Short description:**

```
Multi-currency converter grid. Frankfurter rates by default; advanced ECB/BYO.
```

**Draft — Full description:**

```
fxrows is a multi-currency converter: many currencies at once — change one amount
and the others update via cross-rates.

Features:
• Currency grid with pivot sync
• Inline calculator in amount fields (+ − × ÷ and parentheses)
• Default: Frankfurter (open-source central-bank rate aggregation, offline cache)
• Advanced: ECB direct or your own API key (ExchangeRate-API / Open Exchange Rates)
• Open source (MIT)
• No analytics / activity ping to wynpakt

Note: Exchange rates are informational only. They are not settlement or
transaction benchmarks and not a guarantee of bank or trade rates. The default
source is Frankfurter (aggregated central-bank data).

Support: fxrows@wynpakt.com
Source: https://github.com/Wynpakt/fxrows
Privacy: see the privacy policy URL on the store listing
```

---

## Phase B — Create app, forms, store listing

**Where:** [Play Console](https://play.google.com/console) → Create app.  
**Done-when:** Dashboard checklist for policy + listing is green (build optional).

### B1. Create app

| Field | Draft / choice |
|------|----------------|
| App name | `fxrows` |
| Default language | English (US) |
| App or game | App |
| Free or paid | Free |
| Declarations | Accept policies; no ads / not for children, as applicable |

Package name is set on the **first AAB upload** and must be
**`com.wynpakt.fxrows`** — immutable afterward.

### B2. Store listing

**Where:** Grow → Store presence → Main store listing (labels may vary slightly).

| Field | Draft |
|------|--------|
| App name | `fxrows` |
| Short description | From A5 |
| Full description | From A5 |
| App icon | `store/icon-512.png` |
| Feature graphic | `store/feature-graphic-1024x500.png` |
| Phone screenshots | `store/phone-screenshot-01.png` … `08.png` (≥2 required) |
| Application category | **Finance** (alternative: Tools) |
| Contact email | `fxrows@wynpakt.com` |
| Website (optional) | `https://github.com/Wynpakt/fxrows` |
| Privacy policy | URL from A2 |

### B3. App content — Privacy policy

**Where:** Policy → App content → Privacy policy.

**URL:**

```
https://wynpakt.com/app/fxrows/privacy/
```

### B4. App content — Ads

**Draft:** **No** — the app has no ads / no ads SDK.

If ads are added later: set to **Yes**, extend Data safety (B8) for Ad ID / ads
SDK, and update [privacy.md](privacy.md). The code license
([LICENSE](../LICENSE), MIT) stays unchanged — monetization is not a license
change.

### B5. App content — Target audience and content

| Question | Draft |
|----------|--------|
| Target age groups | Not primarily children (e.g. 18+ or “not primarily children”, per Console UI) |
| Designed for Families / Children | **No** |
| Appeal to children | **No** |

### B6. App content — News / COVID / Government / etc.

Where the Console asks (news app, COVID, government app, etc.): **No** / not
applicable.

### B7. App content — Financial features

| Question | Draft |
|----------|--------|
| Financial features? | Yes, but **informational** FX / currency conversion only |
| Brokerage / trading / payments / crypto exchange / lending / banking | **No** |
| Description (if free text) | see draft below |

**Draft — Financial features description:**

```
fxrows provides informational foreign-exchange conversion only. It does not
execute trades, transfers, payments, or brokerage. Default rates come from
Frankfurter (open-source central-bank aggregation) and are cached on device;
Advanced settings allow ECB direct rates or third-party rate APIs called from
the device when the user supplies their own key.
```

### B8. App content — Data safety

**Where:** App content → Data safety.

Guideline: no account, no ads/analytics SDKs, no activity ping, and **no**
contact with wynpakt servers. Default network: Frankfurter
(`api.frankfurter.dev`, possibly Cloudflare). Advanced: ECB and/or BYO (ERA/OER).
UI may also fetch **IBM Plex** from the **Google Fonts CDN** (`google_fonts`)
on first use when not cached. Do **not** claim “No data collected” if the app
sends HTTPS to third parties (Frankfurter / ECB / BYO / Google Fonts). BYO keys
stay on the device.

Suggestions (Console labels change occasionally — choose the closest match):

| Topic | Draft |
|-------|--------|
| Does your app collect or share user data? | **Yes** — disclose technical/network processing (below); no account, no tracking SDK |
| Account / name / email / location / photos | **Not collected** (no login) |
| App activity / financial info as PII | Amounts/currencies local; no server accounts |
| Device or other IDs for ads/analytics | **No** (no ads/analytics SDK) |
| Data collected / shared — App functionality | Rate fetch: HTTPS to Frankfurter; optional ECB / BYO; optional Google Fonts CDN for IBM Plex |
| Data encrypted in transit | **Yes** (HTTPS) |
| Users can request deletion | N/A for cloud account — local: clear app data / uninstall |
| Data sold | **No** |

**Draft — Data safety free-text (if needed):**

```
fxrows has no user accounts and ships without advertising or analytics SDKs.
Preferences, cached rates, and optional API keys stay on the device (keys in
platform secure storage). By default the app downloads rates from
api.frankfurter.dev (may use Cloudflare; standard request metadata may apply).
Advanced: ECB direct (ecb.europa.eu) or BYO ExchangeRate-API / Open Exchange
Rates. The UI may download the IBM Plex font family from Google’s fonts CDN on
first use when not already cached (standard request metadata may apply; falls
back to system fonts if the fetch fails). fxrows does not contact wynpakt
servers and does not ping for analytics.
```

### B9. App content — Content rating (IARC)

Answer the questionnaire honestly. Expectation for Tools/Finance without
user-generated content / violence / etc.: **low age rating**.

Typical direction: no in-app user communication, no gambling content purchases,
no sexually explicit content — follow the wizard for concrete clicks.

---

## Phase C — Upload AAB and smoke-test

**Done-when:** Signed `fxrows.aab` in the Console, Play App Signing on, dashboard
checklist including build is green; optional short internal testing pass.

### C1. Obtain signed AAB

1. CI: Actions → **Android APK Release** (or release tag) → artifact /
   [GitHub Releases](https://github.com/Wynpakt/fxrows/releases) → download
   **`fxrows.aab`**.
2. Or build a signed bundle locally (same keystore credentials as CI).

`targetSdk`: keep up with Flutter stable. From **31 Aug 2026**, new apps /
updates often require API **36**.

### C2. First upload + Play App Signing

**Where:** Test and release → Testing → Internal testing (recommended) **or**
production later.

1. Create new release → upload `fxrows.aab`.
2. Enable / confirm **Play App Signing**.
3. Keep the upload-keystore backup (same secrets as Obtainium CI).

**Draft — Release name (Internal):**

```
0.1.x internal
```

(Replace `0.1.x` with the real version from the release.)

**Draft — Release notes (Internal):**

```
First internal build: multi-currency grid, Frankfurter default, advanced ECB/BYO.
```

### C3. Internal testing (recommended; no compliance wait)

**Where:** Internal testing → Testers → email list or Google Group; share the
opt-in link.

**Draft — Internal tester invite:**

```
Hi,

Could you install fxrows via the Google Play internal test?

1. Open the link and join as a tester (Google account).
2. Install the app from Play (not sideload).
3. Please briefly check: convert grid (change an amount, several currencies) and
   Settings (rate source). Feedback to fxrows@wynpakt.com or
   https://github.com/Wynpakt/fxrows/issues

Thanks!
Opt-in link: [INTERNAL_OPT_IN_LINK]
```

Closed testing is **optional** for this organization account (extra QA), not a
requirement for production.

### C4. Dashboard checklist

All required items (listing, content, privacy, rating, …) green. Then Phase D.

---

## Phase D — Production

**Where:** Test and release → Production → Create new release.  
**Done-when:** Release submitted for review; after approval, public (or in
selected countries).

1. Upload the same or a newer `fxrows.aab`.
2. Choose countries / rollout.
3. Submit for review and wait.

**Draft — Release name (Production):**

```
0.1.x production
```

**Draft — What’s new / Release notes:**

```
First public release of fxrows:
• Multi-currency converter grid
• Inline calculator in amount fields
• Frankfurter rates by default (offline cache)
• Advanced: ECB direct or BYO API keys on-device only

Rates are informational only — not trade or settlement rates.
```

---

## Phase E — After launch

1. Optionally link the Play listing in the README.

   **Draft — README line:**

   ```
   **Google Play:** [fxrows on Google Play](https://play.google.com/store/apps/details?id=com.wynpakt.fxrows)
   ```

   (Verify the URL after go-live; adjust if the store URL differs.)

2. Update privacy URL and Data safety when behavior changes (new providers,
   analytics, accounts, …).
3. Sideload/Obtainium users on the old package ID (`com.fxboard.fxboard`) are
   **not** the same app — no Play update path.
