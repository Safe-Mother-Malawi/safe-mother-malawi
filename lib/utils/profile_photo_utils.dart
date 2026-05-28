import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/api_service.dart';

ImageProvider<Object>? buildProfilePhotoProvider(String? photoUrl) {
  if (photoUrl == null || photoUrl.trim().isEmpty) return null;

  if (photoUrl.startsWith('data:')) {
    final parts = photoUrl.split(',');
    if (parts.length > 1) {
      return MemoryImage(base64Decode(parts.last));
    }
    return null;
  }

  final resolved = ApiService.resolvePhotoUrl(photoUrl);
  if (resolved == null) return null;

  return NetworkImage(resolved);
}
