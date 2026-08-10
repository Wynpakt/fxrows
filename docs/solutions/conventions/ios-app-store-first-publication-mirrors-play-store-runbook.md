---
title: "iOS App Store first publication mirrors PLAY_STORE.md runbook pattern"
date: 2026-08-10
category: conventions
module: fxrows-ios-app-store
problem_type: convention
component: documentation
severity: high
applies_when:
  - "Preparing first Apple App Store or TestFlight publication for fxrows"
  - "Adding or revising store submission runbooks next to docs/PLAY_STORE.md"
  - "Configuring iPhone-only Flutter iOS release assets and listing screenshots"
resolution_type: documentation_update
related_components:
  - tooling
  - development_workflow
tags:
  - app-store
  - ios
  - flutter
  - play-store
  - documentation
  - wynpakt
  - screenshots
  - xcode
---

# iOS App Store first publication mirrors PLAY_STORE.md runbook pattern

## Context

fxrows already had a durable Android first-publication runbook at `docs/PLAY_STORE.md` (Reference table → Phase 0 → Phases A–E with copy-paste drafts and Frankfurter / finance copy hygiene). iOS was buildable but not store-ready for a first Wynpakt organization upload: Flutter default App Icons, universal iPhone+iPad targeting (`TARGETED_DEVICE_FAMILY = "1,2"`), Play phone screenshots at 864×1928 (wrong Apple sizes), no App Store operator doc, and no export-compliance plist key.

[PR #1](https://github.com/Wynpakt/fxrows/pull/1) (`feat/apple-app-store-submission`, open as of this writing) captures the institutional pattern: mirror the Play checklist into `docs/APP_STORE.md`, harden iPhone-only binary metadata, regenerate branded icons, land 6.9″ screenshots under `store/ios/`, and leave signing / TestFlight / Submit as Mac + Apple-Team operator work documented in that runbook—not as Linux CI deliverables.

A follow-up doc fix on that branch corrected an A4 screenshot inventory that incorrectly grouped `iphone-6.9-01.png`–`04` as convert UI and `05`–`08` as Settings; visual check of the assets shows `01` and `05` are both Settings / rate sources. The same fix aligned Phase 0 / B2 wording so free apps are not told to accept a Paid Apps Agreement.

## Guidance

1. **Mirror the Play Store runbook shape for Apple.** When adding a second store path, clone `docs/PLAY_STORE.md` structure rather than inventing a new outline:
   - Title + prioritized sequence + calendar note
   - **Reference** table (account, immutable ID, privacy URL, assets, support contacts, platform-specific constraints)
   - Shared **Copy hygiene** (no settlement benchmarks; Frankfurter as aggregated / indicative; no live-trading marketing)
   - **Phase 0** prerequisites → **A** blocking prep (with paste-ready listing drafts) → **B** console/ASC listing → **C** build/upload → **D** submit → **E** after launch
   - Cross-link from `docs/HANDOFF.md`, `README.md`, and `store/README.md`

   In-tree result: `docs/APP_STORE.md` states it mirrors Play spirit, and HANDOFF links both readiness docs (`docs/HANDOFF.md` lines 9–10).

2. **Do not reuse Play screenshots or icons as-is.** Play assets under `store/phone-screenshot-*.png` are 864×1928. App Store needs a supported iPhone display class—prefer 6.9″ at ~1290×2796—and an opaque 1024×1024 marketing icon (RGB, no alpha). Generate a dedicated set under `store/ios/` and regenerate `app/ios/Runner/Assets.xcassets/AppIcon.appiconset/` from the brand master. Verified in tree: eight `store/ios/iphone-6.9-0{1..8}.png` at 1290×2796 RGB; `store/ios/AppIcon-1024.png` 1024×1024 RGB; `store/README.md` documents the Play vs iOS split.

3. **Prefer iPhone-only for v1 when the app is still universal.** Universal (`TARGETED_DEVICE_FAMILY = "1,2"`) forces iPad listing screenshot work. For first submission, set project-level Debug / Release / Profile configs to `TARGETED_DEVICE_FAMILY = 1` (Runner inherits). Verified in `app/ios/Runner.xcodeproj/project.pbxproj`. Document Platforms = iPhone only in the APP_STORE Reference table.

4. **Declare HTTPS-only export compliance in Info.plist.** Set `ITSAppUsesNonExemptEncryption` to `false` when the app uses only standard HTTPS / system crypto so App Store Connect can skip export questionnaires. Verified: `app/ios/Runner/Info.plist` keys `ITSAppUsesNonExemptEncryption` / `false`.

5. **Defer a Runner `PrivacyInfo.xcprivacy` until the first archive Privacy Report (unless upload fails).** Flutter engine and plugins typically ship their own manifests. Do not invent unused required-reason codes up front. Add a minimal Runner privacy manifest only for ITMS-91053 / missing reason API. Guidance lives in APP_STORE Phase C3.

6. **Treat signing, archive upload, TestFlight, and Submit as Mac + Apple Developer Team operator steps.** Document the exact commands and Organizer / Transporter flow in `docs/APP_STORE.md`; do not pretend Linux CI can finish first IPA upload without Team enrollment. APP_STORE notes there is no CI IPA job yet.

7. **Start Wynpakt Organization enrollment early (D-U-N-S).** Organization Apple Developer Program membership needs a D-U-N-S number and identity review; APP_STORE estimates ~1–2 weeks. Enrollment without a Team ID blocks archive upload—start Phase 0 before screenshot perfectionism.

8. **Keep listing inventories honest; keep agreement wording precise.**
   - Screenshot tables must match real pixel contents (open the PNGs). Wrong labels ship bad ASC upload ordering advice.
   - For a free app without IAP: require only agreements ASC marks required for free distribution; state that the **Paid Apps Agreement** is needed only if selling the app or adding IAP.

## Why This Matters

- **Operator speed:** A Play-shaped checklist with paste drafts turns App Store Connect into a fill-in exercise instead of rediscovering fields under review pressure.
- **Review / compliance risk:** Misstated finance copy, wrong encryption answers, or invented privacy manifests create avoidable App Review or ITMS failures.
- **Scope control:** iPhone-only plus deferred Privacy Manifest keeps first-ship repo work focused on assets and metadata; Mac signing remains the true gate.
- **Asset pipeline truth:** Mixing Play 864×1928 screenshots into ASC fails size checks; transparent or placeholder Flutter icons fail marketing-icon rules.
- **Trust in the runbook:** A mislabeled inventory (Settings called “convert”) teaches future operators the wrong ASC ordering—fixed once assets were rechecked on PR #1.

## When to Apply

- First Apple App Store publication for a Flutter app that already has a `docs/PLAY_STORE.md`-style Android checklist.
- The iOS target is still universal and iPad screenshots are not budgeted for v1.
- Store listing assets exist for Play but not at Apple’s required sizes / opaque 1024 icon rules.
- Organization Developer Program enrollment (D-U-N-S) is not yet Active, or upload must wait on a Mac + Team.
- Listing copy must describe Frankfurter / ECB / BYO rates without settlement or brokerage language.
- A review or self-audit shows screenshot inventory labels disagree with PNG contents, or free-app agreement wording conflates Paid Apps with required free-distribution terms.

## Examples

### Before / after — runbook pattern

**Before:** Only `docs/PLAY_STORE.md`; iOS path tribal (“open Xcode somehow”). No ASC drafts, no enrollment calendar, no link from HANDOFF.

**After:** `docs/APP_STORE.md` with Reference + Phase 0–E + copy-paste drafts; HANDOFF dual links; plan at `docs/plans/2026-08-10-001-feat-apple-app-store-submission-plan.md`. Ship shape in [PR #1](https://github.com/Wynpakt/fxrows/pull/1).

### Before / after — device family

**Before (universal):**

```text
TARGETED_DEVICE_FAMILY = "1,2";
```

**After (iPhone-only v1):**

```text
TARGETED_DEVICE_FAMILY = 1;
```

(Applied on project-level Debug / Release / Profile in `app/ios/Runner.xcodeproj/project.pbxproj`.)

### Before / after — export compliance

**Before:** No `ITSAppUsesNonExemptEncryption` key → ASC export questions at upload time.

**After** (`app/ios/Runner/Info.plist`):

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

### Before / after — screenshot assets

**Before:** Reuse `store/phone-screenshot-01.png` … (864×1928) and Flutter default AppIcon.

**After:** Dedicated `store/ios/iphone-6.9-*.png` at 1290×2796; opaque `store/ios/AppIcon-1024.png`; regenerated `AppIcon.appiconset`.

### Before / after — inventory honesty (review finding)

**Before (incorrect grouping in APP_STORE A4):** 01–04 claimed as convert; 05–08 as Settings.

**After (matches PNG contents):** `01`/`05` = Settings / rate sources; `02`–`04` and `06`–`08` = convert grid and related UI.

### Softened claims

- Exact Apple review duration and D-U-N-S wait (“~1–2 weeks”) are operator estimates in APP_STORE, not guarantees.
- “Plugins usually ship their own PrivacyInfo” is the documented expectation pending first Privacy Report; it is not verified by an archive on a Linux workspace.
- Screenshots may be reframed from Play captures; optional Simulator re-capture for native status-bar chrome is recommended in APP_STORE but not required for size compliance.

## Related

- [PR #1](https://github.com/Wynpakt/fxrows/pull/1) — feat: prepare first Apple App Store submission
- [`docs/APP_STORE.md`](../../APP_STORE.md) — operator checklist (primary)
- [`docs/PLAY_STORE.md`](../../PLAY_STORE.md) — structural template
- [`docs/HANDOFF.md`](../../HANDOFF.md) — Play and App Store readiness pointers
- [`docs/plans/2026-08-10-001-feat-apple-app-store-submission-plan.md`](../../plans/2026-08-10-001-feat-apple-app-store-submission-plan.md) — session-settled decisions
- [`store/README.md`](../../../store/README.md) — Play vs iOS asset split
