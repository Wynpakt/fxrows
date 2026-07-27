# Data sources & attribution

## Default path: ECB via fxboard server

The aggregation server fetches the European Central Bank (ECB) euro foreign
exchange reference rates (daily XML) and redistributes an unmodified snapshot
to clients.

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
**directly from the device**. Keys are stored in platform secure storage and
are never sent to the fxboard aggregation server. Redistribution of that
provider’s data through our server is intentionally not implemented.

Users remain bound by ExchangeRate-API’s terms of use.

## Optional BYO: Open Exchange Rates

Same model: the user supplies an **App ID**; the app calls
`https://openexchangerates.org/api/latest.json` from the device only. The App ID
stays in secure storage and is never sent to the fxboard server.

Free plans use **USD** as base currency (paid plans can change base). fxboard
still converts via cross-rates, so any pair works. Users remain bound by Open
Exchange Rates’ terms of use.

## What we do not do

- Scrape Yahoo Finance, XE, Google, or similar proprietary UIs
- Proxy commercial FX APIs through the aggregation server
- Claim rates are suitable as transaction benchmarks
