import 'package:flutter/material.dart';

class Boundaryline extends StatelessWidget {
  const Boundaryline({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(250, 400), // 원하는 크기
      painter: ConcaveCornerPainter(),
    );
  }
}

class ConcaveCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Color(0xFFF4B342)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    final path = Path();
    double r = 30;
    double w = 170;
    double h = 330;

    // 👉 외곽 프레임
    path.moveTo(-r, 0);
    path.quadraticBezierTo(0, 0, 0, -r);
    path.lineTo(w, -r);
    path.quadraticBezierTo(w, 0, w + r, 0);
    path.lineTo(w + r, h);
    path.quadraticBezierTo(w, h, w, h + r);
    path.lineTo(0, h + r);
    path.quadraticBezierTo(0, h, -r, h);
    path.close();

    canvas.drawPath(path, paint);

    // ✅ 내부 작은 프레임
    final innerPaint =
        Paint()
          ..color = Color(0xFFF4B342)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final innerPath = Path();
    double inset = 13; // 안쪽으로 얼마나 들어갈지

    double ir = r - 8;
    double iw = w - inset * 2;
    double ih = h - inset * 2;

    // 왼쪽 위
    innerPath.moveTo(-ir + inset, inset);
    innerPath.quadraticBezierTo(inset, inset, inset, -ir + inset);
    innerPath.lineTo(inset + iw, -ir + inset);
    innerPath.quadraticBezierTo(inset + iw, inset, inset + iw + ir, inset);
    innerPath.lineTo(inset + iw + ir, inset + ih);
    innerPath.quadraticBezierTo(
      inset + iw,
      inset + ih,
      inset + iw,
      inset + ih + ir,
    );
    innerPath.lineTo(inset, inset + ih + ir);
    innerPath.quadraticBezierTo(inset, inset + ih, -ir + inset, inset + ih);
    innerPath.close();

    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
