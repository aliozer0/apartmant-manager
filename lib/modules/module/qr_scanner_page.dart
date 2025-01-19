import 'package:flutter/material.dart';

import '../../Global/index.dart';
import '../service/qr-scanner-service.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRScannerController _qrScannerController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _qrScannerController = QRScannerController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _qrScannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _qrScannerController.resumeScanner();
    } else if (state == AppLifecycleState.paused) {
      _qrScannerController.pauseScanner();
    }
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: GlobalConfig.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              'Position QR code within the frame'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.cardTitle
                  .copyWith(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onTap,
    required IconData icon,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: GlobalConfig.primaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StreamBuilder<bool>(
            stream: _qrScannerController.pause$.stream,
            builder: (context, snapshot) {
              return _buildControlButton(
                onTap: _qrScannerController.togglePause,
                icon: snapshot.data ?? false ? Icons.play_arrow : Icons.pause,
                tooltip:
                    snapshot.data ?? false ? 'Resume Scanner' : 'Pause Scanner',
              );
            },
          ),
          StreamBuilder<bool>(
            stream: _qrScannerController.flash$.stream,
            builder: (context, snapshot) {
              return _buildControlButton(
                onTap: _qrScannerController.toggleFlash,
                icon: snapshot.data ?? false
                    ? Icons.flashlight_off
                    : Icons.flashlight_on,
                tooltip:
                    snapshot.data ?? false ? 'Turn Flash Off' : 'Turn Flash On',
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      QRView(
                        key: qrKey,
                        onQRViewCreated: (controller) => _qrScannerController
                            .onQRViewCreated(controller, context),
                        overlay: QrScannerOverlayShape(
                          borderColor: GlobalConfig.primaryColor,
                          borderRadius: 12,
                          borderLength: 32,
                          borderWidth: 12,
                          cutOutSize: 300,
                        ),
                      ),
                      _buildScannerOverlay(),
                    ],
                  ),
                ),
                _buildControls(),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
