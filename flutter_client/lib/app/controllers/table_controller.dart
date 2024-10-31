// file: lib/app/controllers/table_controller.dart

import 'dart:math' show max;
import 'package:get/get.dart';
import '../data/models/table_model.dart';
import '../data/models/order.dart';
import '../data/providers/api_provider.dart';
import './auth_controller.dart';
import './order_controller.dart';
import './sales_controller.dart';
import './order_queue_controller.dart';
import 'package:dio/dio.dart';

class TableController extends GetxController {
  final AuthController authController = Get.find();
  late final OrderController orderController = Get.find();
  final SalesController salesController = Get.find();
  final OrderQueueController orderQueueController = Get.find();
  final ApiProvider apiProvider = Get.find();
  final RxList<TableModel> _originalTables = <TableModel>[].obs;
  final RxList<TableModel> _tables = <TableModel>[].obs;
  RxList<TableModel> get tables => _tables;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool isEditMode = false.obs;

  final Rx<RequestStatus> _fetchStatus = RequestStatus.initial.obs;
  RequestStatus get fetchStatus => _fetchStatus.value;

  @override
  void onInit() {
    super.onInit();
    ever(authController.restaurantToken, _onTokenChanged);
    // 로그인 상태 변경 감지 및 처리

    ever(authController.restaurant, (_) async {
      if (authController.isLoggedIn) {
        final hasTables = await _checkIfTablesExist();
        if (!hasTables) {
          await _initializeTables();
        }
      }
    });
  }

// 테이블 존재 여부 확인 함수
  Future<bool> _checkIfTablesExist() async {
    try {
      final tables = await fetchTables();
      return tables.isNotEmpty;
    } catch (error) {
      _handleError(error, 'Failed to check if tables exist');
      return false; // 오류 발생 시 초기화 시도
    }
  }

  void _onTokenChanged(String? token) {
    if (token != null && token.isNotEmpty) {
      apiProvider.setToken(token);
      _initializeData();
    } else {
      _tables.clear();
    }
  }

  Future<void> _initializeData() async {
    if (authController.restaurantToken.value != null) {
      await fetchTablesAndOrders();
    } else {
      _tables.clear();
    }
  }

  Future<void> _initializeTables() async {
    if (authController.isLoggedIn) {
      await fetchTablesAndOrders();
      if (_tables.isEmpty) {
        await createInitialTables();
      }
    }
  }

  Future<void> fetchTablesAndOrders() async {
    if (!authController.isLoggedIn) {
      print(
          'User is not logged in or restaurant info is missing. Skipping fetch.');
      return;
    }
    _isLoading.value = true;
    try {
      final tablesData = await fetchTables();
      final ordersData = await orderController.fetchOrders();
      _processFetchedData(tablesData, ordersData);
    } catch (error) {
      print('Error fetching tables and orders: $error');
      Get.snackbar('Error', 'Failed to load tables and orders');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<TableModel>> fetchTables() async {
    try {
      final response = await apiProvider.get(
        '/api/tables',
        queryParameters: {
          'restaurantId': authController.restaurant.value?.restaurantId,
        },
      );

      if (response.statusCode == 200) {
        final tablesData = response.data as List;
        final tables =
            tablesData.map((table) => TableModel.fromJson(table)).toList();
        _tables.assignAll(tables);
        return tables;
      } else {
        throw Exception('Failed to fetch tables: ${response.statusMessage}');
      }
    } catch (error) {
      _handleError(error, 'Failed to load tables');
      rethrow;
    }
  }

  void _processFetchedData(
      List<TableModel> tablesData, List<Order> ordersData) {
    _tables.value = tablesData.map((table) {
      table.orders.assignAll(
          ordersData.where((order) => order.tableId == table.tableId).toList());
      return table;
    }).toList();
  }

  void toggleEditMode() {
    isEditMode.toggle();
  }

  void updateTable(String? id, Map<String, dynamic> newProps) {
    if (id == null) return;
    final index = _tables.indexWhere((table) => table.id == id);
    if (index != -1) {
      final updatedTable = TableModel(
        id: _tables[index].id,
        tableId: _tables[index].tableId,
        x: (newProps['x'] ?? _tables[index].x).toDouble(),
        y: (newProps['y'] ?? _tables[index].y).toDouble(),
        width: (newProps['width'] ?? _tables[index].width).toDouble(),
        height: (newProps['height'] ?? _tables[index].height).toDouble(),
        status: newProps['status'] ?? _tables[index].status,
      );
      _tables[index] = updatedTable;
      update();
    }
  }

  Future<void> saveLayout() async {
    try {
      final restaurantId = authController.restaurant.value?.restaurantId;
      if (restaurantId == null) {
        throw Exception('Restaurant ID is null');
      }

      final response = await apiProvider.put(
        '/api/tables',
        {
          'restaurantId': restaurantId,
          'tables': _tables.map((t) => t.toJson()).toList(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> updatedTablesData = response.data['tables'];
        _tables.value = updatedTablesData
            .map((table) => TableModel.fromJson(table))
            .toList();
        update();
        Get.snackbar('성공', '테이블 레이아웃이 성공적으로 저장되었습니다.');
        isEditMode.value = false;
      } else {
        throw Exception('Failed to save layout: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error saving table layout: $e');
      Get.snackbar('오류', '테이블 레이아웃 저장에 실패했습니다: ${e.toString()}');
    }
  }

  void cancelChanges() {
    _tables.value = List<TableModel>.from(_originalTables);
    Get.snackbar('Info', 'Changes cancelled');
  }

  TableModel addTable() {
    final newTableId =
        _tables.isEmpty ? 1 : _tables.map((t) => t.tableId).reduce(max) + 1;
    final newTable = TableModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tableId: newTableId,
      x: 0,
      y: 0,
      width: 250,
      height: 250,
      status: 'empty',
      orders: [],
    );
    _tables.add(newTable);
    update();
    return newTable;
  }

  void removeTable(int tableId) {
    _tables.removeWhere((table) => table.tableId == tableId);
    update();
  }

  TableModel? getTableById(int tableId) {
    return _tables.firstWhereOrNull((table) => table.tableId == tableId);
  }

  List<Order> getActiveOrders() {
    return orderController.orders
        .where((order) => order.status != 'completed')
        .toList();
  }

  List<Order> getOrdersForTable(int tableId) {
    final table = _tables.firstWhereOrNull((table) => table.tableId == tableId);
    return table?.orders ?? [];
  }

  Future<void> createInitialTables() async {
    // 레스토랑 정보에서 테이블 수를 가져옵니다.
    // 레스토랑 정보에서 테이블 수를 가져옵니다.
    final restaurant = authController.restaurant.value;
    final tableCount = restaurant?.tables ?? 10; // 기본값으로 6을 사용합니다.

    // 화면 크기를 고려하여 테이블 크기를 계산합니다.
    final screenSize = Get.size;
    final tableWidth = (screenSize.width * 0.8 / 5).clamp(250.0, 300.0);
    final tableHeight =
        (screenSize.height * 0.8 / 2).clamp(300.0, 350.0); // 세로 길이를 늘렸습니다.

    // 테이블 간 간격을 계산합니다.
    final horizontalSpacing = screenSize.width * 0.1 / 8;
    final verticalSpacing = screenSize.height * 0.2 / 8;

    final initialTables = List.generate(
      tableCount,
      (index) => TableModel(
        id: DateTime.now().millisecondsSinceEpoch.toString() + index.toString(),
        tableId: index + 1,
        // x와 y 위치를 조정하여 테이블을 균등하게 배치합니다.
        x: (index % 8) * (tableWidth + horizontalSpacing) + horizontalSpacing,
        y: (index ~/ 8) * (tableHeight + verticalSpacing) + verticalSpacing,

        width: tableWidth,
        height: tableHeight,
        status: "empty",
        orders: [],
      ),
    );

    try {
      final createdTables = await Future.wait(
        initialTables.map((table) => _createTable(table)),
      );

      _tables.value = createdTables.whereType<TableModel>().toList();
      update();
      // Get.snackbar('Success', 'Initial tables created successfully');
    } catch (error) {
      _handleError(error, 'Failed to create initial tables');
    }
  }

  Future<TableModel?> _createTable(TableModel table) async {
    try {
      final restaurantId = authController.restaurant.value?.restaurantId;
      final tableData = {
        ...table.toJson(),
        'restaurantId': restaurantId,
      };
      print('Sending table data to server: $tableData');

      final response = await apiProvider.post(
        '/api/tables',
        tableData,
      );

      print('Server response: ${response.data}');

      if (response.statusCode == 201) {
        return TableModel.fromJson(response.data['table']);
      } else {
        throw Exception(
            'Failed to create table ${table.tableId}: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Response headers: ${e.response?.headers}');
      _handleError(e, 'Error creating table ${table.tableId}');
      return null;
    } catch (err) {
      _handleError(err, 'Error creating table ${table.tableId}');
      return null;
    }
  }

  void _handleError(dynamic error, String defaultMessage) {
    String errorMessage = defaultMessage;
    if (error is Exception) {
      errorMessage = '${defaultMessage}: ${error.toString()}';
    }
    print('Error: $errorMessage');
    Get.snackbar('Error', errorMessage);
  }
}

enum RequestStatus { initial, loading, success, error }
