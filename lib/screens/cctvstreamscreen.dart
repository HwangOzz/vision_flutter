import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class cctvstreamscreen extends StatefulWidget {
  @override
  _cctvstreamscreenState createState() => _cctvstreamscreenState();
}

class _cctvstreamscreenState extends State<cctvstreamscreen> {
  late VlcPlayerController _vlcController;

  final String rtspUrl =
      "rtsp://project123:project123@192.168.1.126:554/live/ch00_0";

  @override
  void initState() {
    super.initState();
    _vlcController = VlcPlayerController.network(
      rtspUrl,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    _vlcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CCTV 실시간 스트리밍"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: VlcPlayer(
          controller: _vlcController,
          aspectRatio: 16 / 9,
          placeholder: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
