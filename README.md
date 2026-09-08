# Pocket Curio

A Code Cowboys souvenir collection journal. Not an inventory app. No
barcodes, no value estimates, no marketplace. A souvenir is a place + a
memory — photograph it, name the place, and watch the map fill in.

- Package id: `com.codecowboys.pocketcurio` · Domain: mypocketcurio.app
- Privacy-first, local-only (Drift/sqlite), no accounts, no analytics.
- Built on [`cc_core`](https://github.com/Mark-Code-Cowboys/cc_core)
  pinned by tag; local iteration via git-ignored `pubspec_overrides.yaml`
  (`path: ../CC_Core`).

## Building

- SDK: `~/sdks/flutter` (3.44.9 / Dart 3.12.2), the same local SDK every
  CC app uses. `/usr/bin/flutter` is a stale snapshot — don't use it.
- `flutter run --dart-define=DEMO_SEED=true` plants two collections and
  30 souvenirs with placeholder photos for screenshots (no-op on a
  non-empty phone).
- Icons: `python3 tool/make_icon.py && dart run flutter_launcher_icons`.
- Store graphics (icons, feature graphic, captioned screenshots in every
  Play / App Store size): `python3 tool/make_store_assets.py` from the
  raw shots in `docs/store-assets/raw/`.
- Release signing: copy `android/key.properties.example` to
  `android/key.properties` (git-ignored). Without it a release build
  signs with the debug key and says so.

## Docs

- [`docs/release-checklist.md`](docs/release-checklist.md) — ship order.
- [`docs/play-store-listing.md`](docs/play-store-listing.md) — listing
  copy, keywords, screenshot plan.
- [`docs/play-monetization-setup.md`](docs/play-monetization-setup.md) —
  products `pocketcurio_pro_lifetime` / `pocketcurio_pro_monthly`.
- [`docs/privacy-policy.md`](docs/privacy-policy.md) — source for
  code-cowboys.com/privacy/pocketcurio.
- [`docs/cc-core-gaps.md`](docs/cc-core-gaps.md) — what this app needed
  from core, what landed, and what to extract next.
