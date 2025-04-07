import 'package:flutter/material.dart';
import 'package:vision_flutter/widgets/pizzacrust.dart';
import 'package:vision_flutter/widgets/robotarm.dart';

class Practice extends StatefulWidget {
  const Practice({super.key});

  @override
  State<Practice> createState() => _PracticeState();
}

class _PracticeState extends State<Practice> {
  bool m0 = false; // ← 나중에 PLC값으로 바꿀 수 있음
  bool m1 = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 113, 113, 113),
      appBar: AppBar(title: Text('로봇팔 1대')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 800,
          width: 400,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      SizedBox(height: 15),
                      Center(child: RobotArm(active: m0)),
                    ],
                  ),
                  Positioned(
                    top: 20,
                    child: PizzaCrustDoubleOffset(
                      outerColor: const Color.fromARGB(255, 181, 181, 181),
                      innerColor: const Color.fromARGB(255, 98, 98, 98),
                      angleDegree: 90,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: PizzaCrustDoubleOffset(
                      outerColor: const Color.fromARGB(255, 181, 181, 181),
                      innerColor: const Color.fromARGB(255, 98, 98, 98),
                      angleDegree: 180,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(height: 60, width: 60),
                  Container(
                    height: 400,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 161, 161, 161),
                    ),
                    child: Center(
                      child: Container(
                        height: 400,
                        width: 30,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 30, 30, 30),
                        ),
                      ),
                    ),
                  ),
                  RobotArm(active: m0),
                ],
              ),

              PizzaCrustDoubleOffset(
                outerColor: const Color.fromARGB(255, 181, 181, 181),
                innerColor: const Color.fromARGB(255, 98, 98, 98),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            m0 = !m0;
          });
        },
        child: Icon(m0 ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}
