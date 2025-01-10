import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../global/index.dart';
import '../../index.dart';

class CreditCardFormScreen extends StatefulWidget {
  final List<Fee> fees;
  final Apartment apartment;

  CreditCardFormScreen({super.key, required this.apartment, required this.fees});

  @override
  _CreditCardFormScreenState createState() => _CreditCardFormScreenState();
}

class _CreditCardFormScreenState extends State<CreditCardFormScreen> {
  final globalService = GetIt.I<GlobalService>();
  final PaymentModel paymentModel = PaymentModel();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchPaymentDetails();
  }

  void fetchPaymentDetails() {
    final fetchedFee = widget.fees.firstWhere((fee) => !fee.isCompleted,
        orElse: () => Fee(
            id: 0,
            hotelId: 0,
            flatId: 0,
            feeTypeId: 0,
            feeDate: '',
            feeAmount: 0.0,
            paymentDate: DateTime.now().toString(),
            description: '',
            paymentAmount: 0.0,
            feeUid: ''));
    paymentModel.updateData('paymentAmount', fetchedFee.feeAmount.toStringAsFixed(2));
    paymentModel.formData$.value['feeUid'] = fetchedFee.feeUid;
  }

  String generateHashData(Map<String, dynamic> formData) {
    String data =
        '${formData['firstName']}${formData['lastName']}${formData['pan']}${formData['expiryMonth']}${formData['expiryYear']}${formData['cvv']}${formData['paymentAmount']}${formData['currency']}${formData['bank']}';
    var bytes = utf8.encode(data);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>> sendPaymentData(
    Map<String, dynamic> formData,
  ) async {
    final paymentData = {
      "hotelId": widget.apartment.hotelId,
      "feeUid": formData['feeUid'],
      "firstName": formData['firstName'],
      "lastName": formData['lastName'],
      "pan": formData['pan'],
      "expiryMonth": formData['expiryMonth'],
      "expiryYear": formData['expiryYear'],
      "cvv": formData['cvv'],
      "amount": formData['paymentAmount'],
      "currency": formData['currency'],
      "bank": formData['bank'],
      "redirectMode": "backend",
      "hashData": generateHashData(formData),
      "selectedInstallments": '{"installment":"${formData['selectedInstallments']}","finalPrice":"${formData['paymentAmount']}"}',
      "isTest": true,
    };

    try {
      final response = await http.post(
        Uri.parse('https://vpos-demo.elektraweb.io/sendCCInfo'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(paymentData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        return responseData;
      } else {
        debugPrint('?deme i?leme ba?ar?s?z oldu. Durum Kodu: ${response.statusCode}');
        return {"error": '?deme i?leme ba?ar?s?z oldu. Durum Kodu: ${response.statusCode}'};
      }
    } catch (e) {
      debugPrint('?deme i?leme hatas?: $e');
      return {"error": '?deme i?leme hatas?: $e'};
    }
  }

  Future<void> fetchBinDetails(String pan) async {
    String binNumber = pan.substring(0, 6);

    if (!RegExp(r'^\d{6}$').hasMatch(binNumber)) {
      debugPrint('Hata: Ge?ersiz BIN numaras? format?.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://vpos-demo.elektraweb.io/getBankInfoWithBin'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'binNumber': binNumber, 'isTest': true}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final bankInfo = data['bankInfo'];
        if (bankInfo != null && bankInfo['success'] == true) {
          final bankData = bankInfo['data'];
          final bankConfig = bankData['bankConfig'];
          paymentModel.updateData('bank', bankData['bankName'] ?? '');
          paymentModel.updateData('currencyOptions', bankConfig['currency'] != null ? List<String>.from(bankConfig['currency']) : []);
          paymentModel.updateData('installmentOptions', bankConfig['installment'] != null ? List<String>.from(bankConfig['installment']) : []);
          paymentModel.updateData(
              'currency', paymentModel.formData$.value['currencyOptions'].isNotEmpty ? paymentModel.formData$.value['currencyOptions'][0] : '');
        } else {
          debugPrint('Bank bilgisi al?namad? veya ba?ar? durumu false d?nd?.');
        }
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('BIN bilgileri al?namad?. Kod: ${response.statusCode}, Hata: ${errorData['error']}');
      }
    } catch (e) {
      debugPrint('Hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    return Container(
      padding: EdgeInsets.only(top: topPadding),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 30,
          flexibleSpace: Container(
            color: GlobalConfig.primaryColor,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  color: appText,
                ),
                Expanded(
                  child: Text(
                    "KRED? KARTI B?LG?LER?",
                    textAlign: TextAlign.center,
                    style: normalTextStyle.copyWith(color: appText, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
            child: StreamBuilder(
                stream: paymentModel.formData$.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text('Loading...', style: k25Trajan(context).copyWith(color: appText, fontSize: 20));
                  }
                  final formData = paymentModel.formData$.value;
                  return Column(
                    children: [
                      // CreditCardWidget(
                      //   cardNumber: formData?['pan'],
                      //   cardHolderName:
                      //       '${formData?['firstName']} ${formData?['lastName']}',
                      //   expiryDate:
                      //       '${formData?['expiryMonth']}/${formData?['expiryYear']}',
                      //   cvvCode: formData?['cvv'],
                      //   showBackView: formData?['isCvvFocused'],
                      //   cardBgColor: primary,
                      //   onCreditCardWidgetChange: (CreditCardBrand brand) {},
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    border: border,
                                    labelStyle: normalTextStyle.copyWith(
                                      color: GlobalConfig.primaryColor,
                                    ),
                                    labelText: 'Kart Numaras?',
                                    enabledBorder: enableBorder,
                                    focusedBorder: focusBorder,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    paymentModel.updateData('pan', value);
                                    if (value.length >= 6) {
                                      fetchBinDetails(value.substring(0, 6));
                                    }
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    border: border,
                                    labelStyle: normalTextStyle.copyWith(
                                      color: GlobalConfig.primaryColor,
                                    ),
                                    labelText: 'Kart Sahibinin Ad?',
                                    enabledBorder: enableBorder,
                                    focusedBorder: focusBorder,
                                  ),
                                  onChanged: (value) {
                                    final names = value.split(' ');
                                    paymentModel.updateData('firstName', names[0]);
                                    paymentModel.updateData('lastName', names.length > 1 ? names[1] : '');
                                  },
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          border: border,
                                          labelStyle: normalTextStyle.copyWith(
                                            color: GlobalConfig.primaryColor,
                                          ),
                                          labelText: 'MM/YY',
                                          enabledBorder: enableBorder,
                                          focusedBorder: focusBorder,
                                        ),
                                        keyboardType: TextInputType.datetime,
                                        onChanged: (value) {
                                          final parts = value.split('/');
                                          if (parts.length == 2) {
                                            paymentModel.updateData('expiryMonth', parts[0]);
                                            paymentModel.updateData('expiryYear', parts[1]);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: Focus(
                                        onFocusChange: (isFocused) {
                                          paymentModel.updateData('isCvvFocused', isFocused);
                                        },
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            border: border,
                                            labelStyle: normalTextStyle.copyWith(
                                              color: GlobalConfig.primaryColor,
                                            ),
                                            labelText: 'CVV',
                                            enabledBorder: enableBorder,
                                            focusedBorder: focusBorder,
                                          ),
                                          obscureText: true,
                                          cursorColor: GlobalConfig.primaryColor,
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            paymentModel.updateData('cvv', value);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (formData?['currency'] != null &&
                                  formData?['currency'].isNotEmpty &&
                                  formData?['bank'] != null &&
                                  formData?['bank'].isNotEmpty) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            border: border,
                                            labelStyle: normalTextStyle.copyWith(
                                              color: GlobalConfig.primaryColor,
                                            ),
                                            labelText: 'Para Birimi',
                                            enabledBorder: enableBorder,
                                            focusedBorder: focusBorder,
                                          ),
                                          value: paymentModel.formData$.value['currencyOptions'].contains(paymentModel.formData$.value['currency'])
                                              ? paymentModel.formData$.value['currency']
                                              : null,
                                          onChanged: (String? newValue) {
                                            paymentModel.updateData('cvv', newValue);
                                          },
                                          items: formData?['currencyOptions'].map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            border: border,
                                            labelStyle: normalTextStyle.copyWith(
                                              color: GlobalConfig.primaryColor,
                                            ),
                                            labelText: 'Banka',
                                            enabledBorder: enableBorder,
                                            focusedBorder: focusBorder,
                                          ),
                                          initialValue: formData?['bank'],
                                          enabled: false,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (formData?['installmentOptions'].isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      border: border,
                                      labelStyle: normalTextStyle.copyWith(
                                        color: GlobalConfig.primaryColor,
                                      ),
                                      labelText: 'Taksit Se?enekleri',
                                      enabledBorder: enableBorder,
                                      focusedBorder: focusBorder,
                                    ),
                                    value: (paymentModel.formData$.value['selectedInstallments'] != null &&
                                            paymentModel.formData$.value['selectedInstallments'].isNotEmpty)
                                        ? paymentModel.formData$.value['selectedInstallments']
                                        : null,
                                    onChanged: (String? newValue) {
                                      paymentModel.updateData('selectedInstallments', newValue);
                                    },
                                    items: formData?['installmentOptions'].map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    border: border,
                                    labelStyle: normalTextStyle.copyWith(
                                      color: GlobalConfig.primaryColor,
                                    ),
                                    labelText: '?deme Tutar?',
                                    enabledBorder: enableBorder,
                                    focusedBorder: focusBorder,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    paymentModel.updateData('paymentAmount', value);
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(color: GlobalConfig.primaryColor, borderRadius: borderRadius10),
                                child: TextButton(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      var paymentData = await sendPaymentData(paymentModel.formData$.value);

                                      if (paymentData["error"] != null) {
                                        debugPrint(paymentData["error"]);
                                      } else if (paymentData["data"] != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => WebViewScreen(
                                              htmlContent: paymentData["data"],
                                              apartment: widget.apartment,
                                              fees: widget.fees,
                                            ),
                                          ),
                                        ).then((paymentResult) {
                                          if (paymentResult[0] == true) {
                                            debugPrint('?deme ba?ar?l?.');
                                            Navigator.pop(context, [true]);
                                            // apiService.fetchFees(
                                            //     widget.apartment.id,
                                            //     widget.apartment.hotelId);
                                          } else if (paymentResult[0] == false) {
                                            debugPrint('?deme ba?ar?s?z.');
                                          }
                                        });
                                      }
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 50),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    '?de',
                                    style: k25Trajan(context).copyWith(color: appText, fontSize: 14),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                })),
      ),
    );
  }
}
