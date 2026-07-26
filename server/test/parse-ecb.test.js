import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { parseEcbDailyXml } from "../src/parse-ecb.js";

const SAMPLE = `<?xml version="1.0" encoding="UTF-8"?>
<gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" xmlns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref">
  <gesmes:subject>Reference rates</gesmes:subject>
  <Cube>
    <Cube time="2026-07-24">
      <Cube currency="USD" rate="1.1377"/>
      <Cube currency="GBP" rate="0.8539"/>
      <Cube currency="CHF" rate="0.9302"/>
    </Cube>
  </Cube>
</gesmes:Envelope>`;

describe("parseEcbDailyXml", () => {
  it("parses date and rates including EUR=1", () => {
    const { asOf, rates } = parseEcbDailyXml(SAMPLE);
    assert.equal(asOf, "2026-07-24");
    assert.equal(rates.EUR, 1);
    assert.equal(rates.USD, 1.1377);
    assert.equal(rates.GBP, 0.8539);
    assert.equal(rates.CHF, 0.9302);
  });

  it("rejects missing time", () => {
    assert.throws(() => parseEcbDailyXml("<Cube currency='USD' rate='1'/>"), /missing Cube time/);
  });
});
