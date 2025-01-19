import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../global/index.dart';
import '../../index.dart';

class CreditCardFormScreen extends StatefulWidget {
  final List<Fee> fees;
  final Apartment apartment;

  const CreditCardFormScreen(
      {super.key, required this.apartment, required this.fees});

  @override
  _CreditCardFormScreenState createState() => _CreditCardFormScreenState();
}

class _CreditCardFormScreenState extends State<CreditCardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _amountController = TextEditingController();

  final Map<String, dynamic> _formData = {
    'pan': '',
    'firstName': '',
    'lastName': '',
    'expiryMonth': '',
    'expiryYear': '',
    'cvv': '',
    'paymentAmount': '',
    'currency': 'TRY',
    'bank': '',
    'selectedInstallments': '',
    'currencyOptions': <String>[],
    'installmentOptions': <String>[],
    'feeUid': '',
  };

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePaymentAmount();
  }

  void _initializePaymentAmount() {
    // Calculate total amount from all unpaid fees
    final totalAmount = widget.fees
        .where((fee) => !fee.isCompleted)
        .fold(0.0, (sum, fee) => sum + fee.feeAmount);

    _amountController.text = totalAmount.toStringAsFixed(2);
    _formData['paymentAmount'] = totalAmount.toStringAsFixed(2);

    // Keep the existing feeUid logic for the first unpaid fee
    final unpaidFee = widget.fees.firstWhere(
      (fee) => !fee.isCompleted,
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
        feeUid: '',
        isCompleted: false,
      ),
    );
    _formData['feeUid'] = unpaidFee.feeUid;
  }

  Future<void> _fetchBinDetails(String pan) async {
    if (pan.length < 6) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://vpos-demo.elektraweb.io/getBankInfoWithBin'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'binNumber': pan.substring(0, 6), 'isTest': true}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bankInfo = data['bankInfo'];

        if (bankInfo != null && bankInfo['success'] == true) {
          final bankData = bankInfo['data'];
          final bankConfig = bankData['bankConfig'];

          setState(() {
            _formData['bank'] = bankData['bankName'] ?? '';
            _formData['currencyOptions'] = bankConfig['currency'] != null
                ? List<String>.from(bankConfig['currency'])
                : ['TRY'];
            _formData['installmentOptions'] = bankConfig['installment'] != null
                ? List<String>.from(bankConfig['installment'])
                : ['1'];
            _formData['currency'] = _formData['currencyOptions'].first;
            _formData['selectedInstallments'] =
                _formData['installmentOptions'].first;
          });
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Bank information could not be retrieved');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _generateHashData() {
    final data =
        '${_formData['firstName']}${_formData['lastName']}${_formData['pan']}'
        '${_formData['expiryMonth']}${_formData['expiryYear']}${_formData['cvv']}'
        '${_formData['paymentAmount']}${_formData['currency']}${_formData['bank']}';
    return sha256.convert(utf8.encode(data)).toString();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final paymentData = {
        "apartmentUid": widget.apartment.apartmentUid,
        "feeUid": _formData['feeUid'],
        "firstName": _formData['firstName'],
        "lastName": _formData['lastName'],
        "pan": _formData['pan'],
        "expiryMonth": _formData['expiryMonth'],
        "expiryYear": _formData['expiryYear'],
        "cvv": _formData['cvv'],
        "amount": _formData['paymentAmount'],
        "currency": _formData['currency'],
        "bank": _formData['bank'],
        "redirectMode": "backend",
        "hashData": _generateHashData(),
        "selectedInstallments": json.encode({
          "installment": _formData['selectedInstallments'],
          "finalPrice": _formData['paymentAmount']
        }),
        "isTest": true,
      };

      final response = await http.post(
        Uri.parse('https://vpos-demo.elektraweb.io/sendCCInfo'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(paymentData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData["data"] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewScreen(
                htmlContent: responseData["data"],
                apartment: widget.apartment,
                fees: widget.fees,
              ),
            ),
          ).then((result) {
            if (result?[0] == true) {
              Navigator.pop(context, [true]);
            }
          });
        } else {
          setState(() => _errorMessage = 'Payment processing failed');
        }
      } else {
        setState(() => _errorMessage = 'Payment processing failed');
      }
    } catch (e) {
      setState(() => _errorMessage = 'An error occurred during payment');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Payment',
            style: TextStyle(color: Colors.white)),
        backgroundColor: GlobalConfig.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 50),
              height: 100,
              color: GlobalConfig.primaryColor,
              child: const Center(
                child: Icon(
                  Icons.credit_card_outlined,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -50),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCardNumberField(),
                      const SizedBox(height: 20),
                      _buildCardHolderField(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _buildExpiryField()),
                          const SizedBox(width: 20),
                          Expanded(child: _buildCVVField()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_formData['bank'].isNotEmpty) ...[
                        _buildBankInfo(),
                        const SizedBox(height: 20),
                      ],
                      if (_formData['installmentOptions'].isNotEmpty)
                        _buildInstallmentDropdown(),
                      const SizedBox(height: 20),
                      _buildAmountField(),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                      _buildPayButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _cardNumberController,
      decoration: _inputDecoration(
        label: 'Card Number',
        prefixIcon: Icons.credit_card,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
        _CardNumberFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter card number';
        }
        if (value.replaceAll(' ', '').length < 16) {
          return 'Please enter valid card number';
        }
        return null;
      },
      onChanged: (value) {
        _formData['pan'] = value.replaceAll(' ', '');
        if (value.length >= 6) {
          _fetchBinDetails(value.replaceAll(' ', ''));
        }
      },
    );
  }

  Widget _buildCardHolderField() {
    return TextFormField(
      controller: _cardHolderController,
      decoration: _inputDecoration(
        label: 'Card Holder Name',
        prefixIcon: Icons.person,
      ),
      textCapitalization: TextCapitalization.characters,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter card holder name';
        }
        return null;
      },
      onChanged: (value) {
        final names = value.split(' ');
        _formData['firstName'] = names.first;
        _formData['lastName'] = names.length > 1 ? names.last : '';
      },
    );
  }

  Widget _buildExpiryField() {
    return TextFormField(
      controller: _expiryController,
      decoration: _inputDecoration(
        label: 'MM/YY',
        prefixIcon: Icons.calendar_today,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
        _CardExpiryFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (value.length < 5) {
          return 'Invalid date';
        }
        return null;
      },
      onChanged: (value) {
        if (value.length >= 5) {
          _formData['expiryMonth'] = value.substring(0, 2);
          _formData['expiryYear'] = value.substring(3);
        }
      },
    );
  }

  Widget _buildCVVField() {
    return TextFormField(
      controller: _cvvController,
      decoration: _inputDecoration(
        label: 'CVV',
        prefixIcon: Icons.lock,
      ),
      keyboardType: TextInputType.number,
      obscureText: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (value.length < 3) {
          return 'Invalid CVV';
        }
        return null;
      },
      onChanged: (value) => _formData['cvv'] = value,
    );
  }

  Widget _buildBankInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance, color: GlobalConfig.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _formData['bank'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration(
        label: 'Installments',
        prefixIcon: Icons.schedule,
      ),
      value: _formData['selectedInstallments'],
      items: _formData['installmentOptions']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text('$value installments'),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() => _formData['selectedInstallments'] = value!);
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
              left: 25,
              top: 15,
              bottom: 15,
              right: 0), // Adjust padding as needed
          child: Text(
            '₺',
            style: TextStyle(
              color: GlobalConfig.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      enabled: false,
      style: TextStyle(
        color: GlobalConfig.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildPayButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: GlobalConfig.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: _isLoading ? null : _processPayment,
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Pay Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(prefixIcon, color: GlobalConfig.primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: GlobalConfig.primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: GlobalConfig.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

// Custom formatter for credit card number
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String inputData = newValue.text.replaceAll(' ', '');
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < inputData.length; i++) {
      buffer.write(inputData[i]);
      if ((i + 1) % 4 == 0 && i != inputData.length - 1) {
        buffer.write(' ');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(
        offset: buffer.toString().length,
      ),
    );
  }
}

// Custom formatter for expiry date
class _CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String inputData = newValue.text.replaceAll('/', '');
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < inputData.length; i++) {
      buffer.write(inputData[i]);
      if (i == 1 && i != inputData.length - 1) {
        buffer.write('/');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(
        offset: buffer.toString().length,
      ),
    );
  }
}
