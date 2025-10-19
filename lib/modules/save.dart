// save pictures, etc FIXME: Should support PC
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:simple_anime/common/request.dart';
import 'package:simple_anime/conf.dart' show logger;
import 'package:simple_anime/plugins/alert_provider.dart';

/// Image Saver, save images to gallery
class ImageSaver {
  // default saved quality
  static final _defaultQuality = 80;
  // available qualities from 10 to 100
  static final List<DropdownMenuItem<int>> _availableQualities =
      List<DropdownMenuItem<int>>.generate(10, (int v) {
        // e.g. (0 + 1) * 10 = 10
        final avaliableQuailty = (v + 1) * 10;
        return DropdownMenuItem(
          // wrapped with DropdownMenuItem
          value: avaliableQuailty,
          child: Text("$avaliableQuailty"),
        );
      });

  /// get a select field for user to select the quality of the image to be saved
  ///
  /// [url] the url of picture
  ///
  /// [context] the context of the widget
  static void getImageSaver(String url, {required BuildContext context}) {
    final ValueNotifier<int> qualityNotifier = ValueNotifier(_defaultQuality);

    showDialog<void>(
      context: context,
      // build an AlertDialog then
      builder: (BuildContext dialogContext) {
        // PopScope is used to dispose the notifier when the dialog is closed
        return PopScope(
          onPopInvokedWithResult: (bool didPop, res) async {
            if (didPop) {
              qualityNotifier.dispose();
            }
          },
          child: AlertDialog.adaptive(  // self-adapt to android and ios
            title: const Text("Select Quality", style: TextStyle(fontSize: 20)),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _getQuailtySelectNotifier(),
                _getQualitySelector(notifier: qualityNotifier),
                _getConfirmDownloadButton(
                  url: url,
                  // NOTE: Here should only use the value from notifier
                  notifier: qualityNotifier,
                  dialogContext: dialogContext,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// get a confirm button for user to confirm the download of the image
  ///
  /// [url] download the picture of assigned url
  ///
  /// [notifier] the notifier of the quality, [ValueNotifier] is needed (it should be the same as [_getQualitySelector])
  ///
  /// [dialogContext]
  static Widget _getConfirmDownloadButton({
    required String url,
    required ValueNotifier<int> notifier,
    required BuildContext dialogContext,
  }) {
    // a lock to avoid repeated downloading
    final isSavingNotifier = ValueNotifier(false);

    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, value, _) {
        return ValueListenableBuilder(
          valueListenable: isSavingNotifier,
          child: Text("Confirm"),
          builder: (context, isSaving, child) {
            return ElevatedButton(
              // if isSaving, do nothing
              onPressed: isSaving
                  ? null
                  : () async {
                      try {
                        await _saveImageByUrl(
                          url,
                          saveQuality: notifier.value,
                          dialogContext: dialogContext,
                        );
                        isSavingNotifier.value = true;
                      } catch (e) {
                        // no matter success or failed, set isSaving to false
                        isSavingNotifier.value = false;
                      }
                    },
              // when isSaving, draw a circle to warn user to wait
              child: isSaving ? const CircularProgressIndicator() : child,
            );
          },
        );
      },
    );
  }

  /// get the select box of quality, then select a value
  ///
  /// [notifier] the notifier of the quality, [ValueNotifier] is needed
  static Widget _getQualitySelector({required ValueNotifier<int> notifier}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ValueListenableBuilder(
        valueListenable: notifier,
        child: Text("Select a quality"),
        builder: (dialogContext, currentQuality, child) {
          return DropdownButton<int>(
            // let items expand to proper size
            isExpanded: true,
            hint: child,
            value: currentQuality, // current quality
            onChanged: (v) {
              // update value then
              notifier.value = v!;
            },
            items: _availableQualities,
          );
        },
      ),
    );
  }

  /// notify user how to use that selector
  static Widget _getQuailtySelectNotifier() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "Choose a value as the quality of the image to be saved",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  /// save network image to gallery
  ///
  /// [url] the url of the image
  ///
  /// [saveQuality] the quality that user want to save the image, default is 80
  ///
  /// returns a Future of String, "Saved" if success, "Failed to save" if failed, "No Gallery Permissions" if no permission
  static Future<String> _saveImageByUrl(
    String url, {
    required int saveQuality,
    required BuildContext dialogContext,
  }) async {
    String currentStatus;
    // save image to gallery
    if (!(await _checkGalleryPermission(context: dialogContext))) {
      currentStatus = "No Gallery Permissions";
    } else {
      try {
        final response = await Request.get(
          url,
          isInOrigin: false,
          // NOTE: Use default header (Dio)
          options: Options(responseType: ResponseType.bytes),
        );

        final imgBytes = Uint8List.fromList(response?.data);

        final result = await ImageGallerySaverPlus.saveImage(
          imgBytes,
          name: UrlToFileNameUtil.urlToMd5FileName(url),
          quality: saveQuality,
        );

        currentStatus = result["isSuccess"] ? "Saved" : "Failed to save";
      } catch (e) {
        logger.e("Failed to save image: $e");
        currentStatus = "Failed to save";
      }
    }

    if (dialogContext.mounted) {
      showMessageBySnackBar(currentStatus, context: dialogContext);
      // close the dialog after 1 second
      Future.delayed(Duration(seconds: 1)).then((_) {
        if (dialogContext.mounted) {
          Navigator.of(dialogContext).pop();
        }
      });
    }
    return currentStatus;
  }

  /// check if the app can get gallery permission
  static Future<bool> _checkGalleryPermission({
    required BuildContext context,
  }) async {
    final PermissionStatus status = await Permission.photos.request();

    // fully allowed
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // in this case must lead user to open app settings
      if (context.mounted) {
        showMessageBySnackBar(
          "Please enable gallery permission in settings",
          context: context,
        );
      }
      openAppSettings();
      return false;
    } else {
      // only warn when temporary denied
      if (context.mounted) {
        showMessageBySnackBar(
          "Gallery permission is required to save images",
          context: context,
        );
      }
      return false;
    }
  }
}

/// transfer url to file name
class UrlToFileNameUtil {
  /// to MD5 String
  static String urlToMd5FileName(String url) {
    final urlBytes = utf8.encode(url);
    final md5Digest = md5.convert(urlBytes);
    return md5Digest.toString(); // 32 len
  }

  /// to sha1-hash String
  static String urlToSha1FileName(String url) {
    final urlBytes = utf8.encode(url);
    final sha1Digest = sha1.convert(urlBytes);
    return sha1Digest.toString(); // 40 len
  }
}
