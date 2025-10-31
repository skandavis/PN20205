import 'dart:io';
import 'package:PN2025/networkService.dart';
import 'package:flutter/material.dart';

class profileImageCircle extends StatefulWidget {
  final String? imageUrl;
  final File? imageFile;
  final int size;

  const profileImageCircle({
    super.key,
    this.imageUrl,
    this.imageFile,
    required this.size,
  });

  @override
  State<profileImageCircle> createState() => _profileImageCircleState();
}

class _profileImageCircleState extends State<profileImageCircle> {
  Image image = Image.asset('assets/genericAccount.png');

  Future<void> loadImage() async {
    if (widget.imageFile != null) {
      setState(() {
        image = Image.file(widget.imageFile!, fit: BoxFit.cover);
      });
      return; // Prefer local file if present
    }

    if (widget.imageUrl == null) return;

    final img = await NetworkService().getImage(widget.imageUrl!);
    if (img == null) return;

    setState(() {
      image = Image.memory(img, fit: BoxFit.cover);
    });
  }

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  @override
  void didUpdateWidget(covariant profileImageCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageFile?.path != oldWidget.imageFile?.path ||
        widget.imageUrl != oldWidget.imageUrl) {
      loadImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.size.toDouble(),
      width: widget.size.toDouble(),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: image,
    );
  }
}
