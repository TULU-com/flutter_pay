import 'dart:async';

import 'package:flutter/services.dart';

import 'package:flutter_pay/models/payment_item.dart';
import 'package:flutter_pay/models/flutter_pay_error.dart';

class FlutterPay {
  final MethodChannel _channel = MethodChannel('flutter_pay');

  Future<bool> get canMakePayments async {
    final bool canMakePayments = await _channel.invokeMethod('canMakePayments');
    return canMakePayments;
  }

  Future<String> makePayment(
      {String merchantIdentifier,
      String currencyCode,
      String countryCode,
      List<PaymentItem> paymentItems,
      String merchantName,
      String gatewayName = null}) async {
    List<Map<String, String>> items =
        paymentItems.map((item) => item.toJson()).toList();

    print("Gateway name: $gatewayName");

    Map<String, dynamic> params = {
      "gateway": gatewayName,
      "merchantIdentifier": merchantIdentifier,
      "currencyCode": currencyCode,
      "countryCode": countryCode,
      "merchantName": merchantName,
      "items": items,
    };
    try {
      dynamic rawPayResponse = await _channel.invokeMethod('requestPayment', params);
      Map<String, String> payResponse = Map<String, String>.from(rawPayResponse);
      if (payResponse == null) {
        throw FlutterPayError(description: "Pay response cannot be parsed");
      }
      String paymentToken = payResponse["token"];
      String error = payResponse["error"];
      print("Payment token: $paymentToken");
      print("Error: $error");
      if (paymentToken != null) {
        print("Payment token: $paymentToken");
        return paymentToken;
      }
      if (error != null) {
        throw FlutterPayError(description: error);
      }
    } on PlatformException catch(e) {
        throw FlutterPayError(description: e.message);
    }
  }
}