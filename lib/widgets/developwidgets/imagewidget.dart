import 'package:flutter/material.dart';
import 'package:vision_flutter/model/location.dart';
import 'package:vision_flutter/widgets/developwidgets/latlongwidget.dart';

class ImageWidget extends StatelessWidget {
  final Location location;

  const ImageWidget({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: size.height * 0.5,
      width: size.width * 0.8,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 2, spreadRadius: 1),
          ],
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Stack(
          children: [
            buildImage(),
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [buildTopText(), LatLongWidget(location: location)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImage() => SizedBox.expand(
    child: ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: Image.asset(location.urlImage, fit: BoxFit.cover),
    ),
  );

  Widget buildTopText() => Text(
    location.name,
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  );
}
