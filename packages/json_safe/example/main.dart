// ignore_for_file: avoid_print

import 'package:json_safe/json_safe.dart';
import 'package:meta/meta.dart';

@immutable
class User {
  const User({required this.email, required this.userId});

  factory User.fromJson(JsonMap json) =>
      User(email: json['email']! as String, userId: json['userId']! as int);

  final String email;
  final int userId;
}

void main() {
  final user = deserializeJsonMap({
    'email': 'email@example.com',
    'userId': 1,
  }, fromJson: User.fromJson);

  print('Email: ${user.email}');
  print('Email: ${user.userId}');
}
