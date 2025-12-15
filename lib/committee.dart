class committee {
  String id;
  String name;

  committee({
    required this.id,
    required this.name,
  });

  factory committee.fromJson(Map<String, dynamic> json) {
    return committee(
      id: json['id'],
      name: json['name'],
    );
  }
}
