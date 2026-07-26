/** Shared constants for fxboard aggregation server. */

export const ECB_DAILY_URL =
  "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml";

export const ATTRIBUTION =
  "Source: European Central Bank (ECB) euro foreign exchange reference rates.";

export const DISCLAIMER =
  "Rates are published for information purposes only. Using them for transaction purposes is strongly discouraged.";

export const DEFAULT_PORT = 8787;

export const SNAPSHOT_PATH = new URL("../data/latest.json", import.meta.url);
