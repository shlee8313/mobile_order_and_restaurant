// lib/core/config/api_config.dart

class ApiConfig {
  static const String baseUrl = 'http://192.168.0.9:5000'; // 사무실
  // static const String baseUrl = 'http://192.168.219.102:5000'; // 익산집
  // static const String baseUrl = 'https://api.yourproductionserver.com';  // 프로덕션 환경
  // static const String baseUrl = 'http://192.168.0.88:5000'; // 프로덕션 환경

  // 엔드포인트 수정
  static String get restaurants =>
      '$baseUrl/api/restaurants'; // 변경된 부분 (api 추가)
  static String get orders => '$baseUrl/api/orders'; // 경로 수정 (api 추가)
  static String get quickOrders =>
      '$baseUrl/api/quick-orders'; // 경로 수정 (api 추가)
  static String get menu => '$baseUrl/api/menu'; // 메뉴 API 경로 추가
  static String get auth => '$baseUrl/api/auth'; // 인증 관련 API 경로 추가
  static String get sales => '$baseUrl/api/sales'; // 매출 관련 API 경로 추가
  static String get tables => '$baseUrl/api/tables'; // 테이블 관련 API 경로 추가
  static String get businessDay =>
      '$baseUrl/api/business-day'; // 영업일 관련 API 경로 추가
  static String get userAuth =>
      '$baseUrl/api/user-auth'; // 새로 추가된 user-auth 엔드포인트
}
