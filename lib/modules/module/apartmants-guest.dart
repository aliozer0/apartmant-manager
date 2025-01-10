import 'package:apartmantmanager/global/index.dart';
import 'package:apartmantmanager/index.dart';
import 'package:apartmantmanager/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ApartmantsGuest extends StatefulWidget {
  const ApartmantsGuest({super.key});

  @override
  State<ApartmantsGuest> createState() => _ApartmantsGuestState();
}

class _ApartmantsGuestState extends State<ApartmantsGuest> {
  final globalService = GetIt.I<GlobalService>();

  @override
  void initState() {
    // globalService.fetchApartments(, hotelId)
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Apartment Guests'.tr())),
        body: RefreshIndicator(
          color: GlobalConfig.primaryColor,
          onRefresh: () async {
            await globalService.fetchApartments(apartmentName!, hotelId!);
          },
          child: StreamBuilder(
              stream: globalService.apartments$.stream,
              builder: (context, snapshot) {
                if (globalService.apartments$.value == null) {
                  return Center(child: CircularProgressIndicator(color: GlobalConfig.primaryColor));
                } else if (globalService.apartments$.value!.isEmpty) {
                  return Center(child: Text('No Apartment Found'.tr(), style: k19_5Gilroy(context)));
                }

                return SizedBox(
                    height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                    child: ListView.builder(
                      itemCount: globalService.apartments$.value?.length,
                      itemBuilder: (context, index) => apartmentGuestItem(globalService.apartments$.value![index], context),
                    ));
              }),
        ));
  }
}

Widget apartmentGuestItem(Apartment apartment, BuildContext context) {
  double W = MediaQuery.of(context).size.width;
  return Container(
      padding: paddingAll10,
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius10,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 3))]),
      child: InkWell(
          borderRadius: borderRadius10,
          onTap: () async {
            final fees = await GetIt.I<GlobalService>().fetchFees(apartment.id!, apartment.hotelId!);
            Navigator.push(context, RouteAnimation.createRoute(DetailPage(apartment: apartment, fees: fees), 1, 0));
          },
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: W / 3.5,
                padding: paddingAll5,
                child: Column(children: [
                  apartment.photoUrl != null
                      ? CircleAvatar(backgroundImage: NetworkImage(apartment.photoUrl ?? ''), radius: 40)
                      : Icon(Icons.account_circle, size: 80, color: Colors.grey[400]),
                  Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Row(children: [
                        Text(apartment.flatNumber.toString(), style: k25Trajan(context).copyWith(color: Colors.black)),
                        const Icon(Icons.home, color: Colors.black)
                      ]))
                ])),
            SizedBox(width: W / 50),
            SizedBox(
                width: W / 2,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(apartment.contactName ?? '', style: k25Trajan(context), overflow: TextOverflow.ellipsis, softWrap: true, maxLines: 3),
                  SizedBox(height: W / 40),
                  IntrinsicHeight(
                      child: Row(children: [
                    if (apartment.numberOfPeople != null)
                      Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.people, color: Colors.black, size: 25),
                        const SizedBox(width: 10),
                        Text(apartment.numberOfPeople.toString(), style: k25Trajan(context))
                      ]),
                    if (apartment.plateNo != null) VerticalDivider(color: Colors.grey[400], thickness: 1, width: 20),
                    if (apartment.plateNo != null)
                      Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.car_rental_outlined, color: Colors.black, size: 25),
                        const SizedBox(width: 10),
                        Text(apartment.plateNo!, style: k25Trajan(context).copyWith(fontSize: 18))
                      ])
                  ])),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                          if (apartment.phone != null)
                            InkWell(child: const Icon(Icons.phone, color: Colors.white), onTap: () => makePhoneCall(apartment.phone!)),
                          if (apartment.phone != null) SizedBox(width: W / 40),
                          InkWell(
                              onTap: () => sendEmail(apartment.email!),
                              child: Container(
                                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                  padding: const EdgeInsets.all(6.0),
                                  child: const Icon(Icons.email, color: Colors.white))),
                          if (apartment.email != null) SizedBox(width: W / 40),
                          if (apartment.phone != null)
                            InkWell(
                                child: Container(
                                    decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                                    padding: const EdgeInsets.all(6.0),
                                    child: const Icon(Icons.sms, color: Colors.white)),
                                onTap: () => sendSMS(apartment.phone!))
                        ]),
                        SizedBox(width: W / 40),
                        if (apartment.balance != null && apartment.balance != 0)
                          Text('${apartment.balance} TL',
                              style: k25Trajan(context).copyWith(color: Colors.red), overflow: TextOverflow.ellipsis, softWrap: true, maxLines: 3),
                      ],
                    ),
                  )
                ])),
          ])));
}

Future<void> makePhoneCall(String phoneNumber) async {
  final url = 'tel:$phoneNumber';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> sendEmail(String email) async {
  final url = 'mailto:$email';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> sendSMS(String phoneNumber) async {
  final url = 'sms:$phoneNumber';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
