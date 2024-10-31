// file: lib/app/data/models/review.dart

import 'package:get/get.dart';

class Review {
  final String id;
  final String userId;
  final String restaurantId;
  final int? rating;
  final String? comment;
  final List<String>? images; // 추가: 이미지 URL 목록
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.userId,
    required this.restaurantId,
    this.rating,
    this.comment,
    this.images, // 추가
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      restaurantId: json['restaurantId']?.toString() ?? '',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment']?.toString() ?? '',
      images: (json['images'] as List<dynamic>?) // 추가
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'restaurantId': restaurantId,
      'rating': rating,
      'comment': comment,
      'images': images, // 추가
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Extension for reactive properties
extension ReactiveReview on Review {
  RxInt? get rxRating => rating?.obs;
  RxString? get rxComment => comment?.obs;
  RxList<String>? get rxImages => images?.obs;
}
