import 'package:flutter_test/flutter_test.dart';
import 'package:fxrows/data/rates/rates_provider.dart';
import 'package:fxrows/features/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppSettings provider migration', () {
    test('null and aggServer become frankfurter; ecbDirect preserved', () async {
      SharedPreferences.setMockInitialValues({});
      final fresh = AppSettings(secureMemory: {});
      expect(await fresh.providerId(), RatesProviderId.frankfurter);

      SharedPreferences.setMockInitialValues({'provider_id': 'aggServer'});
      final legacy = AppSettings(secureMemory: {});
      expect(await legacy.providerId(), RatesProviderId.frankfurter);

      SharedPreferences.setMockInitialValues({'provider_id': 'ecbDirect'});
      final advanced = AppSettings(secureMemory: {});
      expect(await advanced.providerId(), RatesProviderId.ecbDirect);
    });
  });
}
