import 'package:flutter/material.dart';

class StarsWidget extends StatelessWidget {
  final int stars;

  const StarsWidget({super.key, required this.stars});

  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(
      stars,
      (index) => Icon(Icons.star, size: 16, color: Colors.amber),
    ),
  );
}
