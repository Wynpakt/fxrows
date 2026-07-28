import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fxrows/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('app shows loading indicator on boot', (tester) async {
    await tester.pumpWidget(const FxrowsApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
