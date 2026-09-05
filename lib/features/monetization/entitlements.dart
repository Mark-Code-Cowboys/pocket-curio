import 'package:cc_core/cc_core.dart';

// The billing wrapper, entitlement cache, and store types live in
// cc_core; this file keeps Pocket Curio's product catalog and re-exports
// the shared types for app import sites.
export 'package:cc_core/cc_core.dart'
    show
        EntitlementService,
        FakeEntitlementService,
        StoreEntitlementService,
        StoreProducts,
        StoreUnavailableException;

/// Store product ids. Must match the products configured in Play
/// Console (and later App Store Connect) exactly.
abstract final class ProductIds {
  static const proMonthly = 'pocketcurio_pro_monthly';
  static const proLifetime = 'pocketcurio_pro_lifetime';
  static const all = [proMonthly, proLifetime];
}

/// Pocket Curio's catalog: one Pro entitlement, sold as a lifetime unlock
/// (priced as a gift; the one we lead with) or a monthly subscription.
/// cc_core's `isUnlimited()` is true for either, so the whole app gates
/// on that single answer.
const pcStoreProducts = StoreProducts(
  lifetimeUnlock: ProductIds.proLifetime,
  premiumSubscription: ProductIds.proMonthly,
);
