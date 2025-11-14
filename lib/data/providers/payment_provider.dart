import 'package:flutter/material.dart';

class PaymentProvider extends ChangeNotifier {
  String? _selectedPaymentMethod;
  bool _isProcessing = false;

  String? get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isProcessing => _isProcessing;

  void setSelectedPaymentMethod(String? method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void resetPaymentState() {
    _selectedPaymentMethod = null;
    _isProcessing = false;
    notifyListeners();
  }

  bool isPaymentMethodSelected(String method) {
    return _selectedPaymentMethod == method;
  }
}