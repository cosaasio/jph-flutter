import 'package:flutter/material.dart';
import 'ps_colors.dart';
import 'ps_config.dart';

ThemeData themeData(ThemeData baseTheme) {
  //final baseTheme = ThemeData.light();

  if (baseTheme.brightness == Brightness.dark) {
    PsColors.loadColor2(false);

    // Dark Theme
    return baseTheme.copyWith(
      primaryColor: PsColors.primary500,
      primaryColorDark: PsColors.baseColor,
      primaryColorLight: PsColors.primaryDarkWhite,
      textTheme: TextTheme(
        headline1: TextStyle(
            color: PsColors.primaryDarkWhite,
            fontFamily: PsConfig.ps_default_font_family),
        headline2: TextStyle(
            color: PsColors.primaryDarkWhite,
            fontFamily: PsConfig.ps_default_font_family),
        headline3: TextStyle(
            color: PsColors.primaryDarkWhite,
            fontFamily: PsConfig.ps_default_font_family),
        headline4: TextStyle(
          color: PsColors.primaryDarkWhite,
          fontFamily: PsConfig.ps_default_font_family,
        ),
        headline5: TextStyle(
            color: PsColors.primaryDarkWhite,
            fontFamily: PsConfig.ps_default_font_family,
            fontWeight: FontWeight.bold),
        headline6: TextStyle(
            color: PsColors.primaryDarkWhite,
            fontFamily: PsConfig.ps_default_font_family),
        subtitle1: TextStyle(
            color: PsColors.primaryDarkWhite,
            fontFamily: PsConfig.ps_default_font_family,
            fontWeight: FontWeight.bold),
        subtitle2: TextStyle(
            color: PsColors.primaryDarkWhite,
            fontFamily: PsConfig.ps_default_font_family,
            fontWeight: FontWeight.bold),
        bodyText1: TextStyle(
          color: PsColors.primaryDarkWhite,
          fontFamily: PsConfig.ps_default_font_family,
        ),
        bodyText2: TextStyle(
            color: PsColors.primaryDarkWhite,
            fontFamily: PsConfig.ps_default_font_family,
            fontWeight: FontWeight.bold),
        button: TextStyle(
            color: PsColors.primaryDarkWhite,
            fontFamily: PsConfig.ps_default_font_family),
        caption: TextStyle(
            color: PsColors.primaryDarkGrey,
            fontFamily: PsConfig.ps_default_font_family),
        overline: TextStyle(
            color: PsColors.primaryDarkWhite,
            fontFamily: PsConfig.ps_default_font_family),
      ),
      iconTheme: IconThemeData(color: PsColors.primaryDarkWhite),
      appBarTheme:
          AppBarTheme(color: PsColors.baseColor), //coreBackgroundColor),
    );
  } else {
    PsColors.loadColor2(true);
    // White Theme
    return baseTheme.copyWith(
        primaryColor: PsColors.primary500,
        primaryColorDark: PsColors.primary900,
        primaryColorLight: PsColors.primary50,
        textTheme: TextTheme(
          headline1: TextStyle(
              color: PsColors.secondary500,
              fontFamily: PsConfig.ps_default_font_family),
          headline2: TextStyle(
              color: PsColors.secondary500,
              fontFamily: PsConfig.ps_default_font_family),
          headline3: TextStyle(
              color: PsColors.secondary500,
              fontFamily: PsConfig.ps_default_font_family),
          headline4: TextStyle(
            color: PsColors.secondary500,
            fontFamily: PsConfig.ps_default_font_family,
          ),
          headline5: TextStyle(
              color: PsColors.secondary500,
              fontFamily: PsConfig.ps_default_font_family,
              fontWeight: FontWeight.bold),
          headline6: TextStyle(
              color: PsColors.secondary500,
              fontFamily: PsConfig.ps_default_font_family),
          subtitle1: TextStyle(
              color: PsColors.secondary500,
              fontFamily: PsConfig.ps_default_font_family,
              fontWeight: FontWeight.bold),
          subtitle2: TextStyle(
              color: PsColors.secondary500,
              fontFamily: PsConfig.ps_default_font_family,
              fontWeight: FontWeight.bold),
          bodyText1: TextStyle(
            color: PsColors.secondary500,
            fontFamily: PsConfig.ps_default_font_family,
          ),
          bodyText2: TextStyle(
              color: PsColors.secondary500,
              fontFamily: PsConfig.ps_default_font_family,
              fontWeight: FontWeight.bold),
          button: TextStyle(
              color: PsColors.secondary500,
              fontFamily: PsConfig.ps_default_font_family),
          caption: TextStyle(
              color: PsColors.secondary400,
              fontFamily: PsConfig.ps_default_font_family),
          overline: TextStyle(
              color: PsColors.secondary500,
              fontFamily: PsConfig.ps_default_font_family),
        ),
        iconTheme: IconThemeData(color: PsColors.secondary500),
        appBarTheme: AppBarTheme(
            color: PsColors.primaryDarkWhite)); //coreBackgroundColor));
  }
}
