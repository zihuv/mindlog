import 'package:flutter/material.dart';

class AppBorderRadius {
  // Standard radii
  static const BorderRadius small = BorderRadius.all(Radius.circular(4.0));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius large = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius xLarge = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius xxLarge = BorderRadius.all(Radius.circular(24.0));
  static const BorderRadius full = BorderRadius.all(Radius.circular(999.0));

  // Specific radii for different components
  static const BorderRadius card = large;
  static const BorderRadius button = medium;
  static const BorderRadius inputField = medium;
  static const BorderRadius appBar = medium;
  static const BorderRadius floatingActionButton = large;
  static const BorderRadius dialog = xLarge;
  static const BorderRadius chip = full;
  
  // Circular radius
  static const Radius circular = Radius.circular(999.0);
}