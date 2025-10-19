// this file is served as the API bridge for `db` and `apis` and frontend
import 'package:simple_anime/spider/apis/duitang.dart';
import 'package:simple_anime/spider/interface.dart';

// TODO: Add Methods to save into database
enum AvailableAPIs {
  duitang,
  // ...
}

class InnerAPI {
  static AvailableAPIs api = AvailableAPIs.duitang;

  AvailableAPIs get getAPI => api;
  set setAPI(AvailableAPIs a) => api = a;

  static Future<dynamic> callAPI({required Map<String, dynamic> params}) async {
    DataSpider spider = apiToSpider();
    return await spider.crawl(params);
  }

  // This function needs Database
  // if no data in database, it'll be useless
  // TODO: Maybe a methode is let user add rules, then crawl by the rule? The tag user has set.
  static Future<List> getRecommend() async {
    DataSpider spider = apiToSpider();
    final res = await spider.crawl({"kw": "德克萨斯", "afterId": 0});

    return res.sublist(0, 4);
  }

  /// transform the api to spider
  static DataSpider apiToSpider() {
    switch (api) {
      case AvailableAPIs.duitang:
        return DuitangSpider();
      // ...
    }
  }

  /// return all available APIs
  static Future<List<AvailableAPIs>> getInnerAvailableAPIs() async {
    return AvailableAPIs.values;
  }
}
