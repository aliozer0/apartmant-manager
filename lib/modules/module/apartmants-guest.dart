import 'package:apartmantmanager/global/index.dart';
import 'package:flutter/material.dart';

class ApartmantsGuest extends StatefulWidget {
  const ApartmantsGuest({super.key});

  @override
  State<ApartmantsGuest> createState() => _ApartmantsGuestState();
}

class _ApartmantsGuestState extends State<ApartmantsGuest> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Apartment Guest'.tr())),
        body: RefreshIndicator(
          child: SingleChildScrollView(),
          onRefresh: () {
            return Future.delayed(Duration(seconds: 1));
          },
        ));
  }
}
