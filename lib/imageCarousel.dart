import 'package:NagaratharEvents/imageInfo.dart';
import 'package:NagaratharEvents/imageLoader.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

class imageCarousel extends StatefulWidget {
  String? uploadPath;
  String? fileName;
  List<imageInfo> imageUrls;
  imageCarousel({super.key, required this.imageUrls, this.uploadPath, this.fileName});

  @override
  _imageCarouselState createState() => _imageCarouselState();
}

class _imageCarouselState extends State<imageCarousel> {
  int currentIndex = 0;
  late List<imageLoader> _imageLoaders;

  @override
  void initState() {
    super.initState();
    _initializeImageLoaders();
  }

  @override
  void didUpdateWidget (oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrls.length != _imageLoaders.length)
    {
      _initializeImageLoaders();
    } 
    for (int i = 0; i < widget.imageUrls.length; i++) {
      if (widget.imageUrls[i] != _imageLoaders[i].givenImage)
      {
        _initializeImageLoaders();
      }
    }
  }

  void _initializeImageLoaders() {
    _imageLoaders = widget.imageUrls.map((imageUrl) {
      return imageLoader(
        buttonSize: 45,
        key: ValueKey(imageUrl),
        dontReplace: true,
        shouldExpand: false,
        givenImage: imageUrl,
        uploadRouteRoute: widget.uploadPath,
        onUpload: (image) {
          setState(() {
            if(widget.imageUrls[0].id.startsWith('Category_')|| widget.imageUrls.length >= 3)
            {
              widget.imageUrls.removeAt(0);
            }
            widget.imageUrls.add(imageInfo(id: 'local', url: image.path));
            _initializeImageLoaders();
          });
        },
      );
    }).toList();
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