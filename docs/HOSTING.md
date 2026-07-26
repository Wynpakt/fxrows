# Aggregation server hosting

The fxboard **aggregation server** runs as a Docker container on a VPS.
The Flutter app is **not** Dockerized: it ships as platform builds
(Android / iOS / desktop).

## Image

| Service | Path | Image |
| --- | --- | --- |
| Aggregation API | `server/` | `ghcr.io/goddib/fxboard-server` |

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
    image: ghcr.io/goddib/fxboard-server:latest
    restart: unless-stopped
    ports:
      - "8787:8787"
    volumes:
      - ./data:/app/data
```

First pull may require `docker login ghcr.io` if the package is private.
Make the GHCR package public, or authenticate the VPS once.

## Local development

For day-to-day work without Docker, see [self-host.md](self-host.md)
(`npm start` on Node 20+).
