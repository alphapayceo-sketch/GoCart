import 'package:flutter/material.dart';
import 'package:shop/theme/button_theme.dart';
import 'package:shop/theme/input_decoration_theme.dart';

import '../constants.dart';
import 'checkbox_themedata.dart';
import 'theme_data.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: "Plus Jakarta",
      primarySwatch: primaryMaterialColor,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: blackColor),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: blackColor40),
      ),
      elevatedButtonTheme: elevatedButtonThemeData,
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(),
      inputDecorationTheme: lightInputDecorationTheme,
      checkboxTheme: checkboxThemeData.copyWith(
        side: const BorderSide(color: blackColor40),
      ),
      appBarTheme: appBarLightTheme,
      scrollbarTheme: scrollbarThemeData,
      dataTableTheme: dataTableLightThemeData,
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    final base = ThemeData.dark();
    return base.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF0B0B11),
      canvasColor: const Color(0xFF101015),
      cardColor: const Color(0xFF121217),
      iconTheme: const IconThemeData(color: Colors.white),
      textTheme: base.textTheme.copyWith(
        bodyMedium: const TextStyle(color: Colors.white70),
        bodyLarge: const TextStyle(color: Colors.white70),
        titleSmall: const TextStyle(color: Colors.white70),
        titleMedium: const TextStyle(color: Colors.white70),
      ),
      elevatedButtonTheme: elevatedButtonThemeData,
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(),
      inputDecorationTheme: darkInputDecorationTheme,
      checkboxTheme: checkboxThemeData.copyWith(
        side: const BorderSide(color: whileColor80),
      ),
      appBarTheme: appBarDarkTheme,
      scrollbarTheme: scrollbarThemeData,
      dataTableTheme: dataTableDarkThemeData,
      splashColor: Colors.white24,
      highlightColor: Colors.white10,
    );
  }
}
