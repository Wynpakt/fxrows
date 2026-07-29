# Handoff — fxrows

This document captures planning and implementation context for the project.
Chat history does not move automatically when you open a different folder — use
this file for the current product and technical baseline.

**Product name:** **fxrows** · Android/iOS id: `com.wynpakt.fxrows`  
**Repo:** https://github.com/Wynpakt/fxrows  
**Play readiness:** `docs/PLAY_STORE.md`

## Product decisions

- Multi-currency grid: many currencies at once; changing one amount updates the
  others (cross-rate via provider base, typically EUR).
- Inline calculator in amount fields: `+ - * /` and parentheses; comma as decimal
  separator is OK.
- **Default rates:** [Frankfurter](https://frankfurter.dev/) v2 (aggregated
  central-bank rates) **from the device**, local cache, refresh ~1×/day;
  attribution + disclaimer. Public API may sit behind Cloudflare. No user key.
- **Advanced:** ECB direct (unmodified eurofxref-daily.xml) or BYO
  (ExchangeRate-API / Open Exchange Rates); keys in secure storage.
- **No** contact with wynpakt/fxrows aggregation servers in the shipping app.
- **No** activity ping / analytics.
- `server/` stays in the repo (experiment / fallback if the Frankfurter host
  fails or for self-host) but is **not** wired into the app.
- Exit if Frankfurter is down: self-host Frankfurter Docker **or** own aggregator
  (`server/`).
- Platforms: Flutter Android/iOS/Desktop — **no web**.
- Code license: MIT (Copyright Wynpakt). Frankfurter data: CB terms per source;
  ECB advanced: ESCB free reuse with attribution. Later Play ads: update Console /
  privacy / Data safety only — no license change.

## Legal (core)

- Frankfurter default: blended / indicative — do not market as “ECB reference
  rates”; attribute Frankfurter + central banks.
- ECB/ESCB (Advanced): free reuse with attribution; do not alter data; if sold,
  note that the source is free on the ECB website.
- Commercial APIs: BYO client-side only.
- No scraping of Yahoo/XE/Google.

## What is built

| Area | Location | Status |
|------|----------|--------|
| Flutter app | `app/` | Grid, pivot, expression eval, settings; **Frankfurter** default + ECB/BYO advanced + cache |
| Aggregator (unwired) | `server/` | Optional Node ESM; Docker/GHCR — fallback candidate |
| Docs | `docs/`, `README.md` | data-sources, privacy (Frankfurter + CF), HOSTING, Play |

## Start

```bash
cd app && flutter pub get && flutter run
```

Tests: `cd app && flutter test` · `cd server && npm test`

## Sensible next steps

- Drag-reorder currency rows
- History/charts (Frankfurter time series or ECB history)
- Desktop polishing
- Play Console: organization account → production (see [PLAY_STORE.md](PLAY_STORE.md); no 12/14 closed-test gate)

## Agent note

Follow workspace Cursor rules. In a new session in this workspace, read first:

1. `docs/HANDOFF.md` (this file)
2. `README.md` + `docs/data-sources.md`
