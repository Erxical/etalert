import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF5EA9BE);
const Color secondaryColor = Color(0xFFF3BFB3);
const Color whiteColor = Color(0xFFFFFFFF);
const Color textColor = Color(0xFF322C2C);
const Color pinkColor = Color(0xFFFFDDD3);
const Color skyBlue = Color(0x009acde0);
const Color lightBlueColor = Color(0xFFCBE1EF);

const ColorScheme lightColorScheme = ColorScheme(
  primary: primaryColor,
  secondary: secondaryColor,
  background: whiteColor,
  surface: whiteColor,
  error: Colors.red,
  onPrimary: whiteColor,
  onSecondary: textColor,
  onBackground: textColor,
  onSurface: textColor,
  onError: whiteColor,
  brightness: Brightness.light,
  secondaryContainer: pinkColor,
  primaryContainer: lightBlueColor,
  tertiary: skyBlue,
);

const ColorScheme darkColorScheme = ColorScheme(
  primary: primaryColor,
  secondary: secondaryColor,
  background: textColor,
  surface: textColor,
  error: Colors.red,
  onPrimary: textColor,
  onSecondary: whiteColor,
  onBackground: whiteColor,
  onSurface: whiteColor,
  onError: textColor,
  brightness: Brightness.dark,
  secondaryContainer: pinkColor,
  primaryContainer: lightBlueColor,
  tertiary: skyBlue,
);
