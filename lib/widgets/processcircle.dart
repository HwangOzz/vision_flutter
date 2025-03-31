import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Processcircle extends StatelessWidget {
  const Processcircle({super.key, required this.progress, required this.text1});

  final double progress;
  final String text1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),

            Text(
              "${(progress * 100).toInt()}%",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 15),
        Text(
          text1,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
