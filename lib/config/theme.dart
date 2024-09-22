import 'package:flutter/material.dart';

///[ THEME APP ]
Color primaryColorDark = Colors.deepPurpleAccent;
Color primaryColor = Colors.deepPurpleAccent.shade700;
const secondaryColor = Color(0XFF184c84);
const backgroundColorLight = Color(0XFFffffff);
const backgroundColorDark = Color(0XFF161719);
Color primaryColorDarkVariant = Colors.blue.shade200;
const onBackgroundColorDark = Color(0XFF1d1c1e);
const onBackgroundColorLight = Color.fromARGB(255, 231, 234, 248);
Color cardValueWhite = Colors.grey.shade200;
const TextStyle styleBlackBold =
    TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
const TextStyle styleBlack = TextStyle(color: Colors.black);
const TextStyle styleBold = TextStyle(fontWeight: FontWeight.bold);
const TextStyle styleWhiteBold =
    TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
const TextStyle styleWhite = TextStyle(color: Colors.white);

class ThemeApp {
  static getLight() => ThemeData(
      splashFactory: InkRipple.splashFactory,
      visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
      colorScheme: ColorScheme.light(
          brightness: Brightness.light,
          background: backgroundColorLight,
          primary: primaryColor,
          onBackground: onBackgroundColorLight),
      fontFamily: 'ProximaNovaSoft',
      useMaterial3: true,
      bottomSheetTheme: const BottomSheetThemeData(
        modalElevation: 0,
        modalBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      dialogTheme: const DialogTheme(elevation: 0),
      cardTheme: const CardTheme(elevation: 0, color: Colors.transparent),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        // foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ));
  static getDark() => ThemeData(
        splashFactory: InkRipple.splashFactory,
        visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
        colorScheme: ColorScheme.dark(
          brightness: Brightness.dark,
          background: backgroundColorDark,
          primary: primaryColorDark,
          onBackground: onBackgroundColorDark,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          modalElevation: 0,
          modalBackgroundColor: Colors.grey.shade900,
          backgroundColor: Colors.grey.shade900,
          elevation: 0,
        ),
        dialogTheme: const DialogTheme(
            elevation: 0, backgroundColor: Color.fromARGB(255, 20, 20, 20)),
        fontFamily: 'ProximaNovaSoft',
        useMaterial3: true,
        cardTheme: const CardTheme(elevation: 0, color: Colors.transparent),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          // foregroundColor: Colors.black,
          elevation: 1,
          centerTitle: true,
        ),
      );

  // List<Object?> get props => [];
}
