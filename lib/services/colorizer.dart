import 'dart:io';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

Future<PaletteGenerator> paletteGenerator(File imageFile) async {
  final pg = await PaletteGenerator.fromImageProvider(FileImage(imageFile),

    filters: [],
  // Images are square
    size: const Size(double.infinity, 200),

  // I want the dominant color of the top left section of the image
    region: Rect.fromPoints(
      Offset.zero, // Starting point (top-left corner)
      const Offset(70, 50), // Ending point (bottom-right corner)
    ),
  );
  debugPrint("done computing");
  return pg;
}
