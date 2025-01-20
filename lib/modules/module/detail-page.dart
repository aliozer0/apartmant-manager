import 'package:flutter/material.dart';

import '../../global/index.dart';
import '../../index.dart';

class DetailPage extends StatefulWidget {
  final Apartment apartment;

  DetailPage({required this.apartment});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final globalService = GetIt.I<GlobalService>();

  @override
  void initState() {
    globalService.fetchFees(widget.apartment.id!);
    super.initState();
  }

  // Future<void> fetchData() async {
  //   await globalService.fetchApartments();
  //   final apartments = await globalService.apartments$.first;
  //   if (apartments != null && apartments.isNotEmpty) {
  //     await globalService.fetchFees(apartments.first.id!);
  //   }
  // }
  //
  // Future<void> refreshPage() async {
  //   await fetchData();
  // }
  //
  // String formatDate(String date) {
  //   final parsedDate = DateTime.parse(date);
  //   return DateFormat('dd.MM.yyyy').format(parsedDate);
  // }
  //
  // double getTotalFeeAmount(List<Fee> fees) {
  //   return fees.fold(0.0, (sum, fee) => sum + (fee.feeAmount ?? 0.0));
  // }

  @override
  Widget build(BuildContext context) {
    double W = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(title: Text('Apartment Details'.tr())),
        body: RefreshIndicator(
            onRefresh: () => globalService.fetchFees(widget.apartment.id!),
            color: GlobalConfig.primaryColor,
            child: Column(children: [
              ProfileCard(apartment: widget.apartment),
              SizedBox(height: W / 40),
              StreamBuilder(
                  stream: globalService.fees$.stream,
                  builder: (context, snapshot) {
                    if (globalService.fees$.value == null) {
                      return Center(child: CircularProgressIndicator(color: GlobalConfig.primaryColor));
                    } else if (globalService.fees$.value!.isEmpty) return const Center(child: Text("Borcunuz bulunmamaktadır."));
                    return Expanded(
                        child: ListView.builder(
                            itemCount: globalService.fees$.value?.length,
                            itemBuilder: (context, index) {
                              var item = globalService.fees$.value![index];
                              return ListTile(
                                title: Text(item.feeAmount.toString()),
                                subtitle: Text(item.description),
                                trailing: Text(item.feeDate.toString()),
                              );
                              // return Text('${}');
                            }));
                  })
            ])));
  }
}
