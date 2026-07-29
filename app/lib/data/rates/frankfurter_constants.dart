/// Frankfurter v2 public API (central-bank aggregation, no API key).
///
/// Docs: https://frankfurter.dev/ — self-host: https://frankfurter.dev/deploy/
const frankfurterRatesUrl =
    'https://api.frankfurter.dev/v2/rates?base=EUR&expand=providers';

const frankfurterAttribution =
    'Rates via Frankfurter (frankfurter.dev), aggregated from central banks '
    'and official sources. Public API may run behind Cloudflare. '
    'See each provider’s terms for underlying data.';

const frankfurterDisclaimer =
    'Informational only — not for transaction settlement. Blended rates are '
    'indicative aggregates, not a single central bank’s official fixing. '
    'For unmodified ECB euro reference rates, choose ECB (direct) under '
    'Advanced settings.';
