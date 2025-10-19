import 'dart:io' show File, Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_anime/components/inner_api.dart'
    show AvailableAPIs, InnerAPI;
import 'package:window_manager/window_manager.dart';
// import 'package:simple_anime/components/flask_api.dart';

final logger = Logger();

/// [APPConf] is a class that loads the configuration from the shared_preferences, etc
class APPConf {
  static final APPConf _instance = APPConf._internal();
  late SharedPreferences _preferences;

  // singleton
  factory APPConf() {
    return _instance;
  }
  APPConf._internal();

  /// initialize shared_preferences
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  SharedPreferences get preferences => _preferences;

  /// config windows
  static Future<void> configWindows() async {
    // if on phone, then only allow portrait mode
    if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      return; // phone can't execute APIs of `windows_manager`
    }
    // initialize window manager
    await windowManager.ensureInitialized();
    // config window
    WindowOptions windowOptions = WindowOptions(
      title: 'Simple Anime',
      size: Size(390, 730),
      minimumSize: Size(390, 730),
      maximumSize: Size(390, 730),
      backgroundColor: Colors.white,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /// get picture like status
  bool? getPictureLikeStatus(String url) {
    return _preferences.getBool("like_$url");
  }

  /// set picture like status
  ///
  /// [status] true if the picture is liked, false otherwise
  ///
  /// [url] the url of the picture
  Future<void> setPictureLikeStatus(String url, bool status) async {
    await _preferences.setBool("like_$url", status);
  }

  /// get picture delete status
  bool? getPictureDelStatus(String url) {
    return _preferences.getBool("del_$url");
  }

  /// set picture delete status
  ///
  /// [status] true if the picture is deleted, false otherwise
  ///
  /// [url] the url of the picture
  Future<void> setPictureDelStatus(String url, bool status) async {
    await _preferences.setBool("del_$url", status);
  }
}

/// [FileConf] is a class that loads the configuration from the .env file
class FileConf {
  /// load env file
  ///
  /// [filename] The filename of env, default is '.env'
  static Future<void> load({String filename = '.env'}) async {
    await dotenv.load(fileName: filename);
  }

  /// get available APIs FROM FLASK
  // static Future<Set> get flaskAvailableAPIs async => await getAvailableAPIs();

  /// get available APIs INNER
  static Future<List> get innerAvailableAPIs async =>
      await InnerAPI.getInnerAvailableAPIs();

  /// get scheme of app
  static String? get appScheme => dotenv.env['APP_SCHEME'];

  /// get host of app
  static String? get appHost => dotenv.env['APP_HOST'];

  /// get port of app
  static String? get appIP => dotenv.env['APP_IP'];

  /// get current API app is using
  static String? get currentAPI => dotenv.env['APP_CURRENT_API'];
}

enum AppThemeModeEnum { light, dark, followSys }

class AppThemeMode with ChangeNotifier {
  late ThemeMode _themeMode;
  final SharedPreferences _preferences = APPConf().preferences;

  static final AppThemeMode _instance = AppThemeMode._internal();
  // singleton
  factory AppThemeMode() {
    // initialize _themeMode
    _instance._reloadAppThemeMode();
    return _instance;
  }
  AppThemeMode._internal();

  /// get current app theme mode
  ThemeMode get themeMode => _themeMode;

  /// get current app theme mode as string
  String get themeModeString =>
      _preferences.getString('theme_mode') ?? AppThemeModeEnum.followSys.name;

  /// set current app theme mode
  ///
  /// [value] the value of theme mode, can be 'light', 'dark', 'followSys'(see [AppThemeModeEnum])
  void setAppThemeMode(String value) {
    _preferences.setString('theme_mode', value);
    // reload theme then
    _reloadAppThemeMode();
  }

  /// reload app theme mode by setting `theme_mode`
  void _reloadAppThemeMode() {
    final String mode =
        _preferences.getString('theme_mode') ?? AppThemeModeEnum.followSys.name;

    if (mode == AppThemeModeEnum.light.name) {
      _themeMode = ThemeMode.light;
    } else if (mode == AppThemeModeEnum.dark.name) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }
}

/// check if the current API is available
///
/// return true if the API is available, false otherwise
///
/// use the function like this:
///
/// ```dart
/// // so that when the api is null or is not in the list
/// // throw exception
/// if (!(await isCurrentAPIAvailable())) {
///    throw Exception('Current API is not available');
/// }
///
/// Response response = await getDataFromServer(api: EnvConfLoader.currentAPI!);
/// // do something
///
/// ```
Future<bool> isCurrentAPIAvailable() async {
  // it will also check if the current API is null (null won't be in the list)
  final apis = await FileConf.innerAvailableAPIs;

  for (AvailableAPIs api in apis) {
    if (api.name == FileConf.currentAPI) {
      return true;
    }
  }
  return false;
}
