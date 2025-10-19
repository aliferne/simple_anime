import 'package:flutter/material.dart';
import 'package:simple_anime/app/app_phone.dart';
import 'package:simple_anime/app/chat.dart';
import 'package:simple_anime/app/more.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  // default in HomeScreen
  int _currentIndex = 0;
  late final PageController _pageController;

  final List<Map<String, Widget>> _pages = [
    {"Home": const HomeScreenForPhone()},
    {"Chat": const ChatPage()},
    {"More": MorePage()},
  ];

  @override
  void initState() {
    super.initState();
    // initialize the page controller, default in HomeScreen
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarRadius = Radius.circular(0);

    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_currentIndex].keys.first),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.only(
            bottomLeft: appBarRadius,
            bottomRight: appBarRadius,
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: _pages.map((page) => page.values.first).toList(),
        // handle with the case when user is flipping the page
        onPageChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: _getBottomNavigationBar(),
    );
  }

  /// Returns the bottom navigation bar
  Widget _getBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
      ],
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex,
      onTap: (int index) {
        setState(() {
          _currentIndex = index;
        });
        _pageController.jumpToPage(index);
      },
    );
  }
}
