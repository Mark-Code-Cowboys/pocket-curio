# Pocket Curio — Release checklist

Work top to bottom; nothing ships with an unchecked box above it.

## Code

- [x] `pubspec.yaml` version bumped (`1.0.0+1` for the first release)
- [ ] cc_core pinned to a **pushed** tag (currently `v0.10.0`; the local
      checkout only has tags through v0.6.1 — push `v0.7.0`…`v0.10.0`
      first). `pubspec_overrides.yaml` is git-ignored and must NOT
      influence the release build: `flutter pub get` on a clean checkout
      resolves
- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` — all green (91 at Phase G)
- [ ] `dart run flutter_launcher_icons` output committed (android/ios)
- [ ] `flutter build apk --release` compiles (native config for ML Kit,
      share_plus, file_selector, image_picker verified — Phase G)

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
      review grid, paywall, map
- [ ] iOS lane (Codemagic, later): deployment target is already 15.5
      in the Xcode project and `ios/Podfile` (`google_mlkit_text_recognition`
      requires it); run `pod install` there, then confirm the camera and
      photo-library prompts show the plist copy

## Store

- [ ] Privacy policy live at code-cowboys.com/privacy/pocketcurio
      (source: `docs/privacy-policy.md`)
- [ ] Listing fields pasted from `docs/play-store-listing.md`
- [ ] 6 screenshots captured per the listing doc (DEMO_SEED, plus one
      real fridge photo for the crop screen)
- [ ] Feature graphic + 512 store icon exported
- [ ] Products created per `docs/play-monetization-setup.md`, Active
- [ ] Data safety form matches the privacy policy

## Build & upload

- [ ] `android/key.properties` + keystore in place (never committed)
- [ ] `flutter build appbundle --release`
- [ ] Internal testing release; license testers verify purchases and
      the batch-scan gate
- [ ] Promote to closed → production when the boxes above are checked

## Post-launch

- [ ] Tag the app repo `v1.0.0`
- [ ] Note any cc_core friction found during release in
      `docs/cc-core-gaps.md`
- [ ] Backlog (all "if it ever has more than one install"): automatic
      scene splitting for the shelf scan, map pins with a real map and a
      location permission, a photo-grid batch review in cc_core, the geo
      normalizer and continent strip into cc_core
