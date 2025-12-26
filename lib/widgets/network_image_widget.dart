import 'package:flutter/material.dart';
import 'dart:convert';

class NetworkImageWidget extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;

  const NetworkImageWidget({Key? key, this.url, this.fit = BoxFit.cover, this.width, this.height}) : super(key: key);

  bool _isNetwork(String? u) => u != null && (u.startsWith('http://') || u.startsWith('https://'));
  bool _isBase64(String? u) => u != null && u.startsWith('data:image');

  @override
  Widget build(BuildContext context) {
    // Jika base64 image (dari upload)
    if (_isBase64(url)) {
      try {
        final base64String = url!.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stack) => Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Icon(Icons.broken_image, size: (width ?? 48) / 2, color: Colors.grey[400]),
          ),
        );
      } catch (e) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Icon(Icons.broken_image, size: (width ?? 48) / 2, color: Colors.grey[400]),
        );
      }
    }
    
    // Jika network image (URL)
    if (_isNetwork(url)) {
      return Image.network(
        url!,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: width != null ? (width! * 2).toInt() : null,
        cacheHeight: height != null ? (height! * 2).toInt() : null,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stack) => Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Icon(Icons.broken_image, size: (width ?? 48) / 2, color: Colors.grey[400]),
        ),
      );
    }
    
    // Default: placeholder jika tidak ada gambar
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(Icons.image, size: (width ?? 48) / 2, color: Colors.grey[400]),
    );
  }
}
