import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname } from "node:path";
import { fileURLToPath } from "node:url";
import {
  ATTRIBUTION,
  DISCLAIMER,
  ECB_DAILY_URL,
  SNAPSHOT_PATH,
} from "./constants.js";
import { parseEcbDailyXml } from "./parse-ecb.js";

/**
 * @typedef {object} RateSnapshot
 * @property {string} base
 * @property {string} as_of
 * @property {string} fetched_at
 * @property {string} source
 * @property {string} attribution
 * @property {string} disclaimer
 * @property {Record<string, number>} rates
 */

/**
 * @returns {Promise<RateSnapshot>}
 */
export async function fetchAndBuildSnapshot() {
  const res = await fetch(ECB_DAILY_URL, {
    headers: { "User-Agent": "fxrows-server/0.1 (+https://github.com/Wynpakt/fxrows)" },
  });
  if (!res.ok) {
    throw new Error(`ECB fetch failed: HTTP ${res.status}`);
  }
  const xml = await res.text();
  const { asOf, rates } = parseEcbDailyXml(xml);

  return {
    base: "EUR",
    as_of: asOf,
    fetched_at: new Date().toISOString(),
    source: "ECB",
    attribution: ATTRIBUTION,
    disclaimer: DISCLAIMER,
    rates,
  };
}

/**
 * @param {RateSnapshot} snapshot
 */
export async function writeSnapshot(snapshot) {
  const path = fileURLToPath(SNAPSHOT_PATH);
  await mkdir(dirname(path), { recursive: true });
  await writeFile(path, JSON.stringify(snapshot, null, 2) + "\n", "utf8");
}

/**
 * @returns {Promise<RateSnapshot | null>}
 */
export async function readSnapshot() {
  try {
    const raw = await readFile(fileURLToPath(SNAPSHOT_PATH), "utf8");
    return JSON.parse(raw);
  } catch (err) {
    if (err && err.code === "ENOENT") return null;
    throw err;
  }
}

/**
 * Fetch ECB rates and persist snapshot. Returns the snapshot.
 * @returns {Promise<RateSnapshot>}
 */
export async function ingest() {
  const snapshot = await fetchAndBuildSnapshot();
  await writeSnapshot(snapshot);
  return snapshot;
}
