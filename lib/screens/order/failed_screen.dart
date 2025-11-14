import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:thenexstore/data/providers/providers.dart';
import 'package:thenexstore/routes/navigator_services.dart';
import 'package:thenexstore/routes/routes_names.dart';
import 'package:thenexstore/screens/components/custom_button.dart';

import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class FailedScreen extends StatefulWidget {
  final String title;
  final String message;
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;

  const FailedScreen({
    super.key,
    this.title = "Order Failed",
    this.message = "We're sorry! Your order could not be processed. Please try again or contact support.",
    this.primaryButtonText = "Try Again",
    this.secondaryButtonText = "Back to Home",
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
  });

  @override
  State<FailedScreen> createState() => _FailedScreenState();
}

class _FailedScreenState extends State<FailedScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _crossAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500), // Slightly longer for shake effect
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _crossAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    // Shake animation for error effect
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.elasticOut),
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(26)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: getProportionateScreenHeight(100)),

                  // Animated Cross with particles and shake effect
                  SizedBox(
                    height: getProportionateScreenWidth(220),
                    width: getProportionateScreenWidth(220),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated particles with error colors
                        ...List.generate(25, (index) => _buildParticle(index)),

                        // Circle and cross with shake effect
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            // Shake effect calculation
                            double shakeOffset = 0;
                            if (_shakeAnimation.value > 0) {
                              shakeOffset = math.sin(_shakeAnimation.value * math.pi * 4) * 5 * (1 - _shakeAnimation.value);
                            }

                            return Transform.translate(
                              offset: Offset(shakeOffset, 0),
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Container(
                                  height: getProportionateScreenWidth(90),
                                  width: getProportionateScreenWidth(90),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53E3E), // Red color for error
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFC53030), width: 2),
                                  ),
                                  child: Center(
                                    child: AnimatedBuilder(
                                      animation: _crossAnimation,
                                      builder: (context, child) {
                                        return CustomPaint(
                                          painter: CrossPainter(
                                            progress: _crossAnimation.value,
                                            color: Colors.white,
                                            strokeWidth: 5.5,
                                          ),
                                          size: Size(
                                            getProportionateScreenWidth(75),
                                            getProportionateScreenWidth(75),
                                          ),
                                        );
                                      },
                                    ),
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
                    style: headingH2Style,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),

                  // Message text
                  Text(
                    widget.message,
                    style: bodyStyleStyleB1.copyWith(color: kSecondaryColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getProportionateScreenHeight(50)),

                  // Primary button (e.g. "Try Again")
                  CustomButton(
                    text: widget.primaryButtonText,
                    press: widget.onPrimaryButtonPressed ?? () {
                      Navigator.of(context).pop(); // Go back to retry
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
    // Error-themed colors (reds, oranges, darker tones)
    const colors = [
      Color(0xFFE53E3E), // Red
      Color(0xFFED8936), // Orange
      Color(0xFFD69E2E), // Yellow-orange
      Color(0xFFE53E3E), // Red variant
      Color(0xFFDD6B20), // Orange variant
      Color(0xFFECC94B), // Yellow
      Color(0xFFF56565), // Light red
      Color(0xFFED8936), // Orange
      Color(0xFFE53E3E), // Red
      Color(0xFFBD2130), // Dark red
      Color(0xFFD69E2E), // Yellow-orange
    ];

    final angle = (index / 25) * 2 * math.pi;
    const delay = 0.3;

    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        final animationProgress = math.max(0.0, math.min(1.0, (_controller.value - delay) / 0.6));

        if (animationProgress <= 0) {
          return const SizedBox.shrink();
        }

        // More chaotic movement for error effect
        final easedProgress = Curves.easeOutBack.transform(animationProgress);
        final radius = 140 * easedProgress; // Slightly smaller explosion

        // Add some randomness to the angle for more chaotic feel
        final randomOffset = (index % 3 - 1) * 0.2;
        final adjustedAngle = angle + randomOffset;

        final dx = math.cos(adjustedAngle) * radius;
        final dy = math.sin(adjustedAngle) * radius;

        const fadeOutStart = 0.6; // Fade out earlier for more dramatic effect
        final opacity = animationProgress < fadeOutStart
            ? 1.0
            : 1.0 - ((animationProgress - fadeOutStart) / (1.0 - fadeOutStart));

        final scale = 0.6 + (easedProgress * 0.6); // Slightly different scaling

        return Positioned(
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
    // More angular/jagged shapes for error theme
    switch (index % 7) {
      case 0: // Circle
        return Container(
          width: getProportionateScreenWidth(8),
          height: getProportionateScreenWidth(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        );
      case 1: // Small jagged triangle
        return CustomPaint(
          painter: TrianglePainter(color: color),
          size: Size(getProportionateScreenWidth(12), getProportionateScreenWidth(12)),
        );
      case 2: // Angular line
        return Transform.rotate(
          angle: angle(index),
          child: Container(
            width: getProportionateScreenWidth(16),
            height: getProportionateScreenWidth(4),
            decoration: BoxDecoration(
              color: color,
            ),
          ),
        );
      case 3: // Small circle with thick outline
        return Container(
          width: getProportionateScreenWidth(6),
          height: getProportionateScreenWidth(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
        );
      case 4: // Jagged line
        return CustomPaint(
          painter: JaggedLinePainter(color: color),
          size: Size(getProportionateScreenWidth(18), getProportionateScreenWidth(8)),
        );
      case 5: // Square
        return Container(
          width: getProportionateScreenWidth(8),
          height: getProportionateScreenWidth(8),
          decoration: BoxDecoration(
            color: color,
          ),
        );
      default: // Small dot
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

  double angle(int index) {
    return (index / 25) * 2 * math.pi;
  }
}

// Custom painter for triangle particles
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for jagged lines
class JaggedLinePainter extends CustomPainter {
  final Color color;

  JaggedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.lineTo(size.width * 0.3, size.height * 0.2);
    path.lineTo(size.width * 0.7, size.height * 0.8);
    path.lineTo(size.width, size.height * 0.4);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for the cross/X mark
class CrossPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CrossPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 5.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Define the cross path (X shape)
    // First line: top-left to bottom-right
    final topLeft = Offset(size.width * 0.25, size.height * 0.25);
    final bottomRight = Offset(size.width * 0.75, size.height * 0.75);

    // Second line: top-right to bottom-left
    final topRight = Offset(size.width * 0.75, size.height * 0.25);
    final bottomLeft = Offset(size.width * 0.25, size.height * 0.75);

    final Path path = Path();

    if (progress < 0.5) {
      // First half: draw first line of the X
      final firstLineProgress = math.min(1.0, progress * 2);

      path.moveTo(topLeft.dx, topLeft.dy);
      path.lineTo(
        topLeft.dx + (bottomRight.dx - topLeft.dx) * firstLineProgress,
        topLeft.dy + (bottomRight.dy - topLeft.dy) * firstLineProgress,
      );
    } else {
      // Draw complete first line
      path.moveTo(topLeft.dx, topLeft.dy);
      path.lineTo(bottomRight.dx, bottomRight.dy);

      // Second half: draw second line of the X
      final secondLineProgress = math.min(1.0, (progress - 0.5) * 2);

      path.moveTo(topRight.dx, topRight.dy);
      path.lineTo(
        topRight.dx + (bottomLeft.dx - topRight.dx) * secondLineProgress,
        topRight.dy + (bottomLeft.dy - topRight.dy) * secondLineProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CrossPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}