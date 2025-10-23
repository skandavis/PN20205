import 'package:PN2025/participant.dart';

class Activity {
  String id;
  String name;
  String description;
  String location;
  int duration;
  DateTime startTime;
  String category;
  int favorites;
  int likes;
  bool favoritized;
  bool liked;
  List<String> images;
  List<Participant> participants;

  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.duration,
    required this.location,
    required this.category,
    required this.favorites,
    required this.likes,
    required this.favoritized,
    required this.liked,
    required this.images,
    required this.participants
  });

  void displayActivityDetails() {
    print('Activity Details:');
    print('ID: $id');
    print('Name: $name');
    print('Description: $description');
    print('Location: $location');
    print('Duration: $duration minutes');
    print('Start Time: ${startTime.toLocal()}');
    print('Category: $category');
    print('Favorites: $favorites');
    print('Likes: $likes');
    print('Is Favoritized: ${favoritized ? "Yes" : "No"}');
    print('Is Liked: ${liked ? "Yes" : "No"}');
    print('Images: $images');
  }
 @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Activity && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  // Factory constructor to create Activity from a JSON map
  factory Activity.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    for (var photo in json["photos"]) {
          images.add(photo["url"].substring(1)); 
    }
    return Activity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      duration: json['duration'],
      startTime: DateTime.parse(json['startTime']),
      category: json["category"],
      favorites: json["favoritized"],
      likes: json["liked"],
      favoritized: json["favorite"],
      liked: json["likes"],
      images: images,
      participants: (json["participants"]as List).map((item) => Participant.fromJson(item)).toList().cast<Participant>()

    );
  }

  // Method to convert Activity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'duration': duration,
      'startTime': startTime.toString(),
      'category': category,
      'favoritized': favorites,
      'liked': likes,
      'favorite':favoritized,
      'likes': liked,
      'photos': {"url": images} 
    };
  }

  void toogleFavorite()
  {
    favoritized = !favoritized;
    favorites += favoritized ? 1 : -1;
  }

  void toogleLike()
  {
    liked = !liked;
    likes += liked ? 1 : -1;
  }
}
