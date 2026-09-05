import 'package:cc_core/cc_core.dart';

/// The free tier: one collection and twenty-five items, forever. Only
/// adding beyond either cap is gated (Phase C wires the gates and
/// paywall). The item cap is per install, not per collection.
const collectionFreeLimit = FreeLimit(1, 'collections');
const itemFreeLimit = FreeLimit(25, 'items');
