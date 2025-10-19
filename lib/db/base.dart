// Almost all images can be broken down to columns like:
// - id: an integer that uniquely identifies the Image
// - title: the title of that Image
// - url: the url of that Image
// - tag: the tag of that Image
// - source: where is the image from (e.g. duitang, pixiv, etc.)
// - isLike: whether the user like the picture or not
// other infos, such as description, width or height, can be added as well
// but that's not necessary

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'base.g.dart';

@DataClassName('AppImage')
class Images extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get url => text().unique()();
  TextColumn get tag => text()();
  TextColumn get source => text()();
  BoolColumn get isLike => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Images])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, "image_db.sqlite"));
      return NativeDatabase.createInBackground(file);
    });
  }

  // ------------ CRUD related ------------ //

  Future<int> addImage(ImagesCompanion image) async {
    return await into(images).insert(image);
  }

  Future<int> deleteImage(int id) async {
    return await (delete(images)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteAllImages() async {
    return await delete(images).go();
  }

  Future<AppImage?> getImageById(int id) async {
    return (select(images)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<AppImage?> getImageByUrl(String url) async {
    return (select(images)..where((t) => t.url.equals(url))).getSingleOrNull();
  }

  Future<bool> updateImage(ImagesCompanion image) async {
    return await update(images).replace(image);
  }

  Future<bool> updateImageLikeStatus(int id, bool isLike) async {
    // `write` will return the number of rows affected
    return await (update(images)..where((t) => t.id.equals(id))).write(
          ImagesCompanion(isLike: Value(isLike)),
        ) >
        0;  // so if writed, 1 will be returned
  }

  Stream<List<AppImage>> watchImageByTag(
    String tag, {
    bool useFuzzySearch = false,
  }) {
    return (select(images)..where((t) {
          return (useFuzzySearch ? t.tag.like('%$tag%') : t.tag.equals(tag));
        }))
        .watch();
  }

  // optional maybe?
  Future<List<AppImage>> getFavouriteImages({
    String? title,
    String? tag,
    bool useFuzzySearch = false,
  }) {
    final query = select(images)
      ..where((t) {
        // Search for all liked images first
        var condition = t.isLike.equals(true);

        // then search by tag and/or title if provided
        if (title != null) {
          condition =
              condition &
              (useFuzzySearch
                  ? t.title.like('%$title%')
                  : t.title.equals(title));
        }

        if (tag != null) {
          condition =
              condition &
              (useFuzzySearch ? t.tag.like('%$tag%') : t.tag.equals(tag));
        }

        return condition;
      });

    return query.get();
  }

  /// used in [Provider] to watch all images
  Stream<List<AppImage>> watchAllImages() {
    return select(images).watch();
  }

  Stream<List<AppImage>> watchLikedImages({
    String? title,
    String? tag,
    bool useFuzzySearch = false,
  }) {
    final query = select(images)
      ..where((t) {
        // Search for all liked images first
        var condition = t.isLike.equals(true);

        // then search by tag and/or title if provided
        if (title != null) {
          condition =
              condition &
              (useFuzzySearch
                  ? t.title.like('%$title%')
                  : t.title.equals(title));
        }

        if (tag != null) {
          condition =
              condition &
              (useFuzzySearch ? t.tag.like('%$tag%') : t.tag.equals(tag));
        }

        return condition;
      });

    return query.watch();
  }
}
