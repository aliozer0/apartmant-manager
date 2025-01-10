import 'index.dart';

class RequestResponse {
  String message;
  bool result;
  String? resultResponse;

  RequestResponse({required this.message, required this.result, this.resultResponse});
}

class Apartment {
  final int? id;
  final int? hotelId;
  final String? name;
  final String? blockName;
  final String? flatNumber;
  final String? contactName;
  final String? phone;
  final String? idNo;
  final int? numberOfPeople;
  final String? plateNo;
  final String? ownerName;
  final String? ownerPhone;
  final double? balance;
  final String? startDate;
  final String? endDate;
  final bool? isDisabled;
  String? photoUrl;
  String? email;

  Apartment({
    this.id,
    this.hotelId,
    this.name,
    this.blockName,
    this.flatNumber,
    this.contactName,
    this.phone,
    this.idNo,
    this.numberOfPeople,
    this.plateNo,
    this.ownerName,
    this.ownerPhone,
    this.balance,
    this.startDate,
    this.endDate,
    this.isDisabled,
    this.photoUrl,
    this.email,
  });

  factory Apartment.fromJson(Map<String, dynamic> json) {
    return Apartment(
      id: json['ID'],
      // nullable
      hotelId: json['HOTELID'],
      // nullable
      name: json['NAME'],
      // nullable
      blockName: json['BLOCKNAME'],
      // nullable
      flatNumber: json['FLATNUMBER'],
      // nullable
      contactName: json['CONTACTNAME'],
      // nullable
      phone: json['PHONE'],
      // nullable
      idNo: json['IDNO'],
      // nullable
      numberOfPeople: json['NUMBEROFPEOPLE'],
      // nullable
      plateNo: json['PLATENO'],
      // nullable
      ownerName: json['OWNERNAME'],
      // nullable
      ownerPhone: json['OWNERPHONE'],
      // nullable
      balance: json['BALANCE'] != null ? (json['BALANCE'] as num).toDouble() : null,
      // nullable
      startDate: json['STARTDATE'],
      // nullable
      endDate: json['ENDDATE'],
      // nullable
      isDisabled: json['ISDISABLED'],
      // nullable
      photoUrl: json['PHOTOURL'],
      // nullable
      email: json['EMAIL'], // nullable
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
