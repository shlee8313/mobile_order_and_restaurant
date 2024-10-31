// File: lib/app/modules/admin/sales/sales_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../controllers/sales_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../data/models/daily_sales.dart';
import 'package:excel/excel.dart' as excel;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../ui/theme/app_theme.dart';

// import 'package:excel/excel.dart';
// import 'package:intl/intl.dart';
class SalesView extends StatefulWidget {
  @override
  _SalesViewState createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {
  final SalesController salesController = Get.find<SalesController>();
  final AuthController authController = Get.find<AuthController>();
  late DateTime _focusedDay;
  late DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  // bool _isTimeZoneInitialized = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    // _initializeTimeZone();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  // Future<void> _initializeTimeZone() async {
  //   try {
  //     tz.initializeTimeZones();
  //     setState(() {
  //       _isTimeZoneInitialized = true;
  //     });
  //   } catch (e) {
  //     print('시간대 초기화 오류: $e');
  //     // 오류 처리 로직 추가 (예: 사용자에게 알림)
  //   }
  // }

  void _fetchInitialData() {
    salesController.fetchMonthlySales(
      authController.restaurant.value?.restaurantId,
      _focusedDay.year,
      _focusedDay.month,
    );
  }

  String _getKoreanMonth(DateTime date) {
    List<String> koreanMonths = [
      '1월',
      '2월',
      '3월',
      '4월',
      '5월',
      '6월',
      '7월',
      '8월',
      '9월',
      '10월',
      '11월',
      '12월'
    ];
    return koreanMonths[date.month - 1];
  }

  Future<void> _exportToExcel() async {
    final status = await Permission.storage.request();
    try {
      if (status.isGranted) {
        final excelFile = excel.Excel.createExcel();
        final sheet = excelFile['Sheet1'];

        // Add headers
        sheet.appendRow([
          // excel.TextCellValue('비즈니스 데이 ID'),
          excel.TextCellValue('날짜'),
          excel.TextCellValue('시작 시간'),
          excel.TextCellValue('종료 시간'),
          excel.TextCellValue('총 매출'),
          excel.TextCellValue('상품명'),
          excel.TextCellValue('수량'),
          excel.TextCellValue('판매액')
        ]);

        // Add data
        // final koreaTimeZone = tz.getLocation('Asia/Seoul');
        for (var businessDay in salesController.businessDays) {
          final dailySales = salesController.salesByBusinessDay[businessDay.id];
          if (dailySales != null) {
            for (var itemSales in dailySales.itemSales) {
              sheet.appendRow([
                excel.TextCellValue(
                    DateFormat('yyyy-MM-dd').format(businessDay.startTime)),
                excel.TextCellValue(
                    DateFormat('HH:mm').format(businessDay.startTime)),
                excel.TextCellValue(businessDay.endTime != null
                    ? DateFormat('HH:mm').format(businessDay.endTime!)
                    : '진행 중'),
                excel.IntCellValue(dailySales.totalSales),
                excel.TextCellValue(itemSales.name),
                excel.IntCellValue(itemSales.quantity),
                excel.IntCellValue(itemSales.price * itemSales.quantity),
              ]);
            }
          }
        }
        // 파일 저장 로직
        final Directory? downloadsDir = await getDownloadsDirectory();
        if (downloadsDir == null) {
          throw Exception('다운로드 디렉토리를 찾을 수 없습니다.');
        }

        final String fileName =
            'sales_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
        final String filePath = path.join(downloadsDir.path, fileName);

        final File file = File(filePath);
        await file.writeAsBytes(excelFile.encode()!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('엑셀 파일이 저장되었습니다: $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장소 접근 권한이 필요합니다.')),
        );
      }
    } catch (e) {
      print('Error exporting Excel file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('엑셀 파일 저장 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Temporarily comment out the header for debugging
          _buildCalendarHeader(),
          // Adjust or remove the SizedBox temporarily
          Divider(color: Colors.blueGrey[100], thickness: 0.5),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    // color: Colors.red.withOpacity(0.2), // Visualize the calendar area
                    child: _buildCalendar(),
                  ),
                ),
                SizedBox(
                    width: 16), // Space between the calendar and sales panel
                Expanded(
                  flex: 1,
                  child: Container(
                    // color: Colors.blue.withOpacity(0.2), // Visualize the sales area
                    child: _buildSelectedDaySales(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _focusedDay =
                        DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                  });
                  _fetchInitialData();
                },
              ),

              GetBuilder<SalesController>(
                builder: (_) {
                  return Text(
                    '${_focusedDay.year}년 ${_getKoreanMonth(_focusedDay)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  );
                },
              ),
              SizedBox(width: 8), // 년월과 오른쪽 화살표 사이의 간격
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _focusedDay =
                        DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                  });
                  _fetchInitialData();
                },
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  final today = DateTime.now();
                  setState(() {
                    _focusedDay = today;
                    _selectedDay = today;
                  });
                  _fetchInitialData();
                },
                child: Text('오늘'),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8)),
              ),
              SizedBox(width: 4), // 버튼 사이의 간격
              ElevatedButton(
                onPressed: _exportToExcel,
                child: Text('엑셀 다운로드'),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return GetBuilder<SalesController>(
      builder: (_) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // print("Available height: ${constraints.maxHeight}");
            // print("Available width: ${constraints.maxWidth}");
            // 수정: 달력의 각 날짜 셀의 높이를 계산합니다.
            double cellHeight =
                (constraints.maxHeight - 50) / 6; // 50px는 대략적인 헤더 높이입니다.
            return Container(
              height: constraints.maxHeight, // Try setting it directly
              child: TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2080, 12, 31),
                focusedDay: _focusedDay,
                // focusedDay: DateTime.utc(2024, 1, 1),
                calendarFormat: _calendarFormat,
                headerVisible: false,
                daysOfWeekHeight: 40, // 요일과 날짜 사이의 간격을 늘립니다

                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  _fetchInitialData();
                },
                calendarStyle: CalendarStyle(
                  // markerSize: 1, // 동그라미 크기를 5로 설정 (기본값은 8)
                  // markerDecoration: BoxDecoration(
                  //   color: Colors.grey,
                  //   shape: BoxShape.circle,
                  // ),
                  markerSizeScale: 0.1, // 동그라미 크기를 셀 크기의 10%로 설정
                  markerDecoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                  cellMargin: EdgeInsets.all(0),
                  cellPadding: EdgeInsets.all(0),
                  todayDecoration: BoxDecoration(), // 오늘 날짜 동그라미를 제거합니다
                  todayTextStyle: TextStyle(
                      color: Colors.black), // 오늘 날짜 텍스트 스타일을 일반 날짜와 동일하게 설정
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    return _buildCalendarDay(day, cellHeight);
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return _buildCalendarDay(
                        day, cellHeight); // 오늘 날짜도 일반 날짜와 동일하게 처리
                  },
                ),
                rowHeight: cellHeight,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalendarDay(DateTime day, double cellHeight) {
    int salesAmount = salesController.getDailySalesAmount(day);
    bool isToday = salesController.isSameDay(day, DateTime.now());
    bool isSelected =
        _selectedDay != null && salesController.isSameDay(_selectedDay!, day);

    return Container(
      height: cellHeight, // 수정: 계산된 셀 높이를 사용합니다.
      width: double.infinity,
      margin: const EdgeInsets.all(1.0), // 수정: 마진을 줄여 더 많은 공간 확보
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
        border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 날짜를 왼쪽으로 정렬,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4), // 날짜를 왼쪽 위로 이동
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          if (salesAmount > 0)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '₩${NumberFormat('#,###').format(salesAmount)}',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedDaySales() {
    if (_selectedDay == null) return SizedBox.shrink();

    return GetBuilder<SalesController>(
      builder: (_) {
        print("SalesView _selectedDay $_selectedDay");
        final selectedBusinessDay =
            salesController.getBusinessDayForDate(_selectedDay!);
        print("SalesView selectedBusinessDay $selectedBusinessDay");

        if (selectedBusinessDay == null) {
          print('선택된 날짜의 영업 데이터 없음: ${_selectedDay}');
          return Center(child: Text('해당 날짜의 영업 데이터가 없습니다.'));
        }

        final sales = salesController.getSalesForDate(_selectedDay!);
        final totalSales = sales?.totalSales ?? 0;
        final salesItems = sales?.itemSales ?? [];

        // final koreaTimeZone = tz.getLocation('Asia/Seoul');
        String startTimeString = '정보 없음';
        String endTimeString = '정보 없음';

        if (selectedBusinessDay != null &&
            selectedBusinessDay.startTime != null) {
          startTimeString =
              DateFormat('HH:mm').format(selectedBusinessDay.startTime!);

          if (selectedBusinessDay.endTime != null) {
            endTimeString =
                DateFormat('HH:mm').format(selectedBusinessDay.endTime!);
          } else {
            endTimeString = '진행 중';
          }

          // 디버깅을 위한 로그 추가
          print('Original startTime: ${selectedBusinessDay.startTime}');
          print('Formatted startTimeString: $startTimeString');
        } else {
          print('selectedBusinessDay or startTime is null');
        }
        /** */

        return Card(
          // ... 기존 카드 스타일 ...
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat('yyyy년 MM월 dd일').format(_selectedDay!)}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '영업 시작: $startTimeString',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  '영업 종료: $endTimeString',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(
                  '총 매출: ₩${NumberFormat('#,###').format(totalSales)}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: Column(
                    children: [
                      if (salesItems.isNotEmpty) ...[
                        Row(
                          children: [
                            Expanded(
                                flex: 5,
                                child: Text('상품명',
                                    style: TextStyle(fontSize: 12))),
                            Expanded(
                                flex: 1,
                                child: Text('수량',
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 3,
                                child: Text('판매액',
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.right)),
                          ],
                        ),
                        Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: salesItems.length,
                            itemBuilder: (context, index) {
                              final item = salesItems[index];
                              print(
                                  'Item: ${item.name}, Price: ${item.price}, Sales: ${item.sales}');
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Text(item.name,
                                          style: TextStyle(fontSize: 11)),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text('${item.quantity}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 11)),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        '${NumberFormat('#,###').format(item.price * item.quantity)}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ] else if (totalSales > 0)
                        Expanded(
                          child: Center(
                            child: Text('상세 매출 내역을 불러오는 중 오류가 발생했습니다.'),
                          ),
                        )
                      else
                        Expanded(
                          child: Center(
                            child: Text('해당 날짜의 매출 내역이 없습니다.'),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
