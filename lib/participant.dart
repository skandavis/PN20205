import 'package:NagaratharEvents/imageInfo.dart';

class Participant {
  String id;
  String name;
  int age;
  String state;
  String city;
  String gender;
  String description;
  imageInfo? image;
  String email;
  bool isEditable;
  Participant({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.city,
    required this.state,
    required this.description,
    required this.email,
    required this.isEditable,
    this.image,
  });

 @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Participant && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  factory Participant.fromJson(Map<String, dynamic> json) {
    
    return Participant(
      id: json['id'],
      name: json['name'],
      description: json['about'],
      age: json["age"],
      state: json["state"],
      city: json["city"],
      gender: json["gender"],
      email: json["emailId"] ?? '',
      isEditable: json["isEditable"],
      image: json["photo"] == null ? null : imageInfo.fromJson(json["photo"])
    );
  }

  void updateInfo(Map<String, dynamic> json)
  {
    name = json['name'] ?? name;
    email = json['emailId'] ?? email;
    description = json['about'] ?? description;
    age = json["age"] ?? age;
    city = json["city"] ?? city;
    gender = json["gender"] ?? gender;
  }
}
