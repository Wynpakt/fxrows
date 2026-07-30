# Design

## Overview

Product-register Material 3 app. One brand accent (deep forest green), IBM Plex
for UI and tabular amounts, dense currency rows. No marketing hero, no
decorative card grids.

## Publisher

**Wynpakt LLC** — House of Brands. Visual identity is product-local (this file).
Shared publisher rules (attribution, craft bar, PRODUCT.md/DESIGN.md convention):
ki-os skill `wynpakt-design` / `context/wynpakt-design.md`.
Do not apply Wynpakt.com Inter/teal tokens here.

## Colors

| Token | Light | Dark | Role |
|-------|-------|------|------|
| Seed / primary | `#1B4D3E` | derived M3 | Brand, FAB, selected |
| Surface | M3 from seed | M3 from seed | Canvas |
| On-surface | off-black via M3 | off-white via M3 | Body |
| Error | M3 error | M3 error | Banners |

**The One Accent Rule.** Primary green appears on ≤10% of any screen (FAB,
focus, selected settings row). Rarity is the point.

**The No Pure Extremes Rule.** Prefer M3 surfaces over raw `#000` / `#FFF`.

## Typography

- **UI:** IBM Plex Sans (Regular 400, Medium 500, SemiBold 600), **bundled** in
  `app/assets/fonts/` (no runtime CDN fetch)
- **Amounts:** IBM Plex Mono with `FontFeature.tabularFigures()`
- Product scale ~1.2 between steps; amounts use `headlineSmall` weight 500

**The Tabular Amounts Rule.** Converted values always use mono + tabular nums
so columns do not dance while typing.

## Elevation

Hairline / surface tint before shadow. Currency rows: elevation 0, soft
`surfaceContainerHighest` fill. Active (editing) row: 1.5px primary outline +
slightly stronger surface tint. Card radius ≤12.

## Components

- **Currency row:** drag handle (reorder) + code (semibold) + borderless amount
  field + optional actions; order persists on device
- **FAB:** add currency (primary)
- **Error banner:** dismissible MaterialBanner + Retry; human copy only
- **Status strip:** one compact line (source · as-of · count); legal detail in Settings
- **Settings:** grouped list; radio selection via selected ListTile; AppBar always present

## Do's and Don'ts

**Do**

- Highlight the active pivot row clearly
- Mark offline/dummy fallback rates in status
- Keep legal/disclaimer readable but secondary
- Flag emoji decorative beside the ISO code for quick scan; code stays the semantic label

**Don't**

- Rely on flag emoji alone without a readable currency code
- Em-dashes (`—`) or en-dashes (`–`) in visible UI copy
- Inter/Roboto/Open Sans by reflex
- Side-stripe accent borders, ghost-cards, or ≥24px radii
- Raw `e.toString()` in banners
