import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'Global/index.dart';
import 'modules/module/qr-scanner-page.dart';
import 'service/service-locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  final prefs = await SharedPreferences.getInstance();

  Future<String> initialAppLanguage() async {
    String? selectedlang = prefs.getString('selected_language');

    selectedlang ??= ui.window.locale.languageCode;

    const supportedLanguages = ['en', 'tr', 'de', 'ru'];

    if (!supportedLanguages.contains(selectedlang)) {
      selectedlang = 'en';
      await prefs.setString('selected_language', selectedlang);
    }
    return selectedlang;
  }

  selectedlang = await initialAppLanguage();

  runApp(EasyLocalization(
      startLocale: Locale(selectedlang!),
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
        Locale('de'),
        Locale('ru'),
      ],
      fallbackLocale: Locale(selectedlang!),
      path: 'assets/translations',
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: QRScannerPage());
  }
}
