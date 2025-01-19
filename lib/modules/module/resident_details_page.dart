import 'package:flutter/material.dart';
import '../../global/index.dart';
import 'package:apartmantmanager/modules/module/credit-card-form.dart';

class DetailPage extends StatefulWidget {
  final Apartment apartment;
  final List<Fee> fees;
  final String apartmentUid;

  const DetailPage({
    super.key,
    required this.apartmentUid,
    required this.apartment,
    required this.fees,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final GlobalService _apiService = GetIt.I<GlobalService>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await _apiService.fetchApartments(widget.apartmentUid);
      final apartments = await _apiService.apartments$.first;

      if (apartments != null && apartments.isNotEmpty) {
        await _apiService.fetchFees(widget.apartmentUid, apartments.first.id!);
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      _showError('Failed to fetch data');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd.MM.yyyy').format(parsedDate);
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return date;
    }
  }

  double _getTotalFeeAmount() {
    return widget.fees.fold(0.0, (sum, fee) => sum + fee.feeAmount);
  }

  Widget _buildTopBackground() {
    return Container(
      height: 100,
      color: GlobalConfig.primaryColor,
    );
  }

  Widget _buildFeesTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Fees'.tr(),
                style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: GlobalConfig.primaryColor,
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white,
        backgroundImage: widget.apartment.photoUrl != null
            ? NetworkImage(widget.apartment.photoUrl!)
            : const AssetImage('assets/images/profile.png') as ImageProvider,
      ),
    );
  }

  Widget _buildContactInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.apartment.contactName != null)
            Text(
              widget.apartment.contactName!,
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          const SizedBox(height: 4),
          if (widget.apartment.email != null)
            Row(
              children: [
                Icon(Icons.email, size: 16, color: GlobalConfig.primaryColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.apartment.email!,
                    style: AppTextStyles.bodyText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          if (widget.apartment.phone != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.phone, size: 16, color: GlobalConfig.primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    widget.apartment.phone!,
                    style: AppTextStyles.bodyText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 14, left: 16, right: 16),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileImage(),
              const SizedBox(width: 16),
              _buildContactInfo(),
            ],
          ),
          if (_hasIconInfo(widget.apartment)) const SizedBox(height: 10),
          if (_hasIconInfo(widget.apartment)) _buildIconInfo(widget.apartment),
          if (_hasOwnerInfo(widget.apartment)) const _Divider(),
          if (_hasOwnerInfo(widget.apartment))
            _buildOwnerInfo(widget.apartment),
          if (_hasDateInfo(widget.apartment)) const _Divider(),
          if (_hasDateInfo(widget.apartment)) _buildDateInfo(widget.apartment),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    final unpaidFees = widget.fees.where((fee) => !fee.isCompleted).toList();
    final totalAmount = unpaidFees.fold(0.0, (sum, fee) => sum + fee.feeAmount);

    if (unpaidFees.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: GlobalConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GlobalConfig.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Amount".tr(),
                  style: AppTextStyles.cardTitle.copyWith(
                    color: GlobalConfig.primaryColor,
                  ),
                ),
                Text(
                  "₺${totalAmount.toStringAsFixed(2)}",
                  style: AppTextStyles.cardTitle.copyWith(
                    color: GlobalConfig.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GlobalConfig.primaryColor,
                  GlobalConfig.primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: GlobalConfig.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreditCardFormScreen(
                        apartment: widget.apartment,
                        fees: unpaidFees,
                      ),
                    ),
                  );

                  if (result != null && result[0] == true) {
                    _fetchData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment successful!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.payment_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Pay Outstanding Fees',
                        style: AppTextStyles.cardTitle.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.apartment.id == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Resident Details'.tr())),
        body: Center(child: Text('Invalid Apartment Data'.tr())),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: Text('Resident Details'.tr())),
      bottomNavigationBar: _buildPaymentSection(),
      body: Column(
        children: [
          Stack(
            children: [
              _buildTopBackground(),
              Column(
                children: [
                  _buildProfileCard(),
                ],
              ),
            ],
          ),
          if (_isLoading)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: GlobalConfig.primaryColor,
                ),
              ),
            )
          else
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (widget.fees.isNotEmpty) _buildFeesTitle(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchData,
                        color: GlobalConfig.primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          itemCount: widget.fees.length,
                          itemBuilder: (context, index) {
                            final fee = widget.fees[index];
                            return Card(
                              margin: const EdgeInsets.only(
                                  bottom: 4,
                                  top: 4), // Reduced from 8,10 to 4,4
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: -4,
                                  horizontal: 16,
                                ),
                                title: Text(
                                  fee.description.isNotEmpty
                                      ? fee.description
                                      : 'No Description',
                                  style: AppTextStyles.cardTitle.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 2), // Reduced from 6 to 2
                                  child: Text(
                                    _formatDate(fee.feeDate),
                                    style: AppTextStyles.bodyText.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withAlpha(0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '₺${fee.feeAmount.toStringAsFixed(2)}',
                                    style: AppTextStyles.cardTitle.copyWith(
                                      color: GlobalConfig.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Colors.grey,
      thickness: 0.5,
      height: 16,
      indent: 16,
      endIndent: 16,
    );
  }
}

Widget _buildIconInfo(Apartment apartment) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        if (apartment.flatNumber != null)
          _InfoChip(
            icon: Icons.home,
            text: apartment.flatNumber.toString(),
          ),
        if (apartment.numberOfPeople != null)
          _InfoChip(
            icon: Icons.people,
            text: apartment.numberOfPeople.toString(),
          ),
        if (apartment.plateNo != null)
          _InfoChip(
            icon: Icons.directions_car,
            text: apartment.plateNo!,
          ),
      ],
    ),
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: GlobalConfig.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: GlobalConfig.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: GlobalConfig.primaryColor, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.bodyText.copyWith(
              color: GlobalConfig.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildOwnerInfo(Apartment apartment) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (apartment.ownerName != null)
          Row(
            children: [
              const Text(
                "Owner: ",
                style: AppTextStyles.bodyText,
              ),
              Expanded(
                child: Text(
                  apartment.ownerName!,
                  style: AppTextStyles.bodyText,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (apartment.ownerPhone != null)
                Icon(Icons.phone, size: 16, color: GlobalConfig.primaryColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  apartment.ownerPhone!,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    ),
  );
}

Widget _buildDateInfo(Apartment apartment) {
  if (apartment.startDate != null && apartment.endDate != null) {
    final formattedStartDate = DateFormat('dd.MM.yyyy').format(
      DateTime.parse(apartment.startDate!),
    );
    final formattedEndDate = DateFormat('dd.MM.yyyy').format(
      DateTime.parse(apartment.endDate!),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.date_range,
                size: 16,
                color: GlobalConfig.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                "$formattedStartDate - $formattedEndDate",
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  return const SizedBox.shrink();
}

bool _hasOwnerInfo(Apartment apartment) {
  return apartment.ownerName != null || apartment.ownerPhone != null;
}

bool _hasIconInfo(Apartment apartment) {
  return apartment.flatNumber != null ||
      apartment.numberOfPeople != null ||
      apartment.plateNo != null;
}

bool _hasDateInfo(Apartment apartment) {
  return apartment.startDate != null && apartment.endDate != null;
}
