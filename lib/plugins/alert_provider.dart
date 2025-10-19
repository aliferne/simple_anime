import 'package:flutter/material.dart';

/// A function for building error alert dialogs
///
/// [brief] - The brief error message to display
/// [errorDetail] - The detailed error message to display
Widget getErrorAlertDialog(
  BuildContext context, {
  required String brief,
  String? errorDetail,
}) {
  return AlertDialog.adaptive(
    title: Text(brief),
    content: Text(errorDetail ?? ""),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
    ],
  );
}

/// get a widget for displaying a question mark image with a message
///
/// this is typically used for some sources aren't loaded successfully,
/// such as pictures' recommedation
///
/// [message] - The message to display
Widget getQuestionMarkWidget(String message) {
  return Center(
    child: Column(
      children: [
        Container(
          width: 150.0,
          height: 150.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            image: DecorationImage(
              image: AssetImage("assets/images/question_mark.jpg"),
              fit: BoxFit.contain, // this picture should be fully demostrated
            ),
          ),
        ),
        Text(
          message,
          style: TextStyle(fontSize: 20.0, fontFamily: "Typo_Round"),
        ),
      ],
    ),
  );
}


/// show a message by snackbar
///
/// [message] is the error message
///
/// [context] is the context of the app
void showMessageBySnackBar(String message, {required BuildContext context}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(fontSize: 16)),
      duration: const Duration(seconds: 1),
    ),
  );
}
