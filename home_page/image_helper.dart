// Flutter UI package import
import 'package:flutter/material.dart';

/// =====================================
/// PROFILE IMAGE HELPER FUNCTION
/// =====================================

/// এই function এর কাজ:
/// profile image asset নাকি network image
/// সেটা check করে proper image return করা

ImageProvider? getProfileImage(String? imagePath) {

  /// =====================================
  /// NULL OR EMPTY CHECK
  /// =====================================

  // যদি imagePath null হয়
  // অথবা empty string হয়
  // তাহলে null return করবে
  // মানে কোন image নেই
  if (imagePath == null || imagePath.isEmpty) {
    return null;
  }

  /// =====================================
  /// ASSET IMAGE CHECK
  /// =====================================

  // যদি imagePath "assets/" দিয়ে শুরু হয়
  // তাহলে বুঝবে image app এর ভিতরে local asset image
  if (imagePath.startsWith('assets/')) {

    // AssetImage return করবে
    // Example:
    // assets/images/profile.png
    return AssetImage(imagePath);

  } else {

    /// =====================================
    /// NETWORK IMAGE
    /// =====================================

    // যদি asset না হয়
    // তাহলে network image ধরবে

    // Example:
    // https://.....
    return NetworkImage(imagePath);
  }
}