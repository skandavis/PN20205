
class EventInfo {
  static final EventInfo instance = EventInfo._internal();

  String id = 'id1';
  String name = 'Name Loading...';
  String city = 'City Loading...';
  String state = 'State Loading...';
  int zip = 0;
  String country = 'Country Loading...';
  String address = 'Address Loading...';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String description = 'Description Loading...';
  String mainSection = 'Main Section Loading...';
  String subSection = 'Sub Section Loading...';
  String aside = 'Aside Loading...';
  int userCount = 0;
  bool isLoaded = false;

  EventInfo._internal();

  /// Display event details (you can modify this as needed)
  void displayActivityDetails() {
    print('Event: $name');
    print('Location: $address, $city, $state, $zip, $country');
    print('Start Date: $startDate');
    print('End Date: $endDate');
    print('Description: $description');
    print('Main Section: $mainSection');
    print('Sub Section: $subSection');
    print('Aside: $aside');
    print('User Count: $userCount');

  }

  /// Load event info from a JSON map
  void fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    city = json["city"];
    state = json["state"];
    zip = json["zip"];
    country = json["country"];
    address = json["address"];
    startDate = DateTime.parse(json["startDate"]);
    endDate = DateTime.parse(json["endDate"]);
    description = json["description"];
    mainSection = json["mainSection"];
    subSection = json["subSection"];
    aside = json["aside"];
    userCount = json["_count"]["registeredUsers"];
    isLoaded = true;
  }

  /// Convert event info to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "city": city,
      "state": state,
      "zip": zip,
      "country": country,
      "address": address,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "description": description,
      "mainSection": mainSection,
      "subSection": subSection,
      "aside": aside,
      "_count": {"registeredUsers": userCount}
    };
  }
}
