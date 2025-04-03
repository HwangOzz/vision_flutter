import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vision_flutter/globals/serverurl.dart';
import 'package:vision_flutter/widgets/mbitvideoplayer.dart';
import 'dart:convert';

class PageViewDetail extends StatefulWidget {
  const PageViewDetail({super.key});

  @override
  State<PageViewDetail> createState() => _PageViewDetailState();
}

class _PageViewDetailState extends State<PageViewDetail> {
  List<bool> mBits = List.filled(10, false);
  List<bool> mBitsCompleted = List.filled(10, false);
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
        Uri.parse("${Global.serverUrl}/get_m_bits"),
      );
      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        for (int i = 0; i < 10; i++) {
          bool currentState = data["M$i"] == 1;
          mBits[i] = currentState;
          if (currentState) {
            mBitsCompleted[i] = true;
            for (int j = 0; j < i; j++) {
              mBitsCompleted[j] = true;
            }
          }
        }

        if (data["M9"] == 1) {
          mBitsCompleted = List.filled(10, false);
        }
      });
    } catch (e) {
      print("❌ M 비트 상태 조회 실패: $e");
    }

    isFetching = false;
    if (!_isDisposed) {
      Future.delayed(Duration(seconds: 1), fetchMBitStates);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              height: 1890,
              width: 500,
              child: Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 300,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/storage-mes.png"),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Center(
                            child: MBitVideoPlayer(
                              videoPath: 'assets/animation/robot-arm.mp4',
                              isActive: mBits[0], // M상태와 연결
                              rotation: 0, // 회전
                              flipX: false, // 좌우반전 적용
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Center(
                            child: MBitVideoPlayer(
                              videoPath: 'assets/animation/conveyor-belt.mp4',
                              isActive: mBits[2], // M상태와 연결
                              rotation: 180, // 회전
                              flipX: false, // 좌우반전 적용
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Center(
                            child: MBitVideoPlayer(
                              videoPath: 'assets/animation/robot-arm.mp4',
                              isActive: mBits[1], // M상태와 연결
                              rotation: 0, // 회전
                              flipX: true, // 좌우반전 적용
                            ),
                          ),
                        ),
                        SizedBox(width: 14),
                      ],
                    ),
                  ),

                  Flexible(
                    flex: 1,
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/storage-mes.png"),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: SizedBox(
                            child: MBitVideoPlayer(
                              videoPath: 'assets/animation/conveyor-belt.mp4',
                              isActive: mBits[3], // M상태와 연결
                              rotation: 180, // 회전
                              flipX: false, // 좌우반전 적용
                            ),
                          ),
                        ),
                        Flexible(flex: 1, child: SizedBox()),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Row(
                      children: [
                        Flexible(flex: 1, child: Spacer()),
                        Flexible(
                          flex: 1,
                          child: SizedBox(
                            child: MBitVideoPlayer(
                              videoPath: 'assets/animation/conveyor-belt.mp4',
                              isActive: mBits[4], // M상태와 연결
                              rotation: 180, // 회전
                              flipX: false, // 좌우반전 적용
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: SizedBox(
                            child: MBitVideoPlayer(
                              videoPath: 'assets/animation/camera.mp4',
                              isActive: mBits[5], // M상태와 연결
                              rotation: 0, // 회전
                              flipX: true, // 좌우반전 적용
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Row(
                      children: [
                        Flexible(flex: 1, child: Spacer()),
                        Flexible(
                          flex: 1,
                          child: SizedBox(
                            child: MBitVideoPlayer(
                              videoPath: 'assets/animation/conveyor-belt.mp4',
                              isActive: mBits[6], // M상태와 연결
                              rotation: 180, // 회전
                              flipX: false, // 좌우반전 적용
                            ),
                          ),
                        ),
                        Flexible(flex: 1, child: Spacer()),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              Text(
                                "NG",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage("assets/storage-mes.png"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: SizedBox(
                            child: MBitVideoPlayer(
                              videoPath: 'assets/animation/robot-arm.mp4',
                              isActive: mBits[7], // M상태와 연결
                              rotation: 180, // 회전
                              flipX: false, // 좌우반전 적용
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              Text(
                                "OK",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage("assets/storage-mes.png"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40, // 상태바 아래 여백
            left: 16,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Color.fromARGB(255, 55, 54, 54),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
