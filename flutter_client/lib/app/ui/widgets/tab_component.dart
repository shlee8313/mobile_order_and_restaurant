//file: lib/app/ui/widgets/tab_component.dart
import 'package:flutter/material.dart';

class TabComponent extends StatelessWidget {
  final List<String> tabTitles;
  final List<Widget> tabContents;

  const TabComponent({
    Key? key,
    required this.tabTitles,
    required this.tabContents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabTitles.length,
      child: Column(
        children: [
          TabBar(
            tabs: tabTitles.map((title) => Tab(text: title)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: tabContents,
            ),
          ),
        ],
      ),
    );
  }
}
