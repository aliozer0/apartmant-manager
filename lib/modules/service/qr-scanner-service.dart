import 'package:flutter/material.dart';

import '../../global/index.dart';
import '../../index.dart';

class QRScannerController {
  final pause$ = BehaviorSubject<bool>.seeded(false);
  final flash$ = BehaviorSubject<bool>.seeded(false);
  final blockName$ = BehaviorSubject<String>.seeded('');
  final hotelId$ = BehaviorSubject<int?>.seeded(null);

  QRViewController? qrController;
  final apiService = GetIt.I<GlobalService>();

  void onQRViewCreated(QRViewController controller, BuildContext context) async {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) async {
      apartmentUid = scanData.code ?? '';

      // int? hotelId = int.tryParse(splitData[0]);
      // String blockName = splitData[1];
      // debugPrint('Hotel ID: $hotelId, Block Name: $blockName');

      if (apartmentUid != null) {
        await PreferenceService.setApartmentUid(apartmentUid!);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      }
      // if (hotelId != null) {
      //   blockName$.add(blockName);
      //   hotelId$.add(hotelId);
      //   // await PreferenceService.setHotelId(hotelId);
      //   //
      //   // await PreferenceService.setApartmentName(blockName);
      //
      //
      // }
      else {
        debugPrint('QR code format is incorrect: $apartmentUid');
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
