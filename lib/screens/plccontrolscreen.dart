import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PLCControlScreen extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    getD100();
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
      backgroundColor: Color.fromARGB(255, 191, 222, 191),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.teal[400],
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
              "🔘 M0 ~ M9 스위치 제어",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ...List.generate(10, (i) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("M$i", style: TextStyle(fontSize: 16)),
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
            Divider(),
            Text(
              "📏 D100 제어",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
