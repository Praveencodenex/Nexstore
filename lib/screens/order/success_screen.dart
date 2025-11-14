import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:thenexstore/data/providers/providers.dart';
import 'package:thenexstore/routes/navigator_services.dart';
import 'package:thenexstore/routes/routes_names.dart';
import 'package:thenexstore/screens/components/custom_button.dart';

import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class SuccessScreen extends StatefulWidget {
  final String title;
  final String message;
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;

  const SuccessScreen({
    super.key,
    this.title = "Your Order has been Placed",
    this.message = "Thank you! Your order has been successfully placed. Freshness is on its way!",
    this.primaryButtonText = "Track Order",
    this.secondaryButtonText = "Back to Home",
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000), // Longer animation duration
      vsync: this,
    );

    _checkmarkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          NavigationService.instance.pushReplacementNamed(RouteNames.customBottomNavBar);
          Provider.of<UserProvider>(context, listen: false).setCurrentIndex(0);
        }
      },
      child: Scaffold(
        backgroundColor: kAppBarColor,
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(26)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: getProportionateScreenHeight(100)),

                  // Animated Checkmark with particles
                  SizedBox(
                    height: getProportionateScreenWidth(220),
                    width: getProportionateScreenWidth(220),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [

                        ...List.generate(25, (index) => _buildParticle(index)),

                        // Circle and checkmark
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                height: getProportionateScreenWidth(90), // Slightly smaller container
                                width: getProportionateScreenWidth(90),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF009688), // Teal color
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF008276), width: 2),
                                ),
                                child: Center(
                                  child: AnimatedBuilder(
                                    animation: _checkmarkAnimation,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        painter: CheckmarkPainter(
                                          progress: _checkmarkAnimation.value,
                                          color: Colors.white,
                                          strokeWidth: 5.5, // Thicker checkmark
                                        ),
                                        size: Size(
                                          getProportionateScreenWidth(75), // Making checkmark bigger
                                          getProportionateScreenWidth(75),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),


                  // Title text
                  Text(
                    widget.title,
                    style: headingH3Style.copyWith(color: kPrimaryColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),

                  // Message text
                  Text(
                    widget.message,
                    style: bodyStyleStyleB2.copyWith(color: kSecondaryColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getProportionateScreenHeight(50)),

                  // Primary button (e.g. "Track Order")
                  CustomButton(
                    text: widget.primaryButtonText,
                    press: widget.onPrimaryButtonPressed ?? () {

                      NavigationService.instance.navigateTo(RouteNames.orderScreen,arguments: {'backNeeded': true});
                    },
                    txtColor: kWhiteColor,
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),

                  // Secondary button (e.g. "Back to Home")
                  CustomButton(
                    text: widget.secondaryButtonText,
                    press: widget.onSecondaryButtonPressed ?? () {
                      NavigationService.instance.pushReplacementNamed(RouteNames.customBottomNavBar);
                      Provider.of<UserProvider>(context, listen: false).setCurrentIndex(0);
                    },
                    btnColor: kWhiteColor,
                    borderEnabled: true,
                    txtColor: kPrimaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParticle(int index) {

    const colors = [
      Color(0xFF6200EA), // Purple
      Color(0xFF03A9F4), // Blue
      Color(0xFFFFB300), // Amber
      Color(0xFF009688), // Teal
      Color(0xFFFF5252), // Red
      Color(0xFF00BFA5), // Teal Accent
      Color(0xFF3D5AFE), // Indigo Accent
      Color(0xFF76FF03), // Light Green Accent
      Color(0xFFFF9800), // Orange
      Color(0xFFE91E63), // Pink
      Color(0xFF4CAF50), // Green
    ];

    // Calculate an even distribution of particles in 360 degrees
    final angle = (index / 25) * 2 * math.pi;

    // For firework effect, all particles start at the same time
    const delay = 0.3; // Fixed delay for all particles

    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        // Calculate position based on animation progress - faster for firework effect
        final animationProgress = math.max(0.0, math.min(1.0, (_controller.value - delay) / 0.6));

        if (animationProgress <= 0) {
          return const SizedBox.shrink();
        }

        // Firework effect - all particles start from center and explode outward
        // Easing out for natural deceleration at the end
        final easedProgress = Curves.easeOutQuart.transform(animationProgress);

        // Final radius is larger for a wider explosion
        final radius = 160 * easedProgress;

        // Fixed angle for uniform distribution (true firework)
        final dx = math.cos(angle) * radius;
        final dy = math.sin(angle) * radius;

        const fadeOutStart = 0.7;
        final opacity = animationProgress < fadeOutStart
            ? 1.0
            : 1.0 - ((animationProgress - fadeOutStart) / (1.0 - fadeOutStart));

        // Particles grow slightly as they move outward
        final scale = 0.8 + (easedProgress * 0.5);

        return Positioned(
          // Center everything to make sure particles start from center
          left: getProportionateScreenWidth(110 + dx),
          top: getProportionateScreenWidth(110 + dy),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: _getParticleShape(index, colors[index % colors.length]),
            ),
          ),
        );
      },
    );
  }

  Widget _getParticleShape(int index, Color color) {
    // Different shapes for particles with more variety to match the second image
    switch (index % 6) {
      case 0: // Circle
        return Container(
          width: getProportionateScreenWidth(10),
          height: getProportionateScreenWidth(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        );
      case 1: // Small circle
        return Container(
          width: getProportionateScreenWidth(6),
          height: getProportionateScreenWidth(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        );
      case 2: // Line/curve
        return Transform.rotate(
          angle: angle(index),
          child: Container(
            width: getProportionateScreenWidth(20),
            height: getProportionateScreenWidth(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: color,
            ),
          ),
        );
      case 3: // Small circle with outline
        return Container(
          width: getProportionateScreenWidth(8),
          height: getProportionateScreenWidth(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        );
      case 4: // Curved line (similar to second image)
        return CustomPaint(
          painter: CurvedLinePainter(color: color),
          size: Size(getProportionateScreenWidth(20), getProportionateScreenWidth(12)),
        );
      default: // Dot
        return Container(
          width: getProportionateScreenWidth(4),
          height: getProportionateScreenWidth(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        );
    }
  }

  // Helper function to calculate angle based on index
  double angle(int index) {
    return (index / 25) * 2 * math.pi;
  }
}

// Custom painter for curved lines (like in second image)
class CurvedLinePainter extends CustomPainter {
  final Color color;

  CurvedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.2,
        size.width,
        size.height * 0.8
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CheckmarkPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 5.5, // Increased stroke width for thicker checkmark
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Define the checkmark path
    final Path path = Path();

    // Starting point of the checkmark (left point) - adjusted for less padding
    final startPoint = Offset(size.width * 0.25, size.height * 0.52);
    // Corner point of the checkmark (bottom point) - adjusted for better proportion
    final cornerPoint = Offset(size.width * 0.40, size.height * 0.70);
    // End point of the checkmark (right point) - adjusted to extend further
    final endPoint = Offset(size.width * 0.75, size.height * 0.35);

    // Calculate how far along each part of the checkmark to draw
    if (progress < 0.5) {
      // First half of the animation draws the first stroke (from left to corner)
      final firstStrokeProgress = math.min(1.0, progress * 2);

      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(
        startPoint.dx + (cornerPoint.dx - startPoint.dx) * firstStrokeProgress,
        startPoint.dy + (cornerPoint.dy - startPoint.dy) * firstStrokeProgress,
      );
    } else {
      // Draw the complete first stroke
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(cornerPoint.dx, cornerPoint.dy);

      // Second half of the animation draws the second stroke (from corner to right)
      final secondStrokeProgress = math.min(1.0, (progress - 0.5) * 2);

      path.moveTo(cornerPoint.dx, cornerPoint.dy);
      path.lineTo(
        cornerPoint.dx + (endPoint.dx - cornerPoint.dx) * secondStrokeProgress,
        cornerPoint.dy + (endPoint.dy - cornerPoint.dy) * secondStrokeProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

