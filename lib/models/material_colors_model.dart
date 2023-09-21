import 'package:flutter/material.dart';
import 'package:material_color_utilities/palettes/core_palette.dart';

class MaterialColors {
  static Color seedColor = const Color(0xFF64FFDA);

  static Color getSurface(bool darkMode) {
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 6 : 96));
  }

  static Color getSurfaceDim(bool darkMode) {
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 6 : 87));
  }

  static Color getSurfaceBright(bool darkMode) {
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 24 : 98));
  }

  static Color getSurfaceContainerLowest(bool darkMode) {
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 4 : 100));
  }

  static Color getSurfaceContainerLow(bool darkMode) {
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 10 : 95));
  }

  static Color getSurfaceContainer(bool darkMode) {
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 12 : 92));
  }

  static Color getSurfaceContainerHigh(bool darkMode) {
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 17 : 90));
  }

  static Color getSurfaceContainerHighest(bool darkMode) {
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 22 : 87));
  }
}
