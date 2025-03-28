import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Orderlistpage extends StatefulWidget {
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

      // 1. 공정 중인 주문이 있는지 먼저 확인
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

        final type = product.toString().replaceAll('배터리', '');
        final seconds = processTime[type]! * quantity;
        final elapsed = now.difference(started).inSeconds;

        if (elapsed >= seconds) {
          await orders.doc(doc.id).update({
            'status': '공정 완료',
            'completedAt': now,
          });
          print('업데이트 됨: ${doc.id} → 공정 완료');
        }

        return; // 👉 공정 중인 게 있으면 여기서 끝냄
      }

      // 2. 공정 중인 게 없으면 주문 접수된 것 중 첫 번째를 공정 시작
      final waiting =
          await orders
              .where('status', isEqualTo: '주문 접수됨')
              .orderBy('timestamp')
              .limit(1)
              .get();

      if (waiting.docs.isNotEmpty) {
        final doc = waiting.docs.first;
        await orders.doc(doc.id).update({
          'status': '공정 중',
          'processingStarted': now,
        });
        print('업데이트 됨: ${doc.id} → 공정 중');
      }
    });
  }

  void _addOrder() async {
    final name = _nameController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim());

    if (name.isNotEmpty && quantity != null) {
      await orders.add({
        'product': '배터리$_selectedProduct',
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
    return Scaffold(
      appBar: AppBar(
        title: Text('주문 리스트'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // 강제 새로고침
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('전체 주문 삭제'),
                      content: Text('정말 모든 주문을 삭제할까요?'),
                      actions: [
                        TextButton(
                          child: Text('취소'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        TextButton(
                          child: Text('삭제'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
              );

              if (confirm == true) {
                final snapshot = await orders.get();
                for (final doc in snapshot.docs) {
                  await orders.doc(doc.id).delete();
                }
                setState(() {}); // 삭제 후 화면 갱신
              }
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // 주문 입력 UI
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                DropdownButton<String>(
                  value: _selectedProduct,
                  items:
                      ['A', 'B', 'C'].map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text('배터리$value'),
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
                SizedBox(height: 5),
                ElevatedButton(onPressed: _addOrder, child: Text('주문 추가')),
              ],
            ),
          ),
          Divider(),
          // 주문 리스트 UI
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: orders.orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('주문이 없습니다.'));
                }

                final docs = snapshot.data!.docs;
                final now = DateTime.now();

                return ListView(
                  children:
                      docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final timestamp =
                            (data['timestamp'] as Timestamp?)?.toDate();
                        final product = data['product'] ?? '';
                        final user = data['user'] ?? '';
                        final quantity = data['quantity'] ?? 0;
                        final status = data['status'] ?? '';

                        final type = product.toString().replaceAll('배터리', '');
                        final seconds = processTime[type]! * quantity;

                        // 상태 자동 업데이트
                        if (timestamp != null) {
                          final elapsed = now.difference(timestamp).inSeconds;

                          if (status == '주문 접수됨' && elapsed >= 1) {
                            orders.doc(doc.id).update({
                              'status': '공정 중',
                              'processingStarted': now,
                            });
                          }

                          final started =
                              (data['processingStarted'] as Timestamp?)
                                  ?.toDate();
                          if (status == '공정 중' && started != null) {
                            final processElapsed =
                                now.difference(started).inSeconds;
                            if (processElapsed >= seconds) {
                              orders.doc(doc.id).update({'status': '공정 완료'});
                            }
                          }
                        }

                        return ListTile(
                          title: Text('제품명: $product (수량: $quantity)'),
                          subtitle: Text('사용자: $user | 상태: $status'),
                        );
                      }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
