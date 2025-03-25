import 'package:flutter/material.dart';

class Appbarbutton extends StatelessWidget {
  const Appbarbutton({super.key, required this.icon1, required this.text1});
  final IconData icon1;
  final String text1;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30,
          width: 30,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () {},
            icon: Icon(icon1),
          ),
        ),
        SizedBox(height: 1),
        Text(text1, style: TextStyle(fontSize: 10)),
      ],
    );
  }
}
