import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int failCount = 0;
  List<String> failImages = [];
  final String serverIp = "192.168.0.126"; // Flask 서버 IP 설정

  // Flask 서버에서 불량 개수 가져오기
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
      print("Exception caught: $e");
    }
  }

  // 불량 이미지 목록 가져오기 + 숫자 정렬 적용
  Future<void> fetchFailImages() async {
    try {
      var response = await http.get(
        Uri.parse("http://$serverIp:5000/get_fail_images"),
      );

      if (response.statusCode == 200) {
        List<String> images = List<String>.from(jsonDecode(response.body));

        // ✅ 숫자 정렬 적용
        images.sort((a, b) {
          int numA = extractNumber(a);
          int numB = extractNumber(b);
          return numA.compareTo(numB);
        });

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

  // 🔥 파일명에서 숫자만 추출하는 함수 (예: "image10.jpg" → 10)
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
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(208, 245, 254, 245),
        appBar: AppBar(
          title: Center(
            child: Text(
              "불량 이미지 목록",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 5,
          foregroundColor: Colors.green,
        ),
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
              height: 160, // ✅ 리스트 높이 조정
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
                              (context) => FullScreenImage(
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: failImages[index],
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 50,
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            failImages[index],
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔥 전체 화면 이미지 페이지
class FullScreenImage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String serverIp;

  FullScreenImage({
    required this.imageUrls,
    required this.initialIndex,
    required this.serverIp,
  });

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void changeImage(int newIndex) {
    if (newIndex >= 0 && newIndex < widget.imageUrls.length) {
      setState(() {
        currentIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentImageUrl =
        "http://${widget.serverIp}:5000/get_image/${widget.imageUrls[currentIndex]}";

    return Scaffold(
      appBar: AppBar(
        title: Text("${currentIndex + 1}/${widget.imageUrls.length}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.primaryDelta! < -10) {
            changeImage(currentIndex + 1);
          } else if (details.primaryDelta! > 10) {
            changeImage(currentIndex - 1);
          }
        },
        child: Center(
          child: Hero(
            tag: widget.imageUrls[currentIndex],
            child: Image.network(currentImageUrl, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
