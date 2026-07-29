/// Legal / store-facing URLs and short copy shared across the UI.
class FxrowsLegal {
  FxrowsLegal._();

  /// Public privacy policy (Play Console + in-app). Raw Markdown over HTTPS.
  static const privacyPolicyUrl =
      'https://raw.githubusercontent.com/Wynpakt/fxrows/main/docs/privacy.md';

  static const ratesFooter =
      'Rates are informational only, not for transaction settlement. '
      'Default source: Frankfurter (aggregated central-bank rates; public API '
      'may use Cloudflare). Cached on device for offline use. Advanced: ECB '
      'direct or bring-your-own API.';
}
