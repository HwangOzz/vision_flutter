import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class RobotArm extends StatefulWidget {
  final bool active;
  final double rotationAngleDegree; // ← 도 단위로 받음 (예: 90)

  const RobotArm({
    required this.active,
    this.rotationAngleDegree = 0, // 기본 회전 없음
    super.key,
  });

  @override
  State<RobotArm> createState() => _RobotArmState();
}

class _RobotArmState extends State<RobotArm> {
  double angle = pi / 4;
  bool reverse = false;
  Timer? movementTimer;

  @override
  void initState() {
    super.initState();
    startLoop();
  }

  void startLoop() {
    movementTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (widget.active) {
        setState(() {
          angle += reverse ? -pi / 360 : pi / 360;

          if (angle >= pi / 4) reverse = true;
          if (angle <= -pi / 4) reverse = false;
        });
      }
    });
  }

  @override
  void dispose() {
    movementTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double radian = widget.rotationAngleDegree * pi / 180; // 도 → 라디안 변환

    return Transform.rotate(
      angle: radian,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 67, 66, 66),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromARGB(255, 219, 219, 219),
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 회전축
            Transform.rotate(
              angle: angle + pi / 4,
              child: Container(
                width: 85,
                height: 85,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 254, 254),
                  shape: BoxShape.circle,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_jointBlock(), _centerCircle(), _jointBlock()],
                ),
              ),
            ),

            // 로봇팔
            Transform.rotate(
              angle: angle + pi / 4,
              alignment: Alignment.center,
              child: Transform.translate(
                offset: const Offset(0, -45),
                child: Column(
                  children: [
                    _armSegment(
                      28,
                      55,
                      const Color.fromARGB(255, 232, 232, 232),
                    ),
                    _armSegment(28, 15, const Color.fromARGB(255, 17, 17, 17)),
                    _armSegment(
                      28,
                      26,
                      const Color.fromARGB(255, 228, 228, 228),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _jointBlock() {
    return Container(
      height: 20,
      width: 24,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _centerCircle() {
    return Container(
      height: 35,
      width: 35,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(255, 229, 229, 229),
      ),
    );
  }

  Widget _armSegment(double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
