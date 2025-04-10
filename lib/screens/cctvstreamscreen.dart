import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class cctvScreen extends StatelessWidget {
  final String streamUrl =
      'http://192.168.1.126:81/videostream.cgi?loginuse=admin&loginpas=11111111';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 153, 154, 154),
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
                children: [
                  Icon(Icons.tv, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "CCTV",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // 이전 화면으로 이동
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 50),
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 243, 230, 230),
            ),
            height: 250,
            width: 600,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 191, 222, 191),
                ),
                child: Mjpeg(stream: streamUrl, isLive: true),
              ),
            ),
          ),
          Container(
            height: 350,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/mountain.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//비전카메라 화면도 가져오기 가능할듯? 그러면 실시간 화면으로 이름 바꾸고 위아래로 두개. <- 안되는거같음 ㅠㅜ
