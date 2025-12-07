
class Participant {
  String id;
  String name;
  int age;
  String state;
  String city;
  String gender;
  String description;
  String? image;

  Participant({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.city,
    required this.state,
    required this.description,
    this.image,
  });

 @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Participant && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  // Factory constructor to create Participant from a JSON map
  factory Participant.fromJson(Map<String, dynamic> json) {
    
    return Participant(
      id: json['id'],
      name: json['name'],
      description: json['about'],
      age: json["age"],
      state: json["state"],
      city: json["city"],
      gender: json["gender"],
      image: json["photo"] == null ? null :json["photo"]["url"].substring(1) 
    );
  }

  void updateInfo(Map<String, dynamic> json)
  {
    name = json['name'];
    description = json['about'];
    age = json["age"];
    city = json["city"];
    gender = json["gender"];
  }
}
