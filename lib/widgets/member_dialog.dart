import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemberDialog extends StatefulWidget {
  final List<String> memberImages;
  final List<String> memberNames;

  const MemberDialog({
    super.key,
    required this.memberImages,
    required this.memberNames,
  });

  @override
  State<MemberDialog> createState() => _MemberDialogState();
}

class _MemberDialogState extends State<MemberDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goToNextPage() {
    if (_currentPage < widget.memberImages.length - 1) {
      _currentPage++;

      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context); // ✅ 마지막 페이지 → 닫기!
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: _goToNextPage, // 👉 화면 아무데나 탭하면 다음 페이지로
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(), // 👉 드래그 금지
                itemCount: widget.memberImages.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.memberNames[index], // 조원 이름!
                        textAlign: TextAlign.center,
                        style: GoogleFonts.doHyeon(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10), // 텍스트와 이미지 사이 간격
                      Expanded(
                        child: Image.asset(
                          widget.memberImages[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
