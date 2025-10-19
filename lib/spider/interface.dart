import 'package:dio/dio.dart' show Response;
import 'package:provider/provider.dart' show Provider;

/// NOTE:
/// In order not to make the database too larger,
/// this implementation used a way
/// that only when user clicked the "Save" button in the
/// [Details] page, the data will be saved to the database

abstract class DataSpider<T> {
  /// [crawl] is used to crawl the website and return a list of data
  /// it required a [params] to be passed to the [load] method
  /// the [params] is a map of key value pair, the key-value set should be determined by subclasses
  /// it'll return the `Item<T>` which is implemented in `models` dir
  Future<T> crawl(Map<String, dynamic> params);

  /// [parse] is used to handle the [Response] object loaded from [load] method
  /// it'll return the `Item<T>` which is implemented in `models` dir
  Future<T> parse(Response? resp);

  /// [load] is used to load the website and return a [Response] object
  Future<Response?> load({
    Map<String, dynamic>? headers,
    required Map<String, dynamic> params,
  });
}

/// Data storage interface
abstract class DataStorage<T> {
  DataStorage({required Provider provider});

  /// [save] is used to save the data to the database
  /// it required a [List] of data to be passed to the [save] method
  /// the [List] of data is a list of [Map] whose key is [String] and value is [dynamic]
  Future<void> save(List<T> items);
}
