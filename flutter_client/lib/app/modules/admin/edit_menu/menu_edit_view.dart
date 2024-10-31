// file:\flutter_client\lib\app\modules\admin\edit_menu\menu_edit_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/menu_edit_controller.dart';
import '../../../data/models/menu.dart';
import '../../../ui/widgets/menu_item_edit_form.dart';
import 'package:intl/intl.dart'; // Import intl package

/***
 * 
 */
class MenuEditView extends GetView<MenuEditController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // appBar: AppBar(
        //   title: Text('Edit Menu'),
        // ),

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${controller.errorMessage.value}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.fetchMenu(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.menu.value == null ||
            controller.menu.value!.categories.isEmpty) {
          return Center(child: Text('No menu data available'));
        }

        return Row(
          children: [
            // Left side - Categories
            Expanded(
              flex: 1,
              child: Card(
                margin: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Expanded(
                      child: ReorderableListView(
                        onReorder: (oldIndex, newIndex) {
                          controller.moveCategory(oldIndex, newIndex);
                        },
                        children: [
                          for (final category
                              in controller.menu.value!.categories)
                            ListTile(
                              key: ValueKey(category),
                              title: Text(
                                category.name,
                                style: TextStyle(
                                  fontWeight:
                                      controller.selectedCategory.value ==
                                              category
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                              selected:
                                  controller.selectedCategory.value == category,
                              onTap: () => controller.selectCategory(category),
                              trailing: IconButton(
                                icon: Icon(Icons.edit),
                                iconSize: 16,
                                onPressed: () =>
                                    _showEditCategoryDialog(context, category),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.shade500, // 좀 더 밝은 파란색
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: IconButton(
                              constraints: const BoxConstraints.tightFor(
                                width: 40, // 아이콘 버튼 크기 조정
                                height: 40,
                              ),
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () => _showAddCategoryDialog(context),
                              tooltip: 'Add Category',
                              padding:
                                  EdgeInsets.zero, // 패딩 제거하여 아이콘을 중앙에 정확히 배치
                              splashRadius: 20, // 터치 효과 크기 조정
                            ),
                          )
                          // ElevatedButton(
                          //   onPressed: () => _showAddCategoryDialog(context),
                          //   child: Text('Add Category'),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right side - Menu items
            Expanded(
                flex: 4,
                child: Card(
                  margin: EdgeInsets.all(8),
                  child: MenuItemList(
                    category: controller.selectedCategory.value,
                    onItemUpdated: (updatedItem) =>
                        controller.updateMenuItem(updatedItem),
                  ),
                )),
          ],
        );
      }),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '카테고리 추가',
          style: TextStyle(fontSize: 14),
        ),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(hintText: "카테고리 이름"),
        ),
        actions: [
          TextButton(
            child: Text('취소'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('저장'),
            onPressed: () {
              if (textController.text.isNotEmpty) {
                controller.addCategory(textController.text);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, MenuCategory category) {
    final textController = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '카테고리 수정',
          style: TextStyle(fontSize: 14),
        ),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(hintText: "추가할 카테고리 이름"),
        ),
        actions: [
          TextButton(
            child: Text('취소'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('저장'),
            onPressed: () {
              if (textController.text.isNotEmpty) {
                controller.updateCategory(category, textController.text);
                Navigator.of(context).pop();
              }
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // 현재 다이얼로그 닫기
              _showDeleteCategoryDialog(context, category);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              '삭제', style: TextStyle(color: Colors.white), // Text color
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, MenuCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '카테고리 삭제',
          style: TextStyle(fontSize: 14),
        ),
        content: Text(
            '정말 "${category.name}" 카테고리를 삭제하시겠습니까?\n삭제하면 하위 메뉴들도 모두 삭제됩니다.'),
        actions: [
          TextButton(
            child: Text('취소'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('삭제'),
            onPressed: () {
              controller.deleteCategory(category);
              Navigator.of(context).pop(); // 삭제 확인 다이얼로그 닫기
            },
          ),
        ],
      ),
    );
  }
}

class MenuItemList extends StatelessWidget {
  final MenuCategory? category;
  final Function(MenuItem) onItemUpdated;

  MenuItemList({this.category, required this.onItemUpdated});

  @override
  Widget build(BuildContext context) {
    if (category == null) {
      return Center(child: Text('Select a category'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category!.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddMenuItemDialog(context),
                icon: Icon(Icons.add),
                label: Text('메뉴 추가'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: category!.items.length,
            itemBuilder: (context, index) {
              final item = category!.items[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: item.images.isNotEmpty
                      ? Image.network(item.images[0],
                          width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.fastfood),
                  title: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          formatCurrency(item.price),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Text(
                          item.description ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    iconSize: 16,
                    onPressed: () => _showEditDialog(context, item),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, MenuItem item) {
    final formKey = GlobalKey<MenuItemEditFormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('메뉴 수정',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: MenuItemEditForm(
                      key: formKey,
                      item: item,
                      onSave: (updatedItem) async {
                        try {
                          await onItemUpdated(updatedItem);
                          // 다이얼로그를 닫기 전에 컨트롤러 업데이트
                          // Get.find<MenuEditController>().update();
                          // 약간의 딜레이 후 다이얼로그 닫기
                          // await Future.delayed(Duration(milliseconds: 100));
                          // Navigator.of(context).pop();
                          // Navigator.of(context).pop();
                        } catch (e) {
                          print('Error updating menu item: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('메뉴 업데이트 중 오류가 발생했습니다.')),
                          );
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('취소'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.saveItem()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('저장'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMenuItemDialog(BuildContext context) {
    final formKey = GlobalKey<MenuItemEditFormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('새 메뉴 추가',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: MenuItemEditForm(
                        key: formKey,
                        onSave: (newItem) {
                          Get.find<MenuEditController>().addMenuItem(newItem);
                          // Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('취소'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.saveItem()) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text('저장'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String formatCurrency(int price) {
    final format = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    return format.format(price);
  }
}
