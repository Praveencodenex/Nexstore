import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:thenexstore/routes/navigator_services.dart';
import 'package:thenexstore/routes/routes_names.dart';
import 'package:thenexstore/utils/snack_bar.dart';

class RazorPayService {
  static final RazorPayService _instance = RazorPayService._internal();
  factory RazorPayService() => _instance;
  RazorPayService._internal();

  late Razorpay _razorpay;
  late Function(String) _onPaymentSuccess;
  late Function(String) _onPaymentError;
  late BuildContext _context;

  void initialize({
    required BuildContext context,
    required Function(String) onPaymentSuccess,
    required Function(String) onPaymentError,
  }) {
    _context = context;
    _onPaymentSuccess = onPaymentSuccess;
    _onPaymentError = onPaymentError;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  void startPayment({
    required String orderKey,
    required double amount,
    required String customerName,
    String description = 'Order Payment',
    String? phoneNumber,
    String? email,
    Map<String, dynamic>? additionalOptions,
  }) {
    var options = <String, Object>{
      'key': orderKey,
      'amount': (amount * 100).toInt(),
      'name': customerName,
      'description': description,
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': phoneNumber ?? '',
        'email': email ?? '',
      },
      'theme': {
        'color': '#3399cc'
      },
    };

    // Add method-specific options
    if (additionalOptions != null) {
      // Convert and add non-null values only
      additionalOptions.forEach((key, value) {
        if (value != null) {
          options[key] = value;
        }
      });

      // Configure method-specific settings
      switch (additionalOptions['method']) {
        case 'upi':
          _configureUPIOptions(options, additionalOptions);
          break;
        case 'card':
          _configureCardOptions(options);
          break;
        case 'netbanking':
          _configureNetBankingOptions(options);
          break;
        case 'wallet':
          _configureWalletOptions(options);
          break;
        case 'paylater':
          _configurePayLaterOptions(options);
          break;
      }
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      _onPaymentError("Payment could not be initiated. Please try again.");
    }
  }

  void _configureUPIOptions(Map<String, Object> options, Map<String, dynamic> additionalOptions) {
    // Configure UPI-specific options
    options['method'] = 'upi';

    if (additionalOptions.containsKey('upi') && additionalOptions['upi'] != null) {
      options['upi'] = additionalOptions['upi'];
    }

    // Disable other payment methods for UPI-only flow
    options['config'] = {
      'display': {
        'blocks': {
          'utib': {
            'name': 'Pay using UPI',
            'instruments': [
              {
                'method': 'upi'
              }
            ]
          }
        },
        'sequence': ['block.utib'],
        'preferences': {
          'show_default_blocks': false
        }
      }
    };
  }

  void _configureCardOptions(Map<String, Object> options) {
    // Configure card-specific options
    options['method'] = 'card';

    // Disable other payment methods for card-only flow
    options['config'] = {
      'display': {
        'blocks': {
          'card': {
            'name': 'Pay with Card',
            'instruments': [
              {
                'method': 'card'
              }
            ]
          }
        },
        'sequence': ['block.card'],
        'preferences': {
          'show_default_blocks': false
        }
      }
    };
  }

  void _configureNetBankingOptions(Map<String, Object> options) {
    // Configure net banking specific options
    options['method'] = 'netbanking';

    // Disable other payment methods for netbanking-only flow
    options['config'] = {
      'display': {
        'blocks': {
          'netbanking': {
            'name': 'Pay with Net Banking',
            'instruments': [
              {
                'method': 'netbanking'
              }
            ]
          }
        },
        'sequence': ['block.netbanking'],
        'preferences': {
          'show_default_blocks': false
        }
      }
    };
  }

  void _configureWalletOptions(Map<String, Object> options) {
    // Configure wallet-specific options
    options['method'] = 'wallet';

    // Enable specific wallets
    options['external'] = {
      'wallets': ['paytm', 'phonepe', 'amazonpay', 'mobikwik', 'freecharge']
    };

    // Disable other payment methods for wallet-only flow
    options['config'] = {
      'display': {
        'blocks': {
          'wallet': {
            'name': 'Pay with Wallet',
            'instruments': [
              {
                'method': 'wallet'
              }
            ]
          }
        },
        'sequence': ['block.wallet'],
        'preferences': {
          'show_default_blocks': false
        }
      }
    };
  }

  void _configurePayLaterOptions(Map<String, Object> options) {
    // Configure pay later specific options
    options['method'] = 'paylater';

    // Disable other payment methods for pay later-only flow
    options['config'] = {
      'display': {
        'blocks': {
          'paylater': {
            'name': 'Pay Later',
            'instruments': [
              {
                'method': 'paylater'
              }
            ]
          }
        },
        'sequence': ['block.paylater'],
        'preferences': {
          'show_default_blocks': false
        }
      }
    };
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _onPaymentSuccess(response.paymentId ?? "");
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    String errorMessage = "Payment Failed: ${response.message}";
    _onPaymentError(errorMessage);
    SnackBarUtils.showError(errorMessage);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    SnackBarUtils.showInfo("External Wallet Selected: ${response.walletName}");
  }

  // Method to get available payment methods (for future use)
  List<String> getAvailablePaymentMethods() {
    return [
      'upi',
      'card',
      'netbanking',
      'wallet',
      'paylater',
    ];
  }

  // Method to get UPI apps (for future use)
  List<Map<String, String>> getUPIApps() {
    return [
      {'name': 'Google Pay', 'packageName': 'com.google.android.apps.nbu.paisa.user'},
      {'name': 'PhonePe', 'packageName': 'com.phonepe.app'},
      {'name': 'Paytm', 'packageName': 'net.one97.paytm'},
      {'name': 'Amazon Pay', 'packageName': 'in.amazon.mShop.android.shopping'},
      {'name': 'BHIM', 'packageName': 'in.org.npci.upiapp'},
    ];
  }

  // Method to get popular banks (for future use)
  List<Map<String, String>> getPopularBanks() {
    return [
      {'name': 'State Bank of India', 'code': 'SBIN'},
      {'name': 'HDFC Bank', 'code': 'HDFC'},
      {'name': 'ICICI Bank', 'code': 'ICIC'},
      {'name': 'Axis Bank', 'code': 'UTIB'},
      {'name': 'Kotak Mahindra Bank', 'code': 'KKBK'},
      {'name': 'Punjab National Bank', 'code': 'PUNB'},
    ];
  }

  // Method to get popular wallets (for future use)
  List<Map<String, String>> getPopularWallets() {
    return [
      {'name': 'Paytm', 'code': 'paytm'},
      {'name': 'PhonePe', 'code': 'phonepe'},
      {'name': 'Amazon Pay', 'code': 'amazonpay'},
      {'name': 'MobiKwik', 'code': 'mobikwik'},
      {'name': 'FreeCharge', 'code': 'freecharge'},
    ];
  }
}