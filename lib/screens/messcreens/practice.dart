import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vision_flutter/globals/serverurl.dart';
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
  List<bool> mBits = List.filled(1001, false);
  List<bool> mBitsCompleted = List.filled(1001, false);
  bool isFetching = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    fetchMBitStates();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> fetchMBitStates() async {
    if (isFetching || _isDisposed) return;
    isFetching = true;

    try {
      final response = await http.get(
        Uri.parse("${Global.serverUrl}/get_m_bits?start=0&count=1000"),
      );
      final data = jsonDecode(response.body);

      if (!mounted) return;
      setState(() {
        for (int i = 0; i < 1001; i++) {
          bool currentState = data["M$i"] == 1;
          mBits[i] = currentState;
          if (currentState) {
            mBitsCompleted[i] = true;
            for (int j = 0; j < i; j++) {
              mBitsCompleted[j] = true;
            }
          }
        }

        // 👉 M0, M3, M4 조합으로 박스 위치 이동
        if (data["M0"] == 1 || data["M380"] == 1) {
          movingBoxIndex = 0;
        } else if (data["M3"] == 1) {
          movingBoxIndex = 1;
        } else if (data["M4"] == 1) {
          movingBoxIndex = 2;
        }

        // 👉 M20,21,22 → 카메라 플래시
        if (data["M20"] == 1 || data["M21"] == 1 || data["M22"] == 1) {
          if (flashTimer == null && !_isDisposed) {
            flashTimer = Timer.periodic(Duration(milliseconds: 300), (timer) {
              if (!_isDisposed) {
                setState(() {
                  flashVisible = !flashVisible;
                });
              }
            });
          }
        } else {
          flashTimer?.cancel();
          flashTimer = null;
          setState(() {
            flashVisible = false;
          });
        }

        // M9: 전체 리셋
      });
    } catch (e) {
      print("❌ M 비트 상태 조회 실패: $e");
    }

    isFetching = false;
    if (!_isDisposed) {
      Future.delayed(Duration(seconds: 1), fetchMBitStates);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 113, 113, 113),
      appBar: AppBar(title: Text('연습 모드')),
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
                  Flexible(
                    flex: 1,
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
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
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
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 15),
                            Container(
                              height: 40,
                              width: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(6),
                                ),
                                color: const Color.fromARGB(255, 212, 212, 212),
                              ),
                            ),
                            SizedBox(height: 405),
                            Transform.translate(
                              offset: Offset(-60, 73),
                              child: PizzaCrustDoubleOffset(
                                outerColor: const Color.fromARGB(
                                  255,
                                  181,
                                  181,
                                  181,
                                ),
                                innerColor: const Color.fromARGB(
                                  255,
                                  98,
                                  98,
                                  98,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 30,
                top: 376,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 139, 139, 139),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
              Positioned(
                right: 55,
                top: 391,
                child: Container(
                  height: 20,
                  width: 150,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 221, 221, 221),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
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
              //로봇1
              Positioned(
                top: 65,
                left: 20,
                child: RobotArm(
                  active: mBits[1] || mBits[90] || mBits[91],
                  rotationAngleDegree: 90,
                ),
              ),
              //로봇2
              Positioned(
                top: 85,
                right: 20,
                child: RobotArm(
                  active: mBits[2] || mBits[92] || mBits[93],
                  rotationAngleDegree: 270,
                ),
              ),
              Positioned(
                bottom: 15,
                left: 133,
                child: RobotArm(
                  active:
                      mBits[5] ||
                      mBits[6] ||
                      mBits[94] ||
                      mBits[96] ||
                      mBits[95] ||
                      mBits[97],
                ),
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
    );
  }
}
