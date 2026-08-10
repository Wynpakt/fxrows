# App Store — fxrows (first publication)

Prioritized sequence for the first iPhone upload under the **Wynpakt organization
Apple Developer Program** membership. Every App Store Connect step that needs
text has a **copy-paste draft**.

**Calendar (organization):** start **enrollment early** (D-U-N-S + Apple identity
review often **~1–2 weeks**). After membership is Active: about **1–2 days** of
your Mac work + Apple review after submit (often a few days for a first app).

> This guide is for **manual Mac + Xcode** (Organizer or Transporter). There is
> no CI IPA job yet. Mirror spirit: [PLAY_STORE.md](PLAY_STORE.md).

---

## Reference

| | |
|---|---|
| Account | Apple Developer **Organization — Wynpakt** |
| Bundle ID | `com.wynpakt.fxrows` (immutable after first upload) |
| Platforms | **iPhone only** (`TARGETED_DEVICE_FAMILY = 1`) |
| Privacy policy | `https://wynpakt.com/app/fxrows/privacy/` (canonical; repo: [`privacy.md`](privacy.md)) |
| App icon (ASC 1024) | [`store/ios/AppIcon-1024.png`](../store/ios/AppIcon-1024.png) |
| Screenshots | [`store/ios/iphone-6.9-01.png`](../store/ios/iphone-6.9-01.png) … `08.png` (1290×2796) |
| IPA build | Manual: `flutter build ipa` (see Phase C) |
| Support email | `fxrows@wynpakt.com` |
| Privacy contact | `privacy@wynpakt.com` (see [`privacy.md`](privacy.md)) |
| Export compliance | `ITSAppUsesNonExemptEncryption` = **false** in `Info.plist` (HTTPS / system crypto) |
| Team ID | *(fill after enrollment — Xcode → Signing & Capabilities)* |

**Copy hygiene:** Do not claim settlement/transaction benchmarks. Describe
Frankfurter default as aggregated / indicative rates — not as unmodified ECB
reference rates. Do not market as live trading / brokerage. Older Android
sideloads under `com.fxboard.fxboard` are a **different** app.

**Official refs:** [Enroll](https://developer.apple.com/programs/enroll/) ·
[D-U-N-S](https://developer.apple.com/help/account/membership/D-U-N-S/) ·
[Screenshot specs](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications) ·
[App privacy](https://developer.apple.com/app-store/app-privacy-details/) ·
[Encryption export](https://developer.apple.com/documentation/security/complying-with-encryption-export-regulations) ·
[Privacy manifests](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files) ·
[Flutter iOS deploy](https://docs.flutter.dev/deployment/ios) ·
[App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

## 0. Prerequisites (check today)

Done when all items below are true — then Phase A.

1. [Apple Developer](https://developer.apple.com/account) → **Organization**
   membership for **Wynpakt** is **Active** (D-U-N-S + binding authority complete).
2. [App Store Connect](https://appstoreconnect.apple.com/) Agreements: Account
   Holder accepted current **Paid / Developer** agreements needed for free apps.
3. Mac with recent **Xcode** matching your Flutter iOS toolchain; Flutter
   `doctor` clean for iOS.
4. Privacy URL reachable over HTTPS (same as Play).
5. Repo assets ready: branded AppIcon in
   `app/ios/Runner/Assets.xcassets/AppIcon.appiconset/`, screenshots under
   `store/ios/`, this checklist.

Enrollment without a Team ID blocks archive upload — start Phase 0 before
perfectionist screenshot polish.

---

## Phase A — Blocking prep (first; parallel OK)

**Done-when:** Icons + screenshots ready, listing copy ready, Team selected in
Xcode with Automatic Signing for `com.wynpakt.fxrows`, drafts below ready to paste.

### A1. Apple Developer enrollment (Wynpakt org)

1. Confirm legal entity name matches what you want as **Seller** on the App Store.
2. Obtain / verify **D-U-N-S** for Wynpakt if Apple does not already have it
   ([help](https://developer.apple.com/help/account/membership/D-U-N-S/)).
3. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/enroll/)
   as **Organization**.
4. When Active: note **Team ID** (Membership details) into the Reference table above.

### A2. Register App ID + Xcode signing

1. [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list)
   → Identifiers → App IDs → ensure **`com.wynpakt.fxrows`** exists (or will be
   created by Xcode Automatic Signing).
2. Open `app/ios/Runner.xcworkspace` in Xcode (not `.xcodeproj` alone).
3. Runner target → Signing & Capabilities → **Team** = Wynpakt → **Automatically
   manage signing**.
4. Leave Team ID **out of git** unless you choose to commit a non-secret Team ID
   in this doc’s Reference table only.

### A3. Icons

Repo already has a branded AppIcon set and
[`store/ios/AppIcon-1024.png`](../store/ios/AppIcon-1024.png) (opaque RGB).

Upload the 1024 asset to App Store Connect when prompted; the Xcode asset catalog
ships with the binary.

### A4. Screenshots

Committed under [`store/ios/`](../store/ios/):

| File | Size | Typical use |
|------|------|-------------|
| `iphone-6.9-01.png` … `04.png` | 1290×2796 | Convert grid / UI |
| `iphone-6.9-05.png` … `08.png` | 1290×2796 | Settings / sources |

Apple requires the **highest iPhone display class** you support (6.9″ preferred;
see [screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications)).
Upload ≥2; Recommend ≥4 (grid + settings).

Optional before submit: re-capture from an iOS Simulator on Mac if you want native
status-bar chrome; sizes must still match a listed 6.9″ class.

### A5. Support contact

Listing / general support: **`fxrows@wynpakt.com`**.  
Privacy policy inquiries: **`privacy@wynpakt.com`**.

### A6. Prepare listing copy

Tone: calm, precise — no “live trading” hype ([PRODUCT.md](../PRODUCT.md)).

**Draft — App name:**

```
fxrows
```

**Draft — Subtitle** (≤30 characters; optional polish):

```
Multi-currency converter grid
```

**Draft — Promotional text** (optional; changeable without a new binary):

```
Many currencies at once. Frankfurter rates by default; advanced ECB or BYO.
```

**Draft — Description:**

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
Privacy: https://wynpakt.com/app/fxrows/privacy/
```

**Draft — Keywords** (comma-separated, no spaces after commas if you prefer
density; ASC limit applies):

```
currency,converter,exchange,rates,FX,multi-currency,Frankfurter,ECB
```

**Draft — Support URL:**

```
https://github.com/Wynpakt/fxrows
```

**Draft — Marketing URL** (optional):

```
https://github.com/Wynpakt/fxrows
```

**Draft — What’s New (1.0 / first release):**

```
First public release of fxrows:
• Multi-currency converter grid
• Inline calculator in amount fields
• Frankfurter rates by default (offline cache)
• Advanced: ECB direct or BYO API keys on-device only

Rates are informational only — not trade or settlement rates.
```

### A7. Export compliance (draft)

Binary already sets `ITSAppUsesNonExemptEncryption` = **NO** / `false`.

If ASC still asks: app only uses HTTPS / standard OS encryption → **exempt**.

### A8. Age rating (draft)

Answer the App Store Connect questionnaire honestly. Expectation for an
informational converter without UGC / gambling / unrestricted web:

| Direction | Draft |
|-----------|--------|
| Overall | Typically **4+** |
| Unrestricted web access | No (or as applicable for in-app Safari links to privacy/GitHub only) |
| Gambling / contests | No |
| Trading as a broker | No |

Use the live questionnaire; do not force-fit if Apple’s wording changed.

### A9. Financial features / review notes (draft)

Same spirit as Play B7 — informational FX only.

**Draft — App Review Notes (optional text box):**

```
fxrows is an informational multi-currency converter only. It does not execute
trades, transfers, payments, or brokerage. Default rates: Frankfurter
(api.frankfurter.dev). Optional Advanced: ECB XML or user-supplied BYO API keys
stored in the Keychain / secure storage on device. No user accounts, ads, or
analytics SDKs. Privacy: https://wynpakt.com/app/fxrows/privacy/
```

---

## Phase B — Create app, App Privacy, listing

**Where:** [App Store Connect](https://appstoreconnect.apple.com/) → Apps → +.  
**Done-when:** Version page metadata + App Privacy complete; build can attach later.

### B1. Create app

| Field | Draft / choice |
|------|----------------|
| Platforms | iOS |
| Name | `fxrows` |
| Primary language | English (U.S.) |
| Bundle ID | `com.wynpakt.fxrows` |
| SKU | e.g. `fxrows-ios` (internal; not shown on store) |
| User Access | Full Access (unless you need limited) |

### B2. Pricing

**Free.** No Paid Apps agreement required solely for a free app without IAP.

### B3. Category

| Field | Draft |
|------|--------|
| Primary | **Finance** |
| Secondary (optional) | Utilities |

### B4. Privacy policy URL

```
https://wynpakt.com/app/fxrows/privacy/
```

### B5. App Privacy (Nutrition Labels)

**Where:** App Privacy → Get Started / Edit.

Guideline: no accounts, no ads/analytics SDKs, no wynpakt servers. Preferences,
cached rates, and optional BYO keys stay on device. Default network:
Frankfurter (`api.frankfurter.dev`, possibly Cloudflare). Advanced: ECB and/or
BYO. Fonts bundled. Follow Apple’s definition of **“collect”** (linked to the
user / retained beyond the request). Revisit if you add analytics later.

Suggested direction (labels change — pick closest match):

| Topic | Draft |
|-------|--------|
| Tracking | **No** — no ATT / no tracking SDKs |
| Data Used to Track You | **None** |
| Data Linked to You | Typically **None** (no accounts) |
| Data Not Linked to You | Only if you classify ephemeral request metadata retained by *you*; default: most rate fetches are not “collected” by Wynpakt |
| Contact Info / Location / Photos | **Not collected** |
| Identifiers for ads | **Not collected** |
| Sensitive financial brokerage data | N/A — informational conversion only |
| Privacy policy URL | Required — URL above |

**Draft — Privacy free-text (if asked / for your records):**

```
fxrows has no user accounts and ships without advertising or analytics SDKs.
Preferences, cached rates, and optional API keys stay on the device (keys in
Keychain / platform secure storage). By default the app downloads rates from
api.frankfurter.dev (may use Cloudflare; standard request metadata may apply
at that host). Advanced: ECB direct (ecb.europa.eu) or BYO ExchangeRate-API /
Open Exchange Rates. UI fonts (IBM Plex) are bundled. fxrows does not contact
wynpakt servers and does not ping for analytics.
```

Do **not** claim the privacy policy says “nothing ever leaves the device” — rate
fetches are HTTPS to third parties (see [privacy.md](privacy.md)).

### B6. Screenshots + preview

Upload `store/ios/iphone-6.9-*.png` into the iPhone 6.9″ slot (or current
highest required class). No iPad screenshots required while the app remains
iPhone-only.

### B7. App Review contact

| Field | Draft |
|------|--------|
| First / last name | Your Account Holder / tech contact |
| Phone | Reachable number |
| Email | `fxrows@wynpakt.com` |

### B8. Version & build number strategy

- Marketing version = Flutter `CFBundleShortVersionString` (`pubspec` / `--build-name`)
- Build = `CFBundleVersion` (`--build-number`) — **must increase for every ASC upload**
- Android `versionCode` may diverge; align marketing `0.1.x` when practical

Example first IPA:

```bash
cd app
flutter build ipa --build-name=0.1.0 --build-number=1
```

Later uploads bump `--build-number` (and name when you ship a user-visible bump).

---

## Phase C — Archive, upload, Privacy Report

**Done-when:** Build processed in App Store Connect; Privacy Report checked;
internal TestFlight install works.

### C1. Build IPA

```bash
cd app
flutter pub get
flutter build ipa --build-name=0.1.0 --build-number=1
```

Outputs typically under `app/build/ios/ipa/` and an `.xcarchive` under
`app/build/ios/archive/`.

### C2. Validate & distribute

1. `open app/build/ios/archive/*.xcarchive` (or Xcode → Window → Organizer).
2. **Validate App** → fix any signing / capability errors.
3. **Distribute App** → App Store Connect → Upload  
   **or** drag the `.ipa` into **Transporter**.

### C3. Privacy Manifest check

After archive: Xcode Organizer → generate **Privacy Report**.

- Flutter engine and current plugins (`shared_preferences`,
  `flutter_secure_storage`, …) usually ship their own `PrivacyInfo.xcprivacy`.
- If upload fails with ITMS-91053 / missing required-reason API: add a Runner
  `PrivacyInfo.xcprivacy` declaring only what **your** native code needs, bump
  build number, re-upload. Do not invent unused reason codes.

### C4. Attach build on the version page

Wait until processing finishes → select the build on the iOS version page.

### C5. TestFlight smoke (internal)

Internal testers (same team) — no Beta App Review required for internal only.

Check:

1. Cold launch
2. Change an amount across several currencies (Frankfurter default)
3. Settings: switch source copy is readable; privacy link opens
4. Optional: BYO key save/clear (Keychain path)
5. Airplane mode / failed network shows a recoverable UI

**Draft — Internal tester note:**

```
Hi,

Please install fxrows via TestFlight and briefly check: convert grid (change an
amount) and Settings (rate source). Feedback: fxrows@wynpakt.com or
https://github.com/Wynpakt/fxrows/issues

Thanks!
```

External TestFlight groups need Beta App Review on the first external build —
optional for a solo org first ship.

---

## Phase D — Submit for Review

**Done-when:** Status is **Waiting for Review** / **In Review** (then Approved /
Ready for Sale).

1. Complete every required ASC field (yellow warnings clear).
2. Select the tested build.
3. **Add for Review** → **Submit for Review**.

Rejection watchouts ([guidelines](https://developer.apple.com/app-store/review/guidelines/)):

- Marketing as brokerage / regulated trading (3.1.5 / finance)
- Metadata or screenshots that don’t match the app (2.3)
- Incomplete App Privacy vs real network behavior (5.1)
- Crash on launch / broken default Frankfurter path (2.1)

---

## Phase E — After launch

1. Optionally link the App Store listing in the README.

   **Draft — README line:**

   ```
   **App Store:** [fxrows on the App Store](https://apps.apple.com/app/idXXXXXXXXX)
   ```

   (Replace with the real App Store URL / Apple ID after go-live.)

2. Update privacy URL + App Privacy answers when behavior changes (new
   providers, analytics, accounts, …). Keep [privacy.md](privacy.md) in sync.
3. For the next binary: bump `--build-number`; regenerate screenshots only if UI
   changed materially.

---

## Operator checklist (U4) — first upload day

Complete on a Mac after Phase 0 membership is Active:

- [ ] Team set on Runner; Automatic Signing succeeds
- [ ] `flutter build ipa` with fresh build number
- [ ] Validate App succeeds
- [ ] Build appears in ASC; Privacy Report OK
- [ ] Internal TestFlight smoke passed
- [ ] Submit for Review

This step cannot finish in CI on Linux — it needs your enrolled Apple Team.
