import 'package:flutter/material.dart';
import 'package:vision_flutter/model/location.dart';
import 'package:vision_flutter/widgets/developwidgets/starswidget.dart';

class FullImageScreen extends StatelessWidget {
  final Location location;

  const FullImageScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgroundimage.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: location.name,
                child: Material(
                  color: Colors.transparent,
                  child: ExpandedContentWidget(
                    location: location,
                    enableTap: false,
                  ),
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
      ),
    );
  }
}

class ExpandedContentWidget extends StatelessWidget {
  final Location location;
  final bool enableTap;

  const ExpandedContentWidget({
    super.key,
    required this.location,
    this.enableTap = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Material(
      color: Colors.transparent,
      child: Container(
        height: 500,
        width: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          //여기에 이미지 변수 추가해서 PPT넣을거임
          children: [
            Text(location.addressLine1),
            SizedBox(height: 8),
            buildAddressRating(location: location),
            SizedBox(height: 12),
            buildReview(location: location),
          ],
        ),
      ),
    );

    return enableTap
        ? GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullImageScreen(location: location),
              ),
            );
          },
          child: content,
        )
        : content;
  }

  // 아래 두 함수는 그대로
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
