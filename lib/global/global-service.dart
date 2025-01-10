import 'package:http/http.dart' as http;

import 'index.dart';

class GlobalService {
  BehaviorSubject<List<Apartment>?> apartments$ = BehaviorSubject.seeded(null);
  BehaviorSubject<List<News>?> news$ = BehaviorSubject.seeded(null);

  BehaviorSubject<Map<int, List<Fee>?>> fees$ = BehaviorSubject.seeded({});

  late final Stream<List<Apartment>?> apartmentsBroadcast;
  late final Stream<Map<int, List<Fee>?>> feesBroadcast;

  Future<List<Apartment>> fetchApartments(String blockName, int hotelId) async {
    final Map<String, dynamic> requestBody = {
      "Action": "Execute",
      "Object": "SP_MOBILE_APARTMENT_FLATS_LIST",
      "Parameters": {"BLOCKNAME": blockName, "HOTELID": hotelId}
    };

    try {
      var response = await http.post(Uri.parse('${GlobalConfig.url}/Execute/SP_MOBILE_APARTMENT_FLATS_LIST'),
          headers: {'User-Agent': 'appartmentApp_1.0.0'}, body: json.encode(requestBody));

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));

        if (data[0].isNotEmpty) {
          List<Apartment> apartments = [];
          data[0].forEach((apartment) {
            apartments.add(Apartment.fromJson(apartment));
          });
          apartments$.add(apartments);
        } else {
          apartments$.add([]);
        }
      }
    } catch (e) {}
    return [];
  }

  Future<List<Fee>> fetchFees(int apartmentId, int hotelId) async {
    try {
      var response = await http.post(Uri.parse(GlobalConfig.url),
          body: json.encode({
            "Action": "Execute",
            "Object": "SP_MOBILE_APARTMENT_FEES_LIST",
            "Parameters": {"ID": apartmentId, "HOTELID": hotelId}
          }));

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        if (data[0].isNotEmpty) {
          List<Fee> fees = [];
          data[0].forEach((fee) {
            fees.add(Fee.fromJson(fee));
          });
          fees$.value[apartmentId] = fees;
          fees$.add(fees$.value);
        }
      }
    } catch (e) {}
    return [];
  }

  Future<RequestResponse?> fetchNews(DateTime startDate, DateTime endDate) async {
    try {
      var response = await http.post(Uri.parse(GlobalConfig.url),
          body: json.encode({
            "Action": "Execute",
            "Object": "SP_MOBILE_APARTMENT_NEWS_LIST",
            "Parameters": {
              "HOTELID": GlobalConfig.hotelId,
              "STARTDATE": DateFormat('d.M.yy').format(startDate),
              "ENDDATE": DateFormat('d.M.yy').format(endDate)
            }
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
