import 'package:flutter/material.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주문내역'),
      ),
      body: const Center(
        child: Text('Order List Page'),
      ),
    );
  }
}
