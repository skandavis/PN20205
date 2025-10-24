import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:PN2025/globals.dart' as globals;
import 'package:PN2025/utils.dart' as utils;

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  int? length;
  ImageCarousel({super.key, required this.imageUrls, this.length});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  List<Uint8List>? images;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    debugPrint("length:${widget.imageUrls.length}");
    if(images == null)
    {
      images = List<Uint8List>.filled(widget.imageUrls.length, Uint8List(0));
      loadImage(0); 
    }
  }

  Future<void> loadImage(int index) async {
    if (images![index].isEmpty) {
      try {
        final img = await utils.getImage(widget.imageUrls[index]);
        setState(() {
          images![index] = img;
        });
      } catch (e) {
        debugPrint("Failed to load image at index $index: $e");
      }
    }
    if (currentIndex+1 < widget.imageUrls.length && images![currentIndex+1].isEmpty) {
      debugPrint("prefetching ${currentIndex + 1}");
      loadImage(currentIndex + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: PageView.builder(
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
              loadImage(index);
            },
            itemBuilder: (context, index) {
              final image = images![index];
              if (image.isNotEmpty) {
                return Image.memory(image, fit: BoxFit.cover);
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imageUrls.asMap().entries.map((entry) {
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
