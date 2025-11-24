import 'package:PN2025/networkService.dart';
import 'package:PN2025/profileImageCircle.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:PN2025/globals.dart' as globals;

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
  File? _profileImage;
  final bool? expandable;
  final String? photoRoute;
  final int size;
  final String uploadRoute;
  Function(File)? onImageChanged;
  accountProfile({
    super.key, 
    this.onImageChanged,
    this.expandable,
    required this.size,
    required this.photoRoute, 
    required this.uploadRoute
  });

  @override
  State<accountProfile> createState() => _accountProfileState();
}

class _accountProfileState extends State<accountProfile> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> saveProfileImage() async {
    NetworkService().uploadFile(widget._profileImage!, widget.uploadRoute, 'profile.jpg');
    if (widget.onImageChanged == null) return;
    widget.onImageChanged!(widget._profileImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        widget._profileImage != null ? 
        profileImageCircle(imageFile: widget._profileImage, size: widget.size, expandable: widget.expandable ?? true,) : 
        profileImageCircle(imageUrl: widget.photoRoute, size: widget.size, expandable: widget.expandable ?? true,),
        GestureDetector(
          onTap: () {
            showImageSourceDialog(context).then((file) {
              if (file == null) return;
              setState(() {
                widget._profileImage = file;                
              });
              saveProfileImage();
            });
          },
          child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white), child: Icon(Icons.add,color: globals.accentColor,size: 32,))
        ),
      ],
    );
  }
}
