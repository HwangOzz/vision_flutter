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
  List<bool> mBits = List.filled(10, false); // M0 ~ M9 상태 저장
  bool isFetching = false; // 상태 요청 중 여부
  List<bool> mBitsCompleted = List.filled(10, false);
  bool _isDisposed = false;

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
        Uri.parse("${Global.serverUrl}/get_m_bits"),
      );
      final data = jsonDecode(response.body);

      if (!mounted) return; // <- 여기서 먼저 체크!

      setState(() {
        for (int i = 0; i < 10; i++) {
          bool currentState = data["M$i"] == 1;
          mBits[i] = currentState;
          if (currentState) {
            mBitsCompleted[i] = true;

            // ✅ 현재 켜진 M 비트보다 앞에 있는 비트들도 자동 완료 처리
            for (int j = 0; j < i; j++) {
              mBitsCompleted[j] = true;
            }
          }
        }

        // ✅ M9 들어오면 초기화
        if (data["M9"] == 1) {
          mBitsCompleted = List.filled(10, false);
          print("🔁 M9 감지됨 → 공정 초기화됨");
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

  double _getProgressForRange(int start, int end) {
    int total = end - start + 1;
    int active =
        mBitsCompleted.sublist(start, end + 1).where((bit) => bit).length;
    return active / total;
  }

  String _getStatusForRange(int start, int end) {
    int active =
        mBitsCompleted.sublist(start, end + 1).where((bit) => bit).length;
    if (active == 0) return "대기 중";
    if (active < (end - start + 1)) return "진행 중";
    return "완료";
  }

  Widget _buildProcessCard(String title, int start, int end) {
    double progress = _getProgressForRange(start, end);
    String status = _getStatusForRange(start, end);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: progress),
            SizedBox(height: 4),
            Text("상태: $status"),
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
            _buildProcessCard("1. 제품 조립 (M0~M3)", 0, 3),
            _buildProcessCard("2. 비전센서 검사 (M4~M6)", 4, 6),
            _buildProcessCard("3. 물품 보관 (M7~M9)", 7, 8),
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
