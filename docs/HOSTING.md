# Aggregation server hosting

The **fxrows** aggregation server runs as a Docker container on a VPS.
The Flutter app is **not** Dockerized: it ships as platform builds
(Android / iOS / desktop).

## Image

| Service | Path | Image |
| --- | --- | --- |
| Aggregation API | `server/` | `ghcr.io/wynpakt/fxrows-server` |

## Hard rules

1. **One service = one image.** `server/` has its own `Dockerfile` and is
   deployable alone.
2. **CI builds images; the VPS never does.** On push to `main` that touches
   `server/**` (or via `workflow_dispatch`), GitHub Actions builds and pushes
   to **GHCR**. Tags: git `sha` and `latest`.
3. **Update on the VPS** is pull-only:

   ```bash
   docker compose pull server
   docker compose up -d server
   ```

4. **Secrets stay out of images.** None are required for the ECB aggregator
   today; future credentials belong in Compose/runtime env only.
5. **TLS / reverse proxy** (Caddy, Traefik, nginx) lives on the VPS outside the
   app image. The container listens on HTTP `:8787`; the proxy terminates
   HTTPS and routes by hostname.

   **Proxy checklist (required in production):**
   - Terminate TLS; do not expose `:8787` on the public internet without TLS
   - Forward `X-Forwarded-For` (or equivalent) so the app rate limiter sees the client IP
   - Optionally add proxy-level rate limits in addition to the app’s soft limit
     (`120` req/min/IP on `/v1/*`)
   - Prefer proxy headers for `X-Content-Type-Options`, `X-Frame-Options` /
     `frame-ancestors`, and `Referrer-Policy` if you strip upstream headers;
     the Node app also sets these on JSON responses
   - Health check: `GET /v1/health` (expect `ok` + `has_snapshot`)

6. **Persistent cache** is a host volume (`./data` → `/app/data`), not baked
   into the image.

## Operator loop

```text
git push (server/**) → GitHub Actions → GHCR image
                                    ↓
                       VPS: compose pull && up -d
                                    ↓
                       Reverse proxy → :8787
```

## Compose sketch (VPS)

Copy [`server/compose.example.yml`](../server/compose.example.yml) to the VPS
as `compose.yml` (adjust ports/networks for your proxy):

```yaml
services:
  server:
    image: ghcr.io/wynpakt/fxrows-server:latest
    restart: unless-stopped
    ports:
      - "8787:8787"
    volumes:
      - ./data:/app/data
```

The image runs as user `node` (UID/GID **1000**). A host bind mount
(`./data`) created as root will cause `EACCES` on `/app/data/latest.json`.
Fix once after first `up`:

```bash
sudo chown -R 1000:1000 ./data
docker compose restart server
curl -sS https://fxrows.wynpakt.com/v1/health   # expect ok + has_snapshot
```

First pull may require `docker login ghcr.io` if the package is private.
Make the GHCR package public, or authenticate the VPS once.

## Production URL

Public instance: `https://fxrows.wynpakt.com`  
Health: `GET /v1/health` · Rates: `GET /v1/latest`

## Local development

For day-to-day work without Docker, see [self-host.md](self-host.md)
(`npm start` on Node 20+).
