import 'package:http/http.dart' as http;

import '../../global/index.dart';

class NewsService {
  BehaviorSubject<List<News>?> news$ = BehaviorSubject.seeded(null);

  Future<RequestResponse?> fetchNews(DateTime startDate, DateTime endDate) async {
    try {
      var response = await http.post(Uri.parse(GlobalConfig.url),
          body: json.encode({
            "Action": "Execute",
            "Object": "SP_MOBILE_APARTMENT_NEWS_LIST",
            "Parameters": {"APARTMENTUID": apartmentUid, "STARTDATE": DateFormat('d.M.yy').format(startDate), "ENDDATE": DateFormat('d.M.yy').format(endDate)}
          }));

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        if (data[0].isNotEmpty) {
          List<News> news = [];
          data[0].forEach((newsItem) {
            news.add(News.fromJson(newsItem));
          });
          news$.add(news);
        } else {
          news$.add([]);
        }
      }
    } catch (e) {}
    return null;
  }
}
