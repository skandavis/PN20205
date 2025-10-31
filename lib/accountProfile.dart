import 'package:PN2025/networkService.dart';
import 'package:PN2025/profileImageCircle.dart';
import 'package:PN2025/user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';

final SharedPreferencesAsync prefs = SharedPreferencesAsync();

Future<File?> showImageSourceDialog(BuildContext context) async {
  final picker = ImagePicker();
  File? imageFile;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Select Image'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                imageFile = File(pickedFile.path);
              }
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a Photo'),
            onTap: () async {
              final pickedFile = await picker.pickImage(source: ImageSource.camera);
              if (pickedFile != null) {
                imageFile = File(pickedFile.path);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    ),
  );

  return imageFile;
}

class accountProfile extends StatefulWidget {
  const accountProfile({super.key});

  @override
  State<accountProfile> createState() => _accountProfileState();
}

class _accountProfileState extends State<accountProfile> {
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    loadProfileImage();
  }

  Future<void> loadProfileImage() async {
    final path = await prefs.getString("profile_image_path");
    if (path != null && File(path).existsSync()) {
      setState(() {
        _profileImage = File(path);
      });
    }
  }

  Future<void> saveProfileImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final String filename = basename(imageFile.path);
    final savedImage = await imageFile.copy('${directory.path}/$filename');
    await prefs.setString("profile_image_path", savedImage.path);
    setState(() {
      _profileImage = savedImage;
      debugPrint("Profile Image saved: ${savedImage.path}");
    });
    NetworkService().uploadFile(_profileImage!, "users/photo");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showImageSourceDialog(context).then((file) {
          if (file == null) return;
          saveProfileImage(file);
        });
      },
      child: _profileImage == null
          ? profileImageCircle(imageUrl: User.instance.photo, size: 75)
          : profileImageCircle(imageFile: _profileImage, size: 75),
    );
  }
}
