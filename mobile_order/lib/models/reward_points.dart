import 'package:uuid/uuid.dart';

class RewardPoints {
  final String id;
  final String userId;
  final String restaurantId;
  int points;
  final DateTime expirationDate;

  RewardPoints({
    String? id,
    required this.userId,
    required this.restaurantId,
    this.points = 0,
    required this.expirationDate,
  }) : id = id ?? Uuid().v4();

  factory RewardPoints.fromJson(Map<String, dynamic> json) {
    return RewardPoints(
      id: json['id'],
      userId: json['userId'],
      restaurantId: json['restaurantId'],
      points: json['points'] ?? 0,
      expirationDate: DateTime.parse(json['expirationDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'restaurantId': restaurantId,
      'points': points,
      'expirationDate': expirationDate.toIso8601String(),
    };
  }

  void addPoints(int amount) {
    points += amount;
  }

  bool usePoints(int amount) {
    if (points >= amount) {
      points -= amount;
      return true;
    }
    return false;
  }
}
