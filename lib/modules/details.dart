// @file The detailed page of pictures
import 'save.dart';
import 'package:flutter/material.dart';
import 'package:simple_anime/components/flask_api.dart';
import 'package:simple_anime/conf.dart';

/// The detailed page of pictures
///
/// [String] title: The title of the picture
/// [String] tag: The tag of the picture
/// [String] url: The url of the picture
/// [bool] like: Whether the picture is liked
class Details extends StatefulWidget {
  final String title;
  final String tag;
  final String url;
  final bool like;

  const Details({
    super.key,
    required this.title,
    required this.tag,
    required this.url,
    required this.like,
  });

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  // if the user likes the picture, the icon will be a filled heart
  late bool _isSetLike;
  // if the user choose to delete the picture, the icon will be a "x"
  late bool _isSetDelete;
  // global conf, for remembering the user's settings
  final _appConf = APPConf();

  @override
  void initState() {
    super.initState();
    _isSetLike = _appConf.getPictureLikeStatus(widget.url) ?? false;
    _isSetDelete = _appConf.getPictureDelStatus(widget.url) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final availableSize = MediaQuery.of(context).size;
    final titlePadding = const EdgeInsets.all(5.0);
    final mainAxisSizeOfRow = MainAxisSize.min;

    return Scaffold(
      appBar: AppBar(title: Text("Details")),
      body: Column(
        children: [
          _getDetailedImage(availableSize),
          _getImageListTile(titlePadding, mainAxisSizeOfRow),
        ],
      ),
    );
  }

  /// Get the description, like buttom, etc
  ///
  /// [EdgeInsets] titlePadding: The padding of the title
  ///
  /// [MainAxisSize] mainAxisSizeOfRow: The main axis size of the row
  Expanded _getImageListTile(
    EdgeInsets titlePadding,
    MainAxisSize mainAxisSizeOfRow,
  ) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.vertical,
        child: ListTile(
          title: Padding(
            padding: titlePadding,
            child: Row(
              mainAxisSize: mainAxisSizeOfRow,
              children: [
                Icon(Icons.title, size: 20.0, color: Colors.redAccent),
                Text(widget.title),
              ],
            ),
          ),
          subtitle: Padding(
            padding: titlePadding,
            child: Row(
              mainAxisSize: mainAxisSizeOfRow,
              children: [
                Icon(Icons.tag, size: 20.0, color: Colors.blueAccent),
                Text(widget.tag),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: mainAxisSizeOfRow,
            children: [
              _getLikeImageButton(),
              _getDeleteImageButton(),
              _getDownloadImageButton(),
            ],
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: 10.0,
          ),
          titleTextStyle: TextStyle(fontSize: 22.0, color: Colors.black),
          subtitleTextStyle: TextStyle(fontSize: 18.0, color: Colors.black),
        ),
      ),
    );
  }

  /// Get the like button
  ///
  /// When button is changed to red, that means "like" is pressed,
  /// and it'll sync to the database, "dislike" (black) is the same
  Widget _getLikeImageButton() {
    return IconButton(
      icon: AnimatedCrossFade(
        duration: const Duration(milliseconds: 200),
        firstChild: Icon(Icons.favorite), // black heart
        // red heart
        secondChild: Icon(Icons.favorite, color: Colors.redAccent),
        crossFadeState: (!_isSetLike)
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
      ),
      // cannot set like if set del
      onPressed: (!_isSetDelete)
          ? () {
              final newLikeStatus = !_isSetLike;
              _appConf.setPictureLikeStatus(widget.url, newLikeStatus);
              updateLikeStatus(
                api: FileConf.currentAPI!,
                url: widget.url,
                isLike: newLikeStatus,
              );

              setState(() {
                _isSetLike = newLikeStatus;
              });
            }
          : null,
    );
  }

  /// Get the delete button
  ///
  /// When user pressed this button, firstly alert user if do that,
  /// if confirmed, set `isRemoved` (or other field, that depends on the backend) to true
  /// and remove it from the screen (sync to database,
  /// the backend shouldn't return those pictures that's set to `removed`)
  Widget _getDeleteImageButton() {
    return IconButton(
      icon: AnimatedCrossFade(
        duration: const Duration(milliseconds: 200),
        firstChild: Icon(Icons.delete),
        secondChild: Icon(Icons.clear),
        crossFadeState: (!_isSetDelete)
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
      ),
      // if set del, can't press again, and should pop to main page
      onPressed: (!_isSetDelete)
          ? () {
              _confirmDelete();
            }
          : null,
    );
  }

  Future<dynamic> _confirmDelete() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete?"),
          content: Text("Are you sure to delete this picture?"),
          actions: [
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                _appConf.setPictureDelStatus(widget.url, true);
                updateDeleteStatus(api: FileConf.currentAPI!, url: widget.url, isDel: true);
                logger.w("Delete ${widget.url}");
                setState(() {
                  _isSetDelete = true;
                });
                // back to main page
                Navigator.of(context).pushNamed('/main');
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                // cancel delete
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Get the download button
  ///
  /// When user pressed this button, a selector will pop out,
  /// since [ImageGallerySaverPlus.saveImage] has a parameter
  /// `quality` for user to select the quality they want to save.
  ///
  /// When user checked that value, download
  Widget _getDownloadImageButton() {
    // TODO: Maybe should add saveToDatabase as well 
    return IconButton(
      icon: Icon(Icons.download),
      onPressed: () {
        ImageSaver.getImageSaver(widget.url, context: context);
      },
    );
  }

  /// Get the detailed image
  ///
  /// [Size] availableSize: The available size of the screen
  Widget _getDetailedImage(Size availableSize) {
    return Image.network(
      widget.url,
      height: availableSize.height * 0.6,
      width: availableSize.width,
      fit: BoxFit.cover,
      loadingBuilder:
          (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
    );
  }
}
