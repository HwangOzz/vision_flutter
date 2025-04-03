import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  final String currentServer;
  const SettingScreen({super.key, required this.currentServer});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final Map<String, String> serverOptions = {
    "PC A (3.250)": "http://192.168.0.126:5000",
    "PC B (3.39)": "http://192.168.0.50:5000",
  };

  late String selectedServer;

  @override
  void initState() {
    super.initState();
    selectedServer = widget.currentServer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("설정")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📡 서버 선택",
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
                  setState(() => selectedServer = newValue);
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  selectedServer,
                ); // Homescreen에 선택한 서버 IP 전달
              },
              child: Text("적용"),
            ),
          ],
        ),
      ),
    );
  }
}
