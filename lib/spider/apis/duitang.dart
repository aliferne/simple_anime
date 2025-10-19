import 'package:dio/dio.dart';
import 'package:simple_anime/spider/interface.dart';
import 'package:simple_anime/common/request.dart';
import 'package:simple_anime/conf.dart';
import 'package:simple_anime/spider/models/image_model.dart';

class DuitangSpider extends DataSpider {
  // NOTE: Should extract them into conf file
  final String baseUrl = "https://www.duitang.com/napi/blogv2/list/by_search/";
  Map<String, dynamic> duitangHeader;

  final Map<String, dynamic> _queryParams = {
    "kw": "",
    "afterId": 0,
    'type': 'feed',
    'include_fields':
        'top_comments '
        'is_root '
        'source_link '
        'item '
        'buyable% '
        'root_id '
        'status '
        'like_count '
        'like_id '
        'sender '
        'album '
        'reply_count '
        'favorite_blog_id',
    '_type': '',
    '_': '',
  };

  DuitangSpider({Map<String, dynamic>? headers})
    : duitangHeader =
          headers ??
          {
            // default is only a user-agent
            "user-agent":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
                "(KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0",
          };

  @override
  /// Must contain `kw`(keyword, str) and `afterId`(int)
  Future<List<ImageItem>> crawl(Map<String, dynamic> params) async {
    final Response? resp = await load(params: params);

    final parsedData = await parse(resp);

    if (parsedData == null) {
      logger.e("Failed to parse data from duitang");
      return [];
    }
    return parsedData;
  }

  /// Parse example:
  /// [
  ///   ImageItem(
  ///       url: xxx,
  ///       tags: xxx,
  ///       title: xxx,
  ///       source: "duitang",
  ///   ),
  ///   ...
  /// ]
  @override
  Future<List<ImageItem>?> parse(Response? resp) async {
    if (!_validateResponse(resp)) {
      return null;
    }
    // data has been validated, must be not null
    final rawData = resp!.data;

    final parsedData = <ImageItem>[];

    rawData["data"]["object_list"].forEach((element) {
      parsedData.add(
        ImageItem(
          url: element["photo"]["path"] ?? "",
          tags:
              // convert dynamic to List<String>
              rawData["data"]["terms"].cast<String>() ?? [],
          title: element["msg"] ?? "",
          source: "duitang",
        ),
      );
    });

    return parsedData;
  }

  /// Load data from duitang
  ///
  /// This function is responsible for loading data from the duitang API.
  @override
  Future<Response?> load({
    Map<String, dynamic>? headers,
    required Map<String, dynamic> params,
  }) async {
    if (!_isValidParams(params)) {
      logger.e("Invalid params for duitang");
      return null;
    }

    _queryParams.updateAll(
      (key, value) => params.containsKey(key) ? params[key] : value,
    );

    try {
      return await Request.get(
        baseUrl,
        isInOrigin: false,
        queryParameters: _queryParams,
        options: Options(
          headers: headers ?? duitangHeader,
          responseType: ResponseType.json, // Expecting JSON response
        ),
      );
    } catch (e) {
      logger.e(e);
    }
    return null;
  }

  bool _isValidParams(Map<String, dynamic> params) {
    return params.containsKey("kw") && params.containsKey("afterId");
  }

  bool _validateResponse(Response? resp) {
    final rawData = resp?.data;

    if (resp?.statusCode != 200) {
      logger.e("Failed to load data from duitang");
      return false;
    }

    if (rawData == null || rawData == []) {
      logger.e("Failed to load data from duitang");
      return false;
    }

    if (rawData["status"] != 1) {
      logger.w(
        "Duitang |"
        "Response status is not 1, "
        "< Errors may occur > since this website usually returns 1",
      );
    }

    return true;
  }
}
