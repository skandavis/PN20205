import 'package:NagaratharEvents/imageLoader.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

class ImageCarousel extends StatefulWidget {
  String? uploadPath;
  final List<String> imageUrls;
  ImageCarousel({super.key, required this.imageUrls, this.uploadPath});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int currentIndex = 0;
  late List<Widget> _imageLoaders;

  @override
  void initState() {
    super.initState();
    _initializeImageLoaders();
  }

  void _initializeImageLoaders() {
    _imageLoaders = widget.imageUrls.map((imageUrl) {
      return imageLoader(
        imageRoute: imageUrl,
        uploadRoute: widget.uploadPath,
        onImageChanged: (image) {
          widget.imageUrls.add(image.path);
        },
      );
    }).toList();
  }

  @override
  void didUpdateWidget(ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize if the imageUrls list changes
    if (oldWidget.imageUrls != widget.imageUrls) {
      _initializeImageLoaders();
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
                itemCount: _imageLoaders.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _imageLoaders[index];
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _imageLoaders.asMap().entries.map((entry) {
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