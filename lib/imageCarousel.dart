import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pn2025/globals.dart' as globals;

class ImageCarousel extends StatefulWidget {
  List<Uint8List>? images;
  List<String>? assetLocations;
  ImageCarousel({super.key, this.images, this.assetLocations});
  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int currentIndex = 0;
  int length = 0;
  @override
  Widget build(BuildContext context) {
    if (widget.images != null) {
      length = widget.images!.length;
    } else {
      length = widget.assetLocations!.length;
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * .5,
          child: PageView.builder(
            itemCount: length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              if (widget.assetLocations == null) {
                return Image.memory(
                  widget.images![index],
                  fit: BoxFit.cover,
                );
              } else {
                return Image.asset(
                  widget.assetLocations![index],
                  fit: BoxFit.cover,
                );
              }
            },
          ),
        ),
        if (widget.images != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.images!.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => {},
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .05,
                      horizontal: 5.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == entry.key
                        ? globals.secondaryColor
                        : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
        if (widget.images == null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.assetLocations!.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => {},
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .05,
                      horizontal: 5.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == entry.key
                        ? globals.secondaryColor
                        : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
