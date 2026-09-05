# Pocket Curio — Play monetization setup (manual checklist)

Do these in order — the products menu is hidden until Play has
processed a build containing the billing permission. Mirrors the
Table Encore / Course Ledger checklists; differences called out.

## 0. Payments profile (account level, one-time)

Already done for Table Encore. Skip.

## 1. Upload the AAB

Internal testing → Create release → `app-release.aab` (see
release-checklist.md for the build). The `in_app_purchase` plugin
embeds `com.android.vending.BILLING`; once Play processes the build,
**Monetize** unlocks.

## 2. One-time product (Monetize → Products → In-app products)

| Product ID | Name | Price |
| --- | --- | --- |
| `pocketcurio_pro_lifetime` | Pocket Curio Pro — Forever | $6.99 |

Gift-tier on purpose: the brief prices lifetime as something you'd
buy for the collector in your life. The app leads with this one
("Yours forever · $6.99", footnote "One-time. Makes a good gift.").
Id must match `lib/features/monetization/entitlements.dart` exactly.
Purchase option ID: `buy`. Mark **Active**.

Description (≤200 chars, shown in the purchase dialog):

> Pocket Curio Pro, forever: every collection and souvenir, the map,
> and backup and export. One purchase, no subscription. Makes a good
> gift.

## 3. Subscription (Monetize → Products → Subscriptions)

| Product ID | Base plan ID | Billing | Price |
| --- | --- | --- | --- |
| `pocketcurio_pro_monthly` | `monthly` | Monthly, auto-renewing | $1.49/mo |

The secondary path ("Or month to month"). Single base plan — cc_core's
`premiumPrice()`/`buyPremium()` use the first (only) plan, so no
`premiumPlanLabels` are configured. Enable the base plan, mark the
subscription **Active**.

Benefits list (shown on the store):
unlimited collections and souvenirs · the map · backup & CSV export.

## 4. License testers

Play Console → Settings → License testing: add the test account(s) so
sandbox purchases don't charge. Verify on-device:

- free tier: one collection, 25 souvenirs; the second collection and
  the 26th souvenir each open the sheet
- buy lifetime → gate lifts, counter disappears, Map unlocks
- buy monthly on a second tester → same entitlement; cancel → after
  expiry, `refreshEntitlements()` downgrades on next launch (cache
  answers until a definitive store response)
- **Restore purchase** on a reinstall → entitlement returns
- shelf scan of 3 crops at 24/25 → "24 of 25 free items used — 3 more
  won't fit" → buy from the sheet → the add completes

## 5. Data safety form

All "No" (no data collected, no data shared), except:
- "On-device processing only" note for souvenir photos and the text
  read from them
- Purchases: handled by Google Play

Matches `docs/privacy-policy.md` — keep the two in sync.

## App Store (later, with the Codemagic iOS lane)

`pocketcurio_pro_lifetime` as a non-consumable;
`pocketcurio_pro_monthly` as an auto-renewable subscription in its own
group. No base plans on the App Store — one product per plan is already
the shape cc_core supports if a yearly plan is ever added
(`premiumPlanProducts`).
