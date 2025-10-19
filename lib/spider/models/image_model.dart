import 'package:drift/drift.dart' show Value;
import 'package:simple_anime/db/base.dart';
import 'package:simple_anime/plugins/image_provider/data.dart';
import 'package:simple_anime/spider/interface.dart';

class ImageItem {
  final String url;
  final List<String> tags;
  final String title;
  final String source;

  ImageItem({
    required this.url,
    required this.tags,
    required this.title,
    required this.source,
  });
}


class ImageStorage implements DataStorage<ImageItem> {
  final AppImageProvider imageProvider;

  // provide your `Provider` here
  ImageStorage({required this.imageProvider});

  // save a list of ImageItem to the database
  @override
  Future<void> save(List<ImageItem> items) async {
    for (var item in items) {
      await imageProvider.addImage(
        ImagesCompanion(
          url: Value(item.url),
          tag: Value(item.tags.join((";"))),
          title: Value(item.title),
          source: Value(item.source),
        ),
      );
    }
  }
}
