// File: lib/app/ui/widgets/advanced_table_layout.dart

import 'package:flutter/material.dart';
import '../../data/models/table_model.dart';

class AdvancedTableLayout extends StatefulWidget {
  final List<TableModel> tables;
  final bool isEditMode;
  final Function(String, Map<String, dynamic>) onUpdateTable;
  final Function() onSaveLayout;
  final Widget Function(TableModel) renderTableContent;
  final TableModel Function() onAddTable;
  final Function(int) onRemoveTable;

  const AdvancedTableLayout({
    Key? key,
    required this.tables,
    required this.isEditMode,
    required this.onUpdateTable,
    required this.onSaveLayout,
    required this.renderTableContent,
    required this.onAddTable,
    required this.onRemoveTable,
  }) : super(key: key);

  @override
  _AdvancedTableLayoutState createState() => _AdvancedTableLayoutState();
}

class _AdvancedTableLayoutState extends State<AdvancedTableLayout> {
  final Map<String, Offset> _tablePositions = {};
  final Map<String, Size> _tableSizes = {};
  bool _isResizing = false;
  bool _isMoving = false;

  // 주석: 활성화된 테이블의 ID를 저장하는 변수 추가
  String? _activeTableId;

  @override
  void initState() {
    super.initState();
    _initializeTablePositionsAndSizes();
  }

  void _initializeTablePositionsAndSizes() {
    for (var table in widget.tables) {
      _tablePositions[table.id] = Offset(table.x, table.y);
      _tableSizes[table.id] = Size(table.width, table.height);
    }
  }

  @override
  void didUpdateWidget(AdvancedTableLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isResizing && !_isMoving) {
      _initializeTablePositionsAndSizes();
    }
  }

  void _addNewTable() {
    final newTable = widget.onAddTable();
    setState(() {
      _tablePositions[newTable.id] = Offset(newTable.x, newTable.y);
      _tableSizes[newTable.id] = Size(newTable.width, newTable.height);
    });
  }

  // 주석: 테이블 순서를 정렬하는 함수 추가
  List<TableModel> _getSortedTables() {
    if (_activeTableId == null) return widget.tables;

    return [...widget.tables]..sort((a, b) {
        if (a.id == _activeTableId) return 1; // 활성 테이블을 마지막으로 (가장 위에 표시)
        if (b.id == _activeTableId) return -1;
        return 0;
      });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 주석: 정렬된 테이블 목록 사용
        final sortedTables = _getSortedTables();

        return Stack(
          children: [
            ...sortedTables.map((table) => _buildTable(table, constraints)),
            if (widget.isEditMode)
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      onPressed: _addNewTable,
                      child: Icon(Icons.add),
                      heroTag: 'addTable',
                    ),
                    SizedBox(height: 16),
                    FloatingActionButton(
                      onPressed: () {
                        for (var table in widget.tables) {
                          final position = _tablePositions[table.id]!;
                          final size = _tableSizes[table.id]!;
                          widget.onUpdateTable(table.id, {
                            'x': position.dx,
                            'y': position.dy,
                            'width': size.width,
                            'height': size.height,
                          });
                        }
                        widget.onSaveLayout();
                      },
                      child: Icon(Icons.save),
                      heroTag: 'saveLayout',
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTable(TableModel table, BoxConstraints constraints) {
    final position = _tablePositions[table.id] ?? Offset(table.x, table.y);
    final size = _tableSizes[table.id] ?? Size(table.width, table.height);
    final padding = 30.0;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        // 주석: 테이블 터치시 활성화 처리 추가
        onTapDown: (_) {
          if (_activeTableId != table.id) {
            setState(() {
              _activeTableId = table.id;
            });
          }
        },
        onPanStart: (_) {
          _isMoving = true;
          // 주석: 드래그 시작시에도 해당 테이블 활성화
          if (_activeTableId != table.id) {
            setState(() {
              _activeTableId = table.id;
            });
          }
        },
        onPanUpdate: widget.isEditMode
            ? (details) {
                setState(() {
                  final newX = (position.dx + details.delta.dx)
                      .clamp(0.0, constraints.maxWidth - size.width - padding);
                  final newY = (position.dy + details.delta.dy).clamp(
                      0.0, constraints.maxHeight - size.height - padding);
                  _tablePositions[table.id] = Offset(newX, newY);
                });
              }
            : null,
        onPanEnd: (_) {
          _isMoving = false;
          widget.onUpdateTable(table.id, {
            'x': _tablePositions[table.id]!.dx,
            'y': _tablePositions[table.id]!.dy,
          });
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                width: size.width,
                constraints: BoxConstraints(
                  minWidth: size.width,
                  maxWidth: size.width,
                  minHeight: table.height,
                ),
                decoration: BoxDecoration(
                  // 주석: 테두리 색상을 활성화 상태에 따라 변경
                  border: Border.all(
                    // 주석: 활성화된 테이블은 파란색, 비활성화된 테이블은 회색으로 설정
                    color:
                        _activeTableId == table.id ? Colors.blue : Colors.grey,
                    // 주석: 활성화된 테이블의 테두리를 더 두껍게 설정
                    width: _activeTableId == table.id ? 2.5 : 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: widget.renderTableContent(table),
              ),
            ),
            if (widget.isEditMode) ...[
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onPanStart: (_) {
                    _isResizing = true;
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      final newWidth = (size.width + details.delta.dx).clamp(
                          200.0, constraints.maxWidth - position.dx - padding);
                      final newHeight = (size.height + details.delta.dy).clamp(
                          200.0, constraints.maxHeight - position.dy - padding);
                      _tableSizes[table.id] = Size(newWidth, newHeight);
                    });
                  },
                  onPanEnd: (_) {
                    _isResizing = false;
                    widget.onUpdateTable(table.id, {
                      'width': _tableSizes[table.id]!.width,
                      'height': _tableSizes[table.id]!.height,
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Transform.rotate(
                      angle: 3.14159 / 2,
                      child: Icon(Icons.open_in_full,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () => widget.onRemoveTable(table.tableId),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tablePositions.clear();
    _tableSizes.clear();
    super.dispose();
  }
}
