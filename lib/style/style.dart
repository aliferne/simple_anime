import 'package:flutter/material.dart';
// TODO: Add Cache and store some in phones

/// A class for application stylesheets
class AppStyleLoader with ChangeNotifier {
  static ThemeData getMaterialLightTheme(BuildContext context) => ThemeData(
    useMaterial3: true,
    appBarTheme: getAppBarTheme(),
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
    cardTheme: getCardTheme(),
    textTheme: getTextTheme(),
    listTileTheme: getListTileTheme(),
  );

  static ThemeData getMaterialDarkTheme(BuildContext context) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    appBarTheme: getAppBarTheme(isDarkMode: true),
    // colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
    cardTheme: getCardTheme(isDarkMode: true),
    textTheme: getTextTheme(isDarkMode: true),
    listTileTheme: getListTileTheme(isDarkMode: true),
  );

  static AppBarThemeData getAppBarTheme({bool isDarkMode = false}) =>
      AppBarThemeData(
        centerTitle: true,
        elevation: 5.0,
        titleTextStyle: TextStyle(
          fontSize: 20.0,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.lightBlueAccent,
      );

  static TextTheme getTextTheme({bool isDarkMode = false}) => TextTheme(
    bodyMedium: TextStyle(
      fontSize: 20.0,
      color: isDarkMode ? Colors.white : Colors.black,
    ),
  );

  static CardThemeData getCardTheme({bool isDarkMode = false}) => CardThemeData(
    elevation: 3.0, // shadow
    margin: EdgeInsets.only(left: 0.0, right: 20.0, top: 20.0, bottom: 20.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(50.0),
        bottomRight: Radius.circular(50.0),
      ),
    ),
    clipBehavior: Clip.antiAlias,
  );

  static ListTileThemeData getListTileTheme({bool isDarkMode = false}) =>
      ListTileThemeData(textColor: isDarkMode ? Colors.white : Colors.black);
}

/// draw a bottom arc shape, used for background
class BottomArcShape extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    // the start point of curve
    final startOfCurve = rect.bottom * 0.2;
    // the end point of curve
    final endOfCurve = rect.bottom * 0.2;
    // the lowest point of curve
    final lowestPointOfCurve = rect.bottom * 0.4;

    // start at topleft
    path.moveTo(rect.left, rect.top);
    // ->
    path.lineTo(rect.right, rect.top);
    // ↓
    path.lineTo(rect.right, startOfCurve);
    // round  ↖_↙
    path.quadraticBezierTo(
      rect.center.dx,
      lowestPointOfCurve, // the bottom point
      rect.left, // end of y
      endOfCurve, // end of round
    );
    // <-
    path.lineTo(rect.left, rect.top);
    return path;
  }

  @override
  ShapeBorder scale(double t) {
    return this;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // no need to paint actually
  }
}
