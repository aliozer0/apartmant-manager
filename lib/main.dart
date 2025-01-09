import 'dart:ui' as ui;

import 'package:apartmantmanager/Service/api-service.dart';
import 'package:apartmantmanager/modules/module/home-page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'global/index.dart';
import 'modules/module/qr-scanner-page.dart';
import 'service/service-locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLocator();
  if (!GetIt.I.isRegistered<APIService>()) {
    GetIt.I.registerSingleton<APIService>(APIService());
  }
  if (!GetIt.I.isRegistered<GlobalService>()) {
    GetIt.I.registerSingleton<GlobalService>(GlobalService());
  }
  final prefs = await SharedPreferences.getInstance();

  hotelId = await PreferenceService.getHotelId();
  apartmentName = await PreferenceService.getApartmentName();

  if (hotelId == null || apartmentName == null) {
    debugPrint('hotelId veya apartmentName null');
  }
  Future<String> initialAppLanguage() async {
    selectedlang = prefs.getString('selected_language');

    selectedlang ??= ui.window.locale.languageCode;

    const supportedLanguages = ['en', 'tr', 'de', 'ru'];

    if (!supportedLanguages.contains(selectedlang)) {
      selectedlang = 'en';
      await prefs.setString('selected_language', selectedlang!);
    }
    return selectedlang!;
  }

  selectedlang = await initialAppLanguage();

  runApp(EasyLocalization(
      startLocale: Locale(selectedlang!),
      supportedLocales: const [Locale('en'), Locale('tr'), Locale('de'), Locale('ru')],
      fallbackLocale: Locale(selectedlang!),
      path: 'assets/translations',
      child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: Locale(selectedlang ?? 'tr'),
        theme: ThemeData(
            useMaterial3: false,
            dropdownMenuTheme: const DropdownMenuThemeData(),
            brightness: Brightness.light,
            iconTheme: const IconThemeData(color: Colors.black87),
            appBarTheme: AppBarTheme(
                iconTheme: const IconThemeData(color: Colors.white),
                color: GlobalConfig.primaryColor,
                titleTextStyle: k22Trajan(context),
                elevation: 0,
                toolbarHeight: 50,
                centerTitle: true,
                systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.black87)),
            bottomSheetTheme: const BottomSheetThemeData(
                elevation: 0,
                showDragHandle: true,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))))),
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
          return child!;
        },
        home: (hotelId == null || apartmentName == null) ? const QRScannerPage() : HomePage());
  }
}
