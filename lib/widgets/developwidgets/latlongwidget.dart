import 'package:flutter/material.dart';
import 'package:vision_flutter/model/location.dart';

class LatLongWidget extends StatelessWidget {
  final Location location;

  const LatLongWidget({super.key, required this.location});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Text(location.latitude, style: TextStyle(color: Colors.white70)),
      Icon(Icons.location_on, color: Colors.white70),
      Text(location.longitude, style: TextStyle(color: Colors.white70)),
    ],
  );
}
