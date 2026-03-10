import 'package:flutter/material.dart';

/// Returns a contrasting color (black or white) for a given background color based on luminance.
/// Uses a slightly higher threshold for better readability on vibrant colors.
Color getContrastColor(Color backgroundColor) {
  return backgroundColor.computeLuminance() > 0.45
      ? Colors.black
      : Colors.white;
}
