import 'package:travel_guide_tourist/imports.dart';

class TestGuide {
  late String id;
  final String username;
  final int age;
  final DateTime birthday;

  TestGuide({
    this.id = '',
    required this.username,
    required this.age,
    required this.birthday,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'age': age,
    'birthday': birthday,
  };

  static TestGuide fromJson(Map<String, dynamic>json) => TestGuide(
    id: json['id'],
    username: json['username'],
    age: json['age'],
    birthday: (json['birthday'] as Timestamp).toDate(),
  );
}
