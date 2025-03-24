import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/fullScreenImage.dart';

class failImagescreen extends StatefulWidget {
  @override
  _failImagescreenState createState() => _failImagescreenState();
}

class _failImagescreenState extends State<failImagescreen> {
  int failCount = 0;
  List<String> failImages = [];
  final String serverIp = "192.168.0.126"; // Flask 서버 IP

  Future<void> fetchFailCount() async {
    try {
      var response = await http.get(
        Uri.parse("http://$serverIp:5000/get_fail_count"),
      );
      if (response.statusCode == 200) {
        setState(() {
          failCount = jsonDecode(response.body)["fail_count"];
        });
      }
    } catch (e) {
      print("🔥 예외 발생: $e");
    }
  }

  Future<void> fetchFailImages() async {
    try {
      var response = await http.get(
        Uri.parse("http://$serverIp:5000/get_fail_images"),
      );

      if (response.statusCode == 200) {
        List<String> images = List<String>.from(jsonDecode(response.body));

        images.sort((a, b) => extractNumber(a).compareTo(extractNumber(b)));

        for (String image in images) {
          await Future.delayed(Duration(milliseconds: 700));

          if (!mounted) return;

          setState(() {
            failImages.add(image);
          });
        }
      }
    } catch (e) {
      print("🔥 예외 발생: $e");
    }
  }

  int extractNumber(String filename) {
    return int.tryParse(filename.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    fetchFailCount();
    fetchFailImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(208, 245, 254, 245),
      appBar: AppBar(title: Text("불량 이미지 목록"), backgroundColor: Colors.green),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "현재 불량 개수: $failCount 개",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: failImages.length,
              itemBuilder: (context, index) {
                String imageUrl =
                    "http://$serverIp:5000/get_image/${failImages[index]}";
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => fullScreenImage(
                              imageUrls: failImages,
                              initialIndex: index,
                              serverIp: serverIp,
                            ),
                      ),
                    );
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          offset: Offset(3, 3),
                          color: Colors.black26,
                        ),
                      ],
                      border: Border.all(color: Colors.black54),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error, color: Colors.red, size: 50);
                        },
                      ),
                    ),
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
