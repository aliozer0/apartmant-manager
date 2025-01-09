import 'package:flutter/material.dart';


import '../../global/index.dart';
import '../../index.dart';

class NewsPage extends StatefulWidget {
  final int hotelId;
  final String startDate;
  final String endDate;

  const NewsPage({Key? key, required this.hotelId, required this.startDate, required this.endDate}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final APIService apiService = GetIt.I<APIService>();

  @override
  void initState() {
    super.initState();
    // apiService.fetchNews(widget.hotelId, DateTime.parse(widget.startDate),
    //     DateTime.parse(widget.endDate));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: StreamBuilder(
          stream: apiService.news$.stream,
          builder: (context, snapshot) {
            if (apiService.news$.value == null) {
              return Center(
                child: CircularProgressIndicator(color: GlobalConfig.primaryColor),
              );
            } else if (apiService.news$.value!.isEmpty) {
              return const Center(
                child: Text('Duyuru Bulunamadı', style: normalTextStyle),
              );
            }
            final news = apiService.news$.value;

            apiService.news$.value!.sort((a, b) => b.startDate.compareTo(a.startDate));

            return Container(
              color: background,
              child: ListView.builder(
                itemCount: news!.length,
                itemBuilder: (context, index) {
                  return NewsList(news: news[index]);
                },
              ),
            );
          }),
    ));
  }
}
