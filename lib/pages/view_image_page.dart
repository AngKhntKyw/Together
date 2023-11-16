import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewImagePage extends StatefulWidget {
  final String imgUrl;
  const ViewImagePage({
    super.key,
    required this.imgUrl,
  });

  @override
  State<ViewImagePage> createState() => _ViewImagePageState();
}

class _ViewImagePageState extends State<ViewImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Center(
          child: Hero(
            tag: widget.imgUrl,
            child: PhotoView(
              onTapDown: (context, details, controllerValue) {
                log(controllerValue.position.toString());
              },
              onScaleEnd: (context, details, controllerValue) {
                controllerValue.position == const Offset(0.0, 0.0)
                    ? Navigator.pop(context)
                    : null;
              },
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered,
              loadingBuilder: (context, event) {
                return const CircularProgressIndicator();
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error);
              },
              enablePanAlways: false,
              gaplessPlayback: true,
              enableRotation: false,
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
              // imageProvider: NetworkImage(widget.imgUrl),
              imageProvider: CachedNetworkImageProvider(widget.imgUrl),
            ),
          ),
        ),
      ),
    );
  }
}
