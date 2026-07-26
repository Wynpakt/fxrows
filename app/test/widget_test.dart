import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fxboard/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('app shows loading indicator on boot', (tester) async {
    await tester.pumpWidget(const FxboardApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
