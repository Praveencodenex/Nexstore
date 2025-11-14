import 'package:flutter/material.dart';
import 'package:thenexstore/utils/size_config.dart';

class SnackBarUtils {
  static final GlobalKey<
      ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<
      ScaffoldMessengerState>();

  static void showSuccess(String message, {
    Duration? duration,
  }) {
    _showSnackBar(
      message,
      backgroundColor: const Color(0xFF1F8109),
      icon: Icons.check,
      duration: duration ?? const Duration(seconds: 2),
    );
  }

  static void showError(String message, {
    Duration? duration,
  }) {
    _showSnackBar(
      message,
      backgroundColor: const Color(0xFFE53E3E),
      icon: Icons.close,
      duration: duration ?? const Duration(seconds: 3),
    );
 }

  static void showInfo(String message, {
    Duration? duration,
  }) {
    _showSnackBar(
      message,
      backgroundColor: const Color(0xFFFF8C00),
      icon: Icons.help_outline,
      duration: duration ?? const Duration(seconds: 2),
    );
  }


  static void _showSnackBar(String message, {
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
  }) {
    if (rootScaffoldMessengerKey.currentState == null ||
        rootScaffoldMessengerKey.currentContext == null) {
      return;
    }
  rootScaffoldMessengerKey.currentState!.clearSnackBars();

    final snackBar = SnackBar(
      content: Container(
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(16),
          vertical: getProportionateScreenHeight(12),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative dots pattern
            Positioned(
              right: 30,
              bottom: 0,
              child: _buildWaterSplash(),
            ),

            Row(
              children: [
                // Icon circle
                Container(
                  width: getProportionateScreenWidth(36),
                  height: getProportionateScreenWidth(36),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: getProportionateScreenWidth(20),
                  ),
                ),
                SizedBox(width: getProportionateScreenWidth(12)),
                // Message
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: getProportionateScreenWidth(14),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                SizedBox(width: getProportionateScreenWidth(8)),
                // Close button
                GestureDetector(
                  onTap: () {
                    rootScaffoldMessengerKey.currentState
                        ?.hideCurrentSnackBar();
                  },
                  child: Container(
                    padding: EdgeInsets.all(getProportionateScreenWidth(4)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: getProportionateScreenWidth(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(getProportionateScreenWidth(16)),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      dismissDirection: DismissDirection.horizontal,
    );
    rootScaffoldMessengerKey.currentState!.showSnackBar(snackBar);
  }

  static Widget _buildWaterSplash() {
    return SizedBox(
      width: 35,
      height: 25,
      child: Stack(
        children: [
          // Main large circle
          Positioned(
            left: 8,
            bottom: 10,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Medium circle
          Positioned(
            left: 12,
            bottom:30,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Small circles
          Positioned(
            left: 21,
            bottom: 15,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 15,
            bottom: 2,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Tiny droplets
          Positioned(
            left: 25,
            bottom: 6,
            child: Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity( 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

