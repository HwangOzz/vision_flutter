import 'package:flutter/material.dart';

class FullImagePage extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  FullImagePage({required this.images, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Center(
                  child: Hero(
                    tag: 'image_$index',
                    child: Image.asset(images[index], fit: BoxFit.contain),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 30,
            right: 16,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
