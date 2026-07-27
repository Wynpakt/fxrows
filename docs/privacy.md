# Privacy Policy — fxrows

**Last updated:** 2026-07-29  
**Developer:** wynpakt  
**App package:** `com.wynpakt.fxrows`  
**Contact:** Use the support email listed on the Google Play store listing (or open an issue on [github.com/Wynpakt/fxrows](https://github.com/Wynpakt/fxrows)).

This policy describes how the **fxrows** multi-currency converter app handles information.

---

### What the app does

fxrows converts amounts across multiple currencies on your device. Default exchange rates are downloaded from the open-source **Frankfurter** API (aggregated central-bank / official rates) and stored on your device for offline use. Under Advanced settings you can use **ECB direct** rates or supply your own API credentials for third-party rate providers.

### Data we do not collect

- No user accounts or sign-in  
- No advertising SDKs, analytics, crash reporters, or activity pings  
- No sale of personal data  
- The app does **not** contact wynpakt or fxrows aggregation servers  

### Data processed on your device

| Data | Where stored | Purpose |
|------|----------------|---------|
| Selected currencies, amounts, preferences | Local app storage (`SharedPreferences`) | App functionality |
| Cached exchange-rate snapshot | Local app storage | Offline conversion |
| Optional API keys / App IDs (BYO providers) | Platform secure storage | Call third-party rate APIs **from your device only** |

These stay on the device unless you clear app data or uninstall.

### Network requests

Depending on settings, the app may contact:

1. **Frankfurter** (default) — HTTPS GET to `api.frankfurter.dev` (open-source central-bank rate aggregation). The public host may run behind **Cloudflare**, which may see standard request metadata (e.g. IP, timestamp, user-agent). Frankfurter states the API itself does not collect personal data.
2. **European Central Bank** — only if you choose **ECB (direct)** under Advanced. HTTPS GET of the public eurofxref daily XML (`ecb.europa.eu`).
3. **ExchangeRate-API** or **Open Exchange Rates** — only if you choose that provider and enter your own key/App ID. Requests go **directly** from your device; those providers’ own privacy policies and terms apply.
4. **Google Fonts CDN** — the UI may download the **IBM Plex** font family from Google’s fonts CDN on first use when not already cached; Google may see standard request metadata. If that fetch fails, the app falls back to system fonts.

### Permissions

Android: **Internet** — required to download exchange rates.

### Children’s privacy

fxrows is not directed at children under 13 and does not knowingly collect children’s data.

### Changes

We may update this policy; the “Last updated” date will change. Continued use after changes means you accept the updated policy. If advertising is added later, this policy and the Play Console Ads / Data safety declarations will be updated; the MIT code license does not change.

### Rates disclaimer

Exchange rates are informational only and are not transaction benchmarks. Frankfurter default rates are blended aggregates. ECB reference rates (Advanced) are subject to ECB/ESCB reuse conditions (source attribution required).
