import 'package:flutter/material.dart';
import '../../global/index.dart';

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
      padding: const EdgeInsets.only(left: 16, right: 28, top: 8, bottom: 8),
      margin: const EdgeInsets.only(bottom: 8, right: 16, left: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: GlobalConfig.primaryColor.withAlpha(200),
            width: 2,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Description'.tr(),
            style: AppTextStyles.cardTitle,
          ),
          Text(
            'Amount'.tr(),
            style: AppTextStyles.cardTitle,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
      margin: const EdgeInsets.only(top: 8, bottom: 20, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
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
          if (_hasIconInfo(widget.apartment)) const SizedBox(height: 16),
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

  Widget _buildFeesList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: _fetchData,
        color: GlobalConfig.primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: widget.fees.length,
          itemBuilder: (context, index) {
            final fee = widget.fees[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                title: Text(
                  fee.description.isNotEmpty
                      ? fee.description
                      : 'No Description',
                  style: AppTextStyles.cardTitle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
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
                    vertical: 6,
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
      bottomNavigationBar: BottomAppBar(
        height: 50,
        color: GlobalConfig.primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Fees".tr(),
                style: AppTextStyles.cardTitle.copyWith(
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Text(
                  "₺${_getTotalFeeAmount().toStringAsFixed(2)}",
                  style: AppTextStyles.cardTitle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              _buildTopBackground(),
              Column(
                children: [
                  _buildProfileCard(),
                  if (widget.fees.isNotEmpty) _buildFeesTitle(),
                ],
              ),
            ],
          ),
          if (_isLoading)
            Expanded(
              child: Center(
                  child: CircularProgressIndicator(
                color: GlobalConfig.primaryColor,
              )),
            )
          else
            _buildFeesList(),
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
      height: 20,
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
