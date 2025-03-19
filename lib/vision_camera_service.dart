import 'package:http/http.dart' as http;
import 'dart:convert';

class VisionCameraService {
  final String serverUrl = "http://10.10.24.100:5000"; // PC의 IP 주소

  // 검사 시작 요청
  Future<void> startInspection() async {
    final response = await http.post(Uri.parse("$serverUrl/start_inspection"));
    if (response.statusCode == 200) {
      print("검사 시작 요청 성공");
    } else {
      print("검사 시작 요청 실패: ${response.body}");
    }
  }

  // 검사 결과 가져오기
  Future<String> getInspectionResult() async {
    final response = await http.get(Uri.parse("$serverUrl/get_result"));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data["result"];
    } else {
      print("검사 결과 가져오기 실패: ${response.body}");
      return "Error";
    }
  }
}
