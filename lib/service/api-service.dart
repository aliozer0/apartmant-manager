import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

import '../global/index.dart';

class APIService {
  BehaviorSubject<List<Apartment>?> apartments$ = BehaviorSubject.seeded(null);
  BehaviorSubject<Map<int, List<Fee>?>> fees$ = BehaviorSubject.seeded({});
  BehaviorSubject<List<News>?> news$ = BehaviorSubject.seeded([]);

  late final Stream<List<Apartment>?> apartmentsBroadcast;
  late final Stream<Map<int, List<Fee>?>> feesBroadcast;
  late final Stream<Tuple2<List<Apartment>?, Map<int, List<Fee>?>?>> combinedStream$;

  APIService() {
    apartmentsBroadcast = apartments$.stream.asBroadcastStream();
    feesBroadcast = fees$.stream.asBroadcastStream();

    combinedStream$ = Rx.combineLatest2(apartments$, fees$, (List<Apartment>? apartments, Map<int, List<Fee>?>? fees) {
      return Tuple2(apartments, fees);
    }).asBroadcastStream();
  }

  Future<List<Apartment>> fetchApartments(String blockName, int hotelId) async {
    final Map<String, dynamic> requestBody = {
      "Action": "Execute",
      "Object": "SP_MOBILE_APARTMENT_FLATS_LIST",
      "Parameters": {"BLOCKNAME": blockName, "HOTELID": hotelId}
    };

    try {
      var response = await http.post(
        Uri.parse('${GlobalConfig.url}/Execute/SP_MOBILE_APARTMENT_FLATS_LIST'),
        headers: {'User-Agent': 'appartmentApp_1.0.0'},
        body: json.encode(requestBody),
      );

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
      } else {
        debugPrint("HTTP Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Failed to upload apartments: $e");
    }
    return [];
  }

  Future<List<Fee>> fetchFees(int apartmentId, int hotelId) async {
    final Map<String, dynamic> requestBody = {
      "Action": "Execute",
      "Object": "SP_MOBILE_APARTMENT_FEES_LIST",
      "Parameters": {"ID": apartmentId, "HOTELID": hotelId}
    };

    try {
      var response = await http.post(Uri.parse(GlobalConfig.url), body: json.encode(requestBody));

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        if (data[0].isNotEmpty) {
          List<Fee> fees = [];
          data[0].forEach((fee) {
            fees.add(Fee.fromJson(fee));
          });

          final currentFees = fees$.value;
          currentFees[apartmentId] = fees;
          fees$.add(currentFees);
        }
      }
    } catch (e) {
      debugPrint("Failed to upload fees: $e");
    }
    return [];
  }

  Future<List<News>> fetchNews(int hotelId, DateTime startDate, DateTime endDate) async {
    final Map<String, dynamic> requestBody = {
      "Action": "Execute",
      "Object": "SP_MOBILE_APARTMENT_NEWS_LIST",
      "Parameters": {
        "HOTELID": hotelId,
        "STARTDATE": DateFormat('d.M.yy').format(startDate),
        "ENDDATE": DateFormat('d.M.yy').format(endDate),
      }
    };

    try {
      var response = await http.post(Uri.parse(GlobalConfig.url), body: json.encode(requestBody));

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
    } catch (e) {
      debugPrint("Failed to upload news: $e");
    }
    return [];
  }
}
