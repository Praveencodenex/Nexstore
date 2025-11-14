import 'package:flutter/material.dart';

class OfferTagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFE85C2E)
      ..style = PaintingStyle.fill;

    final Path path = Path();

    // Starting point at top-left
    path.moveTo(0, 0);

    // Top edge
    path.lineTo(size.width, 0);

    // Right edge
    path.lineTo(size.width, size.height - 8);

    // Start with a point on the right edge
    path.lineTo(size.width, size.height - 8);

    double currentX = size.width;
    final double zigzagWidth = size.width / 5; // 6 complete zigzags
    const double zigzagHeight = 5;

    // Start with right edge point
    path.lineTo(currentX, size.height - zigzagHeight);

    // Draw zigzags
    for (var i = 0; i < 5; i++) {
      currentX -= zigzagWidth / 2;
      path.lineTo(currentX, size.height); // Down to bottom
      currentX -= zigzagWidth / 2;
      path.lineTo(currentX, size.height - zigzagHeight); // Up to point
    }

    // End with left edge point
    path.lineTo(0, size.height - zigzagHeight);
    path.lineTo(0, size.height - 8);

    // Left edge
    path.lineTo(0, size.height - 8);

    // Close the path
    path.close();

    canvas.drawPath(path, paint);

    // Add a subtle darker edge for depth (optional)
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}