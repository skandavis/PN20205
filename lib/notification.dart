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

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      message: json['message'],
      type: json['type'],
      creatorName: json['createdBy']['name'],
      creationTime: DateTime.parse(json['createdAt']).toLocal()
    );
  }
}
