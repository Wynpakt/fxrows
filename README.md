# fxrows

Open-source **multi-currency converter** (Flutter). Default rates come from
**[Frankfurter](https://frankfurter.dev/)** (open-source central-bank
aggregation, cached on device). No API key and no wynpakt server in the shipping
app. Advanced settings: ECB direct or BYO commercial APIs. An optional
aggregation server package lives in `server/` for experiments / fallback only
(not wired into the client).

> Repo: [Wynpakt/fxrows](https://github.com/Wynpakt/fxrows).

## Why

Most converters show one pair at a time. fxrows shows **many currencies at
once** — change any amount and the others update. Amount fields also accept
simple expressions (`100+50`, `200-30`, `2*3+4`).

## Features

- **Default rates:** Frankfurter v2 (many currencies, no key), daily-ish refresh, offline cache
- **Advanced:** ECB euro reference rates direct, or BYO ExchangeRate-API / Open Exchange Rates
- **Multi-currency grid** with pivot sync
- **Inline calculator** in amount fields
- **Flags** next to currency codes; optional **custom currencies** with manual rates
- Platforms: Android, iOS, Linux, macOS, Windows (Web out of scope)
- **No** analytics / activity ping / default connection to wynpakt servers

## Repository layout

```
fxrows/
  app/       Flutter client (Frankfurter default)
  server/    Optional Node.js aggregation API (not used by the app today)
  docs/      Data-source policy, hosting, privacy, Play Store notes
```

## Quick start — app

```bash
cd app
flutter pub get
flutter run -d linux   # or macos / windows / a connected device
```

Default: HTTPS to `api.frankfurter.dev`; snapshot cached locally.

## Optional — aggregation server (repo only)

```bash
cd server
node src/ingest.js   # fetch ECB → data/latest.json
npm start            # http://127.0.0.1:8787
curl http://127.0.0.1:8787/v1/latest | head
```

See [docs/HOSTING.md](docs/HOSTING.md) and [docs/self-host.md](docs/self-host.md).

## Android APK / Obtainium

Pushes to `main` that touch `app/**` (or
[`.github/workflows/android-apk.yml`](.github/workflows/android-apk.yml)) build a
signed release APK (and App Bundle for Play) and publish the APK to
[GitHub Releases](https://github.com/Wynpakt/fxrows/releases/latest) so
[Obtainium](https://github.com/ImranR98/Obtainium) can detect updates.

**Note:** Package ID is `com.wynpakt.fxrows`. Older installs under
`com.fxboard.fxboard` are a different app — uninstall and re-add in Obtainium.

- **Quick add (phone with Obtainium installed):**
  [Add fxrows to Obtainium](https://apps.obtainium.imranr.dev/redirect.html?r=obtainium://app/%7B%22id%22%3A%22com.wynpakt.fxrows%22%2C%22url%22%3A%22https%3A%2F%2Fgithub.com%2FWynpakt%2Ffxrows%22%2C%22author%22%3A%22Wynpakt%22%2C%22name%22%3A%22fxrows%22%2C%22preferredApkIndex%22%3A0%2C%22additionalSettings%22%3A%22%7B%5C%22includePrereleases%5C%22%3Atrue%2C%5C%22fallbackToOlderReleases%5C%22%3Atrue%2C%5C%22apkFilterRegEx%5C%22%3A%5C%22fxrows%5C%22%2C%5C%22autoApkFilterByArch%5C%22%3Afalse%2C%5C%22trackOnly%5C%22%3Afalse%2C%5C%22versionDetection%5C%22%3A%5C%22standardVersionDetection%5C%22%2C%5C%22appName%5C%22%3A%5C%22fxrows%5C%22%7D%22%7D)
- **Manual:** add `https://github.com/Wynpakt/fxrows` as a GitHub source
  (enable *Include prereleases* — CI publishes prerelease tags)
- **Build:** Actions → **Android APK Release** → Run workflow

### Signing keystore (one-time setup via secrets)

Obtainium only updates apps whose signature never changes, so CI signs with a
persistent release keystore. The keystore and passwords live **only in GitHub
secrets** — never in the repo. Create a keystore once and keep the file safe
(losing it means users must uninstall/reinstall):

```bash
keytool -genkeypair -v \
  -keystore fxrows-release.keystore \
  -alias fxrows \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass 'YOUR_STRONG_PASSWORD' -keypass 'YOUR_STRONG_PASSWORD' \
  -dname "CN=fxrows, O=wynpakt"

base64 -w0 fxrows-release.keystore   # -> value for ANDROID_KEYSTORE_BASE64
```

Then add these under Repo Settings → Secrets and variables → Actions:

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | base64 of the keystore file |
| `ANDROID_KEYSTORE_PASSWORD` | keystore password |
| `ANDROID_KEY_ALIAS` | key alias (e.g. `fxrows`) |
| `ANDROID_KEY_PASSWORD` | key password |

Optional variables:

| Variable | Purpose |
| --- | --- |
| `ANDROID_VERSION_EPOCH` | Subtract from `run_number` for `0.1.x` display (default `0`) |

For local signed builds, create `app/android/keystore.properties` (git-ignored):

```properties
storeFile=/absolute/path/to/fxrows-release.keystore
storePassword=YOUR_STRONG_PASSWORD
keyAlias=fxrows
keyPassword=YOUR_STRONG_PASSWORD
```

Without secrets, the CI workflow fails on purpose (an unsigned/mis-signed APK
would break Obtainium updates). Local `flutter run --release` still uses the
debug keystore when no release credentials are present.

## Play Store

See [docs/PLAY_STORE.md](docs/PLAY_STORE.md) for the Console checklist.
Privacy policy: [docs/privacy.md](docs/privacy.md).

## Session handoff

Planning/implementation context for agents and future you: [docs/HANDOFF.md](docs/HANDOFF.md).

## License

Application and server code: [MIT](LICENSE).

Default rates via Frankfurter; ECB advanced path subject to ECB/ESCB reuse
conditions — see [docs/data-sources.md](docs/data-sources.md). Rates are
informational only.
