import 'dart:io';
import 'dart:typed_data';

import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/networkService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class imageLoader extends StatefulWidget {
  final String? imageRoute;
  final ValueChanged<File>? onImageChanged;
  final String? uploadRoute;
  final BoxShape shape;
  final double? width;
  final double? height;
  final BoxFit fit;

  const imageLoader({
    super.key,
    this.imageRoute,
    this.onImageChanged,
    this.uploadRoute,
    this.shape = BoxShape.rectangle,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<imageLoader> createState() => _imageLoaderState();
}

class _imageLoaderState extends State<imageLoader> {
  File? _localImageFile;
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void didUpdateWidget(imageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageRoute != widget.imageRoute) {
      setState(() {
        _localImageFile = null;
      });
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      
      if (pickedFile == null || !mounted) return;

      final imageFile = File(pickedFile.path);
      
      // Update UI immediately with selected image
      setState(() {
        _localImageFile = imageFile;
        _isUploading = true;
      });

      // Upload to backend
      if (widget.uploadRoute != null) {
        await NetworkService().uploadFile(
          imageFile,
          widget.uploadRoute!,
          'profile.jpg',
          context,
        );
        
        widget.onImageChanged?.call(imageFile);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (mounted) {
        setState(() {
          _localImageFile = null; // Revert on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    if (widget.uploadRoute == null) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    // Show local file if available (just uploaded)
    if (_localImageFile != null) {
      return Image.file(_localImageFile!, fit: widget.fit);
    }

    // Show network image if route provided
    if (widget.imageRoute != null) {
      return FutureBuilder<List<int>?>(
        future: NetworkService().getImage(widget.imageRoute!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Image.asset('assets/genericAccount.png', fit: widget.fit);
          }
          
          return Image.memory(Uint8List.fromList(snapshot.data!), fit: widget.fit);
        },
      );
    }

    // Default placeholder
    return Image.asset('assets/genericAccount.png', fit: widget.fit);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(shape: widget.shape),
            clipBehavior: widget.shape == BoxShape.circle 
                ? Clip.antiAlias 
                : Clip.hardEdge,
            child: _buildImage(),
          ),
          if (widget.uploadRoute != null) _buildEditButton(),
          if (_isUploading) _buildUploadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: GestureDetector(
        onTap: _showImageSourceDialog,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.edit,
            color: globals.accentColor,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildUploadingOverlay() {
    return Container(
      decoration: BoxDecoration(
        shape: widget.shape,
        color: Colors.black.withOpacity(0.5),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}