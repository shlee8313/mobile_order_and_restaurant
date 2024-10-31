// File: lib/data/models/business_day.dart

// import 'package:intl/intl.dart';
// import 'package:timezone/timezone.dart' as tz;

// class BusinessDay {
//   final String id;
//   final String restaurantId;
//   final DateTime businessDate;
//   final DateTime startTime; // startOfDay에서 startTime으로 변경
//   final DateTime? endTime; // endOfDay에서 endTime으로 변경
//   final bool isActive;

//   BusinessDay({
//     required this.id,
//     required this.restaurantId,
//     required this.businessDate,
//     required this.startTime,
//     this.endTime,
//     required this.isActive,
//   });

//   factory BusinessDay.fromJson(Map<String, dynamic> json) {
//     final koreaTimeZone = tz.getLocation('Asia/Seoul');
//     final startTimeMillis = json['startTime'] is Map
//         ? int.parse(json['startTime']['\$date']['\$numberLong'])
//         : json['startTime'];
//     // print('Raw JSON: $json'); // 전체 JSON 로그
//     // print('startTimeMillis: $startTimeMillis'); // startTimeMillis 값 로그
//     // final parsedStartTime = tz.TZDateTime.from(
//     //     DateTime.fromMillisecondsSinceEpoch(startTimeMillis, isUtc: true),
//     //     koreaTimeZone);

//     // print('Parsed startTime: $parsedStartTime'); // 파싱된 startTime 로그
//     return BusinessDay(
//       id: json['_id'] ?? '',
//       restaurantId: json['restaurantId'] ?? '',
//       startTime: tz.TZDateTime.from(
//           DateTime.fromMillisecondsSinceEpoch(startTimeMillis, isUtc: true),
//           koreaTimeZone),
//       endTime: json['endTime'] != null
//           ? tz.TZDateTime.from(
//               DateTime.fromMillisecondsSinceEpoch(
//                   int.parse(json['endTime']['\$date']['\$numberLong']),
//                   isUtc: true),
//               koreaTimeZone)
//           : null,
//       isActive: json['isActive'] ?? false,
//       businessDate: tz.TZDateTime.from(
//           DateTime.fromMillisecondsSinceEpoch(
//               int.parse(json['businessDate']['\$date']['\$numberLong']),
//               isUtc: true),
//           koreaTimeZone),
//     );
//   }

//   @override
//   String toString() {
//     return 'BusinessDay{id: $id, startTime: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(startTime)}, businessDate: ${DateFormat('yyyy-MM-dd').format(businessDate)}, isActive: $isActive}';
//   }
// }

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

  // factory BusinessDay.fromJson(Map<String, dynamic> json) {
  //   return BusinessDay(
  //     id: json['_id'] ?? '',
  //     restaurantId: json['restaurantId'] ?? '',
  //     startTime: DateTime.parse(json['startTime']),
  //     endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
  //     isActive: json['isActive'] ?? false,
  //     businessDate: DateTime.parse(json['businessDate']),
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'restaurantId': restaurantId,
  //     'startTime': startTime.toIso8601String(),
  //     'endTime': endTime?.toIso8601String(),
  //     'isActive': isActive,
  //     'businessDate': DateFormat('yyyy-MM-dd').format(businessDate),
  //   };
  // }
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
