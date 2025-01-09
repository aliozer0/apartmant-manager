import 'index.dart';

class RequestResponse {
  String message;
  bool result;
  String? resultResponse;

  RequestResponse({required this.message, required this.result, this.resultResponse});
}

class Apartment {
  final int id;
  final int hotelId;
  final String name;
  final String blockName;
  final String flatNumber;
  final String contactName;
  final String phone;
  final String idNo;
  final int numberOfPeople;
  final String plateNo;
  final String ownerName;
  final String ownerPhone;
  final double balance;
  final String startDate;
  final String endDate;
  final bool isDisabled;
  String? photoUrl;
  String? email;

  Apartment({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.blockName,
    required this.flatNumber,
    required this.contactName,
    required this.phone,
    required this.idNo,
    required this.numberOfPeople,
    required this.plateNo,
    required this.ownerName,
    required this.ownerPhone,
    required this.balance,
    required this.startDate,
    required this.endDate,
    required this.isDisabled,
    required this.photoUrl,
    required this.email,
  });

  factory Apartment.fromJson(Map<String, dynamic> json) {
    return Apartment(
      id: json['ID'] ?? 0,
      hotelId: json['HOTELID'] ?? 0,
      name: json['NAME'] ?? '',
      blockName: json['BLOCKNAME'] ?? '',
      flatNumber: json['FLATNUMBER'] ?? '',
      contactName: json['CONTACTNAME'] ?? '',
      phone: json['PHONE'] ?? '',
      idNo: json['IDNO'] ?? '',
      numberOfPeople: json['NUMBEROFPEOPLE'] ?? 0,
      plateNo: json['PLATENO'] ?? '',
      ownerName: json['OWNERNAME'] ?? '',
      ownerPhone: json['OWNERPHONE'] ?? '',
      balance: (json['BALANCE'] as num?)?.toDouble() ?? 0.0,
      // Dönüşüm burada
      startDate: json['STARTDATE'] ?? '',
      endDate: json['ENDDATE'] ?? '',
      isDisabled: json['ISDISABLED'] ?? false,
      photoUrl: json['PHOTOURL'] ?? '',
      email: json['EMAIL'] ?? '',
    );
  }
}

class Fee {
  final int id;
  final int hotelId;
  final int flatId;
  final int feeTypeId;
  final String feeDate;
  final double feeAmount;
  final String paymentDate;
  final double paymentAmount;
  final String description;
  late final String feeUid;
  bool isCompleted;

  Fee({
    required this.id,
    required this.hotelId,
    required this.flatId,
    required this.feeTypeId,
    required this.feeDate,
    required this.feeAmount,
    required this.paymentDate,
    required this.paymentAmount,
    required this.description,
    required this.feeUid,
    this.isCompleted = false,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      id: json['ID'] ?? 0,
      hotelId: json['HOTELID'] ?? 0,
      flatId: json['FLATID'] ?? 0,
      feeTypeId: json['FEETYPEID'] ?? 0,
      feeDate: json['FEEDATE'] ?? '',
      feeAmount: json['FEEAMOUNT']?.toDouble(),
      paymentDate: json['PAYMENTDATE'] ?? '',
      paymentAmount: (json['PAYMENTAMOUNT'] ?? 0.0).toDouble(),
      description: json['DESCRIPTION'] ?? '',
      feeUid: json['FEEUID'] ?? '',
    );
  }
}

class News {
  final int id;
  final int hotelId;
  final String content;
  final DateTime startDate;
  final DateTime endDate;

  News({
    required this.id,
    required this.hotelId,
    required this.content,
    required this.startDate,
    required this.endDate,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['ID'] ?? 0,
      hotelId: json['HOTELID'] ?? 0,
      content: json['CONTENT'] ?? '',
      startDate: DateTime.parse(json['STARTDATE'] ?? ''),
      endDate: DateTime.parse(json['ENDDATE'] ?? ''),
    );
  }
}

class PaymentModel {
  final BehaviorSubject<Map<String, dynamic>> formData$ = BehaviorSubject<Map<String, dynamic>>.seeded({
    'pan': '',
    'expiryMonth': '',
    'expiryYear': '',
    'firstName': '',
    'lastName': '',
    'cvv': '',
    'paymentAmount': '0.00',
    'isCvvFocused': false,
    'selectedInstallments': '',
    'currency': '',
    'bank': '',
    'currencyOptions': [],
    'installmentOptions': [],
  });

  Stream<Map<String, dynamic>> get formDataStream => formData$.stream;

  void updateData(String key, dynamic value) {
    formData$.value[key] = value;
    formData$.add(Map.from(formData$.value));
  }

  void dispose() {
    formData$.close();
  }
}
