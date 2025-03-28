import 'package:flutter/material.dart';
import 'package:vision_flutter/screens/plc_control_screen.dart';
import 'package:vision_flutter/screens/cctvstreamscreen.dart';
import 'package:vision_flutter/screens/homescreen.dart';
import 'FailImageScreen.dart';

class Mainscreen extends StatelessWidget {
  const Mainscreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 32, 112, 241), // 진한 파랑
                      Color.fromARGB(255, 155, 183, 244), // 옅은 파랑
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                  ),
                ),
                height: 470,
                child: Padding(
                  padding: const EdgeInsets.only(top: 30, left: 40, right: 40),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/mainimage.png"),
                                ),
                              ),
                            ),
                            SizedBox(width: 7),
                            Text(
                              "2조",
                              style: TextStyle(
                                fontSize: 27,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                      Text(
                        "로봇활용 첨단 생산시스템\n전문가 양성",
                        style: TextStyle(
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 1.0,
                              color: const Color.fromARGB(128, 85, 82, 82),
                            ),
                          ],
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 15),
                      Transform.translate(
                        offset: Offset(-20, 0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Homescreen(),
                              ),
                            );
                          },
                          child: Container(
                            height: 60,
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              color: const Color.fromARGB(255, 41, 37, 245),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.home_outlined,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "메인화면 바로가기",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: 200,
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset("assets/cloud.png", fit: BoxFit.contain),
                ),
              ),
            ],
          ),
          SizedBox(height: 50),
          Text(
            "선택 메뉴",
            style: TextStyle(
              fontSize: 18,
              color: const Color.fromARGB(255, 51, 138, 210),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      hoverColor: Colors.blue,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => failImagescreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.image),
                      iconSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    "불량품 이미지",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              SizedBox(width: 50),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      hoverColor: Colors.blue,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => cctvScreen()),
                        );
                      },
                      icon: Icon(Icons.tv),
                      iconSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text("CCTV", style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),

              SizedBox(width: 60),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      hoverColor: Colors.blue,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PLCControlScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.wifi),
                      iconSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text("PLC", style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
