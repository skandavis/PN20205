import 'dart:io';
import 'dart:typed_data';

import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/networkService.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'utils.dart' as utils;

class imageLoader extends StatefulWidget {
  final String? imageRoute;
  final String? uploadRoute;
  final String? deleteRoute;
  final Function(File)? onUpload;
  final Function()? onDelete;
  final bool circle;
  final bool dontReplace;
  final double? size;
  final double buttonSize;
  final bool showAboveSnackBar;
  final bool shouldExpand;
  const imageLoader({
    super.key,
    this.imageRoute,
    required this.buttonSize,
    this.dontReplace = false,
    this.deleteRoute,
    this.uploadRoute,
    this.onDelete,
    this.onUpload,
    this.shouldExpand = true,
    this.circle = false,
    this.showAboveSnackBar = false,
    this.size,
  });

  @override
  State<imageLoader> createState() => _imageLoaderState();
}

class _imageLoaderState extends State<imageLoader> {
  static const BoxFit boxFit = BoxFit.cover;
  bool _isUploading = false;
  bool noImage = false;
  Widget? _imageWidget;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  // MARK: - Image Loading
  Future<void> _loadImage() async {
    if (_imageWidget != null) return;

    final route = widget.imageRoute;
    if (route == null) {
      _setPlaceholderImage();
      return;
    }

    if (_isNetworkRoute(route)) {
      await _loadNetworkImage(route);
    } else {
      _setLocalImage(route);
    }
  }

  bool _isNetworkRoute(String route) =>
      route.startsWith('api') || route.startsWith('img');

  Future<void> _loadNetworkImage(String route) async {
    try {
      final data = await NetworkService().getImage(route);
      if (!mounted) return;

      if (data != null) {
        _setMemoryImage(data);
      } else {
        _setPlaceholderImage();
      }
    } catch (e) {
      if (!mounted) return;
      _setPlaceholderImage();
    }
  }

  void _setMemoryImage(List<int> data) {
    setState(() {
      _imageWidget = Image.memory(Uint8List.fromList(data), fit: boxFit);
      noImage = false;
    });
  }

  void _setLocalImage(String path) {
    setState(() {
      _imageWidget = Image.file(File(path), fit: boxFit);
      noImage = false;
    });
  }

  void _setPlaceholderImage() {
    setState(() {
      _imageWidget = _buildPlaceholderWidget();
      noImage = true;
    });
  }

  Widget _buildPlaceholderWidget() {
    final asset = widget.circle 
        ? 'assets/genericAccount.png' 
        : 'assets/genericPhoto.png';
    return Image.asset(asset, fit: boxFit);
  }

  // MARK: - Image Upload
  Future<void> _pickAndUploadImage(ImageSource source) async {
    final imageFile = await _pickImage(source);
    if (imageFile == null) return;

    await _uploadImage(imageFile);
  }

  Future<bool> _handlePermissions() async {
    var status = await Permission.photos.status;

    if (status.isDenied) {
      status = await Permission.photos.request();
    }
  if (status.isDenied||status.isPermanentlyDenied) {
      utils.showPermissionsDialog("Photo permission is required to upload images.");
      return false;
    }

    return true;
  }

  Future<File?> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );

    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() => _isUploading = true);
    final response = await NetworkService().uploadFile(
      await MultipartFile.fromFile(imageFile.path),
      widget.uploadRoute!,
      'profile.jpg',
      context,
      showAboveSnackBar: widget.showAboveSnackBar
    );

    if (response.statusCode == 200) {
      _handleUploadSuccess(imageFile);
    }
  
    setState(() => _isUploading = false);
  }

  void _handleUploadSuccess(File imageFile) {
    if (!widget.dontReplace) {
      setState(() {
        _imageWidget = Image.file(imageFile, fit: boxFit);
        noImage = false;
      });
    }
    widget.onUpload?.call(imageFile);
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

  // MARK: - Image Deletion
  Future<void> deleteImage() async {
    setState(() {
      _isUploading = true;
    });
    final response = await NetworkService().deleteRoute(
      widget.deleteRoute!, 
      showAboveSnackBar: widget.showAboveSnackBar
    );
    if (response.statusCode == 200) {
      _handleDeleteSuccess();
    }
    setState(() {
      _isUploading = false;
    });
  }
  
  void _handleDeleteSuccess() {
    if (!widget.dontReplace) {
      _setPlaceholderImage();
      if(widget.showAboveSnackBar)
      {
        utils.snackBarAboveMessage('Image deleted successfully', color: Colors.green);
      }else{
        utils.snackBarMessage('Image deleted successfully', color: Colors.green);
      }
    }
    widget.onDelete?.call();
  }

  // MARK: - Build Methods
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImageContent(),
          if (_isUploading) _buildLoadingOverlay(),
          if (widget.uploadRoute != null && !_isUploading) _buildUploadButton(),
          if (widget.deleteRoute != null && !noImage && !_isUploading) _buildDeleteButton(),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (_imageWidget == null) {
      return const Center(child: CircularProgressIndicator());
    }
    Widget displayedWidget = widget.circle ? ClipOval(child: _imageWidget!) : _imageWidget!;
    return (widget.shouldExpand && !_isUploading && !noImage) ? GestureDetector(
      onTap: () {
        showDialog(context: context, builder: (context) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: _imageWidget!
          );
        },);
      },
      child : displayedWidget,
    ) : displayedWidget;
  }

  Widget _buildLoadingOverlay() {
    return Container(
      decoration: BoxDecoration(
        shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
        color: Colors.black.withOpacity(0.5),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: _buildActionButton(
        onTap: () async{
          bool granted = await _handlePermissions();
          if (!granted) return;
          _showImageSourceDialog();
        },
        color: globals.secondaryColor,
        icon: Icons.add,
        iconColor: globals.backgroundColor,
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: _buildActionButton(
        onTap: deleteImage,
        color: Colors.red,
        icon: Icons.close,
        iconColor: Colors.white,
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required Color color,
    required IconData icon,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: widget.buttonSize,
        width: widget.buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}