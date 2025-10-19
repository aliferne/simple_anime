import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_anime/app/home.dart';
import 'package:simple_anime/app/routes.dart';
import 'package:simple_anime/common/request.dart';
import 'package:simple_anime/conf.dart';
import 'package:simple_anime/db/base.dart';
import 'package:simple_anime/plugins/image_provider/data.dart';
import 'package:simple_anime/style/style.dart';

void main() async {
  // ensure all initializations are done
  WidgetsFlutterBinding.ensureInitialized();
  // init global conf (shared_preferences)
  await APPConf().init();
  // load env conf
  await FileConf.load();
  // init Request config
  Request.init();
  // load window size
  await APPConf.configWindows();
  // set up image repository
  final imageRepo = AppImageRepository(AppDatabase());

  runApp(
    MultiProvider(
      providers: [
        // theme related
        ChangeNotifierProvider(
          create: (BuildContext context) => AppThemeMode(),
        ),
        // image repo related
        ChangeNotifierProvider(
          create: (BuildContext context) => AppImageProvider(imageRepo),
        ),
      ],
      child: SimpleAnime(),
    ),
  );
}

class SimpleAnime extends StatelessWidget {
  const SimpleAnime({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Anime',
      home: const MainPage(),
      theme: AppStyleLoader.getMaterialLightTheme(context),
      // follow system
      themeMode: Provider.of<AppThemeMode>(context).themeMode,
      darkTheme: AppStyleLoader.getMaterialDarkTheme(context),
      // no more debug banner
      debugShowCheckedModeBanner: false,
      routes: Routes.all,
    );
  }
}
