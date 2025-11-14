import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/profile_provider.dart';
import '../../../routes/navigator_services.dart';
import '../../../utils/constants.dart';
import '../../../utils/size_config.dart';
import '../../../utils/snack_bar.dart';
import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';

class FeedbackBottomSheet extends StatefulWidget {
  const FeedbackBottomSheet({super.key});

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
  final TextEditingController _feedbackController = TextEditingController();
  ProfileProvider? _profileProvider;
  bool _isListenerAttached = false;

  @override
  void initState() {
    super.initState();
    // Setup listener after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _setupStateListener();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get reference to provider and store it
    _profileProvider = Provider.of<ProfileProvider>(context, listen: false);
  }

  void _setupStateListener() {
    if (_profileProvider != null && !_isListenerAttached && mounted) {
      _profileProvider!.addListener(_handleStateChange);
      _isListenerAttached = true;
    }
  }

  void _handleStateChange() {
    // Check if widget is still mounted and provider is available
    if (!mounted || _profileProvider == null) {
      _removeListener();
      return;
    }

    _profileProvider!.feedbackState.state.maybeWhen(
      success: (data) {
        // Use post frame callback to ensure UI operations happen after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            NavigationService.instance.goBack();
            SnackBarUtils.showSuccess("Feedback submitted successfully");
          }
        });
        // Remove listener to prevent multiple calls
        _removeListener();
      },
      failure: (error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            NavigationService.instance.goBack();
            SnackBarUtils.showError("Failed to submit feedback");
          }
        });
        _removeListener();
      },
      orElse: () {},
    );
  }

  void _removeListener() {
    if (_profileProvider != null && _isListenerAttached) {
      _profileProvider!.removeListener(_handleStateChange);
      _isListenerAttached = false;
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        left: getProportionateScreenWidth(20),
        right: getProportionateScreenWidth(20),
        top: getProportionateScreenWidth(20),
        bottom: MediaQuery.of(context).viewInsets.bottom +
            getProportionateScreenWidth(20),
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: getProportionateScreenWidth(10)),
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // Placeholder for alignment
                Text(
                  'Feedback',
                  style: headingH3Style.copyWith(
                    color: kBlackColor
                  ),
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: getProportionateScreenWidth(5)),
            // Subtitle
            Text(
              'Help us improve your experience by sharing your thoughts.',
              style: TextStyle(
                fontSize: getProportionateScreenWidth(14),
                color: kDescription,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: getProportionateScreenWidth(30)),
            // Comments text field

            CustomTextField(
              controller: _feedbackController,
              hint: 'Write your feedback here...',
              maxLines: 4,
              filled: true,
              fillColor: kAppBarColor,
              borderRadius: 12,
              borderWidth: 1,
              focusedBorderWidth: 1,
              enabledBorderColor: Colors.grey.withOpacity(0.3),
              focusedBorderColor: kPrimaryColor,
              contentPadding: EdgeInsets.all(getProportionateScreenWidth(16)),
              onChanged: (value) {
                // Handle feedback text changes if needed
              },
            ),
            SizedBox(height: getProportionateScreenWidth(30)),
            // Submit button
            Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                return CustomButton(
                  text: profileProvider.isReviewing ? "Submitting..." : "Done",
                  btnColor: kPrimaryColor,
                  txtColor: kWhiteColor,
                  press: profileProvider.isReviewing
                      ? null
                      : () => _submitFeedback(context, profileProvider),
                );
              },
            ),
            SizedBox(height: getProportionateScreenWidth(20)),
          ],
        ),
      ),
    );
  }

  void _submitFeedback(BuildContext context, ProfileProvider profileProvider) async {
    if (_feedbackController.text.trim().isEmpty) {
      SnackBarUtils.showError("Please write your feedback");
      return;
    }
    await profileProvider.orderFeedback(_feedbackController.text.trim());
  }
}