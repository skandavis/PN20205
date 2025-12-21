import 'package:NagaratharEvents/category.dart';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/imageInfo.dart';
import 'package:NagaratharEvents/participant.dart';

class Activity {
  String id;
  String name;
  String description;
  String location;
  String main;
  String sub;
  int duration;
  DateTime startTime;
  String category;
  int favorites;
  int likes;
  bool favoritized;
  bool liked;
  bool isActivityAdmin;
  List<imageInfo> images;
  List<Participant> participants;

  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.duration,
    required this.main,
    required this.location,
    required this.sub,
    required this.category,
    required this.favorites,
    required this.likes,
    required this.favoritized,
    required this.liked,
    required this.images,
    required this.participants,
    required this.isActivityAdmin,
  });

 @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Activity && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  factory Activity.fromJson(Map<String, dynamic> json) {
    List<imageInfo> images = [];
    bool categoryImage = false;
    if (json["photos"] == null) {
      categoryImage = true;
      for(ActivityCategory currentCategory in globals.allCategories!)
      {
        if(currentCategory.name == json["main"])
        {
          images = [imageInfo(id: "Category_${currentCategory.id}", url: currentCategory.photoUrl)];
          break;
        }
      }
    } else{
      for (var photo in json["photos"]) {
        images.add(imageInfo.fromJson(photo)); 
      }
    }
    
    return Activity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      duration: json['duration'],
      startTime: DateTime.parse(json['startTime']).toLocal(),
      main: json['main'],
      sub: json['sub'],
      category: json["category"],
      favorites: json["favoritized"],
      likes: json["liked"],
      favoritized: json["favorite"],
      liked: json["likes"],
      images: images,
      isActivityAdmin: json["isActivityAdmin"],
      participants: (json["participants"]as List).map((item) => Participant.fromJson(item)).toList().cast<Participant>()
    );
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
