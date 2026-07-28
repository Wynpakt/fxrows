import { createHash } from "node:crypto";
import { createServer } from "node:http";
import {
  DEFAULT_PORT,
  RATE_LIMIT_MAX,
  RATE_LIMIT_WINDOW_MS,
} from "./constants.js";
import { createRateLimiter } from "./rate-limit.js";
import { ingest, readSnapshot } from "./snapshot.js";

/** @type {import('./snapshot.js').RateSnapshot | null} */
let cache = null;
let lastIngestAttempt = 0;
const INGEST_COOLDOWN_MS = 60 * 60 * 1000; // at most hourly auto-refresh

const limiter = createRateLimiter({
  windowMs: RATE_LIMIT_WINDOW_MS,
  max: RATE_LIMIT_MAX,
});

const SECURITY_HEADERS = {
  "X-Content-Type-Options": "nosniff",
  "X-Frame-Options": "DENY",
  "Referrer-Policy": "no-referrer",
  "Permissions-Policy": "geolocation=(), microphone=(), camera=()",
};

async function ensureSnapshot({ force = false } = {}) {
  if (!cache) {
    cache = await readSnapshot();
  }

  const now = Date.now();
  const stale =
    !cache ||
    force ||
    now - Date.parse(cache.fetched_at) > 20 * 60 * 60 * 1000;

  if (stale && now - lastIngestAttempt > INGEST_COOLDOWN_MS) {
    lastIngestAttempt = now;
    try {
      cache = await ingest();
    } catch (err) {
      if (!cache) throw err;
      console.error("Ingest failed, serving cached snapshot:", err.message);
    }
  }

  if (!cache) {
    throw new Error("No rate snapshot available");
  }
  return cache;
}

function etagFor(snapshot) {
  const body = JSON.stringify(snapshot);
  return `"${createHash("sha256").update(body).digest("hex").slice(0, 16)}"`;
}

function sendJson(res, status, body, extraHeaders = {}) {
  const payload = JSON.stringify(body);
  res.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "public, max-age=300",
    ...SECURITY_HEADERS,
    ...extraHeaders,
  });
  res.end(payload);
}

function notFound(res) {
  sendJson(res, 404, { error: "not_found" });
}

function clientIp(req) {
  const xf = req.headers["x-forwarded-for"];
  if (typeof xf === "string" && xf.length > 0) {
    return xf.split(",")[0].trim();
  }
  return req.socket.remoteAddress ?? "unknown";
}

async function handleLatest(req, res) {
  const snapshot = await ensureSnapshot();
  const etag = etagFor(snapshot);
  if (req.headers["if-none-match"] === etag) {
    res.writeHead(304, { ETag: etag, ...SECURITY_HEADERS });
    res.end();
    return;
  }
  sendJson(res, 200, snapshot, { ETag: etag });
}

async function handleHealth(_req, res) {
  let hasSnapshot = false;
  try {
    const snap = cache ?? (await readSnapshot());
    hasSnapshot = Boolean(snap);
    if (snap) cache = snap;
  } catch {
    hasSnapshot = false;
  }
  sendJson(res, hasSnapshot ? 200 : 503, {
    ok: hasSnapshot,
    has_snapshot: hasSnapshot,
    as_of: cache?.as_of ?? null,
  });
}

/**
 * @param {number} [port]
 * @param {{ cache?: import('./snapshot.js').RateSnapshot | null }} [opts]
 */
export function startServer(port = DEFAULT_PORT, opts = {}) {
  if (opts.cache !== undefined) {
    cache = opts.cache;
  }

  const server = createServer(async (req, res) => {
    try {
      const limited = limiter.check(clientIp(req));
      if (!limited.ok) {
        sendJson(
          res,
          429,
          { error: "rate_limited" },
          { "Retry-After": String(limited.retryAfterSec) },
        );
        return;
      }

      const url = new URL(req.url ?? "/", `http://${req.headers.host ?? "localhost"}`);
      if (req.method !== "GET") {
        sendJson(res, 405, { error: "method_not_allowed" });
        return;
      }
      if (url.pathname === "/v1/latest" || url.pathname === "/v1/latest/") {
        await handleLatest(req, res);
        return;
      }
      if (url.pathname === "/v1/health" || url.pathname === "/health") {
        await handleHealth(req, res);
        return;
      }
      notFound(res);
    } catch (err) {
      console.error(err);
      sendJson(res, 500, { error: "internal_error" });
    }
  });

  server.listen(port, () => {
    console.log(`fxrows-server listening on port ${port}`);
  });
  return server;
}

/** Reset in-memory cache (tests). */
export function __resetCacheForTests() {
  cache = null;
  lastIngestAttempt = 0;
}

import { pathToFileURL } from "node:url";

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const port = Number(process.env.PORT) || DEFAULT_PORT;
  ensureSnapshot().catch((err) => {
    console.warn("Initial ingest/load failed:", err.message);
  });
  startServer(port);
}
