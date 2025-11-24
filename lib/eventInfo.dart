
class EventInfo {
  static final EventInfo instance = EventInfo._internal();

  String id = "";
  String name = "";
  String city = "";
  String state = "";
  int zip = 0;
  String country = "";
  String address = "";
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String description = "";
  String mainSection = "";
  String subSection = "";
  String aside = "";
  int userCount = 0;
  bool isLoaded = false;

  EventInfo._internal();
  /// Load event info from a JSON map
  void fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    city = json["city"];
    state = json["state"];
    zip = json["zip"];
    country = json["country"];
    address = json["address"];
    startDate = DateTime.parse(json["startDate"]).toLocal();
    endDate = DateTime.parse(json["endDate"]).toLocal();
    description = json["description"];
    mainSection = json["mainSection"];
    subSection = json["subSection"];
    aside = json["aside"];
    userCount = json["_count"]["registeredUsers"];
    isLoaded = true;
  }
}
