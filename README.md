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

For a physical phone, use your machine’s LAN IP instead of `127.0.0.1`.

## Session handoff

Planning/implementation context for agents and future you: [docs/HANDOFF.md](docs/HANDOFF.md).

## License

Application and server code: [MIT](LICENSE).

ECB rate data remain subject to ECB/ESCB reuse conditions — see
[docs/data-sources.md](docs/data-sources.md). Rates are informational only.
