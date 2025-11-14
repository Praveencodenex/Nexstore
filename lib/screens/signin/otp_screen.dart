import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:smart_auth/smart_auth.dart';
import '../../data/providers/auth_provider.dart';

import '../../utils/snack_bar.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../components/custom_button.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isEmail;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.isEmail
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late TextEditingController pinController;
  late FocusNode focusNode;
  late PinTheme defaultPinTheme;
  late PinTheme focusedPinTheme;
  late PinTheme submittedPinTheme;
  late AuthenticationProvider authProvider;

  // SmartAuth instance using singleton pattern
  final smartAuth = SmartAuth.instance;
  bool _isSmartAuthSupported = true;
  bool _isVerifying = false; // Flag to prevent multiple verification calls

  @override
  void initState() {
    super.initState();
    print(widget.isEmail);
    print(widget.isEmail);
    print(widget.isEmail);
    print(widget.isEmail);
    print(widget.isEmail);
    print(widget.isEmail);
    _initializeComponents();
    _initializeSmartAuth();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider.startResendTimer();
      focusNode.requestFocus();
    });
  }

  void _initializeComponents() {
    pinController = TextEditingController();
    focusNode = FocusNode();
    authProvider = Provider.of<AuthenticationProvider>(context, listen: false);

    defaultPinTheme = PinTheme(
      width: getProportionateScreenWidth(45),
      height: getProportionateScreenHeight(50),
      textStyle: TextStyle(
        fontSize: getProportionateScreenWidth(24),
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(8)),
        border: Border.all(color: kTextColor),
      ),
    );

    focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: kPrimaryColor,
          width: getProportionateScreenWidth(2),
        ),
      ),
    );

    submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: kPrimaryColor.withOpacity(0.1),
        border: Border.all(
          color: kPrimaryColor,
          width: getProportionateScreenWidth(1),
        ),
      ),
    );
  }

  Future<void> _initializeSmartAuth() async {
    try {
      await _startSmsUserConsentAPI();
    } catch (e) {
      debugPrint('SmartAuth initialization error: $e');
      if (mounted) {
        authProvider.setSmartAuthSupported(false);
      }
    }
  }

  Future<void> _startSmsUserConsentAPI() async {
    try {
      final res = await smartAuth.getSmsWithUserConsentApi();
      if (res.hasData) {
        final smsData = res.requireData;
        final extractedCode = _extractOtpFromSms(smsData.sms ?? '');
        final codeToUse = extractedCode ?? smsData.code;
        if (codeToUse != null && codeToUse.length == 6) {
          _autoFillOtp(codeToUse);
        }
      } else if (res.isCanceled) {
        debugPrint('SMS User Consent API was canceled by user');
      } else {
        debugPrint('SMS User Consent API failed: $res');
        if (mounted) {
          authProvider.setSmartAuthSupported(false);
        }
      }
    } catch (e) {
      debugPrint('SMS User Consent API error: $e');
      if (mounted) {
        authProvider.setSmartAuthSupported(false);
      }
    }
  }

  String? _extractOtpFromSms(String smsText) {
    final RegExp otpRegex = RegExp(r'\b\d{6}\b');
    final match = otpRegex.firstMatch(smsText);
    return match?.group(0);
  }

  void _autoFillOtp(String otp) {
    if (!mounted || _isVerifying) return;

    pinController.text = otp;
    pinController.selection = TextSelection.fromPosition(
      TextPosition(offset: pinController.text.length),
    );

    // Auto-verify after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && pinController.text == otp && !_isVerifying) {
        _handleVerifyOTP();
      }
    });
  }

  @override
  void dispose() {
    smartAuth.removeUserConsentApiListener();
    smartAuth.removeSmsRetrieverApiListener();
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOTP() async {
    // Prevent multiple calls
    if (_isVerifying) return;

    if (pinController.text.length != 6) {
      SnackBarUtils.showError('Please enter a valid OTP');
      return;
    }

    _isVerifying = true;
    focusNode.unfocus();

    if(widget.isEmail) {
      await authProvider.verifyEmailOTP(
        pinController.text,
        widget.phoneNumber,
      );
    }else{
      await authProvider.verifyOTP(
        pinController.text,
        '+91${widget.phoneNumber}',
      );
    }

    // Reset flag after verification attempt
    if (mounted) {
      _isVerifying = false;
    }
  }

  Future<void> _handleResendOTP() async {
    if (!authProvider.canResendOTP) return;

    try {
      await authProvider.loginWithPhone(widget.phoneNumber);
      if (authProvider.phoneLoginState.data?.status == true) {
        pinController.clear();
        focusNode.requestFocus();
        _isVerifying = false; // Reset verification flag

        if (_isSmartAuthSupported) {
          _startSmsUserConsentAPI();
        }

        SnackBarUtils.showSuccess('OTP resent successfully');
      }
    } catch (e) {
      SnackBarUtils.showError('Failed to resend OTP. Please try again.');
    }
  }

  void _handlePinChanged(String value) {
    // Only trigger verification if not already verifying and length is 6
    if (value.length == 6 && !_isVerifying) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && pinController.text.length == 6 && !_isVerifying) {
          _handleVerifyOTP();
        }
      });
    }
  }

  void _handlePinCompleted(String pin) {
    // Remove this method's verification call since _handlePinChanged will handle it
    // This prevents double verification calls
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: getProportionateScreenWidth(24),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(20),
            vertical: getProportionateScreenWidth(20)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OTP Verification', style: headingH2Style),
            SizedBox(height: getProportionateScreenHeight(8)),
            Text(
              'Enter the verification code we just sent to your mobile number',
              style: bodyStyleStyleB1.copyWith(color: kTextColor),
            ),
            SizedBox(height: getProportionateScreenHeight(16)),
            // SMS Auto-fill status indicator
            Consumer<AuthenticationProvider>(
              builder: (context, authProvider, _) => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(12),
                  vertical: getProportionateScreenHeight(8),
                ),
                decoration: BoxDecoration(
                  color: authProvider.isSmartAuthSupported
                      ? kPrimaryColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(getProportionateScreenWidth(6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      authProvider.isSmartAuthSupported ? Icons.sms_outlined : Icons.sms_failed_outlined,
                      size: getProportionateScreenWidth(16),
                      color: authProvider.isSmartAuthSupported ? kPrimaryColor : Colors.grey,
                    ),
                    SizedBox(width: getProportionateScreenWidth(6)),
                    Text(
                      authProvider.isSmartAuthSupported
                          ? 'SMS auto-fill enabled'
                          : 'SMS auto-fill unavailable',
                      style: TextStyle(
                        fontSize: getProportionateScreenWidth(12),
                        color: authProvider.isSmartAuthSupported ? kPrimaryColor : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(24)),
            // Pinput widget
            Center(
              child: Pinput(
                length: 6,
                controller: pinController,
                focusNode: focusNode,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,

                separatorBuilder: (index) => SizedBox(
                  width: getProportionateScreenWidth(8),
                ),

                onChanged: _handlePinChanged,
                onCompleted: _handlePinCompleted,

                // Cursor configuration
                cursor: Container(
                  width: getProportionateScreenWidth(2),
                  height: getProportionateScreenHeight(24),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(getProportionateScreenWidth(1)),
                  ),
                ),

                // Error handling
                errorBuilder: (errorText, pin) => Text(
                  errorText ?? '',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: getProportionateScreenWidth(12),
                  ),
                ),

                // Haptic feedback
                hapticFeedbackType: HapticFeedbackType.lightImpact,

                // Keyboard configuration
                keyboardType: TextInputType.number,

                // Visual feedback
                showCursor: true,
                closeKeyboardWhenCompleted: false,
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(24)),
            Center(
              child: Consumer<AuthenticationProvider>(
                builder: (context, authProvider, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive code? ",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: getProportionateScreenWidth(14),
                      ),
                    ),
                    GestureDetector(
                      onTap: authProvider.canResendOTP ? _handleResendOTP : null,
                      child: Text(
                        'Resend',
                        style: TextStyle(
                          color: authProvider.canResendOTP
                              ? const Color(0xFF008080)
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: getProportionateScreenWidth(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(16)),
            Consumer<AuthenticationProvider>(
              builder: (context, authProvider, _) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time_outlined),
                  SizedBox(width: getProportionateScreenWidth(4)),
                  Text(
                    "${authProvider.remainingTime.toString().padLeft(2, '0')}:00",
                    style: bodyStyleStyleB1,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Consumer<AuthenticationProvider>(
              builder: (context, authProvider, _) => CustomButton(
                txtColor: Colors.white,
                btnColor: kPrimaryColor,
                text: authProvider.isSendingOtp
                    ? 'Please wait...'
                    : 'Verify',
                press: authProvider.isSendingOtp || _isVerifying
                    ? null
                    : _handleVerifyOTP,
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(16)),
          ],
        ),
      ),
    );
  }
}