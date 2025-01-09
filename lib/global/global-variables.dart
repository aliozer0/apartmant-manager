//FontSize:13
import 'package:flutter/material.dart';

import 'index.dart';

String? selectedlang;
BehaviorSubject<bool> isLoading$ = BehaviorSubject.seeded(false);

TextStyle k30Trajan(BuildContext context, {Color? color}) {
  return TextStyle(color: color ?? (Colors.black87), fontSize: MediaQuery.of(context).size.width / 30, fontFamily: "TrajanProBold");
}

//FontSize:14
TextStyle k28Trajan(BuildContext context, {Color? color}) {
  return TextStyle(color: color ?? (Colors.black87), fontSize: MediaQuery.of(context).size.width / 28, fontFamily: "TrajanProBold");
}

//FontSize:15
TextStyle k26Trajan(BuildContext context, {Color? color}) {
  return TextStyle(color: color ?? (Colors.black87), fontSize: MediaQuery.of(context).size.width / 26, fontFamily: "TrajanProBold");
}

//FontSize:16
TextStyle k25Trajan(BuildContext context, {Color? color}) {
  return TextStyle(color: color ?? (Colors.black87), fontSize: MediaQuery.of(context).size.width / 25, fontFamily: "TrajanProBold");
}

//FontSize:17
TextStyle k23Trajan(BuildContext context, {Color? color}) {
  return TextStyle(color: color ?? (Colors.black87), fontSize: MediaQuery.of(context).size.width / 23, fontFamily: "TrajanProBold");
}

//FontSize:18
TextStyle k22Trajan(BuildContext context, {Color? color}) {
  return TextStyle(color: color ?? (Colors.black87), fontSize: MediaQuery.of(context).size.width / 22, fontFamily: "TrajanProBold");
}

//FontSize:19
TextStyle k20_5Trajan(BuildContext context, {Color? color}) {
  return TextStyle(color: color ?? (Colors.black87), fontSize: MediaQuery.of(context).size.width / 20.5, fontFamily: "TrajanProBold");
}

//FontSize:20
TextStyle k19_5Trajan(BuildContext context, {Color? color}) {
  return TextStyle(color: color ?? (Colors.black87), fontSize: MediaQuery.of(context).size.width / 19.5, fontFamily: "TrajanProBold");
}

TextStyle k50Gilroy(BuildContext context, {Color? color, bool? isBold}) {
  return TextStyle(
      color: color ?? (Colors.black87),
      fontWeight: (isBold ??= false) ? FontWeight.normal : FontWeight.w600,
      fontSize: MediaQuery.of(context).size.width / 50,
      fontFamily: "Gilroy");
}

TextStyle k32_5Gilroy(BuildContext context, {Color? color}) {
  return TextStyle(color: color ?? (Colors.black87), fontSize: MediaQuery.of(context).size.width / 32.5, fontFamily: "Gilroy");
}

TextStyle k30Gilroy(BuildContext context, {Color? color}) {
  return TextStyle(color: color ?? (Colors.black87), fontSize: MediaQuery.of(context).size.width / 30, fontFamily: "Gilroy");
}

TextStyle k28Gilroy(BuildContext context, {Color? color}) {
  return TextStyle(color: color ?? (Colors.black87), fontSize: MediaQuery.of(context).size.width / 28, fontFamily: "Gilroy");
}

TextStyle k25Gilroy(BuildContext context, {Color? color, bool? isBold}) {
  return TextStyle(
      color: color ?? (Colors.black87),
      fontWeight: (isBold ??= false) ? FontWeight.normal : FontWeight.bold,
      fontSize: MediaQuery.of(context).size.width / 25,
      fontFamily: "Gilroy");
}

TextStyle k26Gilroy(BuildContext context, {Color? color, bool? isBold}) {
  return TextStyle(
    color: color ?? (Colors.black87),
    fontWeight: (isBold ??= false) ? FontWeight.normal : FontWeight.w600,
    fontSize: MediaQuery.of(context).size.width / 26,
    fontFamily: "Gilroy",
  );
}

TextStyle k23Gilroy(BuildContext context, {Color? color}) {
  return TextStyle(color: color ?? (Colors.black87), fontSize: MediaQuery.of(context).size.width / 23, fontFamily: "Gilroy");
}

TextStyle k22Gilroy(BuildContext context, {Color? color}) {
  return TextStyle(color: color ?? (Colors.black87), fontSize: MediaQuery.of(context).size.width / 22, fontFamily: "Gilroy");
}

TextStyle k20_5Gilroy(BuildContext context, {Color? color}) {
  return TextStyle(color: color ?? (Colors.black87), fontSize: MediaQuery.of(context).size.width / 20.5, fontFamily: "Gilroy");
}

TextStyle k19_5Gilroy(BuildContext context, {Color? color}) {
  return TextStyle(color: color ?? (Colors.black87), fontSize: MediaQuery.of(context).size.width / 19.5, fontFamily: "Gilroy");
}

EdgeInsets marginAll5 = const EdgeInsets.all(5);
EdgeInsets marginAll10 = const EdgeInsets.all(10);
EdgeInsets marginAll7 = const EdgeInsets.all(7);
EdgeInsets paddingAll5 = const EdgeInsets.all(5);
EdgeInsets paddingAll7 = const EdgeInsets.all(5);
EdgeInsets paddingAll10 = const EdgeInsets.all(10);
EdgeInsets paddingAll15 = const EdgeInsets.all(15);

Decoration borderAndBorderRadius =
    BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(10)), border: Border.all(color: Colors.black87, width: 1));
BorderRadius borderRadius8 = const BorderRadius.all(Radius.circular(8));
BorderRadius borderRadius10 = const BorderRadius.all(Radius.circular(10));
BorderRadius borderRadius15 = const BorderRadius.all(Radius.circular(15));
Border borderAll = Border.all(color: Colors.black87, width: 1);
