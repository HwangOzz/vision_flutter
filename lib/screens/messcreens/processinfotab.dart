import 'package:flutter/material.dart';

class ProcessInfoTab extends StatefulWidget {
  const ProcessInfoTab({super.key});
  @override
  _ProcessInfoTabState createState() => _ProcessInfoTabState();
}

class _ProcessInfoTabState extends State<ProcessInfoTab> {
  String selectedProduct = 'A'; // 기본 제품군

  // 각 제품군별 공정 시간 데이터 (ms 단위)
  final Map<String, Map<int, int>> productStepTimes = {
    'A': {
      0: 3200,
      1: 1800,
      2: 2200,
      3: 2100,
      4: 4000,
      5: 2700,
      6: 3000,
      7: 3500,
    },
    'B': {
      0: 4000,
      1: 2000,
      2: 2500,
      3: 2200,
      4: 4500,
      5: 3000,
      6: 3200,
      7: 3700,
    },
    'C': {
      0: 3500,
      1: 1900,
      2: 2300,
      3: 2000,
      4: 4200,
      5: 2800,
      6: 3100,
      7: 3400,
    },
  };

  // M0~M7의 공정명
  final Map<int, String> mStepLabels = {
    0: "컨베이어 1 위치 도달",
    1: "로봇 1",
    2: "로봇 2",
    3: "컨베이어 2 위치 도달",
    4: "비전 검사",
    5: "컨베이어 3 위치 도달",
    6: "로봇 3",
    7: "컨베이어 1 위치 복귀",
  };

  @override
  Widget build(BuildContext context) {
    final currentTimes = productStepTimes[selectedProduct]!;

    return Scaffold(
      body: Column(
        children: [
          // 제품군 선택 드롭다운
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<String>(
              value: selectedProduct,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedProduct = value;
                  });
                }
              },
              items:
                  ['A', 'B', 'C'].map((product) {
                    return DropdownMenuItem<String>(
                      value: product,
                      child: Text("제품군 $product"),
                    );
                  }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: currentTimes.length,
              itemBuilder: (context, index) {
                final label = mStepLabels[index] ?? "공정 ${index + 1}";
                final ms = currentTimes[index] ?? 0;
                final sec = (ms / 1000).toStringAsFixed(1);

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(label),
                    subtitle: Text("$sec 초"),
                    leading: Icon(Icons.timelapse),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//아마 지정된 D값마다 시간이 들어갈텐데 0일때 공정시간을 반영하지 않도록해야함.
//공정 시간정도는 리셋해서 정보를 기입하는것도 나쁘지않을지도??
//한사이클 공정시간도 넣어야할듯.
