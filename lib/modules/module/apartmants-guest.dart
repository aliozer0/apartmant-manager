import 'dart:async';

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
  final searchController = TextEditingController();
  final BehaviorSubject<bool> isSearch$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<List<Apartment>?> filteredApartments$ = BehaviorSubject<List<Apartment>>();

  @override
  void initState() {
    super.initState();
    isLoading$.add(true);
    globalService.fetchApartments().then((value) {
      filteredApartments$.add(globalService.apartments$.value);
    });
    isLoading$.add(false);
    searchController.addListener(() {
      _filterApartments(searchController.text);
    });
  }

  void _filterApartments(String query) {
    final lowerCaseQuery = query.toLowerCase();

    if (lowerCaseQuery.isEmpty) {
      final originalList = globalService.apartments$.valueOrNull ?? [];
      filteredApartments$.add(originalList);
    } else {
      final originalList = globalService.apartments$.valueOrNull ?? [];
      final filteredList = originalList.where((apartment) {
        final nameMatches = apartment.name?.toLowerCase().contains(lowerCaseQuery) ?? false;
        final contactMatches = apartment.contactName?.toLowerCase().contains(lowerCaseQuery) ?? false;
        return nameMatches || contactMatches;
      }).toList();
      filteredApartments$.add(filteredList);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    filteredApartments$.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: isSearch$,
        builder: (context, snapshot) {
          return Scaffold(
              appBar: AppBar(
                  title: isSearch$.value
                      ? TextField(
                          controller: searchController,
                          onChanged: (value) => _filterApartments(searchController.text),
                          decoration: InputDecoration(hintText: 'Search Apartments Guest'.tr(), border: InputBorder.none),
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white)
                      : Text('Apartment Guests'.tr()),
                  actions: [
                    IconButton(
                        icon: Icon(isSearch$.value ? Icons.close : Icons.search, color: Colors.white),
                        onPressed: () {
                          if (isSearch$.value) {
                            searchController.clear();
                          }
                          isSearch$.add(!isSearch$.value);
                        })
                  ]),
              body: isLoading$.value
                  ? Center(child: CircularProgressIndicator(color: GlobalConfig.primaryColor))
                  : RefreshIndicator(
                      color: GlobalConfig.primaryColor,
                      onRefresh: () => globalService.fetchApartments(),
                      child: StreamBuilder(
                          stream: filteredApartments$.stream,
                          builder: (context, snapshot) {
                            if (filteredApartments$.value == null) {
                              return Center(child: CircularProgressIndicator(color: GlobalConfig.primaryColor));
                            } else if (filteredApartments$.value!.isEmpty) {
                              return Center(child: Text('No Apartment Found'.tr(), style: k19_5Gilroy(context)));
                            }
                            return SizedBox(
                                height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                                child: ListView.builder(
                                  itemCount: filteredApartments$.value?.length,
                                  itemBuilder: (context, index) => apartmentGuestItem(filteredApartments$.value![index], context),
                                ));
                          })));
        });
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
            Navigator.push(context, RouteAnimation.createRoute(DetailPage(apartment: apartment), 1, 0));
          },
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: Container(
                  padding: paddingAll5,
                  child: Column(children: [
                    apartment.photoUrl != null
                        ? CircleAvatar(backgroundImage: NetworkImage(apartment.photoUrl ?? ''), radius: 40)
                        : Icon(Icons.account_circle, size: 80, color: Colors.grey[400]),
                  ])),
            ),
            Expanded(
              flex: 3,
              child: SizedBox(
                  height: W / 4,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Text(apartment.contactName ?? '', style: k25Trajan(context), overflow: TextOverflow.ellipsis, softWrap: true, maxLines: 3)),
                    Text(apartment.blockName ?? '', style: k25Gilroy(context)),
                    const Spacer(),
                    Row(children: [
                      if (apartment.phone == null)
                        InkWell(
                            child: Container(
                                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                padding: const EdgeInsets.all(6.0),
                                child: const Icon(Icons.phone, color: Colors.white)),
                            onTap: () => makePhoneCall(apartment.phone!)),
                      SizedBox(width: W / 30),
                      InkWell(
                          onTap: () => sendEmail(apartment.email!),
                          child: Container(
                              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                              padding: const EdgeInsets.all(6.0),
                              child: const Icon(Icons.email, color: Colors.white))),
                      SizedBox(width: W / 30),
                      if (apartment.phone == null)
                        InkWell(
                            child: Container(
                                decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                                padding: const EdgeInsets.all(6.0),
                                child: const Icon(Icons.sms, color: Colors.white)))
                    ])
                  ])),
            ),
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
