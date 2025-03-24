import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class cctvScreen extends StatelessWidget {
  final String streamUrl =
      'http://192.168.1.126:81/videostream.cgi?loginuse=admin&loginpas=11111111';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CCTV 실시간')),
      body: Mjpeg(stream: streamUrl, isLive: true),
    );
  }
}
