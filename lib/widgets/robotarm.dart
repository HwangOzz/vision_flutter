import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class RobotArm extends StatefulWidget {
  final bool active;

  const RobotArm({required this.active, super.key});

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
    movementTimer = Timer.periodic(Duration(milliseconds: 16), (_) {
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
    return Container(
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
          // 동그란 회전축
          Transform.rotate(
            angle: angle + pi / 4,
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 254, 254),
                shape: BoxShape.circle,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 20,
                    width: 24,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(255, 229, 229, 229),
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 24,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 로봇팔 (중심 기준으로 위로 올려서 회전)
          Transform.rotate(
            angle: angle + pi / 4,
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(0, -45), // 막대 길이 절반만큼 위로 올림 (60 / 2)
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 232, 232, 232),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 15,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 17, 17, 17),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 228, 228, 228),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
