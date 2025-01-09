import 'package:apartmantmanager/Global/global-variables.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:url_launcher/url_launcher.dart';

import '../global/global-model.dart';
import '../index.dart';

class ApartmentCard extends StatelessWidget {
  final Apartment apartment;
  final APIService apiService = GetIt.I<APIService>();

  ApartmentCard({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    int? flatNumber;
    String contactName = apartment.contactName ?? 'Unknown';
    String plateNo = apartment.plateNo ?? 'N/A';
    String phone = apartment.phone ?? '';
    int numberOfPeople = apartment.numberOfPeople ?? 0;
    String email = apartment.email ?? '';
    String photoUrl = apartment.photoUrl ?? '';

    try {
      flatNumber = int.parse(apartment.flatNumber ?? '0');
    } catch (e) {
      flatNumber = 0;
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Card(
            color: Colors.white,
            margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius10,
            ),
            child: InkWell(
              borderRadius: borderRadius10,
              onTap: () async {
                final apartmentId = apartment.id;
                try {
                  if (apartmentId == null) {
                    throw ArgumentError('Apartment ID cannot be null');
                  }
                  if (apartment.hotelId == null) {
                    throw ArgumentError('Hotel ID cannot be null');
                  }
                  final fees = await apiService.fetchFees(apartmentId!, apartment.hotelId!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        apartment: apartment,
                        fees: fees
                      ),
                    ),
                  );
                } catch (e) {
                  print('Failed to load fees: $e');
                }
              },
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          photoUrl.isNotEmpty
                              ? CircleAvatar(backgroundImage: NetworkImage(photoUrl), radius: 40)
                              : Icon(Icons.account_circle, size: 80, color: Colors.grey[400]),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(contactName, style: k25Trajan(context), overflow: TextOverflow.ellipsis, softWrap: true, maxLines: 3),
                            const SizedBox(height: 10),
                            IntrinsicHeight(
                                child: Row(children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.people, color: Colors.black, size: 25),
                                  const SizedBox(width: 10),
                                  Text(numberOfPeople.toString(), style: k25Trajan(context).copyWith(fontSize: 18)),
                                ],
                              ),
                              if (plateNo != 'N/A')
                                VerticalDivider(
                                  color: Colors.grey[400],
                                  thickness: 1,
                                  width: 20,
                                ),
                              if (plateNo != 'N/A')
                                Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  const Icon(Icons.car_rental_outlined, color: Colors.black, size: 25),
                                  const SizedBox(width: 10),
                                  Text(plateNo, style: k25Trajan(context).copyWith(fontSize: 18))
                                ])
                            ])),
                            Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(6.0),
                                          child: const Icon(
                                            Icons.phone,
                                            color: Colors.white,
                                          ),
                                        ),
                                        onPressed: () {
                                          makePhoneCall(phone);
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        icon: Container(
                                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                          padding: const EdgeInsets.all(6.0),
                                          child: const Icon(Icons.email, color: Colors.white),
                                        ),
                                        onPressed: () {
                                          sendEmail(email);
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        icon: Container(
                                          decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                                          padding: const EdgeInsets.all(6.0),
                                          child: const Icon(Icons.sms, color: Colors.white),
                                        ),
                                        onPressed: () {
                                          sendSMS(phone);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  if (apartment.balance != null && apartment.balance != 0)
                                    Expanded(
                                        child: Text('${apartment.balance} TL',
                                            style: k25Trajan(context).copyWith(color: Colors.red), overflow: TextOverflow.ellipsis, softWrap: true, maxLines: 3))
                                ]))
                          ]))
                        ])
                      ],
                    )),
                  ])),
            ),
          ),
        ),
        Positioned(
          right: 5.0,
          top: 5.0,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle),
            child: Row(
              children: [
                Text(
                  flatNumber.toString(),
                  style: k25Trajan(context).copyWith(color: Colors.black)
                ),
                const Icon(Icons.home, color: Colors.black),
              ],
            ),
          ),
        ),
      ],
    );
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
}
