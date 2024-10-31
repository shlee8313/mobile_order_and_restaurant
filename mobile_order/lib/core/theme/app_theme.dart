import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.grey,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      color: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.black),
      titleLarge: TextStyle(
          fontSize: 36.0, fontStyle: FontStyle.italic, color: Colors.black),
      bodyMedium:
          TextStyle(fontSize: 14.0, fontFamily: 'Hind', color: Colors.black),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.grey, // Change button color to a gray shade
      textTheme: ButtonTextTheme.primary,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.grey,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[850], // Use a dark gray for background
    appBarTheme: AppBarTheme(
      color: Colors.grey[900], // Darker gray for AppBar
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(
          fontSize: 36.0, fontStyle: FontStyle.italic, color: Colors.white),
      bodyMedium:
          TextStyle(fontSize: 14.0, fontFamily: 'Hind', color: Colors.white),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor:
          Colors.grey[700], // Change button color to a medium gray shade
      textTheme: ButtonTextTheme.primary,
    ),
  );
}
