import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thenexstore/utils/assets.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';

class AnimatedMicrophoneIcon extends StatefulWidget {
  final bool isListening;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final String? tooltip;

  const AnimatedMicrophoneIcon({
    super.key,
    required this.isListening,
    required this.onTap,
    this.activeColor = kPrimaryColor,
    this.inactiveColor = Colors.grey,
    this.tooltip,
  });

  @override
  State<AnimatedMicrophoneIcon> createState() => _AnimatedMicrophoneIconState();
}

class _AnimatedMicrophoneIconState extends State<AnimatedMicrophoneIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _rippleAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.isListening) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedMicrophoneIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget microphone = GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: getProportionateScreenHeight(40),
        height: getProportionateScreenHeight(40),
        margin: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(8)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isListening)
              AnimatedBuilder(
                animation: _rippleAnimation,
                builder: (context, child) {
                  return Container(
                    width: 36 * _rippleAnimation.value,
                    height: 36 * _rippleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kPrimaryColor.withOpacity(
                        (1 - _rippleAnimation.value + 1) * 0.15,
                      ),
                    ),
                  );
                },
              ),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isListening ? _scaleAnimation.value : 1.0,
                  child: Icon(
                    Icons.mic_none,
                    size: getProportionateScreenHeight(28),
                    color: widget.isListening ? widget.activeColor : widget.inactiveColor,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: microphone,
      );
    }

    return microphone;
  }
}