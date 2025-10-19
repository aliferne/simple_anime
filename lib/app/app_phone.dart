import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async' show StreamController, Timer;
import 'package:simple_anime/modules/search.dart' show SearchPage;
import 'package:simple_anime/components/flask_api.dart';
import 'package:simple_anime/conf.dart';
import 'package:simple_anime/plugins/alert_provider.dart';
import 'package:simple_anime/plugins/image_provider/ui.dart';


class HomeScreenForPhone extends StatefulWidget {
  const HomeScreenForPhone({super.key});

  @override
  State<HomeScreenForPhone> createState() => _HomeScreenForPhoneState();
}

/// [_timeStreamController] is used for 1s tick in Time Card, showing times like: 08-30 10:00:01 => 08-30 10:00:02 ...
///
/// But it seems that when user totally quit the app, the timer lost(it'll reload rather than obeying the initial settings)
/// TODO: So maybe we need to update recommendations in every 12:00 per day?
///
/// [_recommendImagesFuture] is a Future object that's subscribed by a [FutureBuilder] in [_getRecommendPictures]
///
/// [_cachedRecommendImages] is a List that stores the recommend images,
/// it's used by [_recommendImagesFuture] to avoid directly reloading images in a [Future] object
class _HomeScreenForPhoneState extends State<HomeScreenForPhone>
    with AutomaticKeepAliveClientMixin {
  final DateFormat dateFormatter = DateFormat("MM-dd HH:mm:ss");
  // 1s tick
  late final StreamController<DateTime> _timeStreamController;
  // The date of the last update of recommand pictures
  Future<List>? _recommendImagesFuture;
  // Get recommend images from backend, backend -> cached -> recommend
  List _cachedRecommendImages = [];

  // avoiding rebuild when switch to other pages
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _startTimerStream();
    _loadNewRecommendImageFuture();
  }

  @override
  void dispose() {
    _timeStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // avoiding rebuild when switch to other pages
    super.build(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getTimeCard(),
          _getTodaysRecommendationTitle(),
          _getRecommendPictures(),
          _getNotifyPictureGridTitle(),
          _getBottomButtons(),
        ],
      ),
    );
  }

  /// get [Card] that shows time
  StreamBuilder<DateTime> _getTimeCard() {
    return StreamBuilder(
      stream: _timeStreamController.stream, // stream of time
      builder: (context, asyncSnapshot) {
        // handle exceptions
        if (asyncSnapshot.connectionState == ConnectionState.waiting ||
            !asyncSnapshot.hasData) {
          return _onloading();
        }
        if (asyncSnapshot.hasError) {
          return _onError();
        }
        // format date
        final String date = dateFormatter.format(asyncSnapshot.data!);

        return Card(
          child: ListTile(
            leading: const Icon(Icons.access_time),
            title: Text("Now is:"),
            subtitle: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue, Colors.purple],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcATop,
              child: Text(
                date,
                style: TextStyle(fontFamily: "Typo_Round", fontSize: 28),
              ),
            ),
          ),
        );
      },
    );
  }

  /// title of pictures
  Widget _getTodaysRecommendationTitle() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        "Today's recommendations:",
        style: TextStyle(fontFamily: "Typo_Round", fontSize: 16),
      ),
    );
  }

  /// Get Recommend Pictures
  Widget _getRecommendPictures() {
    // The height of the picture grid
    // avoiding `max buffer` warning by setting a fixed height
    final pictureCardShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );

    return FutureBuilder(
      future: _recommendImagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _onloading();
        }

        if (snapshot.hasError) {
          return _onError(e: snapshot.error.toString());
        }

        final List images = snapshot.data ?? [];

        if (images.isEmpty) {
          return Center(child: getQuestionMarkWidget("No recommends yet"));
        }

        return RefreshIndicator(
          onRefresh: _onUserRefreshRequest,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.46,
            child: GridView.builder(
              itemCount: images.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0, // w:h = 1:1
              ),
              itemBuilder: (context, index) {
                final imgData = images[index];

                // handle empty url
                if ((imgData["url"] == null) || (imgData["url"] == "")) {
                  return getQuestionMarkWidget("No images");
                }

                return Card(
                  color: Colors.white,
                  shape: pictureCardShape,
                  margin: EdgeInsets.all(10),
                  child: getNetworkImage(imgData, context: context),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// notification of pictures (tell user that they can be clicked)
  Widget _getNotifyPictureGridTitle() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "Click for details",
        style: TextStyle(fontFamily: "Typo_Round", fontSize: 16),
      ),
    );
  }

  /// Buttons in the bottom that can do some actions
  Widget _getBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ElevatedButton(
              onPressed: () => _onSearchRequest(),
              child: const Text("Search"),
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: ElevatedButton(
              onPressed: () => _onUserRefreshRequest(),
              child: const Text("Refresh"),
            ),
          ),
        ],
      ),
    );
  }

  /// return Text with Error
  Center _onError({String? e}) => Center(child: Text("Error $e"));

  /// return a circularProgressIndicator
  Center _onloading() => const Center(child: CircularProgressIndicator());

  /// show error dialog
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) {
        return getErrorAlertDialog(
          context,
          brief: "Something went wrong",
          errorDetail: error,
        );
      },
    );
  }

  /// handling with user's refreshing request
  Future<void> _onUserRefreshRequest() async {
    _loadNewRecommendImageFuture();
  }

  /// handling with user's searching request (get data from backend)
  Future<dynamic> _onSearchRequest() {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  /// load recommend images from backend (only for `_loadNewRecommendImageFuture` to call)
  Future<List> _fetchRecommendImages({int retryCount = 2}) async {
    try {
      // check if API is available
      if (!(await isCurrentAPIAvailable())) {
        throw Exception("API is not available");
      }
      final newImage = await getRecommend(api: FileConf.currentAPI!);
      // update cache
      _cachedRecommendImages = newImage;
      // return new image
      return newImage;
    } catch (e) {
      logger.w("Failed to load recommend images: $e");
      // retry
      if (retryCount > 0) {
        await Future.delayed(Duration(seconds: 5));
        return _fetchRecommendImages(retryCount: retryCount - 1);
      }

      if (mounted) {
        _showErrorDialog(e.toString());
      } else {
        logger.w("Dialog is not mounted");
      }
      return _cachedRecommendImages;
    }
  }

  // start counting time per seconds
  void _startTimerStream() {
    // can be heard more than once by broadcast
    _timeStreamController = StreamController<DateTime>.broadcast();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeStreamController.isClosed) {
        timer.cancel();
      } else {
        _timeStreamController.add(DateTime.now());
      }
    });
  }

  /// Load recommend images from backend
  void _loadNewRecommendImageFuture() {
    setState(() {
      _recommendImagesFuture = _fetchRecommendImages();
    });
  }
}
