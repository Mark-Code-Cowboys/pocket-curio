import '../../data/database/app_database.dart';

extension CollectionKindLabel on CollectionKind {
  /// Plural, for pickers and chips.
  String get label => switch (this) {
    CollectionKind.keychain => 'Keychains',
    CollectionKind.magnet => 'Magnets',
    CollectionKind.shotGlass => 'Shot glasses',
    CollectionKind.patch => 'Patches',
    CollectionKind.ornament => 'Ornaments',
    CollectionKind.pin => 'Pins',
    CollectionKind.spoon => 'Spoons',
    CollectionKind.sticker => 'Stickers',
    CollectionKind.postcard => 'Postcards',
    CollectionKind.other => 'Something else',
  };

  /// Singular, lowercase, for copy like "Photograph your first keychain".
  String get singular => switch (this) {
    CollectionKind.keychain => 'keychain',
    CollectionKind.magnet => 'magnet',
    CollectionKind.shotGlass => 'shot glass',
    CollectionKind.patch => 'patch',
    CollectionKind.ornament => 'ornament',
    CollectionKind.pin => 'pin',
    CollectionKind.spoon => 'spoon',
    CollectionKind.sticker => 'sticker',
    CollectionKind.postcard => 'postcard',
    CollectionKind.other => 'souvenir',
  };
}

extension CollectionLabels on Collection {
  /// What one item on this shelf is called: the kind's singular, or the
  /// collector's own word for an `other` shelf ("snow globe").
  String get itemNoun {
    final custom = otherLabel?.trim();
    if (kind == CollectionKind.other && custom != null && custom.isNotEmpty) {
      return custom.toLowerCase();
    }
    return kind.singular;
  }
}

/// "31 items · 2 collections" — the Home headline. Region counts join in
/// Phase E once the map exists.
String countHeadline({required int items, required int collections}) {
  final itemWord = items == 1 ? 'item' : 'items';
  final shelfWord = collections == 1 ? 'collection' : 'collections';
  return '$items $itemWord · $collections $shelfWord';
}

/// "Traverse City, MI, US" — whichever parts exist, in order.
String placeLine({String? city, String? state, String? country}) => [
  if (city != null && city.isNotEmpty) city,
  if (state != null && state.isNotEmpty) state,
  if (country != null && country.isNotEmpty) country,
].join(', ');
