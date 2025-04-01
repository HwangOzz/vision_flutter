import 'package:flutter/material.dart';
import 'package:vision_flutter/model/location.dart';
import 'package:vision_flutter/widgets/developwidgets/locationwidget.dart';

class DevelopmentProcessPage extends StatelessWidget {
  DevelopmentProcessPage({Key? key}) : super(key: key);

  final List<Location> locations = [
    Location(
      name: "배선",
      latitude: "글씨 들어갈곳1",
      longitude: "글씨 들어갈곳2",
      addressLine1: "배선 설명",
      addressLine2: "배선 1",
      starRating: 4,
      urlImage: "assets/robot1.png",
      reviews: [
        // Review(urlImage: "assets/user1.png"),
        // Review(urlImage: "assets/user2.png"),
      ],
    ),
    Location(
      name: "비전센서",
      latitude: "글씨 들어갈곳1",
      longitude: "글씨 들어갈곳2",
      addressLine1: "비전검사 설명",
      addressLine2: "검사라인",
      starRating: 5,
      urlImage: "assets/vision.png",
      reviews: [],
    ),
    Location(
      name: "중간 개발",
      latitude: "글씨 들어갈곳1",
      longitude: "글씨 들어갈곳2",
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backgroundimage.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              itemCount: locations.length,
              itemBuilder: (context, index) {
                return LocationWidget(location: locations[index]);
              },
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

//https://www.youtube.com/watch?v=RLPZzDOPXG4&list=PLEDu8H3ASVFU2tUTAkv8rPAYVR9q-gqod 이거대로 하고 개발 과정 사진 하나씩 넣고 밑에 설명 누르는식 is good
//밑에 원있는거에 담당한 조원들 얼굴을 넣는거는어때
//위에 빈공간에 이미지 + 설명으로 채워넣기
