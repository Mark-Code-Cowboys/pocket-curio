# Pocket Curio — Release checklist

Work top to bottom; nothing ships with an unchecked box above it.

## Code

- [x] `pubspec.yaml` version bumped (`1.0.0+1` for the first release)
- [x] cc_core pinned to a **pushed** tag (`v0.21.2`, on origin).
      `pubspec_overrides.yaml` is git-ignored and must NOT influence the
      release build — `pubspec.lock` now records the git ref, not the
      `../CC_Core` path (2026-09-08; a `flutter pub get` on a clean
      checkout resolves)
- [x] `flutter analyze` — zero issues (2026-09-08)
- [x] `flutter test` — all green (95 on 2026-09-08)
- [x] `dart run flutter_launcher_icons` output committed (android/ios)
- [x] `flutter build apk --release` compiles (native config for ML Kit,
      share_plus, file_selector, image_picker verified — Phase G; rebuilt
      2026-09-08 with the DEMO_SEED define for the screenshots)
- [x] `flutter build appbundle --release` compiles (2026-09-08, debug-key
      fallback — see Build & upload)

## On-device (Pixel), release build

- [ ] `flutter run --release` cold start < 2s, no red screens
- [ ] Onboarding shows once; each fork works: scan → names the shelf →
      scan sheet; photograph → names the shelf → camera; look around →
      shell. Kill/relaunch skips it
- [ ] Composer: camera opens on arrival; a printed souvenir prefills
      Place with the note; chips show the other lines; typing clears the
      note; two-field save in under 10 seconds
- [ ] Add 25 souvenirs (or seed 24 + one real) → the 26th opens the
      paywall; delete one → still gated (lifetime tally); second
      collection → paywall
- [ ] Shelf scan of a real fridge: boxes land where the finger touches,
      tap removes, crops read, review grid edits, bulk add lands; back
      out at each step leaves no rows and no files (check the photos
      folder size)
- [ ] Sandbox purchase lifetime → gate lifts, counter gone, Map live
- [ ] Restore purchase after reinstall
- [ ] Backup → share to Drive → wipe app data → restore → collections,
      photos, and both free-tier tallies intact; covers still resolve
- [ ] Map: a souvenir typed "Florida" / "usa" / "England" lights FL,
      US, GB; an unknown country still counts in the chips
- [ ] DEMO_SEED build only for screenshots — never the uploaded AAB
- [ ] Dark theme spot-check: home, shelf, detail, composer, crop screen,
      review grid, paywall, map (home, shelf, detail, composer, scan
      sheet, map checked on the Pixel 7 emulator 2026-09-08; crop, review,
      paywall still to eyeball on the phone)
- [x] iOS lane (Codemagic): `ios-release` builds, signs, and uploads to
      TestFlight; triggers on `v*` tags (first: `v1.0.0+2`, build 2,
      2026-09-08). Every upload needs a `+N` bump in pubspec.yaml — App
      Store Connect rejects a repeated build number. Exempt-encryption
      key is in Info.plist so the compliance prompt is gone
- [ ] On the iPhone (TestFlight build 2): camera and photo-library
      prompts show the plist copy; paywall shows prices once the IAPs
      exist in App Store Connect; sandbox purchase + restore

## Store

- [ ] Privacy policy live at pocketcurio.app/privacy/ (source:
      `docs/privacy-policy.md`; code-cowboys.com/privacy/pocketcurio
      already redirects there)
- [x] pocketcurio.app serves /, /help/, /faq/, /user-guide/, /privacy/ —
      the Help & about screen links to them (`lib/core/links.dart`); all
      five answered 200 on 2026-09-08
- [x] Listing fields pasted from `docs/play-store-listing.md` (Play Console,
      2026-09-08: name, short + full description, icon, feature graphic,
      7 phone + 4 tablet shots in both tablet slots; category Lifestyle;
      contact hello@code-cowboys.com / pocketcurio.app)
- [x] Screenshots captured per the listing doc (shot 01 is the real
      Fridge Magnets shelf off the Pixel; 02–07 DEMO_SEED on the Pixel 7
      emulator, 2026-09-08) → `docs/store-assets/raw/`; captioned and
      sized store sets built by `python3 tool/make_store_assets.py`
- [ ] Re-shoot `03-shelf-scan` (and `07-shelf-review`) with a **real**
      fridge photo from the Pixel — the current one is a rendered
      stand-in (`tool/make_store_assets.py` docstring). Optional, but
      it's the honest shot
- [x] Feature graphic + 512 store icon exported (`docs/store-assets/`)
- [x] App Store Connect: 6.5" iPhone set (7) + 13" iPad set (4) uploaded
      one file at a time so the order holds (a multi-file drop lands in
      upload-completion order); all listing copy, review contact, privacy
      (Data Not Collected), age rating 4+, free price, 175 countries
      (2026-09-10)
- [ ] Play products created per `docs/play-monetization-setup.md`, Active
      (still open on 2026-09-10 — the two products are the last Play step)
- [x] App Store IAPs: `pocketcurio_pro_lifetime` $6.99 non-consumable and
      `pocketcurio_pro_monthly` $1.49 in group "Pocket Curio Pro"; each
      needs a review screenshot at an iPhone size — 1284×2778 of the
      paywall (`docs/store-assets/app-store/iap-review-paywall.png`, from
      a non-DEMO_SEED build on the Pixel 7 AVD; the demo build runs as
      Pro and never shows the paywall). Submitted with the version
      (2026-09-10)
- [x] Data safety form matches the privacy policy (no data collected /
      shared; saved 2026-09-08). Also done: content rating (IARC, all
      ages), target audience 18+, ads none, ad ID no, sign-in details
      (IAP-only restriction + reviewer instructions), government /
      financial / health none

## Build & upload

- [x] `android/key.properties` + keystore in place (never committed;
      template in `android/key.properties.example`). Upload key generated
      2026-09-08: `~/keystores/pocketcurio-upload.jks`, alias `upload`,
      CN=Code Cowboys LLC, valid to 2054 — **back up the .jks and the
      password outside this machine**. Without them the release build
      signs with the **debug** key and prints a WARNING — Play rejects
      that bundle, so the warning is the tell
- [x] `flutter build appbundle --release` — signed with the upload key
      (2026-09-08, signer SHA-256 verified against the keystore)
- [x] Internal testing release (version code 1, 2026-09-08)
- [x] Production: version code 1 promoted from internal testing and sent
      for review with 176 countries + rest of world (2026-09-10). Version
      code 2 (the `+2` bump) exists only locally — the 76 MB AAB can't go
      through the browser tool, so the vc1 bundle (built after the last
      Android code change, c1026e4) ships
- [x] App Store: version 1.0 (build 2) + both IAPs + the subscription
      group submitted for review (2026-09-10). Contact phone/email match
      Table Encore's review record

## Post-launch

- [ ] Tag the app repo `v1.0.0`
- [ ] Note any cc_core friction found during release in
      `docs/cc-core-gaps.md`
- [ ] Backlog (all "if it ever has more than one install"): automatic
      scene splitting for the shelf scan, map pins with a real map and a
      location permission, a photo-grid batch review in cc_core, the geo
      normalizer and continent strip into cc_core
