import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'border_radius.dart';
import 'font_size.dart';
import 'font_weight.dart';
import 'padding.dart';

class AppTheme {
  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      // Primary colors
      primarySwatch: Colors.purple,
      primaryColor: AppColors.primary,
      primaryColorLight: AppColors.primaryVariant,
      primaryColorDark: AppColors.primaryVariant,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryVariant,
        onPrimaryContainer: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryVariant,
        onSecondaryContainer: AppColors.onSecondary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
        onError: AppColors.onError,
      ).copyWith(
        brightness: Brightness.light,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
      ),

      // Text theme
      textTheme: _textTheme,

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.card,
        ),
        elevation: 1.0, // Reduced for a cleaner look
        shadowColor: Colors.black12, // More subtle shadow
      ),

      // AppBar theme - Clean white background
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarText,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: AppFontSize.appBarTitle,
          fontWeight: AppFontWeight.appBarTitle,
          color: AppColors.appBarText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.appBar,
        ),
        elevation: 0, // No elevation for cleaner look
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.button,
          ),
          padding: AppPadding.button,
          textStyle: TextStyle(
            fontSize: AppFontSize.buttonLabel,
            fontWeight: AppFontWeight.buttonLabel,
          ).copyWith(color: AppColors.onPrimary),
        ),
      ),

      // Input field theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: AppPadding.inputField,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputField,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputField,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputField,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2.0,
          ),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.dialog,
        ),
        titleTextStyle: TextStyle(
          fontSize: AppFontSize.dialogTitle,
          fontWeight: AppFontWeight.dialogTitle,
          color: AppColors.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontSize: AppFontSize.dialogContent,
          fontWeight: AppFontWeight.body,
          color: AppColors.onSurface,
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.disabled,
        labelStyle: TextStyle(
          fontSize: AppFontSize.chipLabel,
          fontWeight: AppFontWeight.chipLabel,
          color: AppColors.onSurface,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: AppFontSize.chipLabel,
          fontWeight: AppFontWeight.chipLabel,
          color: AppColors.onPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.chip,
        ),
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.onSurface,
          borderRadius: AppBorderRadius.medium,
        ),
        textStyle: TextStyle(
          fontSize: AppFontSize.tooltip,
          fontWeight: AppFontWeight.tooltip,
          color: AppColors.surface,
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: AppBorderRadius.large.topLeft,
          ),
        ),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200, // Cleaner divider color
        thickness: 1.0,
        space: 16.0,
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      // Primary colors
      primarySwatch: Colors.purple,
      primaryColor: AppColors.primary,
      primaryColorLight: AppColors.primaryVariant,
      primaryColorDark: AppColors.primaryVariant,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryVariant,
        onPrimaryContainer: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryVariant,
        onSecondaryContainer: AppColors.onSecondary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        error: AppColors.error,
        onError: AppColors.onError,
      ).copyWith(
        brightness: Brightness.dark,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
      ),

      // Text theme
      textTheme: _textTheme.apply(
        bodyColor: AppColors.darkOnSurface,
        displayColor: AppColors.darkOnSurface,
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.card,
        ),
        elevation: 4.0,
        shadowColor: Colors.black38,
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: AppFontSize.appBarTitle,
          fontWeight: AppFontWeight.appBarTitle,
          color: AppColors.onPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.appBar,
        ),
        elevation: 4.0,
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.button,
          ),
          padding: AppPadding.button,
          textStyle: TextStyle(
            fontSize: AppFontSize.buttonLabel,
            fontWeight: AppFontWeight.buttonLabel,
          ).copyWith(color: AppColors.onPrimary),
        ),
      ),

      // Input field theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: AppPadding.inputField,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputField,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputField,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputField,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2.0,
          ),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.dialog,
        ),
        titleTextStyle: TextStyle(
          fontSize: AppFontSize.dialogTitle,
          fontWeight: AppFontWeight.dialogTitle,
          color: AppColors.darkOnSurface,
        ),
        contentTextStyle: TextStyle(
          fontSize: AppFontSize.dialogContent,
          fontWeight: AppFontWeight.body,
          color: AppColors.darkOnSurface,
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.disabled,
        labelStyle: TextStyle(
          fontSize: AppFontSize.chipLabel,
          fontWeight: AppFontWeight.chipLabel,
          color: AppColors.darkOnSurface,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: AppFontSize.chipLabel,
          fontWeight: AppFontWeight.chipLabel,
          color: AppColors.onPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.chip,
        ),
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkOnSurface,
          borderRadius: AppBorderRadius.medium,
        ),
        textStyle: TextStyle(
          fontSize: AppFontSize.tooltip,
          fontWeight: AppFontWeight.tooltip,
          color: AppColors.darkSurface,
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: AppBorderRadius.large.topLeft,
          ),
        ),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.darkOnSurface.withOpacity(0.12), // We'll keep this as is for now since there's no direct replacement
        thickness: 1.0,
        space: 16.0,
      ),
    );
  }

  // Text theme definition
  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: AppFontSize.display,
        fontWeight: AppFontWeight.extraBold,
        color: AppColors.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: AppFontSize.headline,
        fontWeight: AppFontWeight.bold,
        color: AppColors.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: AppFontSize.title,
        fontWeight: AppFontWeight.semiBold,
        color: AppColors.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: AppFontSize.title,
        fontWeight: AppFontWeight.semiBold,
        color: AppColors.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: AppFontSize.large,
        fontWeight: AppFontWeight.semiBold,
        color: AppColors.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: AppFontSize.large,
        fontWeight: AppFontWeight.semiBold,
        color: AppColors.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: AppFontSize.medium,
        fontWeight: AppFontWeight.medium,
        color: AppColors.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: AppFontSize.small,
        fontWeight: AppFontWeight.medium,
        color: AppColors.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: AppFontSize.body,
        fontWeight: AppFontWeight.normal,
        color: AppColors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: AppFontSize.small,
        fontWeight: AppFontWeight.normal,
        color: AppColors.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: AppFontSize.extraSmall,
        fontWeight: AppFontWeight.light,
        color: AppColors.onSurface,
      ),
      labelLarge: TextStyle(
        fontSize: AppFontSize.medium,
        fontWeight: AppFontWeight.medium,
        color: AppColors.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: AppFontSize.small,
        fontWeight: AppFontWeight.medium,
        color: AppColors.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: AppFontSize.extraSmall,
        fontWeight: AppFontWeight.medium,
        color: AppColors.onSurface,
      ),
    );
  }
}