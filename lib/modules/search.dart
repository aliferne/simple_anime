import 'package:flutter/material.dart';
import 'package:simple_anime/app/routes.dart';
import 'package:simple_anime/components/flask_api.dart' show searchForData;
import 'package:simple_anime/plugins/alert_provider.dart';
import 'package:simple_anime/plugins/image_provider/ui.dart';
import 'package:simple_anime/plugins/input_provider.dart';
import 'package:simple_anime/conf.dart' show FileConf, logger;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avaliableSize = MediaQuery.of(context).size;
    final inputWidth = avaliableSize.width * 0.8;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Container(
        width: avaliableSize.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/city.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              getInputBox(
                inputWidth: inputWidth,
                hintText: "Enter the tag",
                textEditingController: _textEditingController,
              ),
              _getInputBoxButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// get button for input box
  ///
  /// [buttomName] name of button
  ///
  /// [onPressed] function for button
  Widget _getButtomForInputBox(String buttomName, {VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      child: ElevatedButton(onPressed: onPressed, child: Text(buttomName)),
    );
  }

  /// get input box button
  Widget _getInputBoxButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: _getButtomForInputBox(
            "Search",
            onPressed: () {
              if (_textEditingController.text.isEmpty) {
                showMessageBySnackBar("Please enter a tag", context: context);
                return;
              }
              _showSearchResult();
            },
          ),
        ),
        Flexible(
          child: _getButtomForInputBox(
            "Clear",
            onPressed: () {
              _textEditingController.clear();
            },
          ),
        ),
      ],
    );
  }

  void _showSearchResult() {
    Navigator.of(context).pushNamed(
      Routes.searchResult,
      arguments: {'keyWord': _textEditingController.text},
    );
  }
}

class SearchResultPage extends StatefulWidget {
  final String keyWord;

  const SearchResultPage({super.key, required this.keyWord});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  // this variable is kinda like "&page="
  int _currentIdx = 0;
  int _nextStart = 0;
  // if there more data to load
  bool _hasMore = true;
  // if the app is loading
  bool _isLoading = false;
  // store all images
  final List _allImages = [];
  // shape of the image card
  final pictureCardShape = const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  int count = 1; // 调试用，用完删掉

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMoreData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Results: ${widget.keyWord}")),
      body: _getImageGrids(),
    );
  }

  /// Convert the image data to a grid view by requesting the url of that data
  /// This function is used to visualize the image
  Widget _getImageGrids() {
    // if is loading and no data
    if (_allImages.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // if no data and load failed
    if (_allImages.isEmpty && !_isLoading) {
      return const Center(child: Text("No images found"));
    }
    // FIXME: It seems that the loading logic is just simply ask for the same 1 to 15 pictures again and again
    return GridView.builder(
      itemCount: _allImages.length,
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0, // w:h = 1:1
      ),
      itemBuilder: (context, index) {
        final imgData = _allImages[index];

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
    );
  }

  void _onScroll() {
    // if the app is loading, don't do anything
    if (_isLoading || !_hasMore) return;

    // if not at about the bottom of the page, don't do anything
    if (_scrollController.position.pixels <=
        _scrollController.position.maxScrollExtent - 100) {
      return;
    }

    if (count <= 2) {
      // _loadMoreData();
      count++; // 调试用，用完删掉
    }
    _loadMoreData();

    return;
  }

  void _loadMoreData() async {
    try {
      final moreData = await searchForData(
        api: FileConf.currentAPI!,
        keyword: widget.keyWord,
        forceCrawl: false,
        otherData: {"after_id": _currentIdx, "next_start": _nextStart},
      );

      logger.w(
        "current index: $_currentIdx,  next_start: $_nextStart, data[0][next]: ${moreData[0]["next_start"]}",
      );

      setState(() {
        // FIXME: Something's wrong there
        _allImages.addAll(moreData ?? []);
        _currentIdx += moreData?.length as int;
        _nextStart = _currentIdx + 1;
        // by default we think there's more data
        _hasMore = (moreData?.isNotEmpty ?? false);
      });
    } catch (e) {
      logger.e(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
