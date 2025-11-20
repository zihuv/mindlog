import 'package:flutter/material.dart';

class AppBoxShadow {
  // Light theme shadows
  static const List<BoxShadow> cardLight = [
    BoxShadow(
      color: Color(0x1F000000), // 12% opacity black
      blurRadius: 4.0,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> appBarLight = [
    BoxShadow(
      color: Color(0x14000000), // 8% opacity black
      blurRadius: 4.0,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> buttonLight = [
    BoxShadow(
      color: Color(0x1F000000), // 12% opacity black
      blurRadius: 2.0,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> dialogLight = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity black
      blurRadius: 8.0,
      offset: Offset(0, 4),
    ),
  ];

  // Dark theme shadows
  static const List<BoxShadow> cardDark = [
    BoxShadow(
      color: Color(0x14FFFFFF), // 8% opacity white
      blurRadius: 4.0,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> appBarDark = [
    BoxShadow(
      color: Color(0x0F000000), // 6% opacity black
      blurRadius: 4.0,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> buttonDark = [
    BoxShadow(
      color: Color(0x14FFFFFF), // 8% opacity white
      blurRadius: 2.0,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> dialogDark = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity black
      blurRadius: 8.0,
      offset: Offset(0, 4),
    ),
  ];

  // Default shadows (for light theme)
  static const List<BoxShadow> card = cardLight;
  static const List<BoxShadow> appBar = appBarLight;
  static const List<BoxShadow> button = buttonLight;
  static const List<BoxShadow> dialog = dialogLight;
}
