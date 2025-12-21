import 'dart:io';
import 'dart:typed_data';
import 'package:NagaratharEvents/actionButton.dart';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/imageInfo.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'utils.dart' as utils;

class imageLoader extends StatefulWidget {
  final imageInfo? givenImage;
  final String? uploadRouteRoute;
  final String? deleteRoute;
  final Function(File)? onUpload;
  final Function()? onDelete;
  final bool circle;
  final bool dontReplace;
  final double? size;
  final double? buttonSize;
  final bool showAboveSnackBar;
  final bool shouldExpand;

  const imageLoader({
    super.key,
    this.buttonSize,
    this.dontReplace = false,
    this.deleteRoute,
    this.uploadRouteRoute,
    this.onDelete,
    this.onUpload,
    this.shouldExpand = true,
    this.circle = false,
    this.showAboveSnackBar = false,
    this.size,
    this.givenImage,
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
    if (oldWidget.givenImage != widget.givenImage) _loadImage();
  }

  Future<void> _loadImage() async {
    if (widget.givenImage == null) return _setPlaceholderImage();
    final id = widget.givenImage!.id;
    final route = widget.givenImage!.url;

    if (_isNetworkRoute(route)) {
      await _loadNetworkImage(route,id);
    } else {
      _setImage(FileImage(File(route)), false);
    }
  }

  bool _isNetworkRoute(String route) => 
      route.startsWith('https');

  Future<void> _loadNetworkImage(String route, String id) async {
    if (_imageCache.containsKey(id)) {
      return _setImage(MemoryImage(_imageCache[id]!), false);
    }

    try {
      final data = await NetworkService().getImage(route, id);
      if (data != null) {
        _imageCache[id] = data;
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

    Response<dynamic> response = await NetworkService().getRoute(widget.uploadRouteRoute!, true);
    String uploadRoute = response.data["url"];
    String name = response.data["name"];

    response = await NetworkService().uploadFile(
      File(pickedFile.path),
      uploadRoute,
      context,
      showAboveSnackBar: widget.showAboveSnackBar,
    );

    setState(() => _isUploading = false);

    if (response.statusCode == 200) {
      _handleUploadSuccess(File(pickedFile.path));
      response = await NetworkService().postRoute(
        {"name": name},
        widget.uploadRouteRoute!,
      );
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
      _imageCache.remove(widget.givenImage);
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
        _imageCache.remove(widget.givenImage);
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
          if (widget.uploadRouteRoute != null && !_isUploading) _buildButton(
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