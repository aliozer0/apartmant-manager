import 'package:apartmantmanager/index.dart';
import 'package:apartmantmanager/modules/module/apartmant_residents.dart';
import 'package:apartmantmanager/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../../global/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalService _globalService = GetIt.I<GlobalService>();
  bool _isLoading = false;
  String? _apartmentUid;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    try {
      _apartmentUid = PreferenceService.getApartmentUid();
      if (_apartmentUid != null) {
        await _globalService.fetchApartments(_apartmentUid!);
      }
    } catch (e) {
      _showError('Failed to initialize: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetAndScanQR() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          actionsPadding: const EdgeInsets.only(bottom: 15, right: 15, top: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Reset QR Code'.tr(),
            style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
          ),
          content: Text(
            'Do you want to reset and scan a new QR code?'.tr(),
            style: AppTextStyles.bodyText.copyWith(fontSize: 16),
          ),
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                child: Text(
                  'Cancel'.tr(),
                  style: AppTextStyles.cardTitle.copyWith(color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: 1),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                child: Text(
                  'Reset'.tr(),
                  style: AppTextStyles.cardTitle.copyWith(color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // Clear saved QR code
        await PreferenceService.clearApartmentData();

        // Clear saved codes list
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('saved_codes');

        // Navigate to QR scanner
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const QRScannerPage()),
          );
        }
      } catch (e) {
        _showError('Failed to reset: $e');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildWelcomeCard(double width) {
    final apartments = _globalService.apartments$.value;
    if (apartments == null || apartments.isEmpty)
      return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(
          vertical: width / 30,
          horizontal: width / 20,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFDF1940).withAlpha(240),
              const Color(0xFFC4173A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome!".tr(),
              style: AppTextStyles.titleLight.copyWith(color: Colors.white),
            ),
            SizedBox(height: width / 40),
            Text(
              "${apartments.first.name} | ${apartments.first.blockName}",
              style: AppTextStyles.titleBold.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeItem({
    required String title,
    required String imageAsset,
    required Color firstColor,
    required Color secondColor,
    required double width,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.all(10.0),
        height: width / 2.28,
        width: width / 2.28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              firstColor.withAlpha(150),
              secondColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(5, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: width / 6,
              height: width / 6,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                color: Colors.white,
              ),
            ),
            SizedBox(height: width / 30),
            Text(
              title,
              style: AppTextStyles.cardTitle.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeGrid(double width) {
    return Wrap(
      children: [
        _buildHomeItem(
          title: "Apartment Guests".tr(),
          imageAsset: "assets/icons/apartments.png",
          firstColor: const Color(0xFF9628FA),
          secondColor: const Color(0xFF5F0FF8),
          width: width,
          onTap: () {
            Navigator.push(
              context,
              RouteAnimation.createRoute(const ApartmentResidents(), 1, 0),
            );
          },
        ),
        _buildHomeItem(
          title: "Income & Expenses".tr(),
          imageAsset: "assets/icons/income.png",
          firstColor: const Color.fromARGB(255, 125, 206, 19),
          secondColor: const Color.fromARGB(255, 107, 189, 0),
          width: width,
          onTap: () {
            if (_apartmentUid != null) {
              Navigator.push(
                context,
                RouteAnimation.createRoute(
                  Expenses(apartmentUid: _apartmentUid!),
                  1,
                  0,
                ),
              );
            } else {
              _showError('Invalid apartment data');
            }
          },
        ),
        _buildHomeItem(
          title: "Announcements".tr(),
          imageAsset: "assets/icons/notifications.png",
          firstColor: const Color(0xFF17B3FE),
          secondColor: const Color(0xFF0587FF),
          width: width,
          onTap: () {
            Navigator.push(
              context,
              RouteAnimation.createRoute(const NewsPage(), 1, 0),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder(
      stream: _globalService.apartments$.stream,
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            title: Text("Apartment Management".tr()),
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _resetAndScanQR,
                tooltip: 'Reset and Scan New QR'.tr(),
                iconSize: 26,
              ),
            ],
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                  color: GlobalConfig.primaryColor,
                ))
              : RefreshIndicator(
                  color: GlobalConfig.primaryColor,
                  onRefresh: _initializeData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          _buildWelcomeCard(screenWidth),
                          _buildHomeGrid(screenWidth),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
