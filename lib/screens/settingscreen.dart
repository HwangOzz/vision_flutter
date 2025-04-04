import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vision_flutter/globals/serverurl.dart';

class SettingScreen extends StatefulWidget {
  final String currentServer;
  const SettingScreen({super.key, required this.currentServer});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final Map<String, String> serverOptions = {
    "PC A (3.250)": "http://192.168.0.126:5000",
    "PC B (3.39)": "http://192.168.0.70:5000",
  };

  late String selectedServer;
  final TextEditingController customServerController = TextEditingController();
  final TextEditingController plcIpController = TextEditingController();
  final TextEditingController plcPortController = TextEditingController();
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    selectedServer = widget.currentServer;
    customServerController.text = selectedServer;

    plcIpController.text = "192.168.3.250";
    plcPortController.text = "2005";
  }

  Future<void> applyPlcInfo() async {
    final ip = plcIpController.text.trim();
    final portText = plcPortController.text.trim();

    if (ip.isEmpty || portText.isEmpty) {
      showMessage("IP와 포트를 입력해주세요");
      return;
    }

    final port = int.tryParse(portText);
    if (port == null) {
      showMessage("포트는 숫자여야 합니다");
      return;
    }

    final url = Uri.parse("${customServerController.text}/set_plc_info");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ip": ip, "port": port}),
      );

      if (response.statusCode == 200) {
        showMessage("✅ PLC 설정 적용됨!");
      } else {
        showMessage("❌ 적용 실패: ${response.body}");
      }
    } catch (e) {
      showMessage("❌ 오류 발생: $e");
    }
  }

  void showMessage(String msg) {
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(title: Text("설정")),
        body: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    "Flask 서버 선택",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: selectedServer,
                    items:
                        serverOptions.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.value,
                            child: Text(entry.key),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedServer = newValue;
                          customServerController.text = newValue;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: customServerController,
                    decoration: InputDecoration(
                      labelText: "직접 입력 (예: http://192.168.0.126:5000)",
                    ),
                  ),
                  SizedBox(height: 20),
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
                      Global.serverUrl = customServerController.text.trim();
                      showMessage("✅ 서버 선택 적용됨");
                      // 뒤로 안 감
                    },
                    child: Text("서버 선택 적용"),
                  ),
                  Divider(height: 40),
                  Text(
                    "PLC IP 설정",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: plcIpController,
                    decoration: InputDecoration(
                      labelText: "PLC IP 주소 (예: 192.168.3.250)",
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: plcPortController,
                    decoration: InputDecoration(labelText: "PLC 포트 (예: 2005)"),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
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
                    onPressed: applyPlcInfo,
                    child: Text("PLC 설정 적용"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
