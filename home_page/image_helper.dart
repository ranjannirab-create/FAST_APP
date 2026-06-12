import 'package:flutter/material.dart';

ImageProvider? getProfileImage(String? imagePath) {

  if (imagePath == null || imagePath.isEmpty) {
    return null;
  }

  // Asset image
  if (imagePath.startsWith('assets/')) {
    return AssetImage(imagePath);
  }

  // file:///assets/
  if (imagePath.startsWith('file:///assets/')) {

    final assetPath =
        imagePath.replaceFirst(
          'file:///',
          '',
        );

    return AssetImage(assetPath);
  }

  // Network image
  if (imagePath.startsWith('http')) {
    return NetworkImage(imagePath);
  }

  return null;
}