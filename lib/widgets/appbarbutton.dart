import 'package:flutter/material.dart';

class Appbarbutton extends StatelessWidget {
  final IconData icon1;
  final String text1;
  final VoidCallback? onTap; // ✅ 콜백 추가

  const Appbarbutton({
    super.key,
    required this.icon1,
    required this.text1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // ✅ 여기서 전체 위젯에 터치 적용
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 30, width: 30, child: Icon(icon1)),
          SizedBox(height: 1),
          Text(text1, style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
