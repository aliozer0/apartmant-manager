class IncomeAndExpensesModel {
  int? id;
  int? hotelid;
  DateTime? date;
  int? amount;
  String? description;
  int? typeid;

  IncomeAndExpensesModel({
    this.id,
    this.hotelid,
    this.date,
    this.amount,
    this.description,
    this.typeid,
  });

  factory IncomeAndExpensesModel.fromJson(Map<String, dynamic> json) => IncomeAndExpensesModel(
        id: json["ID"],
        hotelid: json["HOTELID"],
        date: json["DATE"] == null ? null : DateTime.parse(json["DATE"]),
        amount: json["AMOUNT"],
        description: json["DESCRIPTION"],
        typeid: json["TYPEID"],
      );

  Map<String, dynamic> toMap() => {
        "ID": id,
        "HOTELID": hotelid,
        "DATE": date?.toIso8601String(),
        "AMOUNT": amount,
        "DESCRIPTION": description,
        "TYPEID": typeid,
      };
}
