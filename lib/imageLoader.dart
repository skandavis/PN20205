import 'dart:io';
import 'dart:typed_data';
import 'package:NagaratharEvents/actionButton.dart';
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
  final double? buttonSize;
  final bool showAboveSnackBar;
  final bool shouldExpand;
  final String? fileName;

  const imageLoader({
    super.key,
    this.imageRoute,
    this.fileName,
    this.buttonSize,
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
  static final Map<String, Uint8List> _imageCache = {};

  bool _isUploading = false;
  bool _noImage = false;
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(imageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageRoute != widget.imageRoute) _loadImage();
  }

  Future<void> _loadImage() async {
    final route = widget.imageRoute;
    if (route == null) return _setPlaceholderImage();

    if (_isNetworkRoute(route)) {
      await _loadNetworkImage(route);
    } else {
      _setImage(FileImage(File(route)), false);
    }
  }

  bool _isNetworkRoute(String route) => 
      route.startsWith('api') || route.startsWith('img');

  Future<void> _loadNetworkImage(String route) async {
    if (_imageCache.containsKey(route)) {
      return _setImage(MemoryImage(_imageCache[route]!), false);
    }

    try {
      final data = await NetworkService().getImage(route);
      if (data != null) {
        _imageCache[route] = data;
        _setImage(MemoryImage(data), false);
      } else {
        _setPlaceholderImage();
      }
    } catch (e) {
      _setPlaceholderImage();
    }
  }

  void _setImage(ImageProvider provider, bool isPlaceholder) {
    if (!mounted) return;
    setState(() {
      _imageProvider = provider;
      _noImage = isPlaceholder;
    });
  }

  void _setPlaceholderImage() {
    final asset = widget.circle ? 'assets/genericAccount.png' : 'assets/genericPhoto.png';
    _setImage(AssetImage(asset), true);
  }

  Future<void> _pickAndUploadImage() async {
    if (!await _requestPermissions()) return;

    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    final response = await NetworkService().uploadFile(
      await MultipartFile.fromFile(pickedFile.path),
      widget.uploadRoute!,
      widget.fileName ?? "Profile.jpg",
      context,
      showAboveSnackBar: widget.showAboveSnackBar,
    );

    setState(() => _isUploading = false);

    if (response.statusCode == 200) {
      _handleUploadSuccess(File(pickedFile.path));
    } else if (response.statusCode == 500) {
      _showSnackBar("You are not connected to the internet");
    }
  }

  Future<bool> _requestPermissions() async {
    var status = await Permission.photos.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      utils.showPermissionsDialog("Photo permission is required to upload images.");
      return false;
    }
    return true;
  }

  void _handleUploadSuccess(File imageFile) {
    if (!widget.dontReplace) {
      _imageCache.remove(widget.imageRoute);
      _setImage(FileImage(imageFile), false);
    }
    widget.onUpload?.call(imageFile);
  }

  Future<void> _deleteImage() async {
    setState(() => _isUploading = true);

    final response = await NetworkService().deleteRoute(
      widget.deleteRoute!,
      showAboveSnackBar: widget.showAboveSnackBar,
    );

    setState(() => _isUploading = false);

    if (response.statusCode == 200) {
      if (!widget.dontReplace) {
        _imageCache.remove(widget.imageRoute);
        _setPlaceholderImage();
        _showSnackBar('Image deleted successfully', Colors.green);
      }
      widget.onDelete?.call();
    }
  }

  void _showSnackBar(String message, [Color? color]) {
    final showFn = widget.showAboveSnackBar ? utils.snackBarAboveMessage : utils.snackBarMessage;
    showFn(message, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(),
          if (_isUploading) _buildLoadingOverlay(),
          if (widget.uploadRoute != null && !_isUploading) _buildButton(
            Alignment.bottomRight,
            globals.secondaryColor,
            Icons.add,
            globals.backgroundColor,
            _pickAndUploadImage,
          ),
          if (widget.deleteRoute != null && !_noImage && !_isUploading) _buildButton(
            Alignment.topLeft,
            Colors.red,
            Icons.close,
            Colors.white,
            _deleteImage,
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (_imageProvider == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    final imageWidget = Image(
      image: _imageProvider!,
      fit: BoxFit.cover,
    );
    final displayWidget = widget.circle ? ClipOval(child: imageWidget) : imageWidget;

    return (widget.shouldExpand && !_isUploading && !_noImage)
      ? GestureDetector(
          onTap: () => _showFullscreenImage(),
          child: displayWidget,
        )
      : displayWidget;
  }

  Widget _buildLoadingOverlay() {
    return Container(
      decoration: BoxDecoration(
        shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
        color: Colors.black45,
      ),
      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildButton(Alignment alignment, Color color, IconData icon, Color iconColor, VoidCallback onTap) {
    return Align(
      alignment: alignment,
      child: actionButton(
        onTap: onTap,
        color: color,
        buttonSize: widget.buttonSize,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  void _showFullscreenImage() {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Image(image: _imageProvider!, fit: BoxFit.contain),
        ),
      ),
    );
  }
}