import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../global/index.dart';
import '../../index.dart';


class QRScannerController {
  final pause$ = BehaviorSubject<bool>.seeded(false);
  final flash$ = BehaviorSubject<bool>.seeded(false);
  final blockName$ = BehaviorSubject<String>.seeded('');
  final hotelId$ = BehaviorSubject<int?>.seeded(null);

  QRViewController? qrController;
  final APIService apiService = GetIt.I<APIService>();

  void onQRViewCreated(QRViewController controller, BuildContext context) async {
    qrController = controller;

    bool hasScannedBefore = await checkIfScannedBefore();
    if (hasScannedBefore) {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedCodes = prefs.getStringList('saved_codes') ?? [];
      if (savedCodes.isNotEmpty) {
        String lastCode = savedCodes.last;
        List<String> splitData = lastCode.split(",");
        int? hotelId = int.tryParse(splitData[0]);
        String blockName = splitData[1];
        navigateToPage(blockName, hotelId!, context);
        return;
      }
    }

    controller.scannedDataStream.listen((scanData) async {
      String qrText = scanData.code ?? '';

      List<String> splitData = qrText.split(",");
      if (splitData.length == 2) {
        int? hotelId = int.tryParse(splitData[0]);
        String blockName = splitData[1];
        debugPrint('Hotel ID: $hotelId, Block Name: $blockName');

        if (hotelId != null) {
          blockName$.add(blockName);
          hotelId$.add(hotelId);
          await saveCode(qrText);
          await fetchApartmentsAndNavigate(blockName, hotelId, context);
        }
      } else {
        debugPrint('QR code format is incorrect: $qrText');
      }
    });
  }

  Future<bool> checkIfScannedBefore() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedCodes = prefs.getStringList('saved_codes');
    return savedCodes != null && savedCodes.isNotEmpty;
  }

  Future<void> fetchApartmentsAndNavigate(String blockName, int hotelId, BuildContext context) async {
    try {
      navigateToPage(blockName, hotelId, context);
    } catch (e) {
      debugPrint("Error fetching apartments: $e");
    }
  }

  void navigateToPage(String blockName, int hotelId, BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(blockName: blockName, hotelId: hotelId)));
  }

  Future<void> saveCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedCodes = prefs.getStringList('saved_codes') ?? [];
    savedCodes.add(code);
    await prefs.setStringList('saved_codes', savedCodes);
  }

  void togglePause() {
    if (qrController != null) {
      if (pause$.value) {
        qrController!.resumeCamera();
      } else {
        qrController!.pauseCamera();
      }
      pause$.add(!pause$.value);
    }
  }

  void toggleFlash() {
    if (qrController != null) {
      qrController!.toggleFlash();
      flash$.add(!flash$.value);
    }
  }

  void dispose() {
    pause$.close();
    flash$.close();
    blockName$.close();
    hotelId$.close();
  }
}
