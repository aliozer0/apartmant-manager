import 'package:flutter/material.dart';

import '../../global/index.dart';
import '../../index.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({
    Key? key,
  }) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final APIService apiService = GetIt.I<APIService>();

  @override
  void initState() {
    super.initState();
    apiService.fetchNews(DateTime.parse('2024-01-01'), DateTime.parse('2026-01-01'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text('Announcements'.tr()), backgroundColor: GlobalConfig.primaryColor),
      body: StreamBuilder(
          stream: apiService.news$.stream,
          builder: (context, snapshot) {
            if (apiService.news$.value == null) {
              return Center(child: CircularProgressIndicator(color: GlobalConfig.primaryColor));
            } else if (apiService.news$.value!.isEmpty) {
              return Center(child: Text('No Announcement Found'.tr(), style: k19_5Gilroy(context)));
            }
            apiService.news$.value!.sort((a, b) => b.startDate.compareTo(a.startDate));
            return Container(
              color: background,
              child: ListView.builder(
                itemCount: apiService.news$.value!.length,
                itemBuilder: (context, index) {
                  return NewsList(news: apiService.news$.value![index]);
                },
              ),
            );
          }),
    ));
  }
}
