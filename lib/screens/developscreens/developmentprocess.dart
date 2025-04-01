import 'package:flutter/material.dart';
import 'package:vision_flutter/widgets/fullimagepage.dart';

class Wait1ProcessPage extends StatelessWidget {
  final List<String> imageUrls = List.generate(
    12,
    (index) => 'assets/process${index + 1}.png',
  );

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [_PhotoGridPage(images: imageUrls), _DescriptionPage()],
    );
  }
}

class _PhotoGridPage extends StatelessWidget {
  final List<String> images;

  const _PhotoGridPage({required this.images});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ 그리드 배경
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 2;
            double width = constraints.maxWidth;

            if (width >= 900) {
              crossAxisCount = 4;
            } else if (width >= 600) {
              crossAxisCount = 3;
            }

            return GridView.builder(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              itemCount: images.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final imagePath = images[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => FullImagePage(
                              images: images,
                              initialIndex: index,
                            ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'image_$index',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(imagePath, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            );
          },
        ),

        // ✅ 상단 뒤로가기 버튼
      ],
    );
  }
}

class _DescriptionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          '넣어야할것들 : 1.프로젝트 설명 2.개발과정 3.간트 차트 4.공정과정설명 5.프로잭트결과',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

//https://www.youtube.com/watch?v=RLPZzDOPXG4&list=PLEDu8H3ASVFU2tUTAkv8rPAYVR9q-gqod 이거대로 하고 개발 과정 사진 하나씩 넣고 밑에 설명 누르는식 is good
