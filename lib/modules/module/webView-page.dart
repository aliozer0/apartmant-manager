import 'dart:convert';

import 'package:apartmantmanager/Global/global-variables.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../global/global-model.dart';

class WebViewScreen extends StatefulWidget {
  final String htmlContent;
  final Apartment apartment;
  final List<Fee> fees;

  WebViewScreen({
    required this.htmlContent,
    required this.apartment,
    required this.fees,
  });

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController webController;

  void initState() {
    super.initState();

    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onUrlChange: (change) {
          if (change.url == 'https://vpos-demo.elektraweb.io/success') {
            Navigator.pop(context, [true]);
          }
          if (change.url == 'https://vpos-demo.elektraweb.io/fail') {
            Navigator.pop(context, [false]);
          }
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {
          if (url == 'https://vpos-demo.elektraweb.io/success') {
            Navigator.pop(context, [true]);
            showSuccessDialog();
          } else if (url == 'https://vpos-demo.elektraweb.io/fail') {
            Navigator.pop(context, [false]);
            showFailureDialog();
          }
        },
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.dataFromString(
        widget.htmlContent,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ));
  }

  Future<void> showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/success-animation.json',
                  repeat: false,
                  onLoaded: (composition) {
                    Future.delayed(composition.duration * 1, () {
                      Navigator.of(context).pop();
                    });
                  }
                ),
                SizedBox(height: 16.0),
                Text('Ödemeniz başarıyla gerçekleşti',
                    style: k25Trajan(context).copyWith(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showFailureDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/failure-animation.json',
                  repeat: false,
                  onLoaded: (composition) {
                    Future.delayed(composition.duration * 1, () {
                      Navigator.of(context).pop();
                    });
                  },
                ),
                SizedBox(height: 16.0),
                Text(
                  'Ödemeniz gerçekleştirilemedi. Lütfen tekrar deneyin.',
                  style:k25Trajan(context) .copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebViewWidget(
          controller: webController,
        ),
      ),
    );
  }
}
