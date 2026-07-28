# Data sources & attribution

## Default path: ECB direct (on device)

The Flutter app downloads the European Central Bank (ECB) euro foreign exchange
reference rates (daily XML) **directly from the ECB**, parses an unmodified
snapshot, and caches it on the device for offline use. Smart refresh aims for
about once per TARGET business day after the usual ~16:00 CET publication.

The shipping app does **not** contact wynpakt/fxrows aggregation servers.

**Reuse policy (summary):** ESCB statistics may be reused free of charge if:

1. The source is quoted (e.g. “Source: European Central Bank”).
2. The statistics are not modified.
3. If the data appear in a product sold for a fee, buyers must be told the
   information is also available free of charge from the ECB website.

Official policy:
https://www.ecb.europa.eu/stats/ecb_statistics/governance_and_quality_framework/html/usage_policy.en.html

**Disclaimer:** ECB reference rates are for information purposes only.
Using them for transaction purposes is strongly discouraged.

## Optional BYO: ExchangeRate-API

When the user pastes their own API key, the Flutter app calls ExchangeRate-API
**directly from the device**. Keys are stored in platform secure storage.
Redistribution of that provider’s data through any fxrows aggregation server is
intentionally not implemented.

Users remain bound by ExchangeRate-API’s terms of use.

## Optional BYO: Open Exchange Rates

Same model: the user supplies an **App ID**; the app calls
`https://openexchangerates.org/api/latest.json` from the device only. The App ID
stays in secure storage. Free plans use **USD** as base currency (paid plans can
change base). fxrows still converts via cross-rates, so any pair works. Users
remain bound by Open Exchange Rates’ terms of use.

## Optional: aggregation server in this repo

The `server/` package can still ingest ECB XML and expose `GET /v1/latest` for
experiments or future features. It is **not** wired into the Flutter app today.
See [self-host.md](self-host.md) and [HOSTING.md](HOSTING.md).

## What we do not do

- Scrape Yahoo Finance, XE, Google, or similar proprietary UIs
- Proxy commercial FX APIs through an aggregation server
- Claim rates are suitable as transaction benchmarks
- Phone home to wynpakt for analytics, install tracking, or default rates
