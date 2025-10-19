import 'package:flutter/material.dart';
import 'package:simple_anime/db/base.dart';
import 'package:simple_anime/conf.dart' show logger;

/// [AppImageRepository] is the repository for image data
/// it offers the API to do operations on image data
class AppImageRepository {
  final AppDatabase db;

  AppImageRepository(this.db);

  // watch all pictures
  Stream<List<AppImage>> watchAll() => db.watchAllImages();
  // watch liked images
  Stream<List<AppImage>> watchLiked() => db.watchLikedImages();

  Future addImage(ImagesCompanion image) async {
    await db.addImage(image).onError((err, stackTrace) {
      logger.e(err, stackTrace: stackTrace);
      return -1;
    });
  }

  Future toggleLikeStatus(AppImage image) async {
    // each time call the method, the like status will be toggled
    await db.updateImageLikeStatus(image.id, !image.isLike).onError((
      err,
      stackTrace,
    ) {
      logger.e(err, stackTrace: stackTrace);
      return false;
    });
  }

  Future deleteImage(int id) async {
    await db.deleteImage(id).onError((err, stackTrace) {
      logger.e(err, stackTrace: stackTrace);
      return -1;
    });
  }
}

/// [AppImageProvider] is the provider for image data
/// it basically call methods from [AppImageRepository], and the notify the UI that status has changed
class AppImageProvider with ChangeNotifier {
  final AppImageRepository repository;

  AppImageProvider(this.repository);

  // the Stream of all images
  Stream<List<AppImage>> get allImages => repository.watchAll();

  // the Stream of liked images
  Stream<List<AppImage>> get likedImages => repository.watchLiked();

  // add Image
  Future<int> addImage(ImagesCompanion image) async {
    final result = await repository.addImage(image);
    return result;
    // NOTE: don't need `notifyListeners()` here, [Stream] can handle that
  }

  // toggle like status
  Future<void> toggleLike(AppImage image) async {
    await repository.toggleLikeStatus(image);
  }

  // delete
  Future<void> deleteImage(int id) async {
    await repository.deleteImage(id);
  }
}
