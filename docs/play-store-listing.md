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

https://code-cowboys.com/privacy/pocketcurio
(Source text: `docs/privacy-policy.md` — publish before submission.)

---

## Screenshots (phone, 1080×2400, DEMO_SEED data)

Run `flutter run --dart-define=DEMO_SEED=true` on the Pixel; the seed
plants two collections / 30 souvenirs / 12 states / 4 countries, every
one with a memory written for these shots. Order tells the product
story, per the build brief:

1. **The collection grid** — Mom's fridge, sorted by Date: 18 tiles of
   place-labelled photos. Caption: "The shelf you can carry."
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

Feature graphic (1024×500) and 512px store icon: derive from
`assets/icon/` art (regenerate with `python3 tool/make_icon.py`) —
curio violet, the luggage-tag mark left, wordmark right. TODO alongside
first upload.
