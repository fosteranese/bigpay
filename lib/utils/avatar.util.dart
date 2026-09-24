import 'dart:convert';

import 'package:flutter/widgets.dart';

/// Decodes a base64 profile-picture string into an [ImageProvider], or null
/// when it's empty or not valid base64 — so callers fall back to a placeholder
/// instead of crashing on `MemoryImage(base64Decode(''))`.
ImageProvider? avatarFromBase64(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return MemoryImage(base64Decode(raw));
  } catch (_) {
    return null;
  }
}
