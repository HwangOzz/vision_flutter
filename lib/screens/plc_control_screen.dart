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
  List<bool> mBitStates = List.filled(
    10,
    false,
  ); // M0~M9 상태 (false: OFF, true: ON)
  final List<String> mBitLabels = [
    "컨베이어 1 작동", // M0
    "로봇1 작동", // M1
    "로봇2 작동", // M2
    "컨베이어 2 작동", // M3
    "비전센서 감지", // M4
    "컨베이어 3 작동", // M5
    "로봇3 작동", // M6
    "컨베이어 1 작동", // M7
    "창고 적재", // M8
    "창고 완료", // M9
  ];
  @override
  void initState() {
    super.initState();
    getD100();
    getMBits();
  }

  Future<void> getMBits() async {
    try {
      final response = await http.get(Uri.parse("$serverUrl/get_m_bits"));
      final responseData = jsonDecode(response.body);

      setState(() {
        for (int i = 0; i < 10; i++) {
          mBitStates[i] = responseData["M$i"] == 1;
        }
      });
    } catch (e) {
      print("❌ M 비트 상태 조회 실패: $e");
    }
  }

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

  Future<void> getD100() async {
    try {
      final response = await http.get(Uri.parse("$serverUrl/get_d100"));
      final responseData = jsonDecode(response.body);
      setState(() {
        d100Value = responseData["value"];
      });
    } catch (e) {
      print("❌ D100 조회 실패: $e");
    }
  }

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
                      SizedBox(width: 215),
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context); // 이전 화면으로 이동
                        },
                      ),
                    ],
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
