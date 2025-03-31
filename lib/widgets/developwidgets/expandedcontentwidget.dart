import 'package:flutter/material.dart';
import 'package:vision_flutter/model/location.dart';
import 'package:vision_flutter/widgets/developwidgets/starswidget.dart';

class FullImageScreen extends StatelessWidget {
  final Location location;

  const FullImageScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(213, 255, 255, 255),
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: location.name,
              child: Material(
                color: Colors.transparent,
                child: ExpandedContentWidget(location: location),
              ),
            ),
          ),
          Positioned(
            top: 40, // 상태바 아래 여백
            left: 16,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: const Color.fromARGB(255, 0, 0, 0),
                size: 28,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandedContentWidget extends StatelessWidget {
  final Location location;

  const ExpandedContentWidget({super.key, required this.location});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FullImageScreen(location: location)),
      );
    },
    child: Material(
      color: Colors.transparent,
      child: Container(
        height: 400,
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(location.addressLine1),
            SizedBox(height: 8),
            buildAddressRating(location: location),
            SizedBox(height: 12),
            buildReview(location: location),
          ],
        ),
      ),
    ),
  );

  Widget buildAddressRating({required Location location}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(location.addressLine2, style: TextStyle(color: Colors.black45)),
      StarsWidget(stars: location.starRating),
    ],
  );

  Widget buildReview({required Location location}) => Row(
    children:
        location.reviews
            .map(
              (review) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.black12,
                  backgroundImage: AssetImage(review.urlImage),
                ),
              ),
            )
            .toList(),
  );
}
