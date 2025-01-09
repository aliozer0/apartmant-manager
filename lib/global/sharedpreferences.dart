import 'index.dart';

class PreferenceService {
  static Future<void> setHotelId(int hotelId) async {
    await prefs.setInt('hotel_id', hotelId);
  }

  static Future<int?> getHotelId() async {
    return prefs.getInt('hotel_id');
  }

  static Future<void> setApartmentName(String apartmentName) async {
    await prefs.setString('apartment_name', apartmentName);
  }

  static Future<String?> getApartmentName() async {
    return prefs.getString('apartment_name');
  }
}
