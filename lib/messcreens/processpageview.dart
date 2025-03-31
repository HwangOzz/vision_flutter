import 'package:flutter/material.dart';

class ProcessSimulationPage extends StatefulWidget {
  @override
  _ProcessSimulationPageState createState() => _ProcessSimulationPageState();
}

class _ProcessSimulationPageState extends State<ProcessSimulationPage> {
  List<bool> mBits = List.filled(10, false); // M0 ~ M9
  bool isRunning = false;

  void startSimulation() async {
    if (isRunning) return;
    setState(() => isRunning = true);

    for (int i = 0; i <= 9; i++) {
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        mBits[i] = true;
      });
    }

    setState(() => isRunning = false);
  }

  double _getProgressForRange(int start, int end) {
    int total = end - start + 1;
    int active = mBits.sublist(start, end + 1).where((bit) => bit).length;
    return active / total;
  }

  String _getStatusForRange(int start, int end) {
    int active = mBits.sublist(start, end + 1).where((bit) => bit).length;
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
            _buildProcessCard("3. 물품 보관 (M7~M9)", 7, 9),
            SizedBox(height: 32),
            ElevatedButton(onPressed: startSimulation, child: Text("M0 수동 시작")),
          ],
        ),
      ),
    );
  }
}
//실제 PLC에서는 M0같은건 한번 켜지고 꺼지니까 한번 켜지면 현재 공정률에 반영하게해야함. 
//그리고 마지막에 끝나는 신호가 들어오면 다 초기화해야함. 