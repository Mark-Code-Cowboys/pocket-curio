# cc_core gaps & new-generic candidates (tracked from Pocket Curio)

Standing rule: cc_core gaps get fixed in cc_core, not worked around here.
This file is the running ledger of what Pocket Curio needs from core.
Updated per phase; items move to "Done" when they land in a tagged cc_core.

Baseline: cc_core v0.6.1. Implemented modules: `paywall/` (complete),
`io/` (cloud backup + legacy Android prefs only), `text/` (fuzzy match,
number format). Empty barrels: `journal/`, `trends/`, `onboarding/`,
`theme/`, `scan/`, `notebook_import/`.

## Empty modules this app needs, by phase

| Phase | Needs | cc_core module | Status |
| --- | --- | --- | --- |
| A | Item as a journal entry (photo IS the record; rating, notes, opt-in lat/lon) | `journal/` | empty — extraction from Table Encore not done (factory Phase 4) |
| D | Item photo → place-name transcription → confirm (auto-runs on composer photo) | `scan/` | empty (factory Phase 5) |
| D | Shelf/fridge batch scan: one photo → detected items split to crops → review grid → bulk insert | `notebook_import/` | empty (factory Phase 5); whole-scene splitting is new — `notebook_import` assumes one item per page |
| E | World/US fill map by item places + opt-in pins; counters (countries, states, items/yr, oldest) | `trends/` | empty (factory Phase 4) |
| E | Export/backup archive behind entitlement, round-trip test | `io/` | README promises CSV/JSON export + zip backup/restore, but only cloud backup is coded (factory Phase 3 partially shipped) |
| F | First-run flow (place+memory framing, fridge-scan fork), consent screen | `onboarding/` | empty (factory Phase 6) |
| 0 | Base theme from per-app tokens (`CcThemeTokens`) | `theme/` | empty — `lib/core/theme/app_theme.dart` here is the third hand copy of Table Encore's `AppTheme` shape (Course Ledger is the second); third copy = extract |

## New generic candidates surfaced by this app

- **Coverage map widget** (`trends/`): Phase E "map fill" — region fill
  (states/countries) + optional pins. Course Ledger's "played map" is the
  same widget; Hitch Post and Loadbook will want it too. The GOT map code
  is the seed.
- **Scene splitter** (`scan/`): one photo of many objects → N crops.
  Batch flavor beyond `notebook_import`'s page-at-a-time model. If the
  automatic split proves unreliable, the guided-crop fallback (user draws
  boxes, extraction per box) is itself generic capture UX.
- **Place-name field extraction schema** (`scan/`): the per-app schema
  here is a single `place` string transcribed from what's printed on the
  object. Smallest possible scan schema; a good first-consumer test.
- **Count headline** (`trends/` or `text/`): "31 items · 12 states ·
  4 countries" — same generic multi-count stat headline Course Ledger
  flagged.
- **Multi-collection per install**: Pocket Curio is the first CC app where
  one install serves a household (keychain collector + magnet collector).
  If `journal/` lands with a single implicit journal, it needs a
  collection/journal-id scope on entries.
- **DEMO_SEED seam**: `--dart-define=DEMO_SEED` screenshot-data hook —
  same ask as Course Ledger; one blessed pattern in core.

## Done

(nothing yet)
