// qr-scanner-service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../global/index.dart';
import '../../index.dart';

class QRScannerController {
  final pause$ = BehaviorSubject<bool>.seeded(false);
  final flash$ = BehaviorSubject<bool>.seeded(false);
  final apartmentUid$ = BehaviorSubject<String>.seeded('');

  QRViewController? _qrController;
  bool _isProcessing = false;
  StreamSubscription? _scanSubscription;

  final _apiService = GetIt.I<GlobalService>();

  void onQRViewCreated(QRViewController controller, BuildContext context) {
    _qrController = controller;
    _setupScanner(context);
  }

  void _setupScanner(BuildContext context) {
    _scanSubscription?.cancel();
    _scanSubscription = _qrController?.scannedDataStream
        .throttleTime(const Duration(seconds: 1))
        .listen((scanData) async {
      if (_isProcessing) return;

      final qrText = scanData.code;
      if (qrText == null || qrText.isEmpty) return;

      _isProcessing = true;

      try {
        debugPrint('Processing QR code: $qrText');

        // Validate QR code format
        if (!_isValidQRFormat(qrText)) {
          _showError(context, 'Invalid QR code format');
          _isProcessing = false;
          return;
        }

        // Check if already scanned
        if (await _isAlreadyScanned(qrText)) {
          _showError(context, 'This QR code has already been scanned');
          _isProcessing = false;
          return;
        }

        // Validate apartment exists in system
        final isValidApartment = await _validateApartment(qrText);
        if (!isValidApartment) {
          _showError(
              context, 'This apartment is not registered in our system.'.tr());
          _isProcessing = false;
          return;
        }

        await _processQRCode(qrText, context);
      } catch (e) {
        debugPrint('Error processing QR code: $e');
        _showError(context, 'Error processing QR code');
      } finally {
        _isProcessing = false;
      }
    });
  }

  Future<bool> _validateApartment(String apartmentUid) async {
    try {
      final apartments = await _apiService.fetchApartments(apartmentUid);
      return apartments.isNotEmpty;
    } catch (e) {
      debugPrint('Error validating apartment: $e');
      return false;
    }
  }

  bool _isValidQRFormat(String code) {
    // Add your QR code format validation logic here
    return code.length >= 6 && code.length <= 50;
  }

  Future<bool> _isAlreadyScanned(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCodes = prefs.getStringList('saved_codes') ?? [];
    return savedCodes.contains(code);
  }

  Future<void> _processQRCode(String code, BuildContext context) async {
    try {
      apartmentUid$.add(code);

      // Save to preferences
      await PreferenceService.setApartmentUid(code);

      // Save to scanned codes list
      final prefs = await SharedPreferences.getInstance();
      final savedCodes = prefs.getStringList('saved_codes') ?? [];
      savedCodes.add(code);
      await prefs.setStringList('saved_codes', savedCodes);

      // Navigate to home page
      if (context.mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      debugPrint('Error saving QR code: $e');
      _showError(context, 'Error saving QR code');
    }
  }

  OverlayEntry? _currentErrorOverlay;

  void _showError(BuildContext context, String message) {
    _currentErrorOverlay?.remove();

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + kToolbarHeight,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: GlobalConfig.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: AppTextStyles.bodyText.copyWith(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    _currentErrorOverlay?.remove();
                    _currentErrorOverlay = null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _currentErrorOverlay = overlayEntry;
    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 5), () {
      _currentErrorOverlay?.remove();
      _currentErrorOverlay = null;
    });
  }

  void togglePause() {
    if (_qrController != null) {
      if (pause$.value) {
        resumeScanner();
      } else {
        pauseScanner();
      }
    }
  }

  void pauseScanner() {
    _qrController?.pauseCamera();
    pause$.add(true);
  }

  void resumeScanner() {
    _qrController?.resumeCamera();
    pause$.add(false);
  }

  void toggleFlash() {
    if (_qrController != null) {
      _qrController!.toggleFlash();
      flash$.add(!flash$.value);
    }
  }

  void dispose() {
    _scanSubscription?.cancel();
    _qrController?.dispose();
    pause$.close();
    flash$.close();
    apartmentUid$.close();
  }
}
