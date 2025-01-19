import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static late SharedPreferences prefs;

  static Future<void> initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setApartmentUid(String apartmentUid) async {
    await prefs.setString('apartment_uid', apartmentUid);
  }

  static String? getApartmentUid() {
    return prefs.getString('apartment_uid');
  }

  static Future<void> setApartmentName(String apartmentName) async {
    await prefs.setString('apartment_name', apartmentName);
  }

  static String? getApartmentName() {
    return prefs.getString('apartment_name');
  }

  static Future<void> clearApartmentData() async {
    await prefs.remove('apartment_uid');
    await prefs.remove('apartment_name');
  }
}
