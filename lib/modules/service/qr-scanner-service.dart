import 'package:flutter/material.dart';

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
          await PreferenceService.setHotelId(hotelId);
          await PreferenceService.setApartmentName(blockName);

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
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
