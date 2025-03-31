import 'package:flutter/material.dart';
import 'package:vision_flutter/model/location.dart';
import 'package:vision_flutter/widgets/developwidgets/locationwidget.dart';

class DevelopmentProcessPage extends StatelessWidget {
  DevelopmentProcessPage({Key? key}) : super(key: key);

  final List<Location> locations = [
    Location(
      name: "로봇 1",
      latitude: "37.1234° N",
      longitude: "127.5678° E",
      addressLine1: "로봇 1 공정 설명",
      addressLine2: "제조라인 A",
      starRating: 4,
      urlImage: "assets/robot1.png",
      reviews: [
        Review(urlImage: "assets/user1.png"),
        Review(urlImage: "assets/user2.png"),
      ],
    ),
    Location(
      name: "비전센서",
      latitude: "37.4321° N",
      longitude: "127.8765° E",
      addressLine1: "비전검사 설명",
      addressLine2: "검사라인 B",
      starRating: 5,
      urlImage: "assets/vision.png",
      reviews: [],
    ),
    Location(
      name: "창고",
      latitude: "37.5555° N",
      longitude: "127.4444° E",
      addressLine1: "창고 적재 설명",
      addressLine2: "물류 창고 C",
      starRating: 3,
      urlImage: "assets/storage.png",
      reviews: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text("개발 과정"), backgroundColor: Colors.teal),
      body: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          return LocationWidget(location: locations[index]);
        },
      ),
    );
  }
}

//https://www.youtube.com/watch?v=RLPZzDOPXG4&list=PLEDu8H3ASVFU2tUTAkv8rPAYVR9q-gqod 이거대로 하고 개발 과정 사진 하나씩 넣고 밑에 설명 누르는식 is good
