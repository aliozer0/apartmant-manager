import 'package:flutter/material.dart';
import 'package:apartmantmanager/global/index.dart';
import 'package:apartmantmanager/index.dart';
import 'package:apartmantmanager/modules/module/resident_details_page.dart';

class ApartmentResidents extends StatefulWidget {
  const ApartmentResidents({super.key});

  @override
  State<ApartmentResidents> createState() => _ApartmentsResidentState();
}

class _ApartmentsResidentState extends State<ApartmentResidents> {
  final GlobalService _globalService = GetIt.I<GlobalService>();
  bool _isLoading = false;
  String? _apartmentUid;
  int? _expandedIndex;
  final _searchController = TextEditingController();
  List<Apartment> _filteredApartments = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      _apartmentUid = PreferenceService.getApartmentUid();
      if (_apartmentUid != null) {
        await _globalService.fetchApartments(_apartmentUid!);
        _updateFilteredApartments();
      }
    } catch (e) {
      _showError('Failed to initialize: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateFilteredApartments() {
    final apartments = _globalService.apartments$.value;
    if (apartments == null) return;

    final searchTerm = _searchController.text.toLowerCase();
    _filteredApartments = apartments.where((apartment) {
      final contactName = apartment.contactName?.toLowerCase() ?? '';
      final flatNumber = apartment.flatNumber?.toString().toLowerCase() ?? '';
      final plateNo = apartment.plateNo?.toLowerCase() ?? '';
      return contactName.contains(searchTerm) ||
          flatNumber.contains(searchTerm) ||
          plateNo.contains(searchTerm);
    }).toList()
      ..sort((a, b) => (a.contactName ?? '')
          .trim()
          .toLowerCase()
          .compareTo((b.contactName ?? '').trim().toLowerCase()));

    if (mounted) setState(() {});
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade800,
      ),
    );
  }

  Future<void> _handleApartmentTap(Apartment apartment) async {
    if (_apartmentUid == null || apartment.id == null) {
      _showError('Invalid Apartment Data'.tr());
      return;
    }

    try {
      setState(() => _isLoading = true);
      final fees =
          await _globalService.fetchFees(_apartmentUid!, apartment.id!);
      if (!mounted) return;

      if (fees.isNotEmpty) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              apartmentUid: _apartmentUid!,
              apartment: apartment,
              fees: fees,
            ),
          ),
        );
      } else {
        _showError('No fees available for this apartment'.tr());
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: GlobalConfig.primaryColor,
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      child: TextField(
        style: AppTextStyles.bodyText.copyWith(
          color: Colors.grey.shade800,
        ),
        cursorColor: GlobalConfig.primaryColor,
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search residents...'.tr(),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.grey,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.white,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: GlobalConfig.primaryColor,
              width: 1,
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (_) => _updateFilteredApartments(),
      ),
    );
  }

  Widget _buildApartmentInfo(Apartment apartment) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (apartment.flatNumber != null)
          _buildInfoChip(
            icon: Icons.home,
            text: apartment.flatNumber.toString(),
          ),
        if (apartment.numberOfPeople != null)
          _buildInfoChip(
            icon: Icons.people,
            text: apartment.numberOfPeople.toString(),
          ),
        if (apartment.plateNo != null)
          _buildInfoChip(
            icon: Icons.directions_car,
            text: apartment.plateNo!,
          ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: GlobalConfig.primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: GlobalConfig.primaryColor.withAlpha(60),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: GlobalConfig.primaryColor, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodyText.copyWith(
              color: GlobalConfig.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String buttonText,
  }) {
    return Material(
      color: color.withAlpha(25),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8), // Icon ve metin arasında boşluk
              Text(
                buttonText,
                style: AppTextStyles.cardText.copyWith(
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactActions(Apartment apartment) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (apartment.phone == null && apartment.email == null) ...[
          Icon(
            Icons.error_outline,
            color: Colors.red.shade300,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            "Contact information is not available.".tr(),
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 14,
            ),
          ),
        ],
        if (apartment.phone != null) ...[
          _buildContactButton(
            icon: Icons.phone,
            color: const Color.fromARGB(255, 62, 158, 62),
            onTap: () => launchUrl(Uri.parse('tel:${apartment.phone}')),
            buttonText: 'Call'.tr(),
          ),
          const SizedBox(width: 8),
          _buildContactButton(
            icon: Icons.sms,
            color: const Color.fromARGB(255, 212, 155, 68),
            onTap: () => launchUrl(Uri.parse('sms:${apartment.phone}')),
            buttonText: 'SMS'.tr(),
          ),
        ],
        if (apartment.email != null) ...[
          const SizedBox(width: 8),
          _buildContactButton(
            icon: Icons.mail,
            color: const Color.fromARGB(255, 64, 154, 214),
            onTap: () => launchUrl(Uri.parse('mailto:${apartment.email}')),
            buttonText: 'Email'.tr(),
          ),
        ],
      ],
    );
  }

  Widget _buildApartmentCard(Apartment apartment, int index) {
    final isExpanded = _expandedIndex == index;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _handleApartmentTap(apartment),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'avatar_${apartment.id}',
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: apartment.photoUrl != null
                              ? NetworkImage(apartment.photoUrl!)
                              : const AssetImage('assets/images/profile.png')
                                  as ImageProvider,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              apartment.contactName ?? 'No Name',
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 14.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 8),
                            _buildApartmentInfo(apartment),
                          ],
                        ),
                      ),
                      IconButton(
                        padding: const EdgeInsets.all(0),
                        icon: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: GlobalConfig.primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _expandedIndex = isExpanded ? null : index;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Container(
              height: 0,
              width: double.infinity,
            ),
            secondChild: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: _buildContactActions(apartment),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 100),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apartment Guests'.tr()),
      ),
      body: RefreshIndicator(
        color: GlobalConfig.primaryColor,
        onRefresh: _initializeData,
        child: StreamBuilder<List<Apartment>?>(
          stream: _globalService.apartments$.stream,
          builder: (context, snapshot) {
            if (_isLoading) {
              return Center(
                  child: CircularProgressIndicator(
                color: GlobalConfig.primaryColor,
              ));
            }

            final apartments = _globalService.apartments$.value;
            if (apartments == null || apartments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apartment,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Apartments Found'.tr(),
                      style: AppTextStyles.cardTitle.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _filteredApartments.length,
                    itemBuilder: (context, index) =>
                        _buildApartmentCard(_filteredApartments[index], index),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
