import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('User.fromJson: Parsing JSON: $json');

      // Kiểm tra các field bắt buộc
      if (json['id'] == null) {
        throw Exception('Missing required field: id');
      }
      if (json['email'] == null) {
        throw Exception('Missing required field: email');
      }
      if (json['name'] == null) {
        throw Exception('Missing required field: name');
      }
      if (json['createdAt'] == null) {
        throw Exception('Missing required field: createdAt');
      }
      if (json['updatedAt'] == null) {
        throw Exception('Missing required field: updatedAt');
      }

      final user = User(
        id: json['id'].toString(),
        email: json['email'].toString(),
        name: json['name'].toString(),
        avatar: json['avatar']?.toString(),
        createdAt: DateTime.parse(json['createdAt'].toString()),
        updatedAt: DateTime.parse(json['updatedAt'].toString()),
      );

      debugPrint('User.fromJson: Successfully created user: ${user.name}');
      return user;
    } catch (e) {
      debugPrint('User.fromJson: Error parsing JSON: $e');
      debugPrint('User.fromJson: JSON structure: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
