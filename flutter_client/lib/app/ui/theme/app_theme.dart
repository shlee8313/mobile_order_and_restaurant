import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue[700]!,
      primary: Colors.blue[700]!,
      secondary: Colors.blueGrey[600]!,
      surface: Colors.white,
      onSurface: Colors.blueGrey[800]!,
      // Replace 'background' with 'surface'
      // surface: Colors.blueGrey[50]!,
      // Replace 'onBackground' with 'onSurface'
      // onSurface: Colors.blueGrey[800]!,
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.blueGrey[50],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueGrey[100],
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.blueGrey[800]),
      titleTextStyle: TextStyle(
        color: Colors.blueGrey[800],
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.blue[700]),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey[800],
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        color: Colors.blueGrey[800],
        fontStyle: FontStyle.normal,
      ),
      bodyMedium: TextStyle(fontSize: 13, color: Colors.blueGrey[700]),
      bodyLarge: TextStyle(fontSize: 13, color: Colors.blueGrey[700]),
    ),
    iconTheme: IconThemeData(color: Colors.blueGrey[700]),
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue[600]!,
      primary: Colors.blue[600]!,
      secondary: Colors.blueGrey[700]!,
      surface: Colors.blueGrey[900],
      onSurface: Colors.white,
      // Use 'surface' instead of 'background'
      // surface: Colors.blueGrey[900]!,
      // Use 'onSurface' instead of 'onBackground'
      // onSurface: Colors.white,
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.blueGrey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueGrey[800],
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.blue[600]!),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 16.0,
        fontStyle: FontStyle.italic,
        color: Colors.white70,
      ),
      bodyMedium: TextStyle(fontSize: 12.0, color: Colors.white60),
    ),
  );

  static final navBarColor = Colors.blueGrey[50];
  static final navBarBorderColor = Colors.blueGrey[200];
}
