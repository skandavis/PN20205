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

  void displayNotificationDetails() {
    print('Notification Details:');
    print('ID: $id');
    print('Message: $message');
    print('Is A Push Notification: ${type=='P' ? "Yes" : "No"}');
    print('Created By: $creatorName');
    print('Created At: $creationTime');
  }

  // Factory constructor to create Notification from a JSON map
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      message: json['message'],
      type: json['type'],
      creatorName: json['createdBy']['name'],
      creationTime: DateTime.parse(json['createdAt'])
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
