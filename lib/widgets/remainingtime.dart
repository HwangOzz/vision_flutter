import 'package:flutter/material.dart';
import 'dart:async';

class RemainingTimeWidget extends StatefulWidget {
  final DateTime started;
  final int totalSeconds;

  const RemainingTimeWidget({
    super.key,
    required this.started,
    required this.totalSeconds,
  });

  @override
  _RemainingTimeWidgetState createState() => _RemainingTimeWidgetState();
}

class _RemainingTimeWidgetState extends State<RemainingTimeWidget> {
  late Timer _timer;
  int _remaining = 0;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _calculateRemaining());
  }

  void _calculateRemaining() {
    final elapsed = DateTime.now().difference(widget.started).inSeconds;
    final remaining = widget.totalSeconds - elapsed;
    if (mounted) {
      setState(() {
        _remaining = remaining > 0 ? remaining : 0;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final min = _remaining ~/ 60;
    final sec = _remaining % 60;
    return Text('⏱ 남은시간: ${min}분 ${sec}초');
  }
}
