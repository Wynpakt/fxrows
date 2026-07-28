/**
 * Tiny in-memory IP rate limiter (no deps).
 * @param {{ windowMs: number, max: number }} opts
 */
export function createRateLimiter({ windowMs, max }) {
  /** @type {Map<string, { count: number, resetAt: number }>} */
  const buckets = new Map();

  function prune(now) {
    if (buckets.size < 500) return;
    for (const [ip, b] of buckets) {
      if (b.resetAt <= now) buckets.delete(ip);
    }
  }

  /**
   * @param {string} ip
   * @returns {{ ok: true } | { ok: false, retryAfterSec: number }}
   */
  function check(ip) {
    const now = Date.now();
    prune(now);
    const key = ip || "unknown";
    let b = buckets.get(key);
    if (!b || b.resetAt <= now) {
      b = { count: 0, resetAt: now + windowMs };
      buckets.set(key, b);
    }
    b.count += 1;
    if (b.count > max) {
      return {
        ok: false,
        retryAfterSec: Math.max(1, Math.ceil((b.resetAt - now) / 1000)),
      };
    }
    return { ok: true };
  }

  return { check, _buckets: buckets };
}
