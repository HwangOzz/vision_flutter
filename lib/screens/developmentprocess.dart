import 'package:flutter/material.dart';
import 'package:vision_flutter/widgets/fullimagepage.dart';

class DevelopmentProcessPage extends StatelessWidget {
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

  _PhotoGridPage({required this.images});

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
          '넣어야할것들 : 1.프로젝트 설명 2.개발과정 3.간트 차트',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
