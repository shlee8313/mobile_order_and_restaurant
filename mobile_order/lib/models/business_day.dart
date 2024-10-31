import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class BusinessDay {
  final String id;
  final String restaurantId;
  final DateTime businessDate;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;

  BusinessDay({
    required this.id,
    required this.restaurantId,
    required this.businessDate,
    required this.startTime,
    this.endTime,
    required this.isActive,
  });

  factory BusinessDay.fromJson(Map<String, dynamic> json) {
    print('Raw JSON for BusinessDay: $json');
    final koreaTimeZone = tz.getLocation('Asia/Seoul');

    DateTime parseToKoreanTime(String dateString) {
      final utcTime = DateTime.parse(dateString);
      return tz.TZDateTime.from(utcTime, koreaTimeZone);
    }

    return BusinessDay(
      id: json['_id'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      startTime: parseToKoreanTime(json['startTime']),
      endTime:
          json['endTime'] != null ? parseToKoreanTime(json['endTime']) : null,
      isActive: json['isActive'] ?? false,
      businessDate: parseToKoreanTime(json['businessDate']),
    );
  }
  @override
  String toString() {
    return 'BusinessDay{id: $id, startTime: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(startTime)}, businessDate: ${DateFormat('yyyy-MM-dd').format(businessDate)}, isActive: $isActive}';
  }
}
