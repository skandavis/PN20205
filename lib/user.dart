class User {
  // Singleton instance
  static final User instance = User._internal();

  // Private constructor
  User._internal();

  // Properties
  String id = '';
  String role = '';
  bool firstTime = true;
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
    // firstTime = json['isFirstTime'];
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
  // Display details
  void displayUserDetails() {
    print('User Details:');
    print('ID: $id');
    print('Role: $role');
    print('Is firstTime: ${firstTime ? "Yes" : "No"}');
    print(primaryUser == null
        ? 'Is Primary User'
        : "Primary User's ID is: ${primaryUser!}");
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'firstTime': firstTime,
      'primaryUserId': primaryUser,
    };
  }

  bool isPrimaryUser() {
    return primaryUser == null;
  }

  bool isAdmin() {
    return role != "User";
  }
}
