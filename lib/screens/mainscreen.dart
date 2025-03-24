import 'package:flutter/material.dart';
import 'package:vision_flutter/screens/Plccontrolscreen.dart';
import 'package:vision_flutter/screens/cctvstreamscreen.dart';
import 'FailImageScreen.dart';

class mainscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("메인 화면"), backgroundColor: Colors.green),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => failImagescreen()),
                );
              },
              child: Text("불량 이미지 목록 보기"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => cctvstreamscreen(),
                  ), // ✅ 소문자 파일 사용
                );
              },
              child: Text("CCTV 실시간 보기"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PLCControlScreen(),
                  ), // ✅ 소문자 파일 사용
                );
              },
              child: Text("PLC 연결"),
            ),
          ],
        ),
      ),
    );
  }
}
