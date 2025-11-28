import 'dart:io';

import 'package:NagaratharEvents/imageLoader.dart';
import 'package:flutter/material.dart';

class profileImageCircle extends StatefulWidget {
  final bool expandable;
  final String? uploadRoute;
  Function(File)? onImageChanged;
  final String? imageUrl;
  final int size;

  profileImageCircle({
    super.key,
    this.expandable = true,
    this.uploadRoute,
    this.onImageChanged,
    required this.imageUrl,
    required this.size,
  });

  @override
  State<profileImageCircle> createState() => _profileImageCircleState();
}

class _profileImageCircleState extends State<profileImageCircle> {
  @override
  Widget build(BuildContext context) {
    return imageLoader(
      imageRoute: widget.imageUrl, 
      uploadRoute: widget.uploadRoute, 
      onUpload: widget.onImageChanged, 
      circle: true,size: widget.size.toDouble(),
    );
  }
}
