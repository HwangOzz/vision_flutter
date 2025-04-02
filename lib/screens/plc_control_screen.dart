import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PLCControlScreen extends StatefulWidget {
  const PLCControlScreen({super.key});

  @override
  _PLCControlScreenState createState() => _PLCControlScreenState();
}

class _PLCControlScreenState extends State<PLCControlScreen> {
  final String serverUrl = "http://192.168.0.126:5000";
  int d100Value = 0;
  bool isFetching = false;
  bool _isDisposed = false;

  List<bool> mBitStates = List.filled(11, false);
  final List<String> mBitLabels = [
    "컨베이어 1 작동",
    "로봇1 작동",
    "로봇2 작동",
    "컨베이어 2 작동",
    "비전센서 감지",
    "컨베이어 3 작동",
    "로봇3 작동",
    "컨베이어 1 작동",
    "창고 적재",
    "창고 완료",
    "⚠️ 긴급 정지",
  ];

  @override
  void initState() {
    super.initState();
    startAutoUpdate(); // 주기적 상태 업데이트 시작
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // 상태를 주기적으로 업데이트하는 루프
  void startAutoUpdate() async {
    while (!_isDisposed) {
      await Future.wait([getMBits(), getD100()]);
      await Future.delayed(Duration(seconds: 1));
    }
  }

  // M 비트 상태 가져오기
  Future<void> getMBits() async {
    if (!mounted) return;
    try {
      final response = await http.get(Uri.parse("$serverUrl/get_m_bits"));
      final responseData = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < 11; i++) {
          mBitStates[i] = responseData["M$i"] == 1;
        }
      });
    } catch (e) {
      print("❌ M 비트 상태 조회 실패: $e");
    }
  }

  // D100 값 가져오기
  Future<void> getD100() async {
    if (!mounted) return;
    try {
      final response = await http.get(Uri.parse("$serverUrl/get_d100"));
      final responseData = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        d100Value = responseData["value"];
      });
    } catch (e) {
      print("❌ D100 조회 실패: $e");
    }
  }

  // D100 설정 (값 보내기)
  Future<void> setD100(int value) async {
    try {
      final response = await http.post(
        Uri.parse("$serverUrl/set_d100"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"value": value}),
      );
      final responseData = jsonDecode(response.body);
      print(responseData["message"]);
    } catch (e) {
      print("❌ D100 설정 실패: $e");
    }
  }

  // M 비트 수동 설정
  Future<void> setMBit(String address, int value) async {
    try {
      final response = await http.post(
        Uri.parse("$serverUrl/set_bit"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"address": address, "value": value}),
      );
      final responseData = jsonDecode(response.body);
      print("✅ ${responseData["message"]}");
    } catch (e) {
      print("❌ $address 설정 실패: $e");
    }
  }

  // build 함수는 그대로 유지 (생략 가능)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 153, 154, 154),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tv, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "PLC 제어",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // 이전 화면으로 이동
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "수동제어",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            SizedBox(height: 10),
            ...List.generate(10, (i) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    mBitLabels[i],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Switch(
                    value: mBitStates[i],
                    onChanged: (val) {
                      setState(() => mBitStates[i] = val);
                      setMBit("M$i", val ? 1 : 0);
                    },
                  ),
                ],
              );
            }),
            SizedBox(height: 30),
            Text(
              "🛑 긴급 정지",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            Divider(),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text("긴급 정지"),
                        content: Text("정말로 긴급 정지하시겠습니까?"),
                        actions: [
                          TextButton(
                            child: Text("취소"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: Text(
                              "확인",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              setMBit("M10", 1); // M10 비트에 1 쓰기
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                );
              },
              child: Text(
                "긴급 정지",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "📏 D100 제어",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            SizedBox(height: 10),
            Text("현재 D100 값: $d100Value", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                int newValue = d100Value + 10;
                setD100(newValue);
                setState(() => d100Value = newValue);
              },
              child: Text("D100 +10"),
            ),
            ElevatedButton(
              onPressed: () {
                int newValue = d100Value - 10;
                setD100(newValue);
                setState(() => d100Value = newValue);
              },
              child: Text("D100 -10"),
            ),
          ],
        ),
      ),
    );
  }
}
