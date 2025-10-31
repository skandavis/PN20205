import 'dart:typed_data';
import 'package:PN2025/networkService.dart';
import 'package:flutter/material.dart';
import 'package:PN2025/globals.dart' as globals;

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  int? length;
  ImageCarousel({super.key, required this.imageUrls, this.length});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  List<Uint8List?>? images;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    debugPrint("length:${widget.imageUrls.length}");
    if(images == null)
    {
      images = List<Uint8List?>.filled(widget.imageUrls.length, null);
      loadImage(0); 
    }
  }

  Future<void> loadImage(int index) async {
    try {
      final img = await NetworkService().getImage(widget.imageUrls[index]);
      if(img == null) return;
      setState(() {
        images![index] = img;
      });
    } catch (e) {
      debugPrint("Failed to load image at index $index: $e");
    }
    if (currentIndex+1 < widget.imageUrls.length && images![currentIndex+1] == null) {
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
              if (image!=null) {
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
