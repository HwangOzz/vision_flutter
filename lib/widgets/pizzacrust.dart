import 'package:flutter/material.dart';
import 'dart:math'; // ← 도 → 라디안 변환을 위해 필요!

class PizzaCrustDoubleOffset extends StatelessWidget {
  final double angleDegree; // ← 도 단위로 받음 (예: 90)
  final Color outerColor;
  final Color innerColor;

  const PizzaCrustDoubleOffset({
    super.key,
    this.angleDegree = 0, // 기본값 0도
    required this.outerColor,
    required this.innerColor,
  });

  @override
  Widget build(BuildContext context) {
    // 도 → 라디안 변환
    final double angleRad = angleDegree * pi / 180;

    return Transform.rotate(
      angle: angleRad,
      child: CustomPaint(
        size: const Size(150, 150),
        painter: CrustOffsetPainter(
          outerColor: outerColor,
          innerColor: innerColor,
        ),
      ),
    );
  }
}

class CrustOffsetPainter extends CustomPainter {
  final Color outerColor;
  final Color innerColor;

  CrustOffsetPainter({required this.outerColor, required this.innerColor});

  @override
  void paint(Canvas canvas, Size size) {
    const double outerRadius = 80;
    const double scale = 0.85;
    final double innerRadius = outerRadius * scale;

    const double startAngle = -pi / 3;
    const double sweepAngle = pi / 1.5;

    final Offset center = Offset(size.width / 2, size.height / 2);

    // 안쪽 크러스트 먼저
    final Paint innerPaint =
        Paint()
          ..color = innerColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 30;
    final Offset offset = const Offset(-10, 0);
    final Rect innerArc = Rect.fromCircle(
      center: center + offset,
      radius: innerRadius,
    );
    canvas.drawArc(innerArc, startAngle, sweepAngle, false, innerPaint);

    // 바깥쪽 크러스트 나중에
    final Paint outerPaint =
        Paint()
          ..color = outerColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 30;
    final Rect outerArc = Rect.fromCircle(center: center, radius: outerRadius);
    canvas.drawArc(outerArc, startAngle, sweepAngle, false, outerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
