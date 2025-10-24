import 'package:PN2025/utils.dart' as utils;
import 'package:flutter/material.dart';

class profileImage extends StatefulWidget {
  String? imageUrl;
  int size;
  profileImage({super.key, required this.imageUrl, required this.size});

  @override
  State<profileImage> createState() => _profileImageState();
}

class _profileImageState extends State<profileImage> {
  Image image = Image.asset('assets/genericAccount.png');
  Future<void> loadImage() async {
    if (widget.imageUrl == null) return;
    try {
      final img = await utils.getImage(widget.imageUrl!);
      if(img.isEmpty) return;
      setState(() {
        image = Image.memory(img, fit: BoxFit.cover);
      });
    } catch (e) {
      debugPrint("Failed to load image at route $widget.imageUrl: $e");
    }
  }
  @override
  void initState() {
    loadImage();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.size.toDouble(),
      width: widget.size.toDouble(),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: image,
    );
  }
}