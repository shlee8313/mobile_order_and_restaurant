// file: \flutter_client\lib\app\modules\admin\table_edit\table_edit_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/table_controller.dart';
import '../../../data/models/table_model.dart';
import '../../../ui/widgets/advanced_table_layout.dart';

class TableEditView extends GetView<TableController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('테이블 레이아웃 편집'),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.save),
      //       onPressed: () {
      //         controller.saveLayout();
      //         Get.back(); // 저장 후 이전 화면으로 돌아가기
      //       },
      //     ),
      //   ],
      // ),
      body: GetBuilder<TableController>(
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                child: AdvancedTableLayout(
                  tables: controller.tables,
                  isEditMode: true,
                  onUpdateTable: controller.updateTable,
                  onSaveLayout: () {
                    controller.saveLayout();
                    Get.back(); // 저장 후 이전 화면으로 돌아가기
                  },
                  renderTableContent: (table) => _buildTableContent(table),
                  onAddTable: controller.addTable,
                  onRemoveTable: controller.removeTable,
                ),
              ),
              // _buildControlPanel(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTableContent(TableModel table) {
    return Center(
      child: Text(
        '테이블 ${table.tableId}',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget _buildControlPanel() {
  //   return Container(
  //     padding: EdgeInsets.all(16),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         ElevatedButton(
  //           onPressed: controller.addTable,
  //           child: Text('테이블 추가'),
  //         ),
  //         ElevatedButton(
  //           onPressed: controller.cancelChanges,
  //           child: Text('변경 취소'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
