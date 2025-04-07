import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vision_flutter/widgets/pizzacrust.dart';
import 'package:vision_flutter/widgets/robotarm.dart';

class Practice extends StatefulWidget {
  const Practice({super.key});

  @override
  State<Practice> createState() => _PracticeState();
}

class _PracticeState extends State<Practice> {
  bool m0 = false; // ← 나중에 PLC값으로 바꿀 수 있음
  bool m1 = false;
  int movingBoxIndex = 0; // 0: 위, 1: 중간, 2: 아래
  bool flashVisible = false;
  Timer? flashTimer;

  double _getBoxTopByIndex(int index) {
    switch (index) {
      case 0:
        return 110; // 위
      case 1:
        return 360; // 중간
      case 2:
        return 490; // 아래
      default:
        return 110;
    }
  }

  void _toggleM0() {
    setState(() {
      m0 = !m0;
    });

    if (m0) {
      // m0이 true → 플래시 시작
      flashTimer = Timer.periodic(Duration(milliseconds: 300), (timer) {
        setState(() {
          flashVisible = !flashVisible;
        });
      });
    } else {
      // m0이 false → 플래시 중지
      flashTimer?.cancel();
      flashTimer = null;
      setState(() {
        flashVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 113, 113, 113),
      appBar: AppBar(title: Text('로봇팔 1대')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 800,
          width: 400,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. 기존 Row 전체 UI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 10,
                          top: 80,
                          child: PizzaCrustDoubleOffset(
                            outerColor: const Color.fromARGB(
                              255,
                              181,
                              181,
                              181,
                            ),
                            innerColor: const Color.fromARGB(255, 98, 98, 98),
                            angleDegree: 90,
                          ),
                        ),
                        Positioned(
                          left: 50,
                          bottom: 20,
                          child: PizzaCrustDoubleOffset(
                            outerColor: const Color.fromARGB(
                              255,
                              181,
                              181,
                              181,
                            ),
                            innerColor: const Color.fromARGB(255, 98, 98, 98),
                            angleDegree: 180,
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(height: 25),
                            // 여기에 RobotArm을 임시로 투명하게 둬도 됨
                            Opacity(
                              opacity: 0, // 위치 계산을 위해 남겨놓음
                              child: RobotArm(
                                active: m0,
                                rotationAngleDegree: 90,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Container(
                          height: 60,
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            color: const Color.fromARGB(255, 216, 216, 216),
                          ),
                          child: Center(
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 500,
                          width: 40,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 161, 161, 161),
                          ),
                          child: Center(
                            child: Container(
                              height: 500,
                              width: 30,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 30, 30, 30),
                              ),
                            ),
                          ),
                        ),
                        RobotArm(active: m0),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 15),
                        Container(
                          height: 40,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            color: const Color.fromARGB(255, 212, 212, 212),
                          ),
                        ),
                        SizedBox(height: 405),
                        Transform.translate(
                          offset: Offset(-60, 70),
                          child: PizzaCrustDoubleOffset(
                            outerColor: const Color.fromARGB(
                              255,
                              181,
                              181,
                              181,
                            ),
                            innerColor: const Color.fromARGB(255, 98, 98, 98),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ), //아래가 서보모터
              AnimatedPositioned(
                duration: Duration(milliseconds: 800),
                top: _getBoxTopByIndex(movingBoxIndex),
                left: 150,
                child: Container(
                  height: 80,
                  width: 68,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 43, 43, 43),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              Positioned(
                top: 65,
                left: 20,
                child: RobotArm(active: m0, rotationAngleDegree: 90),
              ),
              Positioned(
                top: 85,
                right: 20,
                child: RobotArm(active: m0, rotationAngleDegree: 270),
              ),
              // 비전카메라 본체
              Positioned(
                bottom: 272,
                left: 149,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 65,
                      width: 67,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        color: const Color.fromARGB(255, 193, 194, 194),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: flashVisible ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 150),
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'btn1',
            onPressed: () {
              setState(() {
                movingBoxIndex = 0;
              });
            },
            child: Text("1"),
          ),
          FloatingActionButton(
            heroTag: 'btn2',
            onPressed: () {
              setState(() {
                movingBoxIndex = 1;
              });
            },
            child: Text("2"),
          ),
          FloatingActionButton(
            heroTag: 'btn3',
            onPressed: () {
              setState(() {
                movingBoxIndex = 2;
              });
            },
            child: Text("3"),
          ),
          FloatingActionButton(
            onPressed: _toggleM0,
            child: Icon(m0 ? Icons.pause : Icons.play_arrow),
          ),
        ],
      ),
    );
  }
}
