# Self-host the aggregation server

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
`ETag`.

Point the Flutter app (Settings → fxboard server URL) at your instance, e.g.
`http://192.168.1.10:8787` on a LAN, or your public HTTPS URL.

### Cron (optional)

ECB updates on TARGET business days around 16:00 CET. A daily job is enough:

```cron
5 17 * * 1-5 cd /path/to/fxboard/server && node src/ingest.js
```
