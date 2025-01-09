
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../global/index.dart';


class ProfileCard extends StatelessWidget {
  final Apartment apartment;

  const ProfileCard({super.key, required this.apartment});

  String formatDate(String date) {
    initializeDateFormatting('tr_TR', null);
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd MMM yyyy', 'tr_TR').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          color: Colors.green,
          margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
          shape: RoundedRectangleBorder(
            borderRadius:borderRadius10
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IntrinsicHeight(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    apartment.photoUrl != null && apartment.photoUrl!.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(apartment.photoUrl!),
                            radius: 40,
                          )
                        : Icon(Icons.account_circle, size: 80, color: Colors.grey[400]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (apartment.idNo != null && apartment.idNo.isNotEmpty)  Text("KİMLİK NO:", style:  k25Trajan(context)),
                               Text("OTURAN:", style: k25Trajan(context)),
                               Text("TELEFON:", style:  k25Trajan(context)),
                              if (apartment.contactName.toLowerCase() != apartment.ownerName.toLowerCase())  Text("EV SAHİBİ:", style:  k25Trajan(context)),
                              if (apartment.contactName.toLowerCase() != apartment.ownerName.toLowerCase())  Text("TELEFON:", style:  k25Trajan(context)),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (apartment.idNo != null && apartment.idNo.isNotEmpty)
                                  Text(apartment.idNo, style: k25Trajan(context) , overflow: TextOverflow.ellipsis),
                                Text(apartment.contactName, style:  k25Trajan(context), overflow: TextOverflow.ellipsis),
                                Text(apartment.phone, style: k25Gilroy(context), overflow: TextOverflow.ellipsis),
                                if (apartment.contactName.toLowerCase() != apartment.ownerName.toLowerCase())
                                  Text(apartment.ownerName, style: k25Gilroy(context), overflow: TextOverflow.ellipsis),
                                if (apartment.contactName.toLowerCase() != apartment.ownerName.toLowerCase())
                                  Row(
                                    children: [
                                      Text(
                                        apartment.ownerPhone,
                                        style: k25Gilroy(context),
                                      ),
                                      SizedBox(width: 5),
                                      InkWell(
                                        onTap: () {
                                          FlutterClipboard.copy(apartment.ownerPhone);
                                          showDialog(
                                            barrierColor: Colors.transparent,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                  insetPadding: const EdgeInsets.all(5),
                                                  backgroundColor: Colors.grey[850],
                                                  content: SizedBox(
                                                      height: 20,
                                                      child: Center(child: Text("Numara kopyalandı!", style: k23Gilroy(context).copyWith(color: Colors.black)))));
                                            },
                                          );

                                          Future.delayed(const Duration(seconds: 1), () {
                                            Navigator.of(context).pop();
                                          });
                                        },
                                        child: const Icon(Icons.copy, size: 17, color: Colors.black),
                                      )
                                    ],
                                  )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
                Divider(color: Colors.grey[400]),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.people, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(apartment.numberOfPeople.toString(), style: k25Gilroy(context)),
                          ],
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.grey[400],
                        thickness: 1,
                        width: 20,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.car_rental_outlined, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(apartment.plateNo, style: k25Gilroy(context)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey[400]),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                 Text("Başlangıç Tarihi", style:  k25Trajan(context)),
                                Text(formatDate(apartment.startDate), style: k25Gilroy(context)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.grey[400],
                        thickness: 1,
                        width: 20,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                 Text("Bitiş Tarihi", style:  k25Trajan(context)),
                                Text(formatDate(apartment.endDate), style: k25Gilroy(context)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Positioned(
          left: 5.0,
          top: 5.0,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Row(
              children: [
                Text(
                  apartment.flatNumber.toString(),
                  style: k25Trajan(context).copyWith(color: Colors.black),
                ),
                const Icon(Icons.home, color: Colors.black),
              ],
            ),
          )),
    ]);
  }
}
