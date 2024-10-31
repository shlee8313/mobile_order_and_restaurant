class VisitCount {
  final String userId;
  final String restaurantId;
  int count;

  VisitCount({
    required this.userId,
    required this.restaurantId,
    this.count = 0,
  });

  factory VisitCount.fromJson(Map<String, dynamic> json) {
    return VisitCount(
      userId: json['userId'],
      restaurantId: json['restaurantId'],
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'restaurantId': restaurantId,
      'count': count,
    };
  }

  void incrementCount() {
    count++;
  }
}
