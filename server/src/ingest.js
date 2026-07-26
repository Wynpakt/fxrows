#!/usr/bin/env node
import { ingest } from "./snapshot.js";

const snapshot = await ingest();
console.log(
  `Ingested ${Object.keys(snapshot.rates).length} rates (as_of=${snapshot.as_of})`,
);
