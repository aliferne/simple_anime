// will be deprecated soon
import 'package:simple_anime/common/request.dart';
import 'package:simple_anime/conf.dart' show logger;

// Main Routes to flask
final Map<String, String> mainRoutes = {'Home': '/'};

// Crawl Routes to flask
final Map<String, String> crawlRoutes = {
  'Crawl': '/crawl', // GET method
  'CrawlSearch': '/crawl/search', // POST method
  'CrawlRecommend': '/crawl/recommend/',
  'AvailableCrawlAPIs': '/crawl/available_apis',
};

// Update Routes to database
final Map<String, String> updateRoutes = {
  'UpdateLike': '/update/like', // POST method
  'UpdateDelete': '/update/delete', // POST method
};

/// search for data in flask api
///
/// [api] the api to search for
///
/// [keyword] the keyword to search for
///
/// [forceCrawl] force crawl the api,
/// if true, always get data in the web,
/// otherwise only get data in the web when no data in the database
///
/// [otherData] other data to send to the api
///
/// @warning
///
/// [otherData] is a map of key value pairs, it should based on your implementations
/// of the spider and backend driver, for example, my implemetations requires me to send
/// a keyword: "page" and a value: "1" to get the first page of the search results,
/// so I need to send the data as a map.
/// The parsing work of query data should be done in your backend implementations
///
/// ```json
/// {
///   "api": api,
///   "tag": keyword,
///   // these part is for otherData
///   "force_crawl": forceCrawl
///   "after_id": 0,
///   ...
/// }
/// ```
Future<dynamic> searchForData({
  required String api,
  required String keyword,
  bool forceCrawl = false,
  Map<String, dynamic>? otherData,
}) async {
  try {
    final response = await Request.post(
      crawlRoutes["CrawlSearch"]!,
      postData: {
        "api": api,
        "tag": keyword,
        "force_crawl": forceCrawl,
        ...?otherData,
      },
    );

    if (response?.statusCode != 200) {
      logger.e('Failed to search');
      return;
    }

    return response?.data["data"];
  } catch (e) {
    logger.e(e.toString());
  }
}

/// get recommendations for a specific target
///
/// [api] the api to get recommendations for
///
/// [requiredImages] the number of images required
///
/// ```json
/// {
///   "api": api,
///   "required_images": requiredImages,
/// }
/// ```
Future<List> getRecommend({required String api, int requiredImages = 4}) async {
  final response = await Request.post(
    crawlRoutes["CrawlRecommend"]!,
    postData: {"api": api, "required_images": requiredImages},
  );

  if (response?.statusCode != 200) {
    throw Exception('Failed to load recommendations');
  }

  return response?.data["data"];
}

/// update the like status of the database in api
///
/// [api] the api to update
/// [url] the url of the image
/// [isLike] whether the image is liked
Future<Map> updateLikeStatus({
  required String api,
  required String url,
  required bool isLike,
}) async {
  final response = await Request.patch(
    updateRoutes["UpdateLike"]!,
    patchData: {"api": api, "is_like": isLike, "url": url},
  );

  if (response?.statusCode != 200) {
    throw Exception('Failed to load recommendations');
  }
  return response?.data["data"];
}

/// update the delete status of the database in api
///
/// [api] the api to update
/// [url] the url of the image
/// [isDel] whether the image is liked
Future<Map> updateDeleteStatus({
  required String api,
  required String url,
  required bool isDel,
}) async {
  final response = await Request.patch(
    updateRoutes["UpdateDelete"]!,
    patchData: {"api": api, "is_delete": isDel, "url": url},
  );

  if (response?.statusCode != 200) {
    throw Exception('Failed to load recommendations');
  }
  return response?.data["data"];
}

/// get available apis from flask
///
/// return a set of apis
Future<Set> getAvailableAPIs() async {
  // avoid repeating
  final Set apiSets = {};
  // get response
  final response = await Request.get(crawlRoutes["AvailableCrawlAPIs"]!);

  if (response?.statusCode != 200) {
    throw Exception('Failed to load recommendations');
  }
  apiSets.addAll(response?.data["data"]["available_apis"]);

  return apiSets;
}
