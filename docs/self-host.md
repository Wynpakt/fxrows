# Self-host the aggregation server (optional)

The Flutter app defaults to **direct ECB** downloads on the device. The
aggregation server is optional for self-hosters, experiments, or the Advanced
provider in Settings.

## Production (recommended if you host one)

Public reference instance: **https://fxrows.wynpakt.com**  
Deploy via Docker/GHCR on a VPS — see [HOSTING.md](HOSTING.md).
CI builds the image; the VPS only runs `docker compose pull && up -d`.

## Local development

Requirements: Node.js 20+.

```bash
cd server
npm start          # listens on :8787 (or $PORT)
# optional manual refresh:
npm run ingest
```

Endpoints:

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/latest` | JSON snapshot (`base`, `as_of`, `rates`, attribution) |
| GET | `/v1/health` | Liveness + whether a snapshot exists |

On first start the server tries to fetch ECB rates and writes
`server/data/latest.json`. Clients may send `If-None-Match` using the response
`ETag`. The process also auto-refreshes at most hourly when the snapshot is
stale, so a separate cron is not required for production Docker deploys.

In the Flutter app: **Settings → Advanced → Self-hosted aggregator**, then set
the URL (e.g. `http://127.0.0.1:8787` or `http://192.168.1.10:8787` on a LAN).
Optional build-time default for that advanced path:
`--dart-define=FXROWS_AGG_URL=…`.

### Cron (optional, bare Node only)

ECB updates on TARGET business days around 16:00 CET. A daily job is enough
if you run without Docker and without relying on the in-process refresh:

```cron
5 17 * * 1-5 cd /path/to/fxrows/server && node src/ingest.js
```
