import 'package:http/http.dart' as http;

import 'index.dart';

class GlobalService {
  BehaviorSubject<List<Apartment>?> apartments$ = BehaviorSubject.seeded(null);

  BehaviorSubject<List<Fee>?> fees$ = BehaviorSubject.seeded(null);
  late final Stream<List<Apartment>?> apartmentsBroadcast;
  late final Stream<Map<int, List<Fee>?>> feesBroadcast;

  Future<List<Apartment>> fetchApartments() async {
    final Map<String, dynamic> requestBody = {
      "Action": "Execute",
      "Object": "SP_MOBILE_APARTMENT_FLATS_LIST",
      "Parameters": {"APARTMENTUID": apartmentUid}
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

  Future<List<Fee>> fetchFees(int apartmentId) async {
    try {
      var response = await http.post(Uri.parse(GlobalConfig.url),
          body: json.encode({
            "Action": "Execute",
            "Object": "SP_MOBILE_APARTMENT_FEES_LIST",
            "Parameters": {"APARTMENTUID": apartmentUid, "FLATID": apartmentId}
          }));

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        if (data[0].isNotEmpty) {
          List<Fee> fees = [];
          data[0].forEach((fee) {
            fees.add(Fee.fromJson(fee));
          });
          fees$.add(fees);
        }
      }
    } catch (e) {}
    return [];
  }
}
