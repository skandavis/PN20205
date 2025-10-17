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
  }

  // Factory constructor to create Activity from a JSON map
  factory Activity.fromJson(Map<String, dynamic> json) {
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
      liked: json["likes"]
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
      'likes': liked 
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
