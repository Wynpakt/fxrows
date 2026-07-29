# Product

## Register

product

## Users

Travelers, freelancers, and anyone comparing several currencies at once on a phone
or desktop. Context: quick glance between tasks (cafe, desk, transit), not a
trading terminal.

## Product Purpose

fxrows is a multi-currency converter grid: change one amount and every other
row updates via cross-rates. Default rates come from Frankfurter (open-source
central-bank aggregation) and are cached on-device; Advanced offers ECB direct
or optional BYO commercial API keys (on-device only). Success is fast,
trustworthy conversion with clear source attribution and no dark patterns.

## Brand Personality

Calm, precise, spare. Quiet confidence over spectacle. Numbers first.

## Anti-references

- Navy-and-gold “fintech premium” dashboards
- Purple/cyan AI-SaaS converter landings
- Emoji-only currency pickers without ISO codes, and decorative card stacks
- Busy banking apps with metric theater and fake live tickers

## Design Principles

1. **One job per screen.** Convert is amounts; Settings is sources and keys.
2. **Numbers earn the hierarchy.** Amounts dominate; chrome stays quiet.
3. **Source honesty.** Always show where rates came from and when; never hide fallbacks.
4. **On-device trust.** BYO keys never leave the device; default Frankfurter path
   talks to `api.frankfurter.dev` (may use Cloudflare); Advanced ECB talks only
   to the ECB.
5. **Earned familiarity.** Material product patterns users already know; craft in
   type, spacing, and states, not novelty chrome.

## Accessibility & Inclusion

Target WCAG AA contrast for text and interactive states. Touch targets ≥44×44.
Respect reduced motion. Do not rely on color or emoji alone for meaning.
Keyboard/TalkBack: amount fields and currency codes must have clear labels.
