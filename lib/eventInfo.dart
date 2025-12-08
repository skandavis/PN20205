
class EventInfo {
  static final EventInfo instance = EventInfo._internal();

  String id = "";
  String name = "";
  String city = "Fort Worth";
  String state = "TX";
  int zip = 0;
  String country = "USA";
  String address = "815 Main St";
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String description = "";
  String mainSection = "";
  String subSection = "";
  String aside = "";
  int userCount = 0;
  List<String> images = [];
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

  void addImages(List<dynamic> json)
  {
    images = [];
    for (var element in json) {
      images.add(element["url"].substring(1));
    }
  }
}
