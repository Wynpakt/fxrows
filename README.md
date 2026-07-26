# fxboard

Open-source **multi-currency converter** (Flutter) plus a **thin aggregation
server** that redistributes ECB reference rates so users do not need an API key
by default.

## Why

Most converters show one pair at a time. fxboard shows **many currencies at
once** — change any amount and the others update. Amount fields also accept
simple expressions (`100+50`, `200-30`, `2*3+4`).

## Features

- **Default rates:** self-hosted server → ECB euro reference rates (legal free reuse with attribution)
- **Optional BYO key:** ExchangeRate-API from the device only (wider set / own quota)
- **Multi-currency grid** with pivot sync
- **Inline calculator** in amount fields
- Platforms: Android, iOS, Linux, macOS, Windows (Web out of scope)

## Repository layout

```
fxboard/
  app/       Flutter client
  server/    Node.js aggregation API (Docker/GHCR for prod)
  docs/      Data-source policy, hosting & self-host notes
```

## Quick start — server

Local (dev):

```bash
cd server
node src/ingest.js   # fetch ECB → data/latest.json
npm start            # http://127.0.0.1:8787
curl http://127.0.0.1:8787/v1/latest | head
```

Production: Docker image via GitHub Actions → GHCR; VPS does
`docker compose pull && up -d`. See [docs/HOSTING.md](docs/HOSTING.md) and
[docs/self-host.md](docs/self-host.md).
## Quick start — app

```bash
cd app
flutter pub get
flutter run -d linux   # or macos / windows / a connected device
```

Default server URL: `http://127.0.0.1:8787` (change in Settings).
Release APKs can bake a production URL via `--dart-define=FXBOARD_AGG_URL=…`
(or the GitHub Actions variable of the same name).

For a physical phone, use your machine’s LAN IP instead of `127.0.0.1`.

## Android APK / Obtainium

Pushes to `main` that touch `app/**` (or
[`.github/workflows/android-apk.yml`](.github/workflows/android-apk.yml)) build a
signed release APK and publish it to
[GitHub Releases](https://github.com/goddib/fxboard/releases/latest) so
[Obtainium](https://github.com/ImranR98/Obtainium) can detect updates.

- **Obtainium:** add `https://github.com/goddib/fxboard/releases/latest` as a
  GitHub source
- **Manual:** Actions → **Android APK Release** → Run workflow

### Signing keystore (one-time setup via secrets)

Obtainium only updates apps whose signature never changes, so CI signs with a
persistent release keystore. The keystore and passwords live **only in GitHub
secrets** — never in the repo. Create a keystore once and keep the file safe
(losing it means users must uninstall/reinstall):

```bash
keytool -genkeypair -v \
  -keystore fxboard-release.keystore \
  -alias fxboard \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass 'YOUR_STRONG_PASSWORD' -keypass 'YOUR_STRONG_PASSWORD' \
  -dname "CN=fxboard, O=fxboard"

base64 -w0 fxboard-release.keystore   # -> value for ANDROID_KEYSTORE_BASE64
```

Then add these under Repo Settings → Secrets and variables → Actions:

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | base64 of the keystore file |
| `ANDROID_KEYSTORE_PASSWORD` | keystore password |
| `ANDROID_KEY_ALIAS` | key alias (e.g. `fxboard`) |
| `ANDROID_KEY_PASSWORD` | key password |

Optional variables:

| Variable | Purpose |
| --- | --- |
| `ANDROID_VERSION_EPOCH` | Subtract from `run_number` for `0.1.x` display (default `0`) |
| `FXBOARD_AGG_URL` | Default aggregator URL baked into the APK |

For local signed builds, create `app/android/keystore.properties` (git-ignored):

```properties
storeFile=/absolute/path/to/fxboard-release.keystore
storePassword=YOUR_STRONG_PASSWORD
keyAlias=fxboard
keyPassword=YOUR_STRONG_PASSWORD
```

Without secrets, the CI workflow fails on purpose (an unsigned/mis-signed APK
would break Obtainium updates). Local `flutter run --release` still uses the
debug keystore when no release credentials are present.

## Session handoff

Planning/implementation context for agents and future you: [docs/HANDOFF.md](docs/HANDOFF.md).

## License

Application and server code: [MIT](LICENSE).

ECB rate data remain subject to ECB/ESCB reuse conditions — see
[docs/data-sources.md](docs/data-sources.md). Rates are informational only.
