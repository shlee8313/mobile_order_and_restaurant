// File: lib/controllers/sales_controller.dart

import 'package:get/get.dart';
import '../data/providers/api_provider.dart';
import 'package:intl/intl.dart';
import '../data/models/daily_sales.dart';
import '../data/models/business_day.dart';
import './business_day_controller.dart'; // 추가

class SalesController extends GetxController {
  final Map<String, DailySales> _salesByBusinessDay = {};
  final RxList<BusinessDay> _businessDays = <BusinessDay>[].obs;
  final _isLoading = false.obs;
  final _error = Rx<String?>(null);
  final Rx<DailySales?> _todaySales = Rx<DailySales?>(null);

  List<BusinessDay> get businessDays => _businessDays;
  Map<String, DailySales> get salesByBusinessDay => _salesByBusinessDay;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  DailySales? get todaySales => _todaySales.value;
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  Future<void> fetchMonthlySales(
      String? restaurantId, int year, int month) async {
//         final year = selectedDate.year.toString();
// final month = selectedDate.month.toString().padLeft(2, '0');
    print(
        'Fetching monthly sales for restaurant: $restaurantId, year: $year, month: $month');

    if (restaurantId == null) {
      _error.value = 'Restaurant ID is null';
      print('Error: Restaurant ID is null');
      return;
    }
    _isLoading.value = true;
    _error.value = null;

    try {
      final response = await _apiProvider.get(
        '/api/sales',
        queryParameters: {
          'restaurantId': restaurantId,
          'year': year.toString(),
          'month': month.toString(),
        },
      );

      print('API response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> salesData = response.data;
        print('Received ${salesData.length} sales records');

        _businessDays.clear();
        _salesByBusinessDay.clear();

        for (var data in salesData) {
          try {
            print('Processing sales data: $data');
            final dailySales = DailySales.fromJson(data);
            final businessDayId = data['businessDayId'];
            if (businessDayId != null) {
              _salesByBusinessDay[businessDayId] = dailySales;
            } else {
              print(
                  'Warning: businessDayId is null for date ${dailySales.businessDayId}');
              continue;
            }

            // 여기서 BusinessDay 객체를 생성
            final businessDay = BusinessDay.fromJson(data);
            _businessDays.add(businessDay);

            print('Processed businessDay: ${businessDay.toString()}');
          } catch (e) {
            print('Error processing sales data: $e');
            print('Problematic data: $data');
          }
        }

        print('Total business days: ${_businessDays.length}');
        print('Total sales records: ${_salesByBusinessDay.length}');
        update();
      } else {
        throw Exception(
            'Failed to fetch monthly sales. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _error.value = 'Error fetching monthly sales: $e';
      print('Error fetching monthly sales: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  DailySales? getSalesForDate(DateTime date) {
    final targetDate = DateFormat('yyyy-MM-dd').format(date.toLocal());
    print('Getting sales for date: $targetDate');
    print('SalesController getSalesForDate _businessDays:');
    _businessDays.forEach((bd) {
      print('BusinessDay: ${bd.toString()}');
    });

    final businessDay = _businessDays.firstWhereOrNull(
      (bd) => DateFormat('yyyy-MM-dd').format(bd.businessDate) == targetDate,
    );

    if (businessDay != null) {
      print(
          'Found business day: ${businessDay.id}, startTime: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(businessDay.startTime)}');
      final sales = _salesByBusinessDay[businessDay.id];
      if (sales != null) {
        // print('Sales found: ${sales.totalSales}');
        sales.itemSales.forEach((item) {
          // print(
          //     'Item: ${item.name}, Quantity: ${item.quantity}, Price: ${item.price}, Total: ${item.quantity * item.price}');
        });
      } else {
        print('No sales data found for this business day');
      }
      return sales;
    } else {
      // print('No business day found for date: $targetDate');
      return null;
    }
  }

  int getDailySalesAmount(DateTime date) {
    final sales = getSalesForDate(date);
    return sales?.totalSales ?? 0;
  }

  List<ItemSales> getSalesItems(DateTime date) {
    final sales = getSalesForDate(date);
    final items = sales?.itemSales ?? [];
    // print(
    //     'Sales items for ${DateFormat('yyyy-MM-dd').format(date)}: ${items.length} items');
    return items;
  }

  BusinessDay? getBusinessDayForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    final businessDay = _businessDays.firstWhereOrNull((bd) {
      final bdDate = DateTime(
          bd.businessDate.year, bd.businessDate.month, bd.businessDate.day);
      return bdDate.isAtSameMomentAs(targetDate);
    });

    if (businessDay != null) {
      print('Found business day: ${businessDay.toString()}');
      print('Start time: ${businessDay.startTime}');
    } else {
      print('No business day found for date: $targetDate');
    }

    return businessDay;
  }
//   bool isSameDay(DateTime? date1, DateTime? date2) {
//     if (date1 == null || date2 == null) {
//       return false;
//     }
//     return date1.year == date2.year &&
//            date1.month == date2.month &&
//            date1.day == date2.day;
//   }
// }

  Future<void> fetchTodaySales(String? restaurantId) async {
    print('Fetching today\'s sales for restaurant: $restaurantId');
    if (restaurantId == null) {
      _error.value = 'Restaurant ID is null';
      return;
    }

    _isLoading.value = true;
    _error.value = null;

    try {
      final businessDayController = Get.find<BusinessDayController>();

      if (!businessDayController.isBusinessDayActive.value) {
        _todaySales.value = null;
        print('No active business day. Skipping sales fetch.');
        return;
      }

      final response = await _apiProvider.get(
        '/api/sales/today',
        queryParameters: {'restaurantId': restaurantId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          _todaySales.value = DailySales(
            restaurantId: restaurantId,
            businessDayId: data['businessDayId'] ?? '',
            date: DateTime.parse(data['date']),
            totalSales: data['totalSales'] ?? 0,
            itemSales: [],
          );
          print('Today\'s sales fetched: ${_todaySales.value?.totalSales}');
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to fetch today\'s sales. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _error.value = 'Error fetching today\'s sales: $e';
      print('Error fetching today\'s sales: $e');
    } finally {
      _isLoading.value = false;
    }
  }

/**
 * 
 */
  bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) {
      return false;
    }
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

/**
 * 
 */
  void clearError() {
    _error.value = null;
  }

  void setLoading(bool loading) {
    _isLoading.value = loading;
  }
}
