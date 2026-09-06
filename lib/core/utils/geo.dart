/// Turns what people type in the State and Country fields into codes the
/// map can fill. Forgiving on input ("usa", "United States", "Florida",
/// "fl"), honest on output: anything unrecognized is kept as typed
/// (upper-cased) so it still counts, it just can't light a tile.
library;

/// Two-letter US state code for [raw] — a code or a full name, any
/// case — else the trimmed upper-cased input, or null when blank.
String? normalizeState(String? raw) {
  final t = raw?.trim();
  if (t == null || t.isEmpty) return null;
  final upper = t.toUpperCase();
  if (_usStateNames.containsKey(upper)) return upper;
  final byName = _usStateNames.entries
      .where((e) => e.value == upper)
      .map((e) => e.key);
  return byName.isEmpty ? upper : byName.first;
}

/// True when [code] is one of the 50 US states (post-[normalizeState]).
bool isUsState(String? code) => code != null && _usStateNames.containsKey(code);

/// ISO 3166-1 alpha-2 for [raw] where we know the name or alias; when
/// blank, "US" if [state] is a US state; else the trimmed upper-cased
/// input, or null when nothing was given.
String? normalizeCountry(String? raw, {String? state}) {
  final t = raw?.trim();
  if (t == null || t.isEmpty) {
    return isUsState(normalizeState(state)) ? 'US' : null;
  }
  final upper = t.toUpperCase().replaceAll('.', '');
  if (_countries.containsKey(upper)) return upper;
  return _aliases[upper] ?? upper;
}

/// Display name for a normalized country, falling back to the code.
String countryName(String code) => _countries[code]?.$1 ?? code;

/// Continent code for a normalized country: NA, SA, EU, AF, AS, OC, AN;
/// null for countries we don't know.
String? continentOf(String code) => _countries[code]?.$2;

const _usStateNames = {
  'AL': 'ALABAMA',
  'AK': 'ALASKA',
  'AZ': 'ARIZONA',
  'AR': 'ARKANSAS',
  'CA': 'CALIFORNIA',
  'CO': 'COLORADO',
  'CT': 'CONNECTICUT',
  'DE': 'DELAWARE',
  'FL': 'FLORIDA',
  'GA': 'GEORGIA',
  'HI': 'HAWAII',
  'ID': 'IDAHO',
  'IL': 'ILLINOIS',
  'IN': 'INDIANA',
  'IA': 'IOWA',
  'KS': 'KANSAS',
  'KY': 'KENTUCKY',
  'LA': 'LOUISIANA',
  'ME': 'MAINE',
  'MD': 'MARYLAND',
  'MA': 'MASSACHUSETTS',
  'MI': 'MICHIGAN',
  'MN': 'MINNESOTA',
  'MS': 'MISSISSIPPI',
  'MO': 'MISSOURI',
  'MT': 'MONTANA',
  'NE': 'NEBRASKA',
  'NV': 'NEVADA',
  'NH': 'NEW HAMPSHIRE',
  'NJ': 'NEW JERSEY',
  'NM': 'NEW MEXICO',
  'NY': 'NEW YORK',
  'NC': 'NORTH CAROLINA',
  'ND': 'NORTH DAKOTA',
  'OH': 'OHIO',
  'OK': 'OKLAHOMA',
  'OR': 'OREGON',
  'PA': 'PENNSYLVANIA',
  'RI': 'RHODE ISLAND',
  'SC': 'SOUTH CAROLINA',
  'SD': 'SOUTH DAKOTA',
  'TN': 'TENNESSEE',
  'TX': 'TEXAS',
  'UT': 'UTAH',
  'VT': 'VERMONT',
  'VA': 'VIRGINIA',
  'WA': 'WASHINGTON',
  'WV': 'WEST VIRGINIA',
  'WI': 'WISCONSIN',
  'WY': 'WYOMING',
};

/// code → (display name, continent). The souvenir-shop countries; the
/// table grows as users type new ones.
const _countries = <String, (String, String)>{
  'US': ('United States', 'NA'),
  'CA': ('Canada', 'NA'),
  'MX': ('Mexico', 'NA'),
  'PR': ('Puerto Rico', 'NA'),
  'CU': ('Cuba', 'NA'),
  'DO': ('Dominican Republic', 'NA'),
  'JM': ('Jamaica', 'NA'),
  'BS': ('Bahamas', 'NA'),
  'CR': ('Costa Rica', 'NA'),
  'PA': ('Panama', 'NA'),
  'GT': ('Guatemala', 'NA'),
  'BZ': ('Belize', 'NA'),
  'BR': ('Brazil', 'SA'),
  'AR': ('Argentina', 'SA'),
  'CL': ('Chile', 'SA'),
  'PE': ('Peru', 'SA'),
  'CO': ('Colombia', 'SA'),
  'EC': ('Ecuador', 'SA'),
  'UY': ('Uruguay', 'SA'),
  'BO': ('Bolivia', 'SA'),
  'GB': ('United Kingdom', 'EU'),
  'IE': ('Ireland', 'EU'),
  'FR': ('France', 'EU'),
  'DE': ('Germany', 'EU'),
  'IT': ('Italy', 'EU'),
  'ES': ('Spain', 'EU'),
  'PT': ('Portugal', 'EU'),
  'NL': ('Netherlands', 'EU'),
  'BE': ('Belgium', 'EU'),
  'CH': ('Switzerland', 'EU'),
  'AT': ('Austria', 'EU'),
  'GR': ('Greece', 'EU'),
  'SE': ('Sweden', 'EU'),
  'NO': ('Norway', 'EU'),
  'DK': ('Denmark', 'EU'),
  'FI': ('Finland', 'EU'),
  'IS': ('Iceland', 'EU'),
  'PL': ('Poland', 'EU'),
  'CZ': ('Czechia', 'EU'),
  'HU': ('Hungary', 'EU'),
  'HR': ('Croatia', 'EU'),
  'RU': ('Russia', 'EU'),
  'TR': ('Türkiye', 'AS'),
  'JP': ('Japan', 'AS'),
  'CN': ('China', 'AS'),
  'KR': ('South Korea', 'AS'),
  'TH': ('Thailand', 'AS'),
  'VN': ('Vietnam', 'AS'),
  'IN': ('India', 'AS'),
  'ID': ('Indonesia', 'AS'),
  'PH': ('Philippines', 'AS'),
  'SG': ('Singapore', 'AS'),
  'MY': ('Malaysia', 'AS'),
  'AE': ('UAE', 'AS'),
  'IL': ('Israel', 'AS'),
  'JO': ('Jordan', 'AS'),
  'NP': ('Nepal', 'AS'),
  'AU': ('Australia', 'OC'),
  'NZ': ('New Zealand', 'OC'),
  'FJ': ('Fiji', 'OC'),
  'EG': ('Egypt', 'AF'),
  'MA': ('Morocco', 'AF'),
  'ZA': ('South Africa', 'AF'),
  'KE': ('Kenya', 'AF'),
  'TZ': ('Tanzania', 'AF'),
  'GH': ('Ghana', 'AF'),
  'AQ': ('Antarctica', 'AN'),
};

/// Upper-cased, dot-stripped names and aliases → code.
final _aliases = <String, String>{
  for (final e in _countries.entries) e.value.$1.toUpperCase(): e.key,
  'USA': 'US',
  'UNITED STATES OF AMERICA': 'US',
  'AMERICA': 'US',
  'U S': 'US',
  'U S A': 'US',
  'UK': 'GB',
  'U K': 'GB',
  'ENGLAND': 'GB',
  'SCOTLAND': 'GB',
  'WALES': 'GB',
  'GREAT BRITAIN': 'GB',
  'BRITAIN': 'GB',
  'NORTHERN IRELAND': 'GB',
  'HOLLAND': 'NL',
  'THE NETHERLANDS': 'NL',
  'CZECH REPUBLIC': 'CZ',
  'TURKEY': 'TR',
  'TURKIYE': 'TR',
  'UNITED ARAB EMIRATES': 'AE',
  'DUBAI': 'AE',
  'KOREA': 'KR',
  'REPUBLIC OF KOREA': 'KR',
  'THE BAHAMAS': 'BS',
  'DOMINICAN REP': 'DO',
  'DEUTSCHLAND': 'DE',
  'ITALIA': 'IT',
  'ESPAÑA': 'ES',
  'MÉXICO': 'MX',
  'BRASIL': 'BR',
  'NIPPON': 'JP',
};
