import 'package:flutter/material.dart';

/// get the input box of tag
///
/// [inputWidth] the width of the input box
///
/// [hintText] the hint text of the input box
///
/// [textEditingController] the controller of the text field
Widget getInputBox({
  required double inputWidth,
  String? hintText,
  TextEditingController? textEditingController,
}) {
  return Container(
    width: inputWidth,
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withAlpha(45),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
      color: Colors.white.withAlpha(165),
      shape: BoxShape.rectangle,
      borderRadius: BorderRadiusGeometry.all(Radius.circular(15)),
    ),
    child: TextField(
      style: TextStyle(color: Colors.black),
      controller: textEditingController,
      decoration: InputDecoration(
        icon: Icon(Icons.search),
        iconColor: Colors.blueAccent,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black54),
      ),
    ),
  );
}
