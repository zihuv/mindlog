import 'package:flutter/material.dart';

class AppPadding {
  // Standard padding values based on 4dp grid system
  static const EdgeInsets extraSmall = EdgeInsets.all(4.0);
  static const EdgeInsets small = EdgeInsets.all(8.0);
  static const EdgeInsets medium = EdgeInsets.all(12.0);
  static const EdgeInsets large = EdgeInsets.all(16.0);
  static const EdgeInsets xLarge = EdgeInsets.all(20.0);
  static const EdgeInsets xxLarge = EdgeInsets.all(24.0);
  static const EdgeInsets xxxLarge = EdgeInsets.all(32.0);
  static const EdgeInsets huge = EdgeInsets.all(48.0);

  // Specific directional padding
  static const EdgeInsets horizontalSmall = EdgeInsets.symmetric(horizontal: 8.0);
  static const EdgeInsets horizontalMedium = EdgeInsets.symmetric(horizontal: 12.0);
  static const EdgeInsets horizontalLarge = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets verticalSmall = EdgeInsets.symmetric(vertical: 8.0);
  static const EdgeInsets verticalMedium = EdgeInsets.symmetric(vertical: 12.0);
  static const EdgeInsets verticalLarge = EdgeInsets.symmetric(vertical: 16.0);

  // Padding for different components
  static const EdgeInsets card = medium;
  static const EdgeInsets appBar = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static const EdgeInsets button = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static const EdgeInsets inputField = EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
  static const EdgeInsets dialog = large;
  static const EdgeInsets listTile = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static const EdgeInsets chip = EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0);

  // Padding for margins between elements
  static const EdgeInsets elementSpacing = small;
  static const EdgeInsets sectionSpacing = large;
  static const EdgeInsets pagePadding = large;
}