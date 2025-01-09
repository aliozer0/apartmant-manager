import 'package:apartmantmanager/index.dart';
import 'package:apartmantmanager/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../../global/index.dart';

class HomePage extends StatefulWidget {
  final String blockName;
  final int hotelId;

  HomePage({Key? key, required this.blockName, required this.hotelId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final APIService apiService = GetIt.I<APIService>();

  @override
  void initState() {
    super.initState();
    apiService.fetchApartments(widget.blockName, widget.hotelId);
    apiService.fetchNews(widget.hotelId, DateTime.parse('2024-01-01'), DateTime.parse('2025-01-01'));
  }

  Future<void> refreshData() async {
    await apiService.fetchApartments(widget.blockName, widget.hotelId);
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    double W = MediaQuery.of(context).size.width;
    double H = MediaQuery.of(context).size.height;

    return StreamBuilder(
        stream: apiService.apartments$.stream,
        builder: (context, snapshot) {
          return Scaffold(
              body: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Column(children: [
                    Padding(
                        padding: paddingAll10,
                        child: Container(
                            width: W,
                            padding: paddingAll10,
                            decoration: BoxDecoration(color: GlobalConfig.primaryColor, borderRadius: BorderRadius.circular(10)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text("Welcome!".tr(), style: k20_5Trajan(context).copyWith(color: Colors.white)),
                              SizedBox(height: W / 40),
                              Text("${apiService.apartments$.value?.first.name} ${apiService.apartments$.value?.first.blockName.toUpperCase()}",
                                  style: k23Gilroy(context).copyWith(color: Colors.white))
                            ]))),
                    Wrap(children: [
                      homeItem(
                          title: "Apartment Guests".tr(),
                          imageAsset: "assets/icons/apartments.png",
                          color: Colors.green,
                          W: W,
                          onTap: () {
                            Navigator.push(context, RouteAnimation.createRoute(const ApartmantsGuest(), 1, 0));
                          }),
                      homeItem(title: "Notifications".tr(), imageAsset: "assets/icons/notifications.png", color: Colors.green, W: W, onTap: () {}),
                      homeItem(
                          title: "Notifications".tr(),
                          imageAsset: "assets/icons/notifications.png",
                          color: Colors.green,
                          W: W,
                          onTap: () {
                            Navigator.push(
                                context,
                                RouteAnimation.createRoute(
                                    NewsPage(
                                        hotelId: widget.hotelId,
                                        startDate: DateTime.now().toString(),
                                        endDate: DateTime.now().add(const Duration(days: 30)).toString()),
                                    1,
                                    0));
                          }),
                    ])
                  ])));
        });
  }

  Widget homeItem({
    required String title,
    required String imageAsset,
    required Color color,
    required double W,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.all(10.0),
        width: W / 2.28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: W / 6, height: W / 6, child: Image.asset(imageAsset, fit: BoxFit.contain, alignment: Alignment.center)),
            SizedBox(height: W / 30),
            Text(title, style: k25Trajan(context).copyWith(color: Colors.white))
          ],
        ),
      ),
    );
  }
}
