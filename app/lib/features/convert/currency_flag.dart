/// Currency display helpers (ISO 4217 codes). No emoji flags (a11y / anti-slop).
library;

String currencyLabel(String code) => code.toUpperCase();
