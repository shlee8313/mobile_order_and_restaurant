// lib/app/ui/widgets/menu_list.dart
import 'package:flutter/material.dart';

class MenuList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>) onItemTap;

  const MenuList({
    Key? key,
    required this.items,
    required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item['name']),
          subtitle: Text('${item['price']}'),
          onTap: () => onItemTap(item),
        );
      },
    );
  }
}
