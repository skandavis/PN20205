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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.size.toDouble(),
      width: widget.size.toDouble(),
      child: imageLoader(imageRoute: widget.imageUrl, uploadRoute: widget.uploadRoute, onUpload: widget.onImageChanged,shape: BoxShape.circle,)
    );
  }
}
