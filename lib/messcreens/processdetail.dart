import 'package:flutter/material.dart';
import 'package:vision_flutter/widgets/processcircle.dart';

class Processdetail extends StatefulWidget {
  const Processdetail({super.key});

  @override
  State<Processdetail> createState() => _ProcessdetailState();
}

class _ProcessdetailState extends State<Processdetail> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Processcircle(progress: 0.2, text1: "로봇1"),

            Processcircle(progress: 0.4, text1: "로봇2"),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Processcircle(progress: 0.2, text1: "로봇3"),

            Processcircle(progress: 0.4, text1: "저장창고1"),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Processcircle(progress: 0.2, text1: "저장창고2"),

            Processcircle(progress: 0.4, text1: "불량률"),
          ],
        ),
      ],
    );
  }
}

//일단 원형 그래프로 현재 공정률을 보여주고싶은거임
//아니면 그냥 그래프?
//뭐랑 비교해서 %를 만들어야하나
//이거는 만들어봐야할듯??
//일단 원형그래프를 먼저 만들어보자
//일단 보여줘야하는거는 로봇3개의 가동률, 저장창고의 적재량, 불량률정도??
//가동률(%) = (가동 시간 / 총 시간) × 100
//불량률(%) = (불량품 수량 / 전체 수량) × 100
