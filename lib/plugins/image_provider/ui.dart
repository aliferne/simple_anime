import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:simple_anime/modules/details.dart';

/// A function for loading images from the network with specific settings
///
/// [imgData] - imgData, includes the url, title, tag, like, and isRemoved fields
Widget getNetworkImage(
  Map<String, dynamic> imgData, {
  required BuildContext context,
}) {
  final String url = imgData["url"];
  final String title = imgData["title"];
  final String tag = imgData["tag"];
  final bool like = imgData["like"] ?? false;
  final bool isRemoved = imgData["isRemoved"] ?? false;

  final Widget child = isRemoved
      ? Center(
          child: Text("Image Removed", style: TextStyle(color: Colors.red)),
        )
      : CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            return Center(child: CircularProgressIndicator());
          },
          errorWidget: (context, url, error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline),
                  SizedBox(height: 10),
                  Text("Error"),
                  Text("$url may be invalid"),
                ],
              ),
            );
          },
        );

  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Details(url: url, title: title, tag: tag, like: like),
        ),
      );
    },
    // concurrentCacheManager: 2,
    child: child,
  );
}
