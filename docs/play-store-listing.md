# Pocket Curio — Google Play Store Listing

Copy-paste source for the Play Console listing. Character limits noted
per field; counts verified at draft time (2026-09-05).

---

## App name (max 30 chars)

> Pocket Curio: Souvenir Journal

(29 chars. Alternatives: "Pocket Curio" alone (12); "Pocket Curio:
Souvenir Tracker" (30) — keyword-exact but "tracker" reads like
inventory, which we are not.)

## Short description (max 80 chars)

> A souvenir is a place + a memory. Photograph the shelf, watch the map fill in.

(79 chars — the framing line IS the pitch.)

## Full description (max 4000 chars)

> **A souvenir is a place + a memory.**
>
> Pocket Curio is the shelf you can carry. Photograph each keychain,
> fridge magnet, shot glass, or patch, name where it's from, and keep
> the story that came home with it — who gave it to you, the trip, the
> day. Then watch the map fill in.
>
> **Not an inventory app.** No barcodes. No value estimates. No
> marketplace. A souvenir isn't stock — it's the place you stood.
>
> **Camera first**
> Open the app, take the photo, type the place. That's the whole first
> step — under ten seconds. The camera even reads what's printed on the
> souvenir and fills the place in for you to check. The memory can come
> later, when it comes back to you.
>
> **Already have a fridge full?**
> Take one photo of the whole fridge or shelf, box each souvenir with
> your finger, and Pocket Curio turns every box into its own photo,
> reads the place name off it, and adds them all at once. Forty magnets
> in a few minutes.
>
> **Your collections**
> One phone, the whole household: the keychain collector and the
> fridge-magnet collector each get their own shelf. Photo grids that
> look like the real thing, sorted by date or by place.
>
> **The map (Pro)**
> Every state and country your souvenirs came from, lit up one place
> at a time. Souvenirs by year. The oldest one you own. Plus a full
> backup and CSV export, because the collection is yours to keep.
>
> **Private by construction**
> No account. No cloud. No analytics. Everything — photos included —
> stays on your phone; reading the print on a souvenir happens
> on-device. Your first collection and your first 25 souvenirs are free
> forever. Pocket Curio Pro is one purchase (it makes a good gift) or
> month to month.
>
> The shelf is yours. We never see it.

## Keywords (App Store keyword field; woven into Play description above)

souvenir tracker, keychain collection, fridge magnet collection, travel
keepsake journal, souvenir journal, magnet collector, shot glass
collection, places visited map

## Category

Lifestyle (secondary consideration: Travel & Local)

## Privacy policy URL

https://pocketcurio.app/privacy/
(Source text: `docs/privacy-policy.md` — publish before submission. The
Code Cowboys site already redirects code-cowboys.com/privacy/pocketcurio
here.)

## Site pages the app links to (Help & about screen)

`lib/core/links.dart` — live (checked 2026-09-08), same layout as
tableencore.app:

- https://pocketcurio.app/ · https://pocketcurio.app/help/ ·
  https://pocketcurio.app/faq/ · https://pocketcurio.app/user-guide/ ·
  https://pocketcurio.app/privacy/

---

## Screenshots (phone, 1080×2400, DEMO_SEED data)

Run `flutter run --dart-define=DEMO_SEED=true` on the Pixel; the seed
plants two collections / 30 souvenirs / 12 states / 4 countries, every
one with a memory written for these shots. Order tells the product
story, per the build brief:

1. **The collection grid** — a *real* shelf: the Fridge Magnets
   collection off the Pixel (24 magnets, dark theme, status bar
   normalised to 9:00 in post; original in `raw/archive/`). The only
   shot with live photos, so it leads. Caption: "The shelf you can
   carry." (The DEMO_SEED "Mom's fridge" grid is archived alongside.)
2. **The map fill** — Map tab (Pro): continents lit, 12 states filled,
   "United States · 24" chip row. Caption: "Watch the world fill in."
3. **The fridge batch scan** — Guided crop screen with 5–6 boxes drawn
   on a real fridge photo (shoot one for this; the seed can't fake it).
   Caption: "One photo of the whole fridge. Box each one. Done."
4. **The memory** — Item detail for Yellowstone: photo, "Fortieth
   anniversary", the Old Faithful line, five stars. Caption: "Who gave
   it to you. The trip. The day."
5. **Composer speed** — New souvenir with the photo landed and the
   Place field prefilled "KEY WEST" under "Read from the photo — check
   the spelling." Caption: "Photo, place, done. Under ten seconds."
6. **Collections home** — Shelves tab: two tiles (Mom's fridge · 18
   magnets, Dad's keychains · 12 keychains) over "30 items · 2
   collections". Caption: "One phone. Everyone's shelf."

7. **The review grid** (optional 7th) — "Check what was read": the six
   crops with their place names filled in. Caption: "Reads what's
   printed. You check the spelling."

Shots 2–7 captured 2026-09-08 on the Pixel 7 emulator (same 1080×2400
panel as the phone) with the demo status bar (9:00, full battery, Wi-Fi). Shot 3
and 7 used a rendered fridge photo (`KEY WEST`, `MAINE`, … magnets on
brushed steel) because the emulator has no real camera — re-shoot on
the Pixel when there's a fridge handy; ML Kit read every magnet.

## Store assets (`docs/store-assets/`)

Built by `python3 tool/make_store_assets.py` from `assets/icon/` and
the raw screenshots in `docs/store-assets/raw/`:

| File | Size | Use |
| --- | --- | --- |
| `store-icon-512.png` | 512×512, 32-bit | Play hi-res icon |
| `feature-graphic.png` | 1024×500 | Play feature graphic |
| `app-store-icon-1024.png` | 1024×1024, no alpha | App Store icon |
| `play/phone/*.png` | 1080×2400 | Play phone screenshots (captioned) |
| `play/tablet-10/*.png` | 2064×2752 | Play 10" tablet screenshots (raw) |
| `app-store/iphone-6.9/*.png` | 1320×2868 | App Store 6.9" (captioned) |
| `app-store/iphone-6.5/*.png` | 1284×2778 | App Store 6.5" (captioned) |
| `app-store/ipad-13/*.png` | 2064×2752 | App Store 13" iPad (raw) |

Captions live in `CAPTIONS` in the tool — keep them in step with the
screenshot plan above. Upload order is the file order (01–07).

---

## App Store (Codemagic iOS lane)

**Name (30):** Pocket Curio: Souvenir Journal (29)

**Subtitle (30):** A souvenir is a place + a memory (30 — drop the
period to fit; or "Photograph the shelf. Map it." (29))

**Promotional text (170):**

> Photograph each keychain and magnet, name the place, keep the memory,
> and watch the map fill in. Private by construction: no account, no
> cloud, no analytics.

(162 chars.)

**Keywords (100, comma-separated, no spaces after commas):**

> souvenir,keychain,fridge magnet,collection,travel,keepsake,journal,map,places visited,shot glass

(96 chars. Don't repeat words from the name/subtitle — Apple indexes
those already.)

**Description:** the Play full description above, minus the Markdown
bold markers, plus two trailing lines App Review requires for the
auto-renewable subscription (guideline 3.1.2 — it rejected 1.0 (2) for
lacking the EULA link, 2026-09-10):

> Privacy Policy: https://pocketcurio.app/privacy/
> Terms of Use (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

**Category:** Lifestyle; secondary Travel.

**Support URL:** https://pocketcurio.app/help/ · **Marketing URL:**
https://pocketcurio.app/ · **Privacy URL:** https://pocketcurio.app/privacy/

**Privacy nutrition label:** Data Not Collected. **Age rating:** 4+.
**Review notes:** "All data is on-device. Pocket Curio Pro is a
non-consumable + a monthly auto-renewable subscription; no login to
test — the free tier is one collection and 25 souvenirs."
