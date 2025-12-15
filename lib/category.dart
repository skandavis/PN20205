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

  factory ActivityCategory.fromJson(Map<String, dynamic> json) {
    return ActivityCategory(
      name: json['main'],
      photoUrl: json["photoUrl"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': name,
      'photoUrl': photoUrl
    };
  }
}
