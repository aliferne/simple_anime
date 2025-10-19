import 'package:flutter/material.dart';

/// get a button with [ListTile] style
///
/// [leading] - the leading widget
/// [title] - the title of the button
/// [onTap] - the function to call when the button is tapped
Widget getListTileButton({
  Widget? leading,
  required String title,
  Function()? onTap,
}) {
  return getButton(
    onPressed: onTap,
    child: ListTile(
      leading: leading,
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios),
    ),
  );
}

/// get a button
///
/// [child] - the child widget
/// [onPressed] - the function to call when the button is tapped
Widget getButton({required Widget child, Function()? onPressed}) {
  return ElevatedButton(onPressed: onPressed, child: child);
}

/// get a gesture detector
///
/// [child] - the child widget
/// [onTap] - the function to call when the gesture detector is tapped
Widget getGestureDetector({required Widget child, Function()? onTap}) {
  return GestureDetector(onTap: onTap, child: child);
}
