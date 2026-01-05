import 'package:flutter/material.dart';

class RCLLogo extends StatelessWidget {
  final double size;
  final Color? primaryColor;
  final Color? accentColor;

  const RCLLogo({
    Key? key,
    this.size = 80,
    this.primaryColor,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = primaryColor ?? Color(0xFF0A5FBF);
    final accent = accentColor ?? Color(0xFF10B981);

    return CustomPaint(
      size: Size(size, size),
      painter: RCLLogoPainter(
        primaryColor: primary,
        accentColor: accent,
      ),
    );
  }
}

class RCLLogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  RCLLogoPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    // Draw blue background circle
    paint.color = primaryColor;
    canvas.drawCircle(center, radius, paint);

    // Draw white "RCL" text background
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.85, paint);

    // Draw green swoosh accent
    paint.color = accentColor;
    final swooshPath = Path();
    final swooshCenter = center;
    swooshPath.moveTo(swooshCenter.dx - radius * 0.4, swooshCenter.dy + radius * 0.3);
    swooshPath.cubicTo(
      swooshCenter.dx - radius * 0.2,
      swooshCenter.dy + radius * 0.5,
      swooshCenter.dx + radius * 0.2,
      swooshCenter.dy + radius * 0.4,
      swooshCenter.dx + radius * 0.5,
      swooshCenter.dy + radius * 0.1,
    );
    swooshPath.lineTo(swooshCenter.dx + radius * 0.6, swooshCenter.dy + radius * 0.0);
    swooshPath.lineTo(swooshCenter.dx + radius * 0.4, swooshCenter.dy + radius * 0.2);
    swooshPath.cubicTo(
      swooshCenter.dx + radius * 0.1,
      swooshCenter.dy + radius * 0.35,
      swooshCenter.dx - radius * 0.1,
      swooshCenter.dy + radius * 0.42,
      swooshCenter.dx - radius * 0.5,
      swooshCenter.dy + radius * 0.35,
    );
    swooshPath.close();

    canvas.drawPath(swooshPath, paint);

    // Draw "RCL" text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'RCL',
        style: TextStyle(
          color: primaryColor,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(RCLLogoPainter oldDelegate) => false;
}
