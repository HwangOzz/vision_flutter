import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MBitVideoPlayer extends StatefulWidget {
  final String videoPath;
  final bool isActive;
  final double rotation;
  final bool flipX;

  /// 👇 위아래 잘라낼 비율 (0.0 ~ 0.5)
  final double cropVertical;

  /// 👇 좌우 잘라낼 비율 (0.0 ~ 0.5)
  final double cropHorizontal;

  const MBitVideoPlayer({
    super.key,
    required this.videoPath,
    required this.isActive,
    this.rotation = 0,
    this.flipX = false,
    this.cropVertical = 0.0,
    this.cropHorizontal = 0.0,
  });

  @override
  State<MBitVideoPlayer> createState() => _MBitVideoPlayerState();
}

class _MBitVideoPlayerState extends State<MBitVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset(widget.videoPath)
          ..setLooping(true)
          ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MBitVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.value.isInitialized) {
      if (widget.isActive && !_controller.value.isPlaying) {
        _controller.play();
      } else if (!widget.isActive && _controller.value.isPlaying) {
        _controller.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child:
              _controller.value.isInitialized
                  ? ClipRect(
                    child: Align(
                      alignment: Alignment.center,
                      heightFactor: 1.0 - (widget.cropVertical * 2),
                      widthFactor: 1.0 - (widget.cropHorizontal * 2),
                      child: Transform(
                        alignment: Alignment.center,
                        transform:
                            Matrix4.identity()
                              ..rotateZ(widget.rotation * pi / 180)
                              ..scale(widget.flipX ? -1.0 : 1.0, 1.0),
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                  )
                  : Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}
