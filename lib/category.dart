class ActivityCategory {
  String name;
  String photoUrl;


  ActivityCategory({
    required this.name,
    required this.photoUrl
  });
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityCategory && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  void displayCategoryDetails() {
    print('Category Details:');
    print('Name: $name');
    print('PhotoURL: $photoUrl');
  }

  // Factory constructor to create Category from a JSON map
  factory ActivityCategory.fromJson(Map<String, dynamic> json) {
    return ActivityCategory(
      name: json['category'],
      photoUrl: json["photoUrl"]
    );
  }

  // Method to convert Category to JSON
  Map<String, dynamic> toJson() {
    return {
      'category': name,
      'photoUrl': photoUrl
    };
  }
}
