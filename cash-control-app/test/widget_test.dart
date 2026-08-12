import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:cash_control/main.dart';
import 'package:cash_control/providers/theme_provider.dart';
import 'package:cash_control/providers/eye_control_provider.dart';
import 'package:cash_control/providers/date_filter_provider.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    tempDir = await Directory.systemTemp.createTemp('cash_control_test_');

    Hive.init(tempDir.path);

    await Hive.openBox('cash_control_local');
  });

  tearDownAll(() async {
    await Hive.close();

    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('Cash Control crea MyApp correctamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => EyeControlProvider()),
          ChangeNotifierProvider(create: (_) => DateFilterProvider()),
        ],
        child: const MyApp(initialRoute: '/'),
      ),
    );

    expect(find.byType(MyApp), findsOneWidget);
  });
}
