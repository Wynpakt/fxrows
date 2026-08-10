# Concepts

Shared domain vocabulary for this project — entities, named processes, and status concepts with project-specific meaning. Seeded with core domain vocabulary, then accretes as ce-compound and ce-compound-refresh process learnings; direct edits are fine. Glossary only, not a spec or catch-all.

## Frankfurter

The default exchange-rate source for fxrows: an open-source aggregation of central-bank / official rates fetched from the device (no user API key), cached locally, and treated as indicative blended rates—not unmodified ECB reference rates.

## BYO provider

An Advanced rate source where the user supplies their own commercial API credentials (for example ExchangeRate-API or Open Exchange Rates). Keys stay on-device in platform secure storage; the app calls the provider directly and never proxies responses through wynpakt servers.

## Store runbook

A first-publication operator checklist for a store channel (Play or App Store), with a Reference table, Phase 0 prerequisites, phased ASC/Console steps, and copy-paste listing drafts. App Store readiness mirrors the Play Store runbook shape rather than inventing a separate process outline.

## App Store readiness

The durable iOS first-ship prep tracked for fxrows: iPhone-only targeting, branded icons and Apple-sized screenshots, export-compliance metadata, and the App Store Connect runbook. Distinct from completing Apple organization enrollment and the first Mac archive upload, which remain operator-gated.
