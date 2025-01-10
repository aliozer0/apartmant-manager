import 'package:flutter/material.dart';

import '../../global/index.dart';
import '../../index.dart';

class DetailPage extends StatefulWidget {
  final Apartment apartment;
  final List<Fee> fees;

  DetailPage({required this.apartment, required this.fees});

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
    await apiService.fetchApartments(widget.apartment.blockName!, widget.apartment.hotelId!);
    final apartments = await apiService.apartments$.first;
    if (apartments != null && apartments.isNotEmpty) {
      await apiService.fetchFees(apartments.first.id!, apartments.first.hotelId!);
    }
  }

  Future<void> refreshPage() async {
    await fetchData();
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd.MM.yyyy').format(parsedDate);
  }

  double getTotalFeeAmount(List<Fee> fees) {
    return fees.fold(0.0, (sum, fee) => sum + (fee.feeAmount ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final apartmentBalance = widget.apartment.balance;

    return Scaffold(
      appBar: AppBar(
        title: Text('Apartment Details'.tr()),
      ),
      body: RefreshIndicator(
        onRefresh: refreshPage,
        color: GlobalConfig.primaryColor,
        backgroundColor: background,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ProfileCard(apartment: widget.apartment),
            ],
          ),
          // child: StreamBuilder(
          //   stream: Rx.combineLatest2(apiService.fees$, apiService.apartments$, (a, b) => null),
          //   builder: (context, snapshot) {
          //
          //
          //
          //
          //
          //     // if (snapshot.connectionState == ConnectionState.waiting) {
          //     //   return Center(
          //     //     child: CircularProgressIndicator(color: GlobalConfig.primaryColor),
          //     //   );
          //     // } else if (!snapshot.hasData || snapshot.data!.item1 == null || snapshot.data!.item1!.isEmpty) {
          //     //   return const Center(child: Text('No apartments found.'));
          //     // } else {
          //     //   Map<int, List<Fee>?> feesMap = snapshot.data!.item2 ?? {};
          //     //   List<Fee> fees = feesMap[widget.apartment.id] ?? [];
          //
          //       // return Column(
          //       //   crossAxisAlignment: CrossAxisAlignment.start,
          //       //   children: [
          //       //     ProfileCard(apartment: widget.apartment),
          //       //     FeesList(fees: fees, apartment: widget.apartment),
          //       //     SizedBox(height: apartmentBalance! > 0 ? 80.0 : 0.0),
          //       //   ],
          //       // );
          //     // }
          //   },
          // ),
        ),
      ),
    );
  }
}
