import 'package:flutter/material.dart';

const Color pinkColor = Color(0xFFFFDDD3);
const Color skyBlue = Color(0x009acde0);
const Color lightBlueColor = Color(0xFFCBE1EF);

CustomColors lightCustomColors = const CustomColors(
    pinkColor: pinkColor, skyBlue: skyBlue, lightBlueColor: lightBlueColor);

CustomColors darkCustomColors = const CustomColors(
    pinkColor: pinkColor, skyBlue: skyBlue, lightBlueColor: lightBlueColor);

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors(
      {required this.pinkColor,
      required this.skyBlue,
      required this.lightBlueColor});
  final Color? pinkColor;
  final Color? skyBlue;
  final Color? lightBlueColor;

  @override
  CustomColors copyWith({
    Color? pinkColor,
    Color? skyBlue,
    Color? lightBlueColor,
  }) {
    return CustomColors(
        pinkColor: pinkColor ?? this.pinkColor,
        skyBlue: skyBlue ?? this.skyBlue,
        lightBlueColor: lightBlueColor ?? this.lightBlueColor);
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
        pinkColor: Color.lerp(pinkColor, other.pinkColor, t),
        skyBlue: Color.lerp(skyBlue, other.skyBlue, t),
        lightBlueColor: Color.lerp(lightBlueColor, other.lightBlueColor, t));
  }

  CustomColors harmonized(ColorScheme dynamic) {
    return copyWith();
  }
}
