import 'package:flutter/material.dart';

import '../global/index.dart';

class CButton extends StatelessWidget {
  const CButton({
    super.key,
    required this.title,
    required this.func,
    this.width,
    this.backgroundColor,
    this.height,
    this.isBorder = false,
    this.loadingColor,
    this.isLoadingActive = true,
  });

  final String title;
  final VoidCallback func;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final bool isBorder;
  final Color? loadingColor;
  final bool? isLoadingActive;

  @override
  Widget build(BuildContext context) {
    double H = MediaQuery.of(context).size.height;
    double W = MediaQuery.of(context).size.width;

    return StreamBuilder(
        stream: isLoading$.stream,
        builder: (context, snapshot) {
          return InkWell(
              onTap: func,
              child: Container(
                  width: width ?? W * 0.43,
                  height: height ?? H * 0.06,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: isBorder ? Colors.transparent : GlobalConfig.primaryColor,
                      border: Border.all(color: GlobalConfig.primaryColor, width: 1)),
                  child: Container(
                      alignment: Alignment.center,
                      child: isLoading$.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(title,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600, color: isBorder ? GlobalConfig.primaryColor : Colors.white, fontFamily: 'Gilroy'),
                              textAlign: TextAlign.center))));
        });
  }
}
