import 'package:apartmantmanager/modules/news/news-service.dart';
import 'package:flutter/material.dart';

import '../../global/index.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final service = GetIt.I<NewsService>();

  @override
  void initState() {
    service.fetchNews(DateTime.parse('2024-01-01'), DateTime.parse('2026-01-01'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double W = MediaQuery.of(context).size.width;
    double H = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
            title: Text('Announcements'.tr()), leading: InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios_new_rounded))),
        body: StreamBuilder(
            stream: service.news$.stream,
            builder: (context, snapshot) {
              if (service.news$.value == null) {
                return Center(child: CircularProgressIndicator(color: GlobalConfig.primaryColor));
              } else if (service.news$.value!.isEmpty) {
                return Center(child: Text('No Announcement Found'.tr(), style: k19_5Gilroy(context)));
              }
              service.news$.value!.sort((a, b) => b.startDate.compareTo(a.startDate));
              return Container(
                  color: Colors.grey[200],
                  height: H * 0.9,
                  child: ListView.builder(
                      itemCount: service.news$.value!.length,
                      itemBuilder: (context, index) {
                        var news = service.news$.value![index];
                        return Container(
                            decoration: BoxDecoration(borderRadius: borderRadius10, color: Colors.white),
                            padding: paddingAll5,
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                Icon(Icons.notifications, color: GlobalConfig.primaryColor, size: 30),
                                SizedBox(width: W / 30),
                                Expanded(child: Text(news.content, style: k25Trajan(context)))
                              ]),
                              SizedBox(height: W / 40),
                              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                Text(DateFormat('dd MMM yyyy', 'tr_TR').format(DateTime.parse(news.startDate.toString())),
                                    style: k25Trajan(context).copyWith(fontSize: 12)),
                                Text(' - ', style: k25Trajan(context).copyWith(fontSize: 12)),
                                Text(DateFormat('dd MMM yyyy', 'tr_TR').format(DateTime.parse(news.endDate.toString())),
                                    style: k25Trajan(context).copyWith(fontSize: 12)),
                              ])
                            ]));
                      }));
            }));
  }
}
