import 'package:flutter/material.dart';
import 'package:simple_anime/app/home.dart';
import 'package:simple_anime/modules/search.dart';
import 'package:simple_anime/modules/settings.dart';

class Routes {
  static const String main = '/main';
  static const String search = '/search';
  static const String searchResult = '/searchResult';
  static const String detail = '/detail';
  // TODO: Those pages
  static const String settings = '/settings';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String favorite = '/favorite';
  static const String history = '/history';

  static final all = {
    main: (context) => const MainPage(),
    search: (context) => const SearchPage(),
    searchResult: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      // to get the parameter from `Navigator.pushNamed`
      return SearchResultPage(keyWord: args['keyWord']);
    },
    settings: (context) => const SettingsPage(),
    // detail: (context) => const DetailScreen(),
    // login: (context) => const LoginScreen(),
  };
}
