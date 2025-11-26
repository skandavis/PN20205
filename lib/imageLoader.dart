import 'dart:io';
import 'dart:typed_data';

import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/networkService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class imageLoader extends StatefulWidget {
  final String? imageRoute;
  final String? uploadRoute;
  final ValueChanged<File>? onUpload;
  final BoxShape shape;
  final double? width;
  final double? height;
  final BoxFit fit;

  const imageLoader({
    super.key,
    this.imageRoute,
    this.uploadRoute,
    this.onUpload,
    this.shape = BoxShape.rectangle,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<imageLoader> createState() => _imageLoaderState();
}

class _imageLoaderState extends State<imageLoader> {
  bool _isUploading = false;
  Widget _imageWidget = const Center(child: CircularProgressIndicator());

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(imageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageRoute != widget.imageRoute) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.imageRoute == null) {
      setState(() {
        _imageWidget = Image.asset('assets/genericAccount.png', fit: widget.fit);
      });
      return;
    }

    setState(() {
      _imageWidget = const Center(child: CircularProgressIndicator());
    });

    if (widget.imageRoute!.contains("/private/var/mobile/Containers/Data/Application/")) {
      setState(() {
        _imageWidget = Image.file(File(widget.imageRoute!), fit: widget.fit);
      });
    } else {
      try {
        final data = await NetworkService().getImage(widget.imageRoute!);
        if (data != null) {
          setState(() {
            _imageWidget = Image.memory(Uint8List.fromList(data), fit: widget.fit);
          });
        } else {
          setState(() {
            _imageWidget = Image.asset('assets/genericAccount.png', fit: widget.fit);
          });
        }
      } catch (e) {
        debugPrint('Error loading image: $e');
        setState(() {
          _imageWidget = Image.asset('assets/genericAccount.png', fit: widget.fit);
        });
      }
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);
      setState(() => _isUploading = true);

      final response = await NetworkService().uploadFile(imageFile, widget.uploadRoute!, 'profile.jpg', context);
      if(response.statusCode != 200) {
        setState(() => _isUploading = false);
        return;
      }
      widget.onUpload?.call(imageFile);
    } catch (e) {
      debugPrint('Error uploading image: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.shape == BoxShape.circle)
            ClipOval(child: _imageWidget)
          else
            _imageWidget,
          if (widget.uploadRoute != null)
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: globals.secondaryColor,
                    ),
                    child: Icon(Icons.add, color: globals.backgroundColor, size: 24),
                  ),
                ),
              ),
            ),
          if (_isUploading)
            Container(
              decoration: BoxDecoration(
                shape: widget.shape,
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}