/**
 * Parse ECB eurofxref-daily.xml into a normalized snapshot.
 * Rates are quoted as EUR → currency (units of foreign currency per 1 EUR).
 * EUR itself is always 1.
 */

/**
 * @param {string} xml
 * @returns {{ asOf: string, rates: Record<string, number> }}
 */
export function parseEcbDailyXml(xml) {
  const timeMatch = xml.match(/time=["'](\d{4}-\d{2}-\d{2})["']/);
  if (!timeMatch) {
    throw new Error("ECB XML: missing Cube time attribute");
  }

  const rates = { EUR: 1 };
  const cubeRe = /currency=["']([A-Z]{3})["']\s+rate=["']([0-9.]+)["']/g;
  let m;
  while ((m = cubeRe.exec(xml)) !== null) {
    const code = m[1];
    const rate = Number(m[2]);
    if (!Number.isFinite(rate) || rate <= 0) {
      throw new Error(`ECB XML: invalid rate for ${code}`);
    }
    rates[code] = rate;
  }

  if (Object.keys(rates).length < 2) {
    throw new Error("ECB XML: no currency rates found");
  }

  return { asOf: timeMatch[1], rates };
}
