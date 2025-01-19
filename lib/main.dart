import 'dart:ui' as ui;

import 'package:apartmantmanager/modules/module/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global/index.dart';
import 'index.dart';
import 'modules/module/qr_scanner_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependency injection setup
  GlobalFunction().getItInital();

  try {
    // SharedPreferences başlatılıyor
    await PreferenceService.initializePreferences();

    prefs = await SharedPreferences.getInstance();

    apartmentUid = PreferenceService.getApartmentUid();
    apartmentName = PreferenceService.getApartmentName();

    if (apartmentUid == null || apartmentName == null) {
      debugPrint('Apartment UID veya Apartment Name null.');
    }

    // Dil ayarlarını başlat
    selectedlang = await _initialAppLanguage();

    runApp(EasyLocalization(
        startLocale: Locale(selectedlang!),
        supportedLocales: const [
          Locale('en'),
          Locale('tr'),
          Locale('de'),
          Locale('ru')
        ],
        fallbackLocale: const Locale('en'),
        path: 'assets/translations',
        child: const MyApp()));
  } catch (e) {
    debugPrint('Uygulama başlatılırken bir hata oluştu: $e');
  }
}

Future<String> _initialAppLanguage() async {
  try {
    selectedlang = prefs.getString('selected_language');

    selectedlang ??= ui.window.locale.languageCode;
    const supportedLanguages = ['en', 'tr', 'de', 'ru'];
    if (!supportedLanguages.contains(selectedlang)) {
      selectedlang = 'en';
      await prefs.setString('selected_language', selectedlang!);
    }
    return selectedlang!;
  } catch (e) {
    debugPrint('Dil başlatma sırasında hata oluştu: $e');
    return 'en'; // Varsayılan dil
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: Locale(selectedlang ?? 'tr'),
      theme: _buildLightTheme(),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        return child!;
      },
      home: (apartmentUid == null) ? const QRScannerPage() : HomePage(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: false,
      dropdownMenuTheme: const DropdownMenuThemeData(),
      brightness: Brightness.light,
      iconTheme: const IconThemeData(color: Colors.white),
      appBarTheme: AppBarTheme(
        iconTheme: const IconThemeData(color: Colors.white),
        color: GlobalConfig.primaryColor,
        titleTextStyle: AppTextStyles.mainTitle.copyWith(color: Colors.white),
        elevation: 0,
        toolbarHeight: 60,
        centerTitle: true,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 0,
        showDragHandle: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
      ),
    );
  }
}
