import 'package:cc_core/cc_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_curio/core/utils/geo.dart';

void main() {
  test('states: codes and full names in any case become the code', () {
    expect(normalizeState('MI'), 'MI');
    expect(normalizeState('mi'), 'MI');
    expect(normalizeState('Michigan'), 'MI');
    expect(normalizeState(' new mexico '), 'NM');
    expect(isUsState('MI'), isTrue);
  });

  test('states: unknown regions are kept as typed, upper-cased', () {
    expect(normalizeState('Ontario'), 'ONTARIO');
    expect(isUsState('ONTARIO'), isFalse);
    expect(normalizeState(''), isNull);
    expect(normalizeState(null), isNull);
  });

  test('countries: names, aliases, and codes become ISO codes', () {
    expect(normalizeCountry('US'), 'US');
    expect(normalizeCountry('usa'), 'US');
    expect(normalizeCountry('U.S.A.'), 'US');
    expect(normalizeCountry('United States'), 'US');
    expect(normalizeCountry('England'), 'GB');
    expect(normalizeCountry('uk'), 'GB');
    expect(normalizeCountry('Deutschland'), 'DE');
    expect(normalizeCountry('Canada'), 'CA');
  });

  test('countries: a US state with no country implies US', () {
    expect(normalizeCountry(null, state: 'FL'), 'US');
    expect(normalizeCountry('', state: 'Florida'), 'US');
    expect(normalizeCountry(null, state: 'Ontario'), isNull);
    expect(normalizeCountry(null), isNull);
  });

  test('countries: unknown names still count, just unlit', () {
    expect(normalizeCountry('Narnia'), 'NARNIA');
    expect(continentOf('NARNIA'), isNull);
    expect(countryName('NARNIA'), 'NARNIA');
  });

  test('continents and display names', () {
    expect(continentOf('US'), 'NA');
    expect(continentOf('BR'), 'SA');
    expect(continentOf('FR'), 'EU');
    expect(continentOf('JP'), 'AS');
    expect(continentOf('AU'), 'OC');
    expect(continentOf('EG'), 'AF');
    expect(continentOf('AQ'), 'AN');
    expect(countryName('GB'), 'United Kingdom');
    expect(continentNames['OC'], 'Oceania');
  });
}
