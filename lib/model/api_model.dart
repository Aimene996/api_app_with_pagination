// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ApiModel {
  String name;
  String email;
  String body;
  ApiModel({
    required this.name,
    required this.email,
    required this.body,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'body': body,
    };
  }

  factory ApiModel.fromMap(Map<String, dynamic> map) {
    return ApiModel(
      name: map['name'] as String,
      email: map['email'] as String,
      body: map['body'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ApiModel.fromJson(String source) =>
      ApiModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
