import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vision_flutter/globals/serverurl.dart';
import 'package:vision_flutter/screens/messcreens/processinfotab.dart';
import 'package:vision_flutter/screens/messcreens/processdetail.dart';
import 'package:vision_flutter/screens/messcreens/processpageview1.dart';
import 'dart:async';
import 'package:vision_flutter/widgets/remainingtime.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Orderlistpage extends StatefulWidget {
  const Orderlistpage({super.key});
  @override
  State<Orderlistpage> createState() => _OrderlistpageState();
}

class _OrderlistpageState extends State<Orderlistpage> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedProduct = 'A';

  final orders = FirebaseFirestore.instance.collection('orders');

  final processTime = {'A': 10, 'B': 12, 'C': 15};

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: 1), (timer) async {
      final now = DateTime.now();

      final processing =
          await orders
              .where('status', isEqualTo: '공정 중')
              .orderBy('processingStarted')
              .limit(1)
              .get();

      if (processing.docs.isNotEmpty) {
        final doc = processing.docs.first;
        final data = doc.data();
        final started = (data['processingStarted'] as Timestamp?)?.toDate();
        final product = data['product'];
        final quantity = data['quantity'];

        if (started == null || product == null || quantity == null) return;

        final type = product.toString().replaceAll('제품군', '');
        final seconds = processTime[type]! * quantity;
        final elapsed = now.difference(started).inSeconds;

        if (elapsed >= seconds) {
          await orders.doc(doc.id).update({
            'status': '공정 완료',
            'completedAt': now,
          });
          print('업데이트 됨: ${doc.id} → 공정 완료');
        }

        return;
      }

      final waiting =
          await orders
              .where('status', isEqualTo: '주문 접수됨')
              .orderBy('timestamp')
              .limit(1)
              .get();

      if (waiting.docs.isNotEmpty) {
        print("🟢 주문 감지됨, 공정 시작으로 업데이트");

        final doc = waiting.docs.first;
        await orders.doc(doc.id).update({
          'status': '공정 중',
          'processingStarted': now,
        });

        try {
          final response = await http.post(
            Uri.parse("${Global.serverUrl}/set_bit"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"address": "M0", "value": 1}),
          );
          print('📤 M0 ON 요청 완료: ${response.body}');

          // 4초 후 자동 OFF
          Future.delayed(Duration(seconds: 6), () async {
            try {
              final offResponse = await http.post(
                Uri.parse("${Global.serverUrl}/set_bit"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({"address": "M0", "value": 0}),
              );
              print('📴 M0 OFF 요청 완료: ${offResponse.body}');
            } catch (e) {
              print("❌ M0 OFF 실패: $e");
            }
          });
        } catch (e) {
          print("❌ M0 전송 실패: $e");
        }
      }
    });
  }

  void _addOrder() async {
    final name = _nameController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim());

    if (name.isNotEmpty && quantity != null) {
      await orders.add({
        'product': '제품군$_selectedProduct',
        'user': name,
        'quantity': quantity,
        'status': '주문 접수됨',
        'timestamp': DateTime.now(),
      });

      _nameController.clear();
      _quantityController.clear();
      setState(() {
        _selectedProduct = 'A';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('MES 시스템'),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: Icon(Icons.refresh),
            ),
          ],
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: '주문리스트'),
              Tab(text: '공정 현황'),
              Tab(text: '공정 정보'),
              Tab(text: "가동률"),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButton<String>(
                        underline: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple,
                                const Color.fromARGB(255, 79, 170, 245),
                              ],
                            ),
                          ),
                        ),
                        value: _selectedProduct,
                        items:
                            ['A', 'B', 'C'].map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text('제품군$value'),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedProduct = value;
                            });
                          }
                        },
                      ),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: '사용자 이름'),
                      ),
                      TextField(
                        controller: _quantityController,
                        decoration: InputDecoration(labelText: '수량'),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              elevation: WidgetStatePropertyAll(2),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                              backgroundColor: WidgetStatePropertyAll(
                                const Color.fromARGB(255, 107, 159, 236),
                              ),
                              foregroundColor: WidgetStatePropertyAll(
                                Colors.white,
                              ),
                            ),
                            onPressed: _addOrder,
                            child: Text(
                              '주문 추가',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              elevation: WidgetStatePropertyAll(2),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                              backgroundColor: WidgetStatePropertyAll(
                                const Color.fromARGB(255, 107, 159, 236),
                              ),
                              foregroundColor: WidgetStatePropertyAll(
                                Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: Text(
                                        '전체 주문 삭제',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      content: Text('정말 모든 주문을 삭제할까요?'),
                                      actions: [
                                        TextButton(
                                          child: Text('취소'),
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                        ),
                                        TextButton(
                                          child: Text('삭제'),
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) {
                                final snapshot = await orders.get();
                                for (final doc in snapshot.docs) {
                                  await orders.doc(doc.id).delete();
                                }
                                setState(() {});
                              }
                            },
                            child: Text(
                              '주문 삭제',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        orders
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('주문이 없습니다.'));
                      }

                      final docs = snapshot.data!.docs;

                      return ListView(
                        children:
                            docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final product = data['product'] ?? '';
                              final user = data['user'] ?? '';
                              final quantity = data['quantity'] ?? 0;
                              final status = data['status'] ?? '';

                              return ListTile(
                                title: Row(
                                  children: [
                                    Text('제품명: $product (수량: $quantity)'),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('사용자: $user | 상태: $status'),
                                    if (status == '공정 중' &&
                                        data['processingStarted'] != null) ...[
                                      Builder(
                                        builder: (context) {
                                          final started =
                                              (data['processingStarted']
                                                      as Timestamp)
                                                  .toDate();
                                          final type = product
                                              .toString()
                                              .replaceAll('제품군', '');
                                          final totalSeconds =
                                              ((processTime[type] ?? 0) *
                                                      quantity)
                                                  .toInt();

                                          return RemainingTimeWidget(
                                            started: started,
                                            totalSeconds: totalSeconds,
                                          );
                                        },
                                      ),
                                    ] else if (status == '주문 접수됨') ...[
                                      Builder(
                                        builder: (context) {
                                          final type = product
                                              .toString()
                                              .replaceAll('제품군', '');
                                          final totalSeconds =
                                              ((processTime[type] ?? 0) *
                                                      quantity)
                                                  .toInt();

                                          final min = totalSeconds ~/ 60;
                                          final sec = totalSeconds % 60;
                                          return Text('예상 공정시간: $min분 $sec초');
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
            ProcessSimulationPage(), // 두 번째 탭 화면
            ProcessInfoTab(), //세 번째 탭 화면
            Processdetail(), //네 번째 탭 화면
          ],
        ),
      ),
    );
  }
}

//주문 하나 들어갔을때 PLC랑 연동해서 1개만 들어가도록 한번해볼까..? 제품군과 주문추가
//눌렸을때
