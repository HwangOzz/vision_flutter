import 'package:flutter/material.dart';

class fullScreenImage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String serverIp;

  fullScreenImage({
    required this.imageUrls,
    required this.initialIndex,
    required this.serverIp,
  });

  @override
  _fullScreenImageState createState() => _fullScreenImageState();
}

class _fullScreenImageState extends State<fullScreenImage> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void changeImage(int newIndex) {
    if (newIndex >= 0 && newIndex < widget.imageUrls.length) {
      setState(() {
        currentIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentImageUrl =
        "http://${widget.serverIp}:5000/get_image/${widget.imageUrls[currentIndex]}";

    return Scaffold(
      appBar: AppBar(title: Text("확대"), backgroundColor: Colors.green),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.primaryDelta! < -10) changeImage(currentIndex + 1);
          if (details.primaryDelta! > 10) changeImage(currentIndex - 1);
        },
        child: Center(
          child: Image.network(currentImageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
