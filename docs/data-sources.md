# Data sources & attribution

## Default path: Frankfurter (on device)

The Flutter app downloads blended central-bank exchange rates from the
open-source [Frankfurter](https://frankfurter.dev/) v2 API
(`api.frankfurter.dev`) **from the device**, caches the snapshot for offline
use, and refreshes about once per day. No API key is required.

The public Frankfurter host may run behind **Cloudflare** (CDN / abuse
protection). Frankfurter’s FAQ: the API itself does not collect personal data;
Cloudflare may see standard request metadata. Self-hosting Frankfurter avoids
Cloudflare — see [frankfurter.dev/deploy](https://frankfurter.dev/deploy/).

**Rates are blended** across many central banks and official sources (not a
single official fixing). Use Advanced → **ECB (direct)** for unmodified ECB
euro reference rates.

**Attribution (summary):** Credit Frankfurter and that underlying data come from
central banks / official sources; each provider’s own terms still apply to its
data. Rates are informational only — not for transaction settlement.

**Exit strategy:** If the public API becomes unavailable, self-host Frankfurter
(Docker) or revive/extend the optional `server/` aggregator in this repo — the
shipping app does not depend on wynpakt hosts.

## Advanced: ECB direct (on device)

Optional path: European Central Bank (ECB) euro foreign exchange reference rates
(daily XML) **directly from the ECB**, unmodified snapshot, local cache.

**Reuse policy (summary):** ESCB statistics may be reused free of charge if:

1. The source is quoted (e.g. “Source: European Central Bank”).
2. The statistics are not modified.
3. If the data appear in a product sold for a fee, buyers must be told the
   information is also available free of charge from the ECB website.

Official policy:
https://www.ecb.europa.eu/stats/ecb_statistics/governance_and_quality_framework/html/usage_policy.en.html

**Disclaimer:** ECB reference rates are for information purposes only.
Using them for transaction purposes is strongly discouraged.

## Advanced BYO: ExchangeRate-API

When the user pastes their own API key, the Flutter app calls ExchangeRate-API
**directly from the device**. Keys are stored in platform secure storage.
Redistribution of that provider’s data through any fxrows aggregation server is
intentionally not implemented.

Users remain bound by ExchangeRate-API’s terms of use.

## Advanced BYO: Open Exchange Rates

Same model: the user supplies an **App ID**; the app calls
`https://openexchangerates.org/api/latest.json` from the device only. The App ID
stays in secure storage. Free plans use **USD** as base currency (paid plans can
change base). fxrows still converts via cross-rates, so any pair works. Users
remain bound by Open Exchange Rates’ terms of use.

## Optional: aggregation server in this repo

The `server/` package can still ingest ECB XML and expose `GET /v1/latest` for
experiments or as a future fallback if Frankfurter’s public host disappears. It
is **not** wired into the Flutter app today.
See [self-host.md](self-host.md) and [HOSTING.md](HOSTING.md).

## What we do not do

- Scrape Yahoo Finance, XE, Google, or similar proprietary UIs
- Proxy commercial FX APIs through an aggregation server
- Claim rates are suitable as transaction benchmarks
- Phone home to wynpakt for analytics, install tracking, or default rates
