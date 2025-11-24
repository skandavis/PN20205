import 'dart:io';
import 'dart:typed_data';
import 'package:PN2025/networkService.dart';
import 'package:flutter/material.dart';
import 'package:PN2025/globals.dart' as globals;
import 'package:image_picker/image_picker.dart';

class ImageCarousel extends StatefulWidget {
  String? uploadPath;
  Function? onUpload;
  final List<String> imageUrls;
  ImageCarousel({super.key, required this.imageUrls, this.uploadPath, this.onUpload});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  List<Uint8List?> images = []; // Changed to growable list
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    ("length:${widget.imageUrls.length}");
    images = List<Uint8List?>.filled(widget.imageUrls.length, null, growable: true);
    loadImage(0);
  }

  Future<void> loadImage(int index) async {
    try {
      final img = await NetworkService().getImage(widget.imageUrls[index]);
      if (img == null) return;
      setState(() {
        images[index] = img;
      });
    } catch (e) {
      ("Failed to load image at index $index: $e");
    }
    if (currentIndex + 1 < widget.imageUrls.length &&
        images[currentIndex + 1] == null) {
      ("prefetching ${currentIndex + 1}");
      loadImage(currentIndex + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: PageView.builder(
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                  if (index < widget.imageUrls.length) {
                    loadImage(index);
                  }
                },
                itemBuilder: (context, index) {
                  final image = images[index];
                  if (image != null) {
                    return Image.memory(image, fit: BoxFit.cover);
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            if (widget.uploadPath != null && widget.onUpload != null)
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    Uint8List bytes = await pickedFile.readAsBytes();
                    setState(() {
                      images.add(bytes);
                    });
                    (pickedFile.path);
                    NetworkService().uploadFile(
                    File(pickedFile.path),
                    widget.uploadPath!,
                    'activityNewImage.jpg');
                    widget.onUpload!();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.upload, color: globals.accentColor),
                  ),
                ),
              )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: images.asMap().entries.map((entry) {
            return Container(
              width: 12.0,
              height: 12.0,
              margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.05,
                  horizontal: 5.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == entry.key
                    ? globals.secondaryColor
                    : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}