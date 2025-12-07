class Notification {
  String id;
  String message;
  String type;
  String creatorName;
  DateTime creationTime;

  Notification({
    required this.id,
    required this.message,
    required this.type,
    required this.creatorName,
    required this.creationTime,

  });

  // Factory constructor to create Notification from a JSON map
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      message: json['message'],
      type: json['type'],
      creatorName: json['createdBy']['name'],
      creationTime: DateTime.parse(json['createdAt']).toLocal()
    );
  }

  // Method to convert Notification to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'type': type,
      'createdBy': {'name': creatorName},
      'createdAt': creationTime
    };
  }
}
