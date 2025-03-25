import 'package:flutter/material.dart';
import 'package:vision_flutter/widgets/appbarbutton.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 0,
        padding: EdgeInsets.zero,
        height: 62,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Transform.translate(
              offset: Offset(12, 0),
              child: Appbarbutton(text1: "HOME", icon1: Icons.home),
            ),
            Transform.translate(
              offset: Offset(15, 0),
              child: Appbarbutton(text1: "QR", icon1: Icons.qr_code),
            ),
            Transform.translate(
              offset: Offset(6, 39.7),
              child: Column(
                children: [
                  SizedBox(width: 20),
                  Text("조원 소개", style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
            Appbarbutton(text1: "개발 과정", icon1: Icons.headset_mic),
            Appbarbutton(text1: "설정", icon1: Icons.settings),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 0, spreadRadius: 0)],
        ),
        padding: EdgeInsets.all(7),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color.fromARGB(255, 27, 26, 26),
          shape: CircleBorder(),
          elevation: 0,
          child: Icon(
            Icons.people,
            color: const Color.fromARGB(255, 179, 178, 178),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 350,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/cloudbackground.png"),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              // 필요하다면 여기 다른 위젯 추가
            ],
          ),
          Positioned(
            top: 30, // 상단에서 거리
            right: 16, // 오른쪽에서 거리
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: const Color.fromARGB(255, 55, 54, 54),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
