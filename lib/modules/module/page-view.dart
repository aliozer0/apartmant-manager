import 'package:flutter/material.dart';

import '../../index.dart';

class PageViewScreen extends StatelessWidget {
  final String blockName;
  final int hotelId;
  final String startDate;
  final String endDate;

  const PageViewScreen({Key? key, required this.blockName, required this.hotelId , required this.endDate, required this.startDate }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView(
          scrollDirection: Axis.horizontal,
          children:[
            HomePage(blockName: blockName, hotelId: hotelId),
            NewsPage(hotelId: hotelId, startDate: startDate, endDate: endDate)
          ]
        );


  }
}