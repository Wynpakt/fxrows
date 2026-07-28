# Self-host the aggregation server (optional / not used by the app)

The Flutter app fetches ECB rates **directly** and does not call this server.
`server/` remains in the repo for self-host experiments or a possible future
in-app option.

## Production (if you host one anyway)

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

### Cron (optional, bare Node only)

ECB updates on TARGET business days around 16:00 CET. A daily job is enough
if you run without Docker and without relying on the in-process refresh:

```cron
5 17 * * 1-5 cd /path/to/fxrows/server && node src/ingest.js
```
