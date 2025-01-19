import 'package:http/http.dart' as http;
import 'index.dart';

class GlobalService {
  BehaviorSubject<List<Apartment>?> apartments$ = BehaviorSubject.seeded(null);
  BehaviorSubject<List<News>?> news$ = BehaviorSubject.seeded(null);
  BehaviorSubject<Map<String, List<Fee>?>> fees$ = BehaviorSubject.seeded({});

  late final Stream<List<Apartment>?> apartmentsBroadcast;
  late final Stream<Map<int, List<Fee>?>> feesBroadcast;

  // Dispose streams to avoid memory leaks
  void dispose() {
    apartments$.close();
    news$.close();
    fees$.close();
  }

  Future<List<Apartment>> fetchApartments(String apartmentUid) async {
    final Map<String, dynamic> requestBody = {
      "Action": "Execute",
      "Object": "SP_MOBILE_APARTMENT_FLATS_LIST",
      "Parameters": {"APARTMENTUID": apartmentUid}
    };

    try {
      var response = await http.post(
        Uri.parse('${GlobalConfig.url}/Execute/SP_MOBILE_APARTMENT_FLATS_LIST'),
        headers: {'User-Agent': 'apartmentApp_1.0.0'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));

        // Check if the response data is valid
        if (data is List && data.isNotEmpty && data[0] is List) {
          List<Apartment> apartments = (data[0] as List)
              .map((apartment) =>
                  Apartment.fromJson(apartment as Map<String, dynamic>))
              .toList();
          apartments$.add(apartments);
          return apartments;
        } else {
          apartments$.add([]); // Add an empty list if no apartments found
        }
      }
    } catch (e, stackTrace) {
      print('Error fetching apartments: $e');
      print('Stack Trace: $stackTrace');
    }

    return [];
  }

  Future<List<Fee>> fetchFees(String apartmentUid, int flatId) async {
    try {
      var response = await http.post(
        Uri.parse('${GlobalConfig.url}/Execute/SP_MOBILE_APARTMENT_FEES_LIST'),
        body: json.encode({
          "Action": "Execute",
          "Object": "SP_MOBILE_APARTMENT_FEES_LIST",
          "Parameters": {"APARTMENTUID": apartmentUid, "FLATID": flatId}
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));

        // Check if the response data is valid
        if (data is List && data.isNotEmpty && data[0] is List) {
          List<Fee> fees = (data[0] as List)
              .map((fee) => Fee.fromJson(fee as Map<String, dynamic>))
              .toList();

          // Update the BehaviorSubject with new data
          fees$.value[apartmentUid] = fees;
          fees$.add(fees$.value);
          return fees;
        }
      }
    } catch (e, stackTrace) {
      print('Error fetching fees: $e');
      print('Stack Trace: $stackTrace');
    }

    return [];
  }

  Future<RequestResponse?> fetchNews(
      String apartmentUid, DateTime startDate, DateTime endDate) async {
    try {
      var response = await http.post(
        Uri.parse('${GlobalConfig.url}/Execute/SP_MOBILE_APARTMENT_NEWS_LIST'),
        body: json.encode({
          "Action": "Execute",
          "Object": "SP_MOBILE_APARTMENT_NEWS_LIST",
          "Parameters": {
            "APARTMENTUID": apartmentUid,
            "STARTDATE": DateFormat('d.M.yy').format(startDate),
            "ENDDATE": DateFormat('d.M.yy').format(endDate),
          }
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));

        // Check if the response data is valid
        if (data is List && data.isNotEmpty && data[0] is List) {
          List<News> news = (data[0] as List)
              .map(
                  (newsItem) => News.fromJson(newsItem as Map<String, dynamic>))
              .toList();
          news$.add(news);
          return RequestResponse(
              message: 'News fetched successfully', result: true);
        } else {
          news$.add([]); // Add an empty list if no news found
        }
      }
    } catch (e, stackTrace) {
      print('Error fetching news: $e');
      print('Stack Trace: $stackTrace');
    }

    return null;
  }
}
