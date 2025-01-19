import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../global/index.dart';
import '../../index.dart';

class DetailPage extends StatefulWidget {
  final Apartment apartment;
  final List<Fee> fees;
  final String apartmentUid;

  DetailPage(
      {required this.apartmentUid,
      required this.apartment,
      required this.fees});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final apiService = GetIt.I<GlobalService>();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await apiService.fetchApartments(widget.apartmentUid);
    final apartments = await apiService.apartments$.first;
    if (apartments != null && apartments.isNotEmpty) {
      await apiService.fetchFees(widget.apartmentUid, apartments.first.id!);
    } else {
      debugPrint('No apartments found');
    }
  }

  Future<void> refreshPage() async {
    await fetchData();
    setState(() {}); // Refresh UI after fetching data
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd.MM.yyyy').format(parsedDate);
  }

  double getTotalFeeAmount(List<Fee> fees) {
    return fees.fold(0.0, (sum, fee) => sum + fee.feeAmount);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.apartment.id == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Apartment Details'.tr()),
        ),
        body: Center(
          child: Text('Invalid Apartment Data'.tr()),
        ),
      );
    }

    final apartmentBalance = widget.apartment.balance ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Resident Details'.tr()),
      ),
      body: RefreshIndicator(
        onRefresh: refreshPage,
        color: GlobalConfig.primaryColor,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileCard(apartment: widget.apartment),
              if (widget.fees.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.fees.length,
                  itemBuilder: (context, index) {
                    final fee = widget.fees[index];
                    return ListTile(
                      title: Text(fee.description.isNotEmpty
                          ? fee.description
                          : 'No Description'),
                      subtitle: Text(formatDate(fee.feeDate)),
                      trailing: Text(
                        '₺ ${fee.feeAmount.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.green),
                      ),
                    );
                  },
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No fees available'.tr(),
                  ),
                ),
              if (apartmentBalance > 0)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Balance: ₺ ${apartmentBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
