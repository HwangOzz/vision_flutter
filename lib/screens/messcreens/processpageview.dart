import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vision_flutter/globals/serverurl.dart';
import 'dart:convert';
import 'package:vision_flutter/screens/messcreens/pageviewdetail.dart';
import 'package:vision_flutter/screens/messcreens/practice.dart';

class ProcessSimulationPage extends StatefulWidget {
  @override
  _ProcessSimulationPageState createState() => _ProcessSimulationPageState();
}

class _ProcessSimulationPageState extends State<ProcessSimulationPage> {
  List<bool> mBits = List.filled(1000, false); // M0 ~ M9 상태 저장
  bool isFetching = false; // 상태 요청 중 여부
  bool _isDisposed = false;
  List<bool> mBitsCompleted = List.filled(1000, false);

  @override
  void initState() {
    super.initState();
    fetchMBitStates(); // 시작 시 M 비트 상태 가져오기
  }

  // PLC 서버에서 M 비트 상태를 가져오는 함수
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          for (int i = 0; i < 1000; i++) {
            final key = "M$i";
            // fetchMBitStates 내부에서 누적 저장
            if (data.containsKey(key)) {
              final isOn = data[key] == 1;
              mBits[i] = isOn;
              if (isOn) {
                mBitsCompleted[i] = true; // ✅ 누적
              }
            }
          }
          // ✅ true인 비트만 로그 출력
          final activeBits = <int>[];
          for (int i = 0; i < mBits.length; i++) {
            if (mBits[i]) {
              activeBits.add(i);
            }
          }
          print("✅ 현재 활성화된 M 비트: $activeBits");
        });
      } else {
        print("❌ 서버 응답 오류: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ M 비트 상태 조회 실패: $e");
    }

    isFetching = false;
    if (!_isDisposed) {
      Future.delayed(Duration(seconds: 1), fetchMBitStates);
    }
  }

  Widget _buildProcessCardGrouped(
    String title,
    List<List<int>> combinations,
    int groupIndex,
  ) {
    double bestProgress = 0.0;
    String bestStatus = "대기 중";

    for (final group in combinations) {
      final total = group.length;
      // 진행률 계산할 때는 이걸로
      final active = group.where((i) => mBitsCompleted[i]).length;

      final progress = active / total;

      if (progress == 1.0) {
        bestProgress = 1.0;
        bestStatus = "완료";
        break; // 더 볼 필요 없음
      }

      if (progress > bestProgress) {
        bestProgress = progress;
        bestStatus = "진행 중";
      }
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: bestProgress),
            SizedBox(height: 4),
            Text("상태: $bestStatus (${(bestProgress * 100).toInt()}%)"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProcessCardGrouped("1. 제품 조립", [
              [0, 1, 2, 20],
              [0, 90, 92, 21],
              [0, 91, 93, 22],
            ], 0),

            _buildProcessCardGrouped("2. 비전센서 검사", [
              [3, 20],
              [3, 21],
              [3, 22],
            ], 1),

            _buildProcessCardGrouped("3. 물품 보관", [
              [4, 5, 6],
              [4, 94, 96],
              [4, 95, 97],
            ], 2),

            SizedBox(height: 32),
            Text(
              "※ 실시간으로 PLC 상태를 반영합니다",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              style: ButtonStyle(
                elevation: WidgetStatePropertyAll(2),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                backgroundColor: WidgetStatePropertyAll(
                  const Color.fromARGB(255, 107, 159, 236),
                ),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PageViewDetail()),
                );
              },
              child: Text(
                '상세 화면',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              style: ButtonStyle(
                elevation: WidgetStatePropertyAll(2),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                backgroundColor: WidgetStatePropertyAll(
                  const Color.fromARGB(255, 107, 159, 236),
                ),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Practice()),
                );
              },
              child: Text(
                '연습 화면',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
