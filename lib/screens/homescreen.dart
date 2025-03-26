import 'package:flutter/material.dart';
import 'package:vision_flutter/screens/qr_scanner_screen.dart';
import 'package:vision_flutter/widgets/appbarbutton.dart';
import 'package:vision_flutter/widgets/boundaryline.dart';
import 'package:vision_flutter/widgets/member_dialog.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  bool _showBoundaryLine = false;

  void _toggleBoundaryLine() {
    setState(() {
      _showBoundaryLine = !_showBoundaryLine;
    });
  }

  void _showMemberDialog() {
    setState(() {
      _showBoundaryLine = true; // 같이 띄우기
    });

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return WillPopScope(
          onWillPop: () async {
            setState(() {
              _showBoundaryLine = false; // 뒤로가기 시 같이 끄기
            });
            return true;
          },
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              setState(() {
                _showBoundaryLine = false; // 바깥 탭해서 닫을 때 같이 끄기
              });
            },
            child: Center(
              child: MemberDialog(
                memberImages: [
                  'assets/member1.png',
                  'assets/member2.png',
                  'assets/member3.png',
                  'assets/member4.png',
                  'assets/member5.png',
                  'assets/member6.png',
                  'assets/member7.png',
                  'assets/member8.png',
                ],
                memberNames: [
                  '조장 : 함상현',
                  '조원 : 지정재\nE-PLAN',
                  '조원 : 김수현\nE-PLAN',
                  '조원 : 남현수\nSCADA',
                  '조원 : 임윤재\nSCADA',
                  '조원 : 황성현\nSCADA',
                  '조원 : 권익환\nSCADA',
                  '조원 : 이경준\nSCADA',
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      // 다이얼로그 닫힌 후에도 꺼지게 보장
      setState(() {
        _showBoundaryLine = false;
      });
    });
  }

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
              child: Appbarbutton(
                text1: "QR",
                icon1: Icons.qr_code,
                onTap: () async {
                  print("QR 버튼 눌림");
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                  );

                  if (result != null) {
                    print("QR 코드 결과: $result");
                  }
                },
              ),
            ),
            Transform.translate(
              offset: Offset(6, 39.7),
              child: GestureDetector(
                onTap: _toggleBoundaryLine,
                child: Column(
                  children: [
                    SizedBox(width: 20),
                    Text("조원 소개", style: TextStyle(fontSize: 10)),
                  ],
                ),
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
          onPressed: _showMemberDialog,
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
          // ✅ grassimage를 제일 아래로!
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/grassimage.png"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),

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
            ],
          ),
          if (_showBoundaryLine)
            Positioned(bottom: -15, left: 120, child: Boundaryline()),
          Positioned(
            top: 30,
            right: 16,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Color.fromARGB(255, 55, 54, 54),
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
