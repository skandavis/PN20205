class User {
  static final User instance = User._internal();

  User._internal();

  String id = '';
  String role = '';
  bool firstTime = false;
  bool isAdmin = false;
  String name = '';
  String city = '';
  String phone = '';
  String email = '';
  String? photo;
  String? primaryUser;

  void fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    primaryUser = json['primaryUserId'];
    photo = json["photo"] == null ? null : json["photo"]["url"].substring(1);
    email = json["email"];
    isAdmin = json["isAdmin"];
    firstTime = json['isFirstTime'];
    name = json['name'] ?? name;
    city = json['city'] ?? city;
    phone = json['phoneNumber'] ?? phone;
  }

  void setPersonalInfo(Map<String, dynamic> json) {
    name = json['name'];
    city = json['city'];
    phone = json['phone'];
  }
  void setEmail(String email) {
    this.email = email;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'firstTime': firstTime,
      'primaryUserId': primaryUser,
    };
  }

  void clear() {
    id = '';
    role = '';
    firstTime = false;
    isAdmin = false;
    name = '';
    city = '';
    phone = '';
    email = '';
    photo = null;
    primaryUser = null;
  }

  bool isPrimaryUser() {
    return primaryUser == null;
  }
}
