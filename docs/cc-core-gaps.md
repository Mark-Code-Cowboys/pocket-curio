# cc_core gaps & new-generic candidates (tracked from Pocket Curio)

Standing rule: cc_core gaps get fixed in cc_core, not worked around here.
This file is the running ledger of what Pocket Curio needs from core.
Updated per phase; items move to "Done" when they land in a tagged cc_core.

Baseline: cc_core v0.10.0 (pinned from Phase F; 0.9.0 for E, 0.8.0 for C–D, 0.6.1 through Phase B).
Implemented modules: `paywall/` (complete, incl. `LifetimeTally` since
0.7.0), `io/` (cloud backup, legacy Android prefs, CSV import), `text/`
(fuzzy match, number format), `scan/` + `notebook_import/` (document
scan + OCR + batch review, since 0.8.0). Empty barrels: `journal/`,
`trends/`, `onboarding/`, `theme/`.

## Empty modules this app needs, by phase

| Phase | Needs | cc_core module | Status |
| --- | --- | --- | --- |
| A | Item as a journal entry (photo IS the record; rating, notes, opt-in lat/lon) | `journal/` | empty — extraction from Table Encore not done (factory Phase 4). **Phase A decision:** `items` is an app-local Drift table carrying photoPath/rating/notes/lat/lng itself, same as Course Ledger; when `journal/` lands, migrate those columns to a core entry row keyed by item id |
| D | Item photo → place-name transcription → confirm (auto-runs on composer photo) | `scan/` | **done on 0.8.0** — `TextRecognitionService` + `OcrLine`; the per-app parser is `readPlace` (tallest line wins, every line offered verbatim) |
| D | Shelf/fridge batch scan: one photo → crops → review grid → bulk insert | `notebook_import/` | **built app-side** as guided crop (user boxes each souvenir); `notebook_import`'s page-at-a-time `BatchReviewScreen` is list-shaped, the souvenir review needs a photo grid, so this app owns `GuidedCropScreen`, `PhotoCropper`, `ShelfReviewScreen` |
| E | World/US fill map by item places + opt-in pins; counters (countries, states, items/yr, oldest) | `trends/` | **done on 0.9.0** — `RegionTileGrid` + `usStateTiles` for the States, a 7-tile continent strip in-app, `YearlyBars`. Pins deferred: a tile cartogram has nowhere to pin, and lat/lng capture needs a location permission — revisit with a real map if the app ever earns one |
| E | Export/backup archive behind entitlement, round-trip test | `io/` | **done on 0.9.0** — `buildBackupArchive`/`readBackupArchive`, `buildCsv`, `ShareLauncher`; app owns the format-1 JSON, photo media by base name, and `PhotoStore.write` for restore |
| F | First-run flow (place+memory framing, fridge-scan fork), consent screen | `onboarding/` | **done on 0.10.0** — `FirstRunFlag` + `OnboardingScaffold`; the fork here pushes the collection composer (now pops its id) then lands on the shelf with `ShelfStart` already chosen |
| 0 | Base theme from per-app tokens (`CcThemeTokens`) | `theme/` | empty — `lib/core/theme/app_theme.dart` here is the third hand copy of Table Encore's `AppTheme` shape (Course Ledger is the second); third copy = extract |

## New generic candidates surfaced by this app

- **Geo normalizer** (`text/` or `trends/`): `normalizeState` (US codes +
  full names), `normalizeCountry` (ISO2 from ~70 names/aliases, US
  implied by a US state), `continentOf`, `countryName`. Course Ledger's
  played map only fills states typed as codes; Hitch Post and Loadbook
  will type the same free text. Table lives in `lib/core/utils/geo.dart`.
- **Continent strip** (`trends/`): the 7-tile world cartogram beside
  `usStateTiles` — a `worldContinentTiles` const belongs next to it.

- **PhotoStore + PhotoCapture** (`journal/` or a new `photos/`): Pocket
  Curio is the first CC app with camera capture. `lib/core/photos/` holds
  an app-private store (relative paths under the documents dir so iOS
  container moves don't break rows; import/resolve/delete) and a
  `PhotoCapture` seam over image_picker with a test fake. Every
  photo-first CC app (Course Ledger's round photos, Table Encore's dishes)
  wants exactly this; second consumer = extract. Note: the store does its
  IO synchronously behind a Future API on purpose — dart:io futures never
  resolve inside flutter_test's fake-async zone, and one ≤2048px JPEG
  copies in milliseconds.
- **Lazy-list widget-test lessons** (core test docs): one-shot reads must
  be `get()`, never `watch().first` (stalls under the widget-test zone);
  screens under test go above a blank root route so self-popping
  composers don't empty the Navigator; ListView children below the fold
  aren't built in the 800×600 test viewport. Course Ledger will hit all
  three the moment it wires photos.

- **Coverage map widget** (`trends/`): Phase E "map fill" — region fill
  (states/countries) + optional pins. Course Ledger's "played map" is the
  same widget; Hitch Post and Loadbook will want it too. The GOT map code
  is the seed.
- **Guided crop** (`scan/`): `GuidedCropScreen` (drag boxes on one photo,
  tap to remove, normalized rects out) + `PhotoCropper` (dart:ui decode →
  drawImageRect → PNG, no image-processing dependency) are generic
  capture UX — any "one photo, many things" flow. Shipped here first;
  automatic scene splitting deferred until the app has users. Test
  lesson: drive the drag with `tester.dragFrom`, and record the box
  corner on `onPanDown` — `onPanStart` fires ~18px past the finger.
- **Photo-grid batch review** (`notebook_import/`): `BatchReviewScreen`
  is a list; photo-first apps want a grid of thumbnails with one field
  each. `ShelfReviewScreen` is the shape. Extract when a second app wants
  it.
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
  same ask as Course Ledger; one blessed pattern in core. New wrinkle
  here: photo-first seeds need photo *files*, so `seedDemoData` takes a
  `DemoPhotoPainter` (dart:ui renders a labeled tile; tests inject a
  byte fake). A core `renderPlaceholderPhoto(label, color)` would serve
  Course Ledger's round photos too.
- **Launcher-icon art script**: `tool/make_icon.py` (PIL) draws the
  icon + adaptive foreground from a few shapes and brand colors; the
  same script with a different glyph function would stamp every CC app.

## Done

- **Lifetime free-tier tally** — `LifetimeTally` (cc_core 0.7.0). Pocket
  Curio is its third consumer, with two tallies per install
  (`collections_created_lifetime`, `items_created_lifetime`). Lesson for
  the docs: a batch insert must `raiseTo(value + n)` once, not call
  `recordCreated` per row — the per-call floor at the live count double
  counts.
