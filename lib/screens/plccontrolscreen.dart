import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PLCControlScreen extends StatefulWidget {
  @override
  _PLCControlScreenState createState() => _PLCControlScreenState();
}

class _PLCControlScreenState extends State<PLCControlScreen> {
  final String serverUrl = "http://192.168.0.126:5000"; // 서버 주소
  int d100Value = 0;

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
      print("❌ 값 설정 실패: $e");
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
      print("❌ 값 조회 실패: $e");
    }
  }

  void testPing() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.0.126:5000/ping"),
      );
      print("✅ 서버 응답: ${response.body}");
    } catch (e) {
      print("❌ 서버 연결 실패: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getD100(); // 앱 시작 시 D100 값 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PLC 제어")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("현재 D100 값: $d100Value", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
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
