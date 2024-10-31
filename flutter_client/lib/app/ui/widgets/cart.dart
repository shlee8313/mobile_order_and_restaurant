// lib/app/ui/widgets/cart.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Cart extends StatelessWidget {
  final RxList<Map<String, dynamic>> items;

  const Cart({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: [
            Text('Cart', style: Theme.of(context).textTheme.bodySmall),
            ...items.map((item) => ListTile(
                  title: Text(item['name']),
                  subtitle: Text('${item['price']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle),
                    onPressed: () {
                      // 아이템 제거 로직
                    },
                  ),
                )),
            Text('Total: ${calculateTotal()}'),
            ElevatedButton(
              child: Text('Checkout'),
              onPressed: () {
                // 체크아웃 로직
              },
            ),
          ],
        ));
  }

  String calculateTotal() {
    return items
        .fold(0.0, (sum, item) => sum + (item['price'] as double))
        .toStringAsFixed(2);
  }
}
